package terraform.security

# Require tags on VPC resources
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_vpc"
    not resource.change.after.tags.Environment
    msg := "VPC must have Environment tag"
}

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_vpc"
    not resource.change.after.tags.Project
    msg := "VPC must have Project tag"
}

# Require tags on subnets
deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_subnet"
    not resource.change.after.tags.Environment
    msg := "Subnets must have Environment tag"
}