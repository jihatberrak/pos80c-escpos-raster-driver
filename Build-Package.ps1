# Surucu paketini (katalog + imza) kendi kod imzalama sertifikanizla uretir.
# Gereksinim: Windows SDK (makecat.exe, signtool.exe) ve kisisel depoda kod imzalama sertifikasi.
# Kullanim:  .\Build-Package.ps1 -Thumbprint <SERTIFIKA_PARMAK_IZI>
param(
    [Parameter(Mandatory)][string]$Thumbprint,
    [string]$SdkBin = (Get-ChildItem "${env:ProgramFiles(x86)}\Windows Kits\10\bin\10.*\x64" -Directory | Sort-Object Name -Descending | Select-Object -First 1).FullName
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$out = Join-Path $root 'dist'
New-Item -ItemType Directory -Force $out | Out-Null
Copy-Item (Join-Path $root 'driver\*') $out -Force

$cert = Get-ChildItem Cert:\CurrentUser\My, Cert:\LocalMachine\My | Where-Object { $_.Thumbprint -eq $Thumbprint -and $_.HasPrivateKey } | Select-Object -First 1
if (-not $cert) { throw "Sertifika bulunamadi: $Thumbprint" }
Export-Certificate -Cert $cert -FilePath (Join-Path $out 'Sertifika.cer') | Out-Null

@"
[CatalogHeader]
Name=POS80C.cat
ResultDir=$out
PublicVersion=0x0000001
EncodingType=0x00010001
CATATTR1=0x10010001:OSAttr:2:10.0
[CatalogFiles]
<hash>POS80C.GPD=$out\POS80C.GPD
<hash>POS80C.inf=$out\POS80C.inf
"@ | Set-Content (Join-Path $out 'POS80C.cdf') -Encoding ASCII

Push-Location $out
& (Join-Path $SdkBin 'makecat.exe') POS80C.cdf
Pop-Location
& (Join-Path $SdkBin 'signtool.exe') sign /sha1 $Thumbprint /fd SHA256 (Join-Path $out 'POS80C.cat')
Remove-Item (Join-Path $out 'POS80C.cdf')
Write-Host "Hazir: $out  (Surucu-Kur.ps1 yonetici olarak calistirilir)"
