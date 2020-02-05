if(!([string] (Get-NetConnectionProfile).Name).Contains("Sgraastra")){

  Start-Service OpenVPNService
}
