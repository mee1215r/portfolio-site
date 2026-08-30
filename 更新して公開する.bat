@echo off
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-gallery.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish-github.ps1"
pause
