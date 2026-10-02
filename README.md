# POS-80C ESC/POS Raster Driver (Windows)

STMicroelectronics tabanlı (`USB\VID_0483&PID_5743`) jenerik **POS-80C / POS-80** 80 mm termal fiş yazıcıları için,
Windows'un kendi **Unidrv** motorunu kullanan, DLL içermeyen bir yazıcı sürücüsü (GPD + INF).

## Neden?
Bu klon yazıcılar üreticinin sürücüsüyle bozuk karakter basıyor, "Generic / Text Only" ile de Türkçe karakterler bozuluyor.
Bu sürücü sayfayı (metin dahil) **1 bit grafik** olarak `GS v 0` ESC/POS raster komutuyla gönderir; karakter tablosu
(code page) sorunu olmaz. FastReport (ERP12 vb.) gibi GDI ile yazdıran programlarla çalışır.

## İçerik
- `driver/POS80C.GPD`  – Unidrv minidriver (203 dpi, 576 nokta genişlik, raster çıktı, kesici komutu)
- `driver/POS80C.inf`  – Sürücü INF (USB donanım kimlikleri dahil)
- `driver/Surucu-Kur.ps1` – Kurulum (sertifika, sürücü, yazıcı kuyruğu)
- `Build-Package.ps1` – Katalog (`.cat`) üretip **kendi** sertifikanızla imzalar

## Kurulum
1. Windows SDK kurulu olmalı (`makecat.exe`, `signtool.exe`) ve kod imzalama sertifikanız olmalı.
2. Paketi üretin:
   ```powershell
   .\Build-Package.ps1 -Thumbprint <SERTIFIKA_PARMAK_IZI>
   ```
3. Yazıcı USB ile bağlıyken `dist\Surucu-Kur.ps1` dosyasını **yönetici** olarak çalıştırın.
4. Programınızda `POS-80C Raster` yazıcısını seçin.

> Güvenlik notu: Kendinden imzalı sertifika kurulumda **Kök** ve **Güvenilen Yayımcılar** depolarına eklenir.
> Yalnızca kendi bilgisayarlarınızda ve kendi sertifikanızla kullanın. Üçüncü kişilerin sertifikasına güvenmeyin.

## Bilinenler
- Varsayılan kağıt: 80 mm x 200 mm (576 nokta). 80 mm x 100/150/297 mm ve özel boyut tanımlı.
- 512 nokta genişlikli yazıcılar için `POS80C.GPD` içindeki `576` değerlerini `512` yapın (ve `Build-Package.ps1`'i yeniden çalıştırın).
- Kesici komutu (`GS V 66 0`) sayfa sonunda gönderilir.
- Windows 11 (26100) üzerinde test edildi.

## Lisans
[MIT](LICENSE)
