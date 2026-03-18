@echo off
::App version
set appv=0.5.2

::Verify if T2 is has admin privileges and if not, prompt to restart with them
net.exe session 1>nul 2>nul && (
	set "admreq="
	) || (
	title T2 - WARNING : Not admin
	echo [33m[WARNING][0m[1m T2 is not currently running as admin and some commands might not work[0m
	echo           Do you want to restart it as admin^? [y/N]
	set "admreq=[93m*Admin is required[0m"
	choice /c yn /n
	)

if %errorlevel% == 1 (
	powershell start -verb runas '%0'
	exit /b
	)

::Set the function shortcut
set "f=call :"

:00 Menu
%f%dispHead2 "Menu" "Troubleshooting Tools"
echo 1. Network
echo 2. Storage
echo 3. Boot
echo 4. About
echo 5. Exit
choice /c 1234 /n
goto %errorlevel%0

:10 Network
%f%dispHead "Network tools"
echo 1. Restart a network adapter %admreq%
echo 2. Reset IP and DNS %admreq%
echo 3. (^<-)
choice /c 123 /n
goto 1%errorlevel%

:13 Go back
goto 00

:11 Restart a network adapter
%f%dispHead "Restart a network adapter"
echo Select the adapter that you want to restart :
echo 1. Wi-Fi
echo 2. Ethernet
echo 3. Other
echo 4. (^<-)
choice /c 1234 /n
goto 11%errorlevel%

:111 Wi-Fi
cls&title T2 - Restarting the "Wi-Fi" network adapter...
echo Restarting the "Wi-Fi" network adapter...
powershell -command "(Restart-NetAdapter -Name "Wi-Fi")"
powershell -command "(Restart-Service WLANSVC -Force)"
echo.&echo [92m[Done][0m
pause
goto 11

:112 Ethernet
cls&title T2 - Restarting the "Ethernet" network adapter...
echo Restarting the "Ethernet" network adapter...
powershell -command "(Restart-NetAdapter -Name "Ethernet")"
powershell -command "(Restart-Service DOT3SVC -Force)"
echo.&echo [92m[Done][0m
pause
goto 11

:113 Other
%f%dispHead "Other network adapter"
echo Type the name of the network adapter that you want to restart :
echo (Enter nothing to go back)&echo.
powershell -command "(Get-NetAdapter -Name * -IncludeHidden| Format-List -Property Name)"|find "Name : "&echo.
set /p "ada=Adapter's name : "
if "%ada%"=="" goto 11

title T2 - Trying to restart the "%ada%" network adapter...&echo.
echo Trying to restart the "%ada%" network adapter...
powershell -command "(Restart-NetAdapter -Name "%ada%")"

::If the first try didn't work, it tries it again but with the first word and add an asterisk
::(also removes hyphens, that may cause a problem, as a byproduct)
if %errorlevel%==1 (
	echo First attempt didn't work, trying workaround...
	set "awa=%ada: =-%"
	for /f "tokens=1 delims=-" %%a in ("%awa%") do set awa=%%a
	title T2 - Trying to restart the "%awa%*" network adapter...
	pause
	powershell -command "(Restart-NetAdapter -Name "%awa%^*")"
	)
echo.&echo [92m[Done][0m
pause
goto 11

:114 Go back
goto 10

:12 Reset IP and DNS
%f%dispHead "Reset IP and DNS"
ipconfig /release
ipconfig /renew
arp -d *
nbtstat -R
nbtstat -RR
ipconfig /flushdns
ipconfig /registerdns
echo.&echo [92m[Done][0m
pause
goto 10

:20 Storage
%f%dispHead "Storage tools"
%f%getFolderSize %temp%
echo 1. Clean %%temp%% (%gfs% bytes)
echo 2. (^<-)
choice /c 12 /n
goto 2%errorlevel%

:21 Clean %temp%
%f%dispHead "Clean %%temp%%"
%f%getFolderSize %temp%
set bef=%gfs%
echo [33m[Deleting][0m
del /f /s /q %temp%\*.*>nul
%f%getFolderSize %temp%
echo.&echo [92m[Done][0m
%f%math %bef%-%gfs%
echo %math% bytes cleared
echo.&pause
goto 20

:22 Go back
goto 00

:30 Boot options
%f%dispHead "Boot options"
echo 1. Reboot to BIOS
echo 2. Reboot to specific UEFI
echo 3. (^<-)
choice /c 123 /n
goto 3%errorlevel%

:31 Reboot to BIOS
%f%dispHead "Reboot to BIOS"
choice /c cr /n /t 10 /d r /m "Your computer will restart automatically in 10 seconds. Press 'C' to cancel."
if %errorlevel%==1 (
	goto 30
) else (
	shutdown /r /fw /t 0
)

:32 Reboot to specific UEFI
%f%dispHead "Reboot to specific UEFI"
echo Copy the identifier of the UEFI entries that you want to reboot to :
echo (Do not include the "{}" of the identifier. Enter nothing to go back)&echo.
echo Available UEFI entries
bcdedit /enum firmware|findstr "desc iden --"
set /p "iden=Identifier : "
if "%iden%"=="" goto 30
bcdedit /enum firmware | findstr /i "{%iden%}" >nul
if %errorlevel%==0 (
    echo Rebooting to {%iden%}...
	choice /c cr /n /t 10 /d r /m "Your computer will restart automatically in 10 seconds. Press 'C' to cancel."
	if %errorlevel%==1 (
		goto 30
	) else (
		bcdedit /bootsequence {%iden%}
		shutdown /r /t 0
	)
) else (
    echo Could not find {%iden%}
	pause
	goto 32
)
goto 30

:33 Go back
goto 00

:40 About
%f%dispHead2 "About" "Troubleshooting Tools"
echo       -About-
echo Location : %0
echo  Made by : Baikil
echo   Github : https://github.com/baikil/t2
echo.
echo 1. Restart as admin
echo 2. (^<-)
choice /c 12 /n
goto 3%errorlevel%

:41 Restart as admin
powershell start -verb runas '%0'&exit/b

:42 Go back
goto 00

:50 Exit
exit

:::::::::::::::
:: Functions ::
:::::::::::::::

:dispHead <Menu name>
cls&title T2 - %~1
echo [1m%~1 (T2)[0m&echo.
exit /b

:dispHead2 <Title name> <Menu name>
cls&title T2 - %~1
echo [1m%~2 (T2)[0m ver.%appv%&echo.
exit /b

:getFolderSize <Path> [->] %gfs%
setlocal enableextensions disabledelayedexpansion
set "target=%~1"
if not defined target set "target=%cd%"
set "size=0"
for /f "tokens=3,5" %%a in ('
dir /a /s /w /-c "%target%"
^| findstr /b /l /c:"  "
') do if "%%b"=="" set "size=%%a"
echo %size%>getFolderSize
endlocal
set /p gfs=<getFolderSize
del getFolderSize
exit /b

:math <Equation> [->] %math%
for /f "tokens=* usebackq" %%M in (`powershell -command "(%~1)"`) do (set math=%%M)
exit /b