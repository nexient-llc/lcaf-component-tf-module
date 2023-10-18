# Common Automation Framework - Terraform Module Component

This repo holds the component for terraform modules within the Common Automation Framework (CAF).

It contains the following:

* tasks - Makefiles for performing terraform operations on your module and running tests and pre-checks
* policy - OPA policy definitions for terraform modules.  The contents here apply to **all** CAF terraform modules.
* linkfiles - other files used by terraform and CAF projects

## Policy Customization

To add policies in addition to the policies defined by the CAF terraform module and by Regula, define

```CUSTOM_POLICY_REPO=https://some.git.url/```

in your Makefile.includes.  Only the default branch (`main`) is supported.

This repo should have 2 top-level directories:

* policy
* regula

`policy` will contain your rego policy files (and tests), if any.

`regula` will contain your regula config file which defines your waivers for regula rules (if any).
