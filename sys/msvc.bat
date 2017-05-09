@echo off

rem If LIBPATH is already set (VC Console or whatever) just start the bash script
if defined LIBPATH goto :Bash

:Default
rem Keep this empty if you want the script to autodect the file location
rem Otherwise set your vcvarsall.bat location in this variable
rem set VC_VARS_ALL=C:\VS\VC\vcvarsall.bat
set VC_VARS_ALL=
if ["%VC_VARS_ALL%"] == [""] goto :FindVcVars else goto :SetVars

:FindVcVars
echo VC_VARS_ALL was not set, trying to find its location...
set KEY_NAME="HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\SxS\VS7"
for /F "skip=2 tokens=1,2*" %%A in ('REG QUERY %KEY_NAME% 2^>nul') do (
    set VC_DIR=%%C
)
if ["%VC_DIR%"] == [""] goto :FindFail

:VcVarsDefaults
echo Found VC_DIR location: %VC_DIR%
if exist "%VC_DIR%VC\Auxiliary\Build\vcvarsall.bat" (
    set vcvarsall="%VC_DIR%VC\Auxiliary\Build\vcvarsall.bat"
)
if exist "%VC_DIR%VC\vcvarsall.bat" (
    set vcvarsall="%VC_DIR%VC\vcvarsall.bat"
)
if [%vcvarsall%] == [] (
    goto :FindFail
)
echo Found %vcvarsall%
goto :SetVars

:VcSearch
echo Could not find vcvarsall.bat, making a deeper search...
for /r "%VC_DIR%" %%a in (*) do if "%%~nxa"=="vcvarsall.bat" set vcvarsall=%%~dpnxa
if defined vcvarsall (
    echo Found %vcvarsall% !
) else (
    goto :FindFail
)

:SetVars
echo Setting vars...
call %vcvarsall% x64
set VC_LIB=%LIB%

:Bash
echo Calling script...
PATH=%cd%\sys;C:\cygwin64\bin;%PATH%
bash sys\msvc.sh
goto :End

:FindFail
echo Could not find the vcvarsall.bat location.
echo Maybe are you missing Visual Studio compiler ?
echo Try setting it manually at the beginning of this file.

:End
