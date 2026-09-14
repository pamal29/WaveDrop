@echo off
REM ===== WavaShare wireless connect helper =====
REM Update PHONE_IP and PHONE_PORT below each time your phone's
REM Wireless Debugging screen shows a new port (the IP usually stays
REM the same as long as you're on the same WiFi network).

set PHONE_IP=192.168.177.215
set PHONE_PORT=43511

echo Connecting to %PHONE_IP%:%PHONE_PORT% ...
adb connect %PHONE_IP%:%PHONE_PORT%

echo.
echo Checking devices...
flutter devices

echo.
echo If your phone shows up above, run:
echo   flutter run -d %PHONE_IP%:%PHONE_PORT%
pause
