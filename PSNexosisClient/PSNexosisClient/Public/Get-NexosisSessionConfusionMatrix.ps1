Function Get-NexosisSessionConfusionMatrix {
<# 
 .Synopsis
  Gets the confusion matrix for a classification session

 .Description
  A confusion matrix describes the performance of the classification model generated by this session by showing how
  each record in the test set was classified by the model. The rows in the confusion matrix are actual classes from
  the test set, and the columns are classes predicted by the model for those rows. Each cell in the matrix contains
  the count of records in the test set with a particular actual value and predicted value. The headers for both rows
  and columns of the matrix can be found in the 'classes' property of the response.

 .Parameter SessionId
  A Session identifier (UUID) of the session results to retrieve.

 .Example
  # Retrieve session data for sesion with the given session ID
  Get-NexosisSessionConfusionMatrix -sessionId 015df24f-7f43-4efe-b8ba-1e28d67eb3fa

 .Example
  # Return just the session result data for the given session ID.
  (Get-NexosisSessionConfusionMatrix -SessionId 015df24f-7f43-4efe-b8ba-1e28d67eb3fa).data

#>[CmdletBinding()]
	Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$True)]
        [GUID]$SessionId
	)
    process {
        $encodedSessionId = [uri]::EscapeDataString($SessionId)
        Invoke-Http -method Get -path "sessions/$encodedSessionId/results/confusionmatrix"
    }
}