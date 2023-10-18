package appmesh_test

import data.appmesh
import future.keywords

test_valid_egress if {
	good_mesh := {"resource_changes": [{
		"address": "module.appmesh.aws_appmesh_mesh.this",
		"module_address": "module.appmesh",
		"mode": "managed",
		"type": "aws_appmesh_mesh",
		"name": "this",
		"provider_name": "registry.terraform.io/hashicorp/aws",
		"change": {
			"actions": ["create"],
			"after": {
				"name": "demo-mesh-25334",
				"spec": [{"egress_filter": [{"type": "DROP_ALL"}]}],
			},
		},
	}]}
	expected := "Appmesh has invalid egress filter: module.appmesh.aws_appmesh_mesh.this"
	not appmesh.deny_egress[expected] with input as good_mesh
}

test_fail_open_egress if {
	bad_mesh := {"resource_changes": [{
		"address": "module.appmesh.aws_appmesh_mesh.this",
		"module_address": "module.appmesh",
		"mode": "managed",
		"type": "aws_appmesh_mesh",
		"name": "this",
		"provider_name": "registry.terraform.io/hashicorp/aws",
		"change": {
			"actions": ["create"],
			"after": {
				"name": "demo-mesh-25334",
				"spec": [{"egress_filter": [{"type": "INVALID_TYPE"}]}],
			},
		},
	}]}
	expected := "Appmesh has invalid egress filter: module.appmesh.aws_appmesh_mesh.this"
	appmesh.deny_egress[expected] with input as bad_mesh
}
