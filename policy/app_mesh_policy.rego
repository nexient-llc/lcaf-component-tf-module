package appmesh

import data.terraform.plan_functions
import data.terraform.tag_validation
import input.resource_changes

# Allowable egress filters:
allowable_egress_filters := {"ALLOW_ALL", "DROP_ALL"}

# Get different resource change types
# Get all creates
resources_added := plan_functions.get_resources_by_action("create", resource_changes)

# Get all deletes
resources_removed := plan_functions.get_resources_by_action("delete", resource_changes)

# Get all modifies
resource_changed := plan_functions.get_resources_by_action("update", resource_changes)

# Get the appmeshes (changes)
appmeshes := plan_functions.get_resources_by_type("aws_appmesh_mesh", resource_changes)

# Example rule to enforce ALLOW_ALL on egress filter - required for external communication
deny_egress[msg] {
	resources := appmeshes
	resources != null
	change := resources[_].change
	action := change.actions[_]
	action == "create"
	spec := change.after.spec[_]
	type := spec.egress_filter[_].type
	not allowable_egress_filters[type]

	msg := sprintf("Appmesh has invalid egress filter: %s", [resources[_].address])
}
