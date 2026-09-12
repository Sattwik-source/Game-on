@echo off
cd /d "%~dp0"

REM Read .env file line by line and set variables
for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
    set %%a=%%b
)

REM Use local profile with H2
set SPRING_PROFILES_ACTIVE=local

REM Start the backend
mvn spring-boot:run
pause
