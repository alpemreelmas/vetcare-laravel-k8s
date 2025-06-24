# Run this script as Administrator
# Right-click PowerShell and "Run as Administrator"

$hostsPath = "C:\Windows\System32\drivers\etc\hosts"
$hostsEntry = "127.0.0.1    vetcare.local"

# Check if entry already exists
$hostsContent = Get-Content $hostsPath
if ($hostsContent -notcontains $hostsEntry) {
    Add-Content -Path $hostsPath -Value $hostsEntry
    Write-Host "Added vetcare.local to hosts file" -ForegroundColor Green
} else {
    Write-Host "vetcare.local already exists in hosts file" -ForegroundColor Yellow
}

# Flush DNS cache
ipconfig /flushdns

Write-Host "Setup complete! You can now access:" -ForegroundColor Green
Write-Host "Frontend: http://vetcare.local" -ForegroundColor Cyan
Write-Host "Backend API: http://vetcare.local/api/health" -ForegroundColor Cyan
