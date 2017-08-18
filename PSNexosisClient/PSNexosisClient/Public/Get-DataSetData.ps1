Function Get-DataSetData {
<# 
 .Synopsis
  Reads the data in a particular dataset and returns it or CSV format.

 .Description
  Returns all of the data stored in a dataset. If the DataSet does not exist or an error occurs, it will return 
  an object containing the REST Status Code along with Error details.

 .Parameter DataSetName
  Name of the dataset for which to retrieve data

 .Parameter StartDate  
  Format - date-time (as date-time in ISO8601). Limits results to those on or after the specified date

 .Parameter EndDate 
  Format - date-time (as date-time in ISO8601). Limits results to those on or before the specified date

 .Parameter Page
  Zero-based page number of results to retrieve.

 .Parameter PageSize
  Count of datasets to retrieve in each page (max 1000).
 
 .Parameter Include 
 Limits results to the specified columns

 .Parameter UseCsv
 Returns a CSV of the dataset instead of JSON.

 .Example
  # Read the data in the dataset named 'salesdata'
  Get-DataSetData -dataSetName 'salesdata'   
 
  .Example 
  # Return the data from dataset Location-A
  (Get-DataSetData -dataSetName 'Location-A').Data
  
  .Example
  # Get the data in the dataset named 'salesdata' starting at page and include 1000 records between the provided start date and enddate.
  Get-DataSetData -dataSetName 'salesdata' -page 0 -pageSize 1000 -startDate 2017-02-25 -endDate 2017-03-25

 .Example
  # Read up to 1000 records in from dataset Sales Data
  Get-DataSetData -dataSetName 'salesdata' -page 0 -pageSize 1000 

 .Example
  # Read the data in the dataset named 'salesdata' and convert it to JSON at a dept of 4
  Get-DataSetData -dataSetName 'salesdata' | ConvertTo-Json -Depth 4

 .Example
  # Returns data in DataSet name 'Location-A' in CSV format.
  Get-DataSetData -dataSetName 'Location-A' -ReturnCsv
#>[CmdletBinding()]
	Param(
        [Parameter(Mandatory=$false, ValueFromPipeline=$True)]
		[string]$dataSetName,
		[Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
		[DateTime]$startDate,
		[Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
		[DateTime]$endDate,
		[Parameter(Mandatory=$false)]
		[int]$page=0,
		[Parameter(Mandatory=$false)]
		[int]$pageSize=$script:PSNexosisVars.DefaultPageSize,
		[Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
		$include=@(),
		[Parameter(Mandatory=$false)]
        [switch]$ReturnCsv=$false
	)
	process {
		$params = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

		if ($dataSetName.Trim().Length -eq 0) { 
			throw "Argument '-DataSetName' cannot be null or empty."
		}

		if ($page -lt 0) {
            throw "Parameter '-page' must be an integer greater than 0."
        }

		if (($pageSize -gt ($script:MaxPageSize)) -or ($pageSize -lt 1)) {
            throw "Parameter '-pageSize' must be an integer between 1 and $script:MaxPageSize."
        }
		
		if ($null -ne $startDate ) { 
			$params['startDate'] = $startDate
		}

		if ($null -ne $endDate) {
			$params['endDate'] = $endDate
		}

		if ($page -ne 0) {
			$params['page'] = $page
		}

		if ($pageSize -ne ($script:PSNexosisVars.DefaultPageSize)) {
            $params['pageSize'] = $pageSize
        }

		foreach ($val in  $include) {
			$params.Add('include', $val)
		}
		
		if ($ReturnCsv) {
			$response = Invoke-Http -method Get -path "data/$dataSetName" -params $params -acceptHeader "text/csv"
		} else {
			$response = Invoke-Http -method Get -path "data/$dataSetName" -params $params
		}
		    
        $hasResponseCode = $null -ne $response.StatusCode
        
        if ($hasResponseCode -eq $true) {
            $response
        } else {
            $response
        }
	}
}
