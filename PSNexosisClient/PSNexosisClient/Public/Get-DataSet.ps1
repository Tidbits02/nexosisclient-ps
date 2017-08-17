Function Get-DataSet {
<# 
 .Synopsis
  Gets the list of all datasets that have been saved to the system.

 .Description
  Returns a list of all the stored datasets and related data.

 .Parameter PartialName
  Limits results to only those datasets with names containing the specified value

 .Parameter Page
  Zero-based page number of results to retrieve.

 .Parameter PageSize
  Count of datasets to retrieve in each page (max 1000).

 .Example
  # Get a list of datasets that have the world 'sales' in the dataset name
  Get-DataSet -partialName 'sales'

 .Example
  # Get a list of datasets, convert it to Json
  Get-DataSet -page 0 -pageSize 2 | ConvertTo-Json -Depth 4

  .Example
   # Get page 0 of datasets that have the world 'sales' in the dataset name, with a max of 20 for this page
   Get-DataSet -partialName 'sales' -page 0 -pageSize 20
#>[CmdletBinding()]
	Param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$True)]
		[string]$partialName=$null,
		[Parameter(Mandatory=$false)]
		[int]$page=0,
		[Parameter(Mandatory=$false)]
        [int]$pageSize=$script:PSNexosisVars.DefaultPageSize
	)
    process {
        if (($page -ge $script:MaxPageSize) -or ($page -lt 0)) {
            throw "Parameter '-page' must be an integer between 0 and $script:MaxPageSize."
        }

        if (($pageSize -ge $script:MaxPageSize) -or ($pageSize -lt 0)) {
            throw "Parameter '-pageSize' must be an integer between 0 and $script:MaxPageSize."
        }

        $params = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($partialName.Trim().Length -gt 0) { 
            $params['partialName'] = $partialName
        }
        if ($page -ne 0) {
            $params['page'] = $page
        }

        if ($pageSize -ne ($script:PSNexosisVars.DefaultPageSize)) {
            $params['pageSize'] = $pageSize
        }

        $response = Invoke-Http -method Get -path 'data' -params $params
        
        $hasResponseCode = $null -ne $response.StatusCode
        
        if ($hasResponseCode -eq $true) {
            $response
        } else {
            $response.items
        }
    }
}