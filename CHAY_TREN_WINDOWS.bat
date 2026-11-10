@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo ===== SMARTTASKS UTH - FLUTTER =====
where flutter >nul 2>nul
if errorlevel 1 (
  echo KHONG TIM THAY FLUTTER. Can cai Flutter SDK va them vao PATH.
  echo Mo terminal thu: flutter doctor
  pause
  exit /b 1
)
echo [1/2] Cai phu thuoc...
call flutter pub get
if errorlevel 1 goto :fail
echo [2/2] Chay tren Google Chrome...
call flutter run -d chrome
if errorlevel 1 goto :fail
exit /b 0
:fail
echo Co loi xay ra. Hay xem thong bao o tren.
pause
exit /b 1
