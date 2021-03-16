targetScope = 'subscription'

param tagNames array

resource reqTagsOnRG_policyAssignments 'Microsoft.Authorization/policyAssignments@2020-09-01' = [for name in tagNames: {
  name: 'reqTag-${name}-OnRG'
  properties: {
    policyDefinitionId: reqTagRG_PolicyDef.id
    displayName: 'Require tag "${name}" on RG'
    parameters: {
      tagName: {
        value: '${name}'
      }
    }
  }  
}]

resource reqTagRG_PolicyDef 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: 'require-tag-on-rg'
  properties: {
    displayName: 'Require tag on resource groups'
    policyType: 'Custom'
    mode: 'All'
    description: 'Requires the specified tag when any resource group is created or updated.'
    parameters: {
      tagName: {
        type: 'String'
        metadata: {
          displayName: 'Tag Name'
          description: 'Name of the tag, such as "environment"'
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
            exists: false
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
}