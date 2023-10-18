package appmesh_virtual_gateway

import data.terraform.plan_functions
import data.terraform.tag_validation
import input.resource_changes

# Get different resource change types
# Get all creates
resources_added := plan_functions.get_resources_by_action("create", resource_changes)

# Get all deletes
resources_removed := plan_functions.get_resources_by_action("delete", resource_changes)

# Get all modifies
resource_changed := plan_functions.get_resources_by_action("update", resource_changes)

# Get the appmeshes (changes)
appmeshvgw := plan_functions.get_resources_by_type("aws_appmesh_virtual_gateway", resource_changes)

allowable_tls_modes := {"STRICT"}

# Example rule to enforce TLS on backend client policy for appmesh virtual gateways
deny_non_tls[msg] {
	resources := appmeshvgw
	resources != null

	change := resources[_].change
	action := change.actions[_]
	action == "create"

	spec := change.after.spec[_]
	spec != null

	backend_default := spec.backend_defaults[_]
	backend_default != null

	cp := backend_default.client_policy[_]
	cp != null

	tls := cp.tls[_]
	tls != null
	tls.enforce == "true"

	msg := sprintf("Appmesh Virtual Gateway must enforce TLS: %s", [resources[_].address])
}

deny_non_strict[msg] {
	resources := appmeshvgw
	resources != null

	change := resources[_].change
	action := change.actions[_]
	action == "create"

	spec := change.after.spec[_]
	spec != null

	listener := spec.listener[_]
	listener != null

	tls := listener.tls[_]
	tls != null
	not allowable_tls_modes[tls.mode]

	msg := sprintf("Appmesh Virtual Gateway listener TLS mode must be STRICT: %s, got %s", [resources[_].address, tls.mode])
}
