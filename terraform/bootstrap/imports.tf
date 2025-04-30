# This file takes care of importing bootstrap
# resources onto a new developer's machine if needed
# import happens automatically on a normal ./apply.sh run

import {
  to = cloudfoundry_service_credential_binding.bucket_creds
  id = "e2902704-d283-40c0-ac91-64de0fce073a"
}
import {
  to = module.mgmt_space.cloudfoundry_space.space
  id = "211cad8c-0175-49b4-b1c0-2990c53be833"
}
import {
  to = module.s3.cloudfoundry_service_instance.bucket
  id = "f0314509-da87-47b9-8425-f7d8eca40538"
}

locals {
  developer_import_map = "{\"ryan.ahearn@gsa.gov\":\"0a0cf46e-8b9f-47cb-aa4a-f266971543d7\"}"
  manager_import_map   = "{}"
}
import {
  for_each = jsondecode(local.developer_import_map)
  to       = module.mgmt_space.cloudfoundry_space_role.developers[each.key]
  id       = each.value
}
import {
  for_each = jsondecode(local.manager_import_map)
  to       = module.mgmt_space.cloudfoundry_space_role.managers[each.key]
  id       = each.value
}
