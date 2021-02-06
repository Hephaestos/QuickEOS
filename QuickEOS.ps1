param(
    [int32]$n = 01,
    [switch]$arch = $false
    [switch]$help = $false
    [switch]$h = $false
)
if ($arch){
    if($n -lt 1 -or $n -gt 10) {
        Write-Host "QuickEOS: Invalid server number" -fore red
        Exit
    }
} else {
    if($n -lt 1 -or $n -gt 32) {
        Write-Host "QuickEOS: Invalid server number" -fore red
        Exit
    }
}
$number = $n
if ($n -lt 10) {
    $number = "0"+$n
}

$vpn = "C:\Program Files (x86)\Common Files\Pulse Secure\Integration\pulselauncher.exe"
$vpnexists = Test-Path -Path $vpn
if (-not $vpnexists) {
    Write-Host "QuickEOS: Please install PulseVPN" -fore red
    Exit
}
$credpath = "${HOME}\Documents\WindowsPowerShell\Scripts\eos.creds"
$credsexist = Test-Path -Path $credpath
if ($credsexist) {
    $vpncred = Import-CliXml -Path $credpath
    Write-Host = "QuickEOS: Loading credentials from ${credpath}" -fore green
} else {
    $vpncred = Get-Credential
}
if($vpncred) {
    $username = $vpncred.Username
    $passwd = $vpncred.Password
    $plainpasswd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwd))
    Write-Host = "QuickEOS: Connecting VPN" -fore green
    & $vpn -u $username -p $plainpasswd -url vpn.student.gvsu.edu -r Users
    if ($lastexitcode -eq 0) {
        if (-not $credsexist) {
            Write-Host "QuickEOS: Storing credentials to ${credpath}" -fore green
            $vpncred | Export-CliXml -Path $credpath
        }
        $lab = if ($arch) {"arch"} else {"eos"}
        ssh "${username}@${lab}${number}.cis.gvsu.edu"
        Write-Host = "QuickEOS: Disconnecting VPN" -fore green
        & $vpn -stop
    } else {
        Write-Host "QuickEOS: VPN Connection Error" -fore red
    }
} else {
    Write-Host "QuickEOS: Credential Error" -fore red
    if ($credsexist) {
        Write-Host "QuickEOS: Deleting invalid credentials at ${credpath}" -fore green
        Remove-Item $credpath
    }
}
