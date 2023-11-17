@echo off
::App version
set appv=0.1
::Verify if T2 is has admin privileges and if not, prompt to restart with them
net.exe session 1>NUL 2>NUL || (
	title T2 - WARNING : Not admin
	echo [33m[WARNING][0m[1m T2 is not currently running as admin and some commands might not work[0m
	echo           Do you want to restart it as admin^? [Y/n]
	choice /c yn /n)
if %errorlevel% == 1 (
	powershell start -verb runas '%0'
	exit /b)

:00 Menu
cls&title T2 - Menu
echo [1mTroubleshooting Tools (T2)[0m ver.%appv%&echo.
echo 1. Network
echo 2. More
echo 3. Exit
choice /c 123 /n
goto %errorlevel%0

:10 Network
cls&title T2 - Network tools
echo [1mNetwork tools (T2)[0m&echo.
echo 1. Restart a network adapter
echo 2. Reset IP and DNS
echo 3. (^<-)
choice /c 123 /n
goto 1%errorlevel%

:13 Go back
goto 00

:11 Restart a network adapter
cls&title T2 - Restart a network adapter
echo [1mRestart a network adapter (T2)[0m&echo.
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
echo.&echo [93m[Done][0m
pause
goto 11

:112 Ethernet
cls&title T2 - Restarting the "Ethernet" network adapter...
echo Restarting the "Ethernet" network adapter...
powershell -command "(Restart-NetAdapter -Name "Ethernet")"
echo.&echo [93m[Done][0m
pause
goto 11

:113 Other
cls&title T2 - Other network adapter
echo [1mRestart a network adapter (T2)[0m&echo.
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
echo.&echo [93m[Done][0m
pause
goto 11

:114 Go back
goto 10

:12 Reset IP and DNS
cls&title T2 - Reset IP and DNS
echo [1mReset IP and DNS (T2)[0m&echo.
ipconfig /release
ipconfig /renew
arp -d *
nbtstat -R
nbtstat -RR
ipconfig /flushdns
ipconfig /registerdns
echo.&echo [93m[Done][0m
pause
goto 10

:20 More
cls&title T2 - More
echo [1mTroubleshooting Tools (T2)[0m ver.%appv%&echo.
echo       -About-
echo Location : %0
echo  Made by : Baikil
echo   Github : https://github.com/baikil/t2
echo.
echo 1. Restart as admin
echo 2. (^<-)
choice /c 12 /n
goto 2%errorlevel%

:21 Restart as admin
powershell start -verb runas '%0'&exit/b

:22 Go back
goto 00

:30 Exit
exit