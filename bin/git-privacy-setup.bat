@echo off
Powershell -ExecutionPolicy RemoteSigned -File "%~dp0\..\var\git-privacy-setup\git-privacy-setup.ps1" "%~1"
