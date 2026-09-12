@echo off
cd /d "%~dp0"
setlocal enabledelayedexpansion

REM Read .env file and set variables
for /f "usebackq tokens=* delims=" %%a in (.env) do (
    set "%%a"
)

REM Start the backend
mvn spring-boot:run -Dspring-boot.run.profiles=h2 -DskipTests
