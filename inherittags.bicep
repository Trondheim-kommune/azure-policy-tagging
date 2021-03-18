targetScope = 'subscription'

param tagNames array

resource contrib_roleDef 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}

resource inheritTagsFromRG_policyAssignments 'Microsoft.Authorization/policyAssignments@2020-09-01' = [for name in tagNames: {
  name: 'inheritTag-${name}-FromRG'
  properties: {
    policyDefinitionId: inheritTagRG_PolicyDef.id
    displayName: 'Inherit tag "${name}" from RG'
    parameters: {
      tagName: {
        value: '${name}'
      }
    }
  }
  location: 'norwayeast'
  identity: {
    type: 'SystemAssigned'
  }  
}]

resource inheritTagsFromRG_roleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for i in range(0, length(tagNames)): {
  name: guid('contributor ${inheritTagsFromRG_policyAssignments[i].name}', subscription().subscriptionId)
  properties: {
    roleDefinitionId: contrib_roleDef.id
    principalId: inheritTagsFromRG_policyAssignments[i].identity.principalId
  }
}]

resource inheritTagRG_PolicyDef 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: 'inherit-tag-from-rg'
  properties: {
    displayName: 'Inherit a tag from the resource group if missing'
    policyType: 'Custom'
    mode: 'Indexed'
    description: 'Adds the specified tag and value from the parent resource group when any resource is created or updated, if it\'s missing.'
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
            field: '[concat(\'tags[\', parameters(\'tagName\'), \']\')]'
            exists: false
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
            value: '[resourceGroup().tags[parameters(\'tagName\')]]'
          }
        ]
        }
      }
    }
  }
}