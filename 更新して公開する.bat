@echo off
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-gallery.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy-netlify.ps1"
pause
