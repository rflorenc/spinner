OCP_MIRROR_URL=mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest
JQ_URL=github.com/stedolan/jq/releases/download/jq-1.6

export PATH="/home/${USER}/.local/bin:${PATH}"

cat << EOF > requirements.txt
jmespath
kubernetes
openshift
wheel
netaddr
openstacksdk
EOF

python3 -m pip install --upgrade pip --user && \
python3 -m pip install -r requirements.txt --user && \

# openshift related clients
wget https://${OCP_MIRROR_URL}/openshift-client-linux.tar.gz && \
wget https://${OCP_MIRROR_URL}/openshift-install-linux.tar.gz && \

tar xvf openshift-client-linux.tar.gz && \
tar xvf openshift-install-linux.tar.gz

# misc tools
wget https://${JQ_URL}/jq-linux64 && \
mv jq-linux64 jq && chmod +x jq

# place clients in path
mv -v jq kubectl oc openshift-install /home/${USER}/.local/bin/

# cleanup       
rm -rf requirements.txt *.tar* LICENSE README.md &> /dev/null