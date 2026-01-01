
@echo off
set TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NjY3OTU0MzgsInN1YiI6ImU2ZGVjNDRjLTcwZDYtNGI0OS05YzdmLTYzYjQxZWUwMGU5YSJ9.qK-dwjtqFu0Yo0qyeRiiQJVm2Unsgw_LeJJbuhQNdME
echo Attempt 1:
curl -X POST http://localhost:8005/api/v1/patients/ -H "Authorization: Bearer %TOKEN%" -H "Content-Type: application/json" -d "{\"name\":\"Test A\", \"gender\":\"Male\", \"dob\":\"1990-01-01\", \"patient_uiid\":\"P20251227-9001\"}"
echo.
echo Attempt 2:
curl -X POST http://localhost:8005/api/v1/patients/ -H "Authorization: Bearer %TOKEN%" -H "Content-Type: application/json" -d "{\"name\":\"Test B\", \"gender\":\"Male\", \"dob\":\"1990-01-01\", \"patient_uiid\":\"P20251227-9001\"}"
