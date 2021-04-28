$encodedapilink = 'https://graph.microsoft.com/v1.0/users?$select=userPrincipalName,assignedLicenses'
$more = $true
$listpower = [System.Collections.Generic.List[PSCustomObject]]::new()
$list365 = [System.Collections.Generic.List[PSCustomObject]]::new()
$listEMS = [System.Collections.Generic.List[PSCustomObject]]::new()

#Process all the fun
Function ProcessData() {    
    
    Write-Host "processing"
    
    while($more)
    {  
        $data = Invoke-RestMethod -Uri $encodedapilink -Headers $Headers | Select '@odata.context','@odata.nextLink',value           
        
        foreach($alert in $data.value)
        {   
            if($alert.assignedLicenses -ne $null -and $alert.assignedLicenses -ne "")
            {           
                foreach($license in $alert.assignedLicenses){
                    
                    if($license.SkuId -eq "de5f128b-46d7-4cfc-b915-a89ba060ea56")
                    {
                       $listpower.Add($alert)
                    }
                    if($license.SkuId -eq "efccb6f7-5641-4e0e-bd10-b4976e1bf68e")
                    {
                       $listEMS.Add($alert)
                    }
                    if($license.SkuId -eq "e578b273-6db4-4691-bba0-8d691f4da603")
                    {
                       $list365.Add($alert)
                    }
                }                         
            }               
        }
        
        if($data.'@odata.nextLink' -eq $null -or $data.'@odata.nextLink' -eq "")
        {
            $more = $false
        }
        else 
        {   
            Write-Host "NEXT LINK"                        
            $encodedapilink = [System.Web.HttpUtility]::UrlDecode($data.'@odata.nextLink').Trim()                   
        }      
    }           
    return $body 
}

#Put together tenant info and request auth token
$reqBody = @{
    'tenant' = *TENANT_ID*[redacted]
    'client_id' = *CLIENT_ID*[redacted]
    'scope' = 'https://graph.microsoft.com/.default'
    'client_secret' = *CLIENT_SECRET*[redacted]
    'grant_type' = 'client_credentials'
}

$Params = @{
    'Uri' = "https://login.microsoftonline.com/bd79c313-cdf7-458e-aaf9-06e1d7fd1889/oauth2/v2.0/token"
    'Method' = 'Post'
    'Body' = $reqBody
    'ContentType' = 'application/x-www-form-urlencoded'
}

$AuthResponse = Invoke-RestMethod @Params

$Headers = @{
    'Authorization' = "Bearer $($AuthResponse.access_token)"
}

ProcessData

$listpower | Select userPrincipalName | Export-Csv "PowerBiLicenses.csv"
$list365 | Select userPrincipalName | Export-Csv "365A3Licenses.csv"
$listEMS | Select userPrincipalName | Export-Csv "EMSLicense.csv"
