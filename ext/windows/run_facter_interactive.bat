@echo Running facter on demand ...
@echo off
SETLOCAL
if exist "%~dp0environment.bat" (
  call "%~dp0environment.bat" %0 %*
) else (
  SET "PATH=%~dp0;%PATH%"
)
elevate.exe "%~dp0facter_interactive.bat"
