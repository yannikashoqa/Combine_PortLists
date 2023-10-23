# Combine_PortLists


AUTHOR		: Yanni Kashoqa

TITLE		: Deep Security and Cloud One Workload Security Port Lists Combine Script

DESCRIPTION	: This Powershell script will combine the portslists from  Deep Security and Cloud One Workload Security instances 
              and apply the changes to both environments.  This is usefull when migrating agents from DS to C1WS and maintaining 
              the same portlists that could either be used for Firewall or the Intrusion Prevention Application Types. 

FEATURES
- Combine Portlists from two different installations of Deep Securoty and Cloud One Workload Secuerity.

REQUIRMENTS
- PowerShell 7+ Core
- Create a TM-Config.json in the same folder with the following content:
~~~~JSON
{
    "MANAGER": "dsm.local.com",
    "PORT"   : "4119",
    "APIKEY" : "DS_APIKey",
    "C1WS"   : "workload.trend-us-1.cloudone.trendmicro.com",
    "C1API"  : "ApiKey C1APIKey"
}
~~~~

- An API Key created on the Deep Security Manager 
- An API Key created on the Cloud One console
- The API Key Role minimum requirement is Read Only access to Workload Security/Deep Security
- The API Key format in the TM-Config.json for Cloud One is "ApiKey YourAPIKey"
