@echo off

IF EXIST build RMDIR /q /s build
IF EXIST "SteelGrapple-#.#.#.zip" DEL "SteelGrapple-#.#.#.zip"
MKDIR build
MKDIR build\SteelGrapple

REM Copy required files into build directory
XCOPY img build\SteelGrapple\img /s /e /i
XCOPY scripts build\SteelGrapple\scripts /s /e /i

REM Zipping contents
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::CreateFromDirectory('build', 'SteelGrapple-#.#.#.zip'); }"

REM Removing build directory
RMDIR /q /s build
