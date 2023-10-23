Clear-Host
Write-Host "################################  Start of Script  ################################"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
$ErrorActionPreference = 'Stop'

$Config = (Get-Content "$PSScriptRoot\TM-Config.json" -Raw) | ConvertFrom-Json
$Manager = $Config.MANAGER
$APIKEY = $Config.APIKEY
$PORT = $Config.PORT
$C1WS = $Config.C1WS
$C1API = $Config.C1API

$DS_headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$DS_headers.Add("api-secret-key", $APIKEY)
$DS_headers.Add("api-version", 'v1')
$DS_headers.Add("Content-Type", 'application/json')

$C1WS_headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$C1WS_headers.Add("Authorization", $C1API)
$C1WS_headers.Add("api-version", 'v1')
$C1WS_headers.Add("Content-Type", 'application/json')

$DS_HOST_URI = "https://" + $Manager + ":" + $PORT + "/api/"
$C1WS_HOST_URI = "https://" + $C1WS + "/api/"

$PortListsAPIPath = "portlists"
$DS_PortLists_URI = $DS_HOST_URI + $PortListsAPIPath
$C1WS_PortLists_URI = $C1WS_HOST_URI + $PortListsAPIPath

try {
    try {
        $DS_PortLists_REST = Invoke-RestMethod -Uri $DS_PortLists_URI -Method Get -Headers $DS_headers -SkipCertificateCheck
        $C1WS_PortLists_REST = Invoke-RestMethod -Uri $C1WS_PortLists_URI -Method Get -Headers $C1WS_headers -SkipCertificateCheck  
    }
    catch {
        Write-Host "[ERROR] Failed to retreive the Policies.  $_"
    }    
    $DS_PortLists = $DS_PortLists_REST.portLists
    $C1WS_PortLists = $C1WS_PortLists_REST.portLists
    ForEach ($DS_PortList in $DS_PortLists) {
        ForEach ($C1WS_PortList in $C1WS_PortLists){
            If ($DS_PortList.name -eq $C1WS_PortList.name){
                $DS_PortListName = $DS_PortList.name 
                $DS_PortListID = $DS_PortList.ID

                $WS_PortListName = $C1WS_PortList.name
                $WS_PortListID = $C1WS_PortList.ID

                $New_PortList = $C1WS_PortList.items + $DS_PortList.items | Sort-Object -Unique
                $New_PortList_Payload = @{
                    "name"=$WS_PortListName
                    "items"=$New_PortList
                }
                $New_PortList_Payload_Json = $New_PortList_Payload | ConvertTo-Json
                $C1WS_PortLists_Post_URI = $C1WS_PortLists_URI + "/" + $WS_PortListID
                try {
                    $Update_C1WS_PortLists = Invoke-RestMethod -Uri $C1WS_PortLists_Post_URI -Method Post -Headers $C1WS_headers -Body $New_PortList_Payload_Json -SkipCertificateCheck 
                }
                catch {
                    Write-Host "[ERROR]	Failed to update PortList:	$_"
                    Write-Host "Please manually update this PortList:  $WS_PortListName"
                    Continue
                }

                $DS_PortLists_Post_URI = $DS_PortLists_URI + "/" + $DS_PortListID
                try {
                    $Update_DS_PortLists = Invoke-RestMethod -Uri $DS_PortLists_Post_URI -Method Post -Headers $DS_headers -Body $New_PortList_Payload_Json -SkipCertificateCheck 
                }
                catch {
                    Write-Host "[ERROR]	Failed to update PortList:	$_"
                    Write-Host "Please manually update this PortList:  $DS_PortListName"
                    Continue
                }
            }
        }
    } 
}
catch {
    Write-Host "[ERROR]	Failed to run main script.	$_"
}