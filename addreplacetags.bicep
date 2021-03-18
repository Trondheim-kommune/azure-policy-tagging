targetScope = 'subscription'

param tags array

resource contrib_roleDef 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}

resource addReplaceTagsOnRG_policyAssignments 'Microsoft.Authorization/policyAssignments@2020-09-01' = [for tag in tags: {
  name: 'addReplaceTag-${tag.name}-OnRG'
  properties: {
    policyDefinitionId: addReplaceTagRG_PolicyDef.id
    displayName: 'Add/replace tag "${tag.name}" on RG'
    parameters: {
      tagName: {
        value: '${tag.name}'
      }
      tagValue: {
        value: '${tag.value}'
      }
    }
  } 
  location: 'norwayeast'
  identity: {
    type: 'SystemAssigned'
  }   
}]

resource addReplaceTagsOnRG_roleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for i in range(0, length(tags)): {
  name: guid('contributor ${addReplaceTagsOnRG_policyAssignments[i].name}', subscription().subscriptionId)
  properties: { 
    roleDefinitionId: contrib_roleDef.id
    principalId: addReplaceTagsOnRG_policyAssignments[i].identity.principalId
  }
}]

resource addReplaceTagRG_PolicyDef 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: 'add-replace-tag-on-rg'
  properties: {
    displayName: 'Add or replace a tag on resource groups'
    policyType: 'Custom'
    mode: 'All'
    description: 'Adds or replaces the specified tag and value when any resource group is created or updated. Existing resource groups can be remediated by triggering a remediation task.'
    parameters: {
      tagName: {
        type: 'String'
        metadata: {
          displayName: 'Tag Name'
          description: 'Name of the tag, such as "environment"'
        }
      }
      tagValue: {
        type: 'String'
        metadata: {
          displayName: 'Tag Value'
          description: 'Value of the tag, such as "production"'
        }
      }
    }
    metadata: { 
      category: 'Tags'
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Resources/subscriptions/resourceGroups'
          }
          {
            field: '[concat(\'tags[\', parameters(\'tagName\'), \']\')]'
            notEquals: '[parameters(\'tagValue\')]'
          }
        ]
      }
      then: {
        effect: 'modify'
        details: {
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          operations: [
            {
            operation: 'addOrReplace'
            field: '[concat(\'tags[\', parameters(\'tagName\'), \']\')]'
            value: '[parameters(\'tagValue\')]'
          }
        ]
        }
      }
    }
  }
}