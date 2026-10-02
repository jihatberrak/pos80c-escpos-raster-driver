# POS-80C Raster surucu kurulumu (yonetici). Sertifika -> surucu paketi -> yazici kuyrugu
param([string]$PrinterName = 'POS-80C Raster', [string]$Port = '')
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$log = Join-Path $here 'kurulum.log'
$driverName = 'POS-80C Raster (Berrak)'
Start-Transcript -Path $log -Force | Out-Null
try {
    # Kendi urettiginiz paketteki sertifikayi (Build-Package.ps1 -> Sertifika.cer) guvenilir yapar.
    # Kendinden imzali sertifika Kok depoya eklenir: yalnizca kendi bilgisayarlarinizda kullanin.
    $cer = @('Sertifika.cer', 'BerrakBilisim.cer') | ForEach-Object { Join-Path $here $_ } | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($cer) {
        foreach ($store in 'Root', 'TrustedPublisher') {
            try {
                Import-Certificate -FilePath $cer -CertStoreLocation "Cert:\LocalMachine\$store" | Out-Null
                Write-Host "Sertifika yuklendi: $store"
            } catch {
                Write-Host "UYARI: sertifika $store deposuna yuklenemedi: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host 'UYARI: sertifika dosyasi bulunamadi (Sertifika.cer).' -ForegroundColor Yellow
    }

    pnputil /add-driver (Join-Path $here 'POS80C.inf') /install
    if ($LASTEXITCODE -ne 0 -and -not (Get-PrinterDriver -Name $driverName -ErrorAction SilentlyContinue)) {
        Write-Host 'UYARI: pnputil hata kodu dondu, surucu eklemeye devam ediliyor.' -ForegroundColor Yellow
    }
    if (-not (Get-PrinterDriver -Name $driverName -ErrorAction SilentlyContinue)) {
        Add-PrinterDriver -Name $driverName
    }
    Write-Host 'Surucu eklendi'

    # Windows donanim kimligiyle kuyrugu kendisi eklemis olabilir
    if (Get-Printer -ErrorAction SilentlyContinue | Where-Object { $_.DriverName -eq $driverName }) {
        Write-Host 'Yazici kuyrugu zaten mevcut.'
    } else {
        if (-not $Port) {
            $Port = (Get-PrinterPort | Where-Object { $_.Name -like 'USB*' -and $_.Description -match 'POS-80C' } | Select-Object -First 1).Name
        }
        if (-not $Port) { throw 'POS-80C USB portu bulunamadi. Yaziciyi baglayip tekrar deneyin.' }
        Add-Printer -Name $PrinterName -DriverName $driverName -PortName $Port
        Write-Host "Yazici eklendi: $PrinterName ($Port)"
    }
} catch {
    Write-Host "HATA: $($_.Exception.Message)" -ForegroundColor Red
} finally { Stop-Transcript | Out-Null }
