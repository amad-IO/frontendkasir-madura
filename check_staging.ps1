# ============================================
# Script untuk Memeriksa Staging Area
# Mendeteksi file tim lain yang tidak sengaja masuk
# ============================================

Write-Host "=== CHECKING STAGING AREA ===" -ForegroundColor Cyan
Write-Host ""

# Daftar file yang TIDAK BOLEH di staging (milik tim lain)
$forbiddenFiles = @(
    # ========== Alif ==========
    "lib/data/models/Kasir.dart",
    "lib/data/models/toko.dart",
    "lib/data/services/toko_service.dart",
    "lib/data/services/user_service.dart",
    "lib/state/kasir_controller.dart",
    "lib/state/toko_controller.dart",
    "lib/ui/pages/TambahKasir.dart",
    "lib/ui/pages/popupTambahToko.dart",
    "lib/ui/pages/TambahToko.dart",
    "lib/ui/pages/tambahPenggunaPage.dart",
    
    # ========== Umar ==========
    "lib/data/models/product.dart",
    "lib/data/services/product_service.dart",
    "lib/state/product_controller.dart",
    "lib/ui/pages/TambahEditProduk.dart",
    "lib/ui/pages/TambahProdukPage.dart",
    
    # ========== Chelsy ==========
    "lib/data/models/login_request.dart",
    "lib/data/models/login_response.dart",
    "lib/data/models/signup_response.dart",
    "lib/data/models/user_request.dart",
    "lib/data/services/auth_service.dart",
    "lib/data/services/signup_service.dart",
    "lib/ui/pages/onBoarding.dart",
    "lib/ui/pages/LoginPage.dart",
    "lib/ui/pages/registerPage.dart",
    "lib/ui/pages/dashboardPage.dart",
    
    # ========== Aisyah ==========
    "lib/data/models/laporan_harian.dart",
    "lib/data/models/laporan_item.dart",
    "lib/data/models/laporan_transaksi.dart",
    "lib/data/services/laporan_service.dart",
    "lib/ui/pages/laporanPenjualan.dart"
)

# Ambil daftar file di staging dengan format path Unix
$stagedFiles = git diff --cached --name-only | ForEach-Object { $_ -replace '\\', '/' }

$foundForbidden = @()
$ownerMap = @{
    "Alif" = @("Kasir.dart", "toko.dart", "toko_service.dart", "user_service.dart", "kasir_controller.dart", "toko_controller.dart", "TambahKasir.dart", "popupTambahToko.dart", "TambahToko.dart", "tambahPenggunaPage.dart")
    "Umar" = @("product.dart", "product_service.dart", "product_controller.dart", "TambahEditProduk.dart", "TambahProdukPage.dart")
    "Chelsy" = @("login_request.dart", "login_response.dart", "signup_response.dart", "user_request.dart", "auth_service.dart", "signup_service.dart", "onBoarding.dart", "LoginPage.dart", "registerPage.dart", "dashboardPage.dart")
    "Aisyah" = @("laporan_harian.dart", "laporan_item.dart", "laporan_transaksi.dart", "laporan_service.dart", "laporanPenjualan.dart")
}

foreach ($file in $stagedFiles) {
    if ($forbiddenFiles -contains $file) {
        # Determine owner
        $owner = "Unknown"
        $fileName = Split-Path $file -Leaf
        
        foreach ($person in $ownerMap.Keys) {
            if ($ownerMap[$person] -contains $fileName) {
                $owner = $person
                break
            }
        }
        
        $foundForbidden += @{
            Path = $file
            Owner = $owner
        }
    }
}

if ($foundForbidden.Count -gt 0) {
    Write-Host "❌ PERINGATAN! File berikut tidak boleh di-push:" -ForegroundColor Red
    Write-Host ""
    
    # Group by owner
    $groupedByOwner = $foundForbidden | Group-Object -Property Owner
    
    foreach ($group in $groupedByOwner) {
        Write-Host "  🔸 File milik $($group.Name):" -ForegroundColor Yellow
        foreach ($item in $group.Group) {
            Write-Host "     - $($item.Path)" -ForegroundColor Gray
        }
        Write-Host ""
    }
    
    Write-Host "Untuk mengeluarkan file tersebut dari staging, jalankan:" -ForegroundColor Cyan
    Write-Host ""
    foreach ($item in $foundForbidden) {
        Write-Host "  git reset HEAD $($item.Path)" -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "ATAU reset semua sekaligus:" -ForegroundColor Cyan
    Write-Host "  git reset HEAD" -ForegroundColor Green
    
} else {
    Write-Host "✅ Staging area aman! Tidak ada file tim lain yang terdeteksi." -ForegroundColor Green
    Write-Host ""
    Write-Host "File yang akan di-commit:" -ForegroundColor Cyan
    git diff --cached --name-status | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Gray
    }
}

Write-Host ""
