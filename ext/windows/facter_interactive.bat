@echo off
SETLOCAL
echo Running Facter on demand ...
cd "%~dp0"
call .\facter.bat %*
PAUSE
