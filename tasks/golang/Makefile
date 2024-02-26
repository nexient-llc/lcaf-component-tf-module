SHELL := /bin/bash

# Binaries

GO ?= go
GOLANGCI_LINT ?= golangci-lint
TEE ?= tee
GREP ?= grep
FIND ?= find

# Variables

GO_TEST_DIRECTORIES ?= tests
GO_TEST_TIMEOUT ?= 2h
GO_TEST_READONLY_DIRECTORY ?= post_deploy_functional_readonly
TEST_RUN_ONLY_READONLY = #intentionally empty
TEST_RUN_EXCLUDE_READONLY = -v
GOLANGCI_LINT_CONFIG ?= .golangci.yaml
DISABLE_MAKE_CHECK_LINT ?= false

# Functions

# Checks for Go files in the GO_TEST_DIRECTORIES. If they exist, runs the default configuration for golangci-lint
# https://golangci-lint.run/usage/quick-start/
define go_lint
	$(FIND) $(1)/ -name '*.go' | $(GREP) -q '\.go' || exit 0; $(GOLANGCI_LINT) run -c $(GOLANGCI_LINT_CONFIG) -v ./$(1)/...;

endef

# Check for Go files. If they exist, run tests. Either runs only readonly tests(default) or tests except readonly ones
define go_test
	$(FIND) $(1)/ -name '*.go' |$(GREP) $(2) $(GO_TEST_READONLY_DIRECTORY) | $(GREP) -q '\.go' || exit 0; $(GO) test -v -count=1 -timeout=$(GO_TEST_TIMEOUT) $$($(GO) list ./$(1)/...|$(GREP) $(2)  $(GO_TEST_READONLY_DIRECTORY)) ;

endef

# Tasks

.PHONY: go/list
go/list :
	@echo -n "Test dirs: "
	@echo $(GO_TEST_DIRECTORIES) | tr ' ' '\n' | sort

.PHONY: go/lint
go/lint :
	$(foreach test_dir,$(GO_TEST_DIRECTORIES),$(call go_lint,$(test_dir)))

.PHONY: go/test
go/test :
	$(foreach test_dir,$(GO_TEST_DIRECTORIES),$(call go_test,$(test_dir),$(TEST_RUN_EXCLUDE_READONLY)))

go/readonly_test:
	$(foreach test_dir,$(GO_TEST_DIRECTORIES),$(call go_test,$(test_dir),$(TEST_RUN_ONLY_READONLY)))

.PHONY: lint
lint::
ifeq ($(DISABLE_MAKE_CHECK_LINT),false)
	$(MAKE) go/lint
else
	$(info "make go/lint has been disabled!")

.PHONY: test
test:: tfmodule/plan
	$(MAKE) go/test
