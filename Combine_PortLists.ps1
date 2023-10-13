Clear-Host
Write-Host "################################  Start of Script  ################################"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
$ErrorActionPreference = 'Stop'

$Config = (Get-Content "$PSScriptRoot\DS-Config.json" -Raw) | ConvertFrom-Json
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
    ForEach ($PortList in $C1WS_PortLists) {
        ForEach ($Item in $DS_PortLists){
            If ($PortList.name -eq $Item.name){
                $DS_PortListName = $PortList.name 
                $WS_PortListName = $Item.name
                Write-Host "$DS_PortListName,  $WS_PortListName"
                $NewPortList = $PortList.items + $Item.items | Sort-Object -Unique
                Write-Host $NewPortList
            }
        }
    } 
}
catch {
    Write-Host "[ERROR]	Failed to run main script.	$_"
}