@echo off
set PATH=D:\Dev\Flutter\bin;%PATH%
rmdir /s /q build
xcopy assets\* build\web\* /e /q
flutter build web --wasm
