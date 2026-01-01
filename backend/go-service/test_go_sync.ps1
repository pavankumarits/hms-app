$headers = @{
    "Content-Type" = "application/json"
}

$body = @{
    patients = @(
        @{
            id           = "test-patient-uuid-1"
            hospital_id  = "test-hospital-id"
            name         = "John Doe HighScale"
            age          = 30
            gender       = "Male"
            phone        = "1234567890"
            patient_uiid = "HOSP-2025-001"
            sync_status  = "pending"
        }
    )
    visits   = @(
        @{
            id              = "test-visit-uuid-1"
            patient_id      = "test-patient-uuid-1"
            hospital_id     = "test-hospital-id"
            date            = "2025-12-25 10:00:00"
            doctor_name     = "Dr. Speed"
            chief_complaint = "Fever"
            diagnosis       = "Flu"
            total_amount    = 500.0
        }
    )
} | ConvertTo-Json -Depth 3

# First, check if service is running
Write-Host "Checking if Go service is running on port 8001..." -ForegroundColor Yellow
try {
    $healthCheck = Invoke-RestMethod -Uri "http://localhost:8001/api/v1/health" -Method Get -TimeoutSec 3 -ErrorAction Stop
    Write-Host "✅ Service is running: $($healthCheck.status)" -ForegroundColor Green
}
catch {
    Write-Host "❌ Go service is NOT running on port 8001!" -ForegroundColor Red
    Write-Host "Please start it first: .\hms-service.exe" -ForegroundColor Yellow
    exit 1
}

# Now test the sync endpoint with timeout
Write-Host "`nSending POST request to http://localhost:8001/api/v1/sync..." -ForegroundColor Yellow
try {
    # 10-second timeout prevents infinite hanging
    $response = Invoke-RestMethod -Uri "http://localhost:8001/api/v1/sync" -Method Post -Headers $headers -Body $body -TimeoutSec 10 -ErrorAction Stop
    Write-Host "✅ Success!" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json)
}
catch {
    Write-Host "❌ Failed!" -ForegroundColor Red
    Write-Host $_.Exception.Message
    if ($_.Exception.Message -like "*timed out*") {
        Write-Host "`n⚠️  Request timed out - Check database connection!" -ForegroundColor Yellow
    }
}
