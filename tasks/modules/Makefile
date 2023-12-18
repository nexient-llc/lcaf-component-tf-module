SHELL := /bin/bash

# Binaries

TERRAFORM ?= terraform
RM ?= rm -rf
CONFTEST ?= conftest
REGULA ?= regula
TFLINT ?= tflint
FIND ?= find

# Variables

ALL_TF_MODULES = $(shell $(call list_terraform_modules))
ALL_EXAMPLES = $(shell $(call list_examples))
CONFTEST_POLICY_DIRECTORIES ?= $(MODULE_DIR)/policy
TFLINT_CONFIG ?= .tflint.hcl
VAR_FILE ?= test.tfvars
# Temporary value until we can relocate policies and validate; will be defaulted
# to 'high' in the future with the option to change this via .cafenv
REGULA_SEVERITY ?= off 

# Functions

define check_terraform_fmt
	echo && echo "Checking format ...";
	$(TERRAFORM) fmt -recursive -check;

endef

define clean_terraform_module
	$(RM) $(1)/.terraform* $(1)/terraform.*;

endef

define conftest_terraform_module
	echo && echo "Conftest $(1) ...";
	echo $(CONFTEST) test $(1)/terraform.tfplan.json --all-namespaces $(foreach dir,$(CONFTEST_POLICY_DIRECTORIES),$(shell echo "-p $(dir) ")) -p $(MODULE_DIR)/custom_policy/policy;
	$(CONFTEST) test $(1)/terraform.tfplan.json --all-namespaces $(foreach dir,$(CONFTEST_POLICY_DIRECTORIES),$(shell echo "-p $(dir) ")) -p $(MODULE_DIR)/custom_policy/policy;

endef

define regula_terraform_module
	echo && echo "Regula $(1) ...";
	echo $(REGULA) run $(1)/terraform.tfplan.json --input-type tf-plan --severity $(REGULA_SEVERITY)
	$(REGULA) run $(1)/terraform.tfplan.json --input-type tf-plan --severity $(REGULA_SEVERITY)

endef

define init_terraform_module
	echo && echo "Initializing $(1) ...";
	$(TERRAFORM) -chdir=$(1) init -backend=false -input=false;

endef

define list_terraform_modules
	$(FIND) . -path "*/.terraform" -prune -o -name "main.tf" -not -path '*pipeline*' -not -path '*examples*' -exec dirname {} \;;

endef

define list_examples
	filedir="$($(FIND) ./examples -path "*/.terraform" -prune -o -name "main.tf" -not -path '*pipeline*' -exec dirname {} \;;)
	if [ -n "${filedir}" ]; then
		echo "${filedir}" | tr ' ' '\n' | sort;
	else
        printf 'Oops! Found no file matching \n' >&2
	fi
endef

define plan_terraform_module
	echo && echo "Planning $(1) ...";
	$(TERRAFORM) -chdir=$(1) plan -input=false -out=terraform.tfplan -var-file $(VAR_FILE);
	echo && echo "Creating JSON plan output for $(1) ...";
	cd $(1) && $(TERRAFORM) show -json ./terraform.tfplan > ./terraform.tfplan.json;

endef

define tflint_terraform_module
	echo && echo "Linting $(1) ...";
	(cd $(1) && TF_LOG=info $(TFLINT) -c $(TFLINT_CONFIG)) || exit 1;

endef

define validate_terraform_module
	echo && echo "Validating $(1) ...";
	$(TERRAFORM) -chdir=$(1) validate || exit 1;

endef

# Tasks

.PHONY: tfmodule/all
tfmodule/all: check

.PHONY: tfmodule/clean
tfmodule/clean :
	@$(foreach module,$(ALL_TF_MODULES),$(call clean_terraform_module,$(module)))

.PHONY: tfmodule/fmt
tfmodule/fmt :
	$(TERRAFORM) fmt -recursive;

.PHONY: tfmodule/init
tfmodule/init :
	@$(foreach module,$(ALL_TF_MODULES),$(call init_terraform_module,$(module)))

.PHONY: tfmodule/lint
tfmodule/lint : tfmodule/init
	@$(call check_terraform_fmt)
	@$(foreach module,$(ALL_TF_MODULES),$(call tflint_terraform_module,$(module)))
	@$(foreach module,$(ALL_TF_MODULES),$(call validate_terraform_module,$(module)))

.PHONY: tfmodule/list
tfmodule/list :
	@echo -n "Modules: "
	@echo $(ALL_TF_MODULES) | tr ' ' '\n' | sort
	@echo -n "Examples: "
	@echo $(ALL_EXAMPLES) | tr ' ' '\n' | sort

.PHONY: tfmodule/plan
tfmodule/plan : tfmodule/init
	@$(foreach module,$(ALL_TF_MODULES),$(call plan_terraform_module,$(module)))

.PHONY: tfmodule/test/regula
tfmodule/test/regula : 
	@$(foreach module,$(ALL_TF_MODULES),$(call regula_terraform_module,$(module)))

.PHONY: tfmodule/test/conftest
tfmodule/test/conftest : 
	@$(foreach module,$(ALL_TF_MODULES),$(call conftest_terraform_module,$(module)))

.PHONY: tfmodule/pre_deploy_test
tfmodule/pre_deploy_test : tfmodule/clone_custom_rules
	@$(foreach example,$(ALL_EXAMPLES),$(call init_terraform_module,$(example)))
	@$(foreach example,$(ALL_EXAMPLES),$(call plan_terraform_module,$(example)))
	@$(foreach example,$(ALL_EXAMPLES),$(call conftest_terraform_module,$(example)))
	@$(foreach example,$(ALL_EXAMPLES),$(call regula_terraform_module,$(example)))

.PHONY: tfmodule/post_deploy_test
tfmodule/post_deploy_test :

.PHONY: tfmodule/clone_custom_rules
tfmodule/clone_custom_rules :
	-rm -rf $(MODULE_DIR)/custom_policy
ifeq ($(origin CUSTOM_POLICY_REPO),undefined)
	mkdir -p $(MODULE_DIR)/custom_policy/policy
else
	git clone $(CUSTOM_POLICY_REPO) $(MODULE_DIR)/custom_policy
endif

.PHONY: check
check::
	$(MAKE) tfmodule/lint
	$(MAKE) tfmodule/clone_custom_rules
	$(MAKE) tfmodule/plan
	$(MAKE) tfmodule/test/conftest
	$(MAKE) tfmodule/test/regula
