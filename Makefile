ifndef uuid
$(error uuid environment variable is not defined)
endif

.PHONY: default install test venv venv-clean clean pull

WORKDIR?=.
PY?=python3
VENVDIR?=$(WORKDIR)/venv
VENV=$(VENVDIR)/bin

.EXPORT_ALL_VARIABLES:

default: install

install: venv
	$(VENV)/ansible-playbook site.yaml -v -e "uuid=${uuid}" -e is_prod=false

clean: venv-clean

# prepare the base python3 virtualenv
venv:
	$(PY) -m venv --prompt logispin $(VENVDIR)
	$(VENV)/pip install --upgrade pip
	$(VENV)/pip install -Ur requirements.txt pip

venv-clean:
	rm -fr $(VENVDIR)
