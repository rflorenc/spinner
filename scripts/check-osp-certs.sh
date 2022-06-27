#!/usr/bin/env bash

set -Eeuo pipefail

declare catalog san
catalog="$(mktemp)"
san="$(mktemp)"
readonly catalog san

declare invalid=0

openstack catalog list --format json --column Name --column Endpoints \
	| jq -r '.[] | .Name as $name | .Endpoints[] | [$name, .interface, .url] | join(" ")' \
	| sort \
	> "$catalog"

while read -r name interface url; do
	# Ignore HTTP
	if [[ ${url#"http://"} != "$url" ]]; then
		continue
	fi

	# Remove the schema from the URL
	noschema=${url#"https://"}

	# If the schema was not HTTPS, error
	if [[ noschema == "$url" ]]; then
		echo "ERROR (unknown schema): $name $interface $url"
		exit 2
	fi

	# Remove the path and only keep host and port
	noschema="${noschema%%/*}"
	host="${noschema%%:*}"
	port="${noschema##*:}"

	# Add the port if was implicit
	if [[ "$port" == "$host" ]]; then
		port='443'
	fi

	# Get the SAN fields
	openssl s_client -showcerts -servername "$host" -connect "$host:$port" </dev/null 2>/dev/null \
		| openssl x509 -noout -ext subjectAltName \
		> "$san"

	# openssl returns the empty string if no SAN is found.
	# If a SAN is found, openssl is expected to return something like:
	#
	#    X509v3 Subject Alternative Name:
	#        DNS:standalone, DNS:osp1, IP Address:192.168.2.1, IP Address:10.254.1.2
	if [[ "$(grep -c "Subject Alternative Name" "$san" || true)" -gt 0 ]]; then
		echo "PASS: $name $interface $url"
	else
		invalid=$((invalid+1))
		echo "INVALID: $name $interface $url"
	fi
done < "$catalog"

# clean up temporary files
rm "$catalog" "$san"

if [[ $invalid -gt 0 ]]; then
	echo "${invalid} legacy certificates were detected. Update your certificates to include a SAN field."
	exit 1
else
	echo "All HTTPS certificates for this cloud are valid."
fi
