# POS-80C Raster surucu kurulumu (yonetici). Sertifika -> surucu paketi -> yazici kuyrugu
param([string]$PrinterName = 'POS-80C Raster', [string]$Port = '')
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$log = Join-Path $here 'kurulum.log'
Start-Transcript -Path $log -Force | Out-Null
try {
    # Kendi urettiginiz paketteki sertifikayi (Build-Package.ps1 -> Sertifika.cer) guvenilir yapar.
    # Kendinden imzali sertifika Kok depoya eklenir: yalnizca kendi bilgisayarlarinizda kullanin.
    $cer = Join-Path $here 'Sertifika.cer'
    if (Test-Path $cer) {
        Import-Certificate -FilePath $cer -CertStoreLocation 'Cert:\LocalMachine\TrustedPublisher' | Out-Null
        Import-Certificate -FilePath $cer -CertStoreLocation 'Cert:\LocalMachine\Root' | Out-Null
        Write-Host 'Sertifika yuklendi'
    }

    pnputil /add-driver (Join-Path $here 'POS80C.inf') /install
    Add-PrinterDriver -Name 'POS-80C Raster (Berrak)'
    Write-Host 'Surucu eklendi'

    if (-not $Port) {
        $Port = (Get-PrinterPort | Where-Object { $_.Name -like 'USB*' -and $_.Description -match 'POS-80C' } | Select-Object -First 1).Name
    }
    if (-not $Port) { throw 'POS-80C USB portu bulunamadi. Yaziciyi baglayip tekrar deneyin.' }
    if (-not (Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue)) {
        Add-Printer -Name $PrinterName -DriverName 'POS-80C Raster (Berrak)' -PortName $Port
    }
    Write-Host "Yazici eklendi: $PrinterName ($Port)"
} catch {
    Write-Host "HATA: $($_.Exception.Message)" -ForegroundColor Red
} finally { Stop-Transcript | Out-Null }
