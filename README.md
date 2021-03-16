# Azure Bicep - Tagging Policies

Azure Bicep modules for creating policies to enforce minimum set of tagging governance.

1. reqtagnames.bicep requires tags on Resource Groups, denying the creation of RGs without the required tags.
2. addreplacetags.bicep adds and replaces tags on Resource Groups, useful for example to enforce "Environment: Production" on all RGs in Production subscriptions.
3. inherittags.bicep inherit tags on all supported resources in a RG, from the RG, if it isn't already present on the resource. 

## Example usage:

Bicep does not yet allow consuming external modules; in [backlog for v0.4](https://github.com/Azure/bicep/issues/660).

```bicep
var reqTagNames = [ 
  'requiredTag1'
  'requiredTag2'
]

var inheritTagNames = [ 
  'inheritedTag1'
  'inheritedTag2'
]

var addReplaceTags = [ 
  {
    name: 'Tag1'
    value: 'This is the value for Tag1'
  }
  {
    name: 'Tag2'
    value: 'This is the value for Tag2'
  }
]

module reqTagNamesOnRG 'reqtagnames.bicep' = {
  name: 'reqTagNamesOnRG'
  params: { 
    tagNames: reqTagNames 
  }
}

module inheritTagNamesFromRG 'inherittags.bicep' = {
  name: 'inheritTagNamesFromRG'
  params: {
    tagNames: inheritTagNames
  }
}

module addReplaceTagsOnRG 'addreplacetags.bicep' = {
  name: 'addReplaceTagsOnRG'
  params: {
    tags: addReplaceTags
  }
}
```
