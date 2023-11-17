@echo off
if not "%1"=="isAdmin" (
	cls&title T2 - WARNING : Not running as admin
	echo [WARNING] T2 is not currently running as admin and some commands might not work
	echo           Do you want to restart it as admin? [Y/n]
	choice /c yn /n /d y
	if %errorlevel% == 1 (
		powershell start -verb runas '%0' isAdmin
		exit /b
		) else (
		set "errmsg="
	)

:00 Menu
cls%title T2 - Menu
echo Troubleshooting Tools (T2) ver.0.1
echo %errmsg% 
echo 1. Network
echo 2. About
echo 3. Exit
choice /cs /c A123 /n

:10 Advanced Mode
cls%title T2 - Advanced Mode

:20 Network
cls%title T2 - Advanced Mode

:30 About
cls%title T2 - Advanced Mode

:40 Exit
exit

::Functions::