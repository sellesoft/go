@echo off
REM i run this from go\

ctime -begin misc\go.ctm

pushd src

REM _____________________________________________________________________________________________________
REM                                       Includes/Sources/Libs
REM _____________________________________________________________________________________________________

@set INCLUDES=/I"..\src" /I"..\deshi\src" /I"..\deshi\src\external" /I"C:\src\glfw-3.3.2.bin.WIN64\include" /I"%VULKAN_SDK%\include"
@set SOURCES=..\deshi\src\deshi.cpp go.cpp
@set LIBS=/LIBPATH:C:\src\glfw-3.3.2.bin.WIN64\lib-vc2019 /libpath:%VULKAN_SDK%\lib glfw3.lib opengl32.lib gdi32.lib shell32.lib vulkan-1.lib shaderc_combined.lib

REM _____________________________________________________________________________________________________
REM                                      Compiler and Linker Flags
REM _____________________________________________________________________________________________________

@set WARNINGS=/W1 /wd4201 /wd4100 /wd4189 /wd4706 /wd4311 /wd4552 /wd4553
@set COMPILE_FLAGS=/diagnostics:column /EHsc /nologo /MD /MP /Oi /Gm- /Fm /std:c++17 %WARNINGS%
@set LINK_FLAGS=/nologo /opt:ref
@set OUT_EXE=go.exe

REM _____________________________________________________________________________________________________
REM                                            Defines
REM _____________________________________________________________________________________________________

REM  DESHI_WINDOWS:   build for 64-bit windows
REM  DESHI_MAC:       build for Mac OS X
REM  DESHI_LINUX:     build for Linux
REM  DESHI_SLOW:      slow code allowed (Assert, etc)
REM  DESHI_INTERNAL:  build for developer only (Renderer debug, etc)
REM  DESHI_VULKAN:    build for Vulkan
REM  DESHI_OPENGL:    build for OpenGL
REM  DESHI_DIRECTX12: build for DirectX12

@set DEFINES_DEBUG=/D"DESHI_INTERNAL=1" /D"DESHI_SLOW=1" 
@set DEFINES_RELEASE=
@set DEFINES_OS=/D"DESHI_WINDOWS=1" /D"DESHI_MAC=0" /D"DESHI_LINUX=0" /D"UNICODE=1"
@set DEFINES_RENDERER=/D"DESHI_VULKAN=1" /D"DESHI_OPENGL=0" /D"DESHI_DIRECTX12=0"

REM _____________________________________________________________________________________________________
REM                                    Command Line Arguments
REM _____________________________________________________________________________________________________

IF [%1]==[] GOTO DEBUG
IF [%1]==[-i] GOTO ONE_FILE
IF [%1]==[-l] GOTO LINK_ONLY
IF [%1]==[-r] GOTO RELEASE

REM _____________________________________________________________________________________________________
REM                              DEBUG (compiles without optimization)
REM _____________________________________________________________________________________________________

:DEBUG
ECHO %DATE% %TIME%    Debug
ECHO ---------------------------------
@set OUT_DIR="..\build\debug"
IF NOT EXIST %OUT_DIR% mkdir %OUT_DIR%
cl /Z7 /Od %COMPILE_FLAGS% %DEFINES_DEBUG% %DEFINES_OS% %DEFINES_RENDERER% %INCLUDES% %SOURCES% /Fe%OUT_DIR%/%OUT_EXE% /Fo%OUT_DIR%/ /link %LINK_FLAGS% %LIBS%
GOTO DONE

REM _____________________________________________________________________________________________________
REM    ONE FILE (compiles just one file with debug options, links with previously created .obj files)
REM _____________________________________________________________________________________________________

:ONE_FILE
ECHO %DATE% %TIME%    One File (Debug)
ECHO ---------------------------------
IF [%~2]==[] ECHO "Place the .cpp path after using -i"; GOTO DONE;
ECHO [93mWarning: debugging might not work with one-file compilation[0m

@set OUT_DIR="..\build\debug"
IF NOT EXIST %OUT_DIR% mkdir %OUT_DIR%
cl /c /Z7 %COMPILE_FLAGS% %DEFINES_DEBUG% %DEFINES_OS% %DEFINES_RENDERER% %INCLUDES% %~2 /Fo%OUT_DIR%/
pushd ..\build\Debug
link %LINK_FLAGS% *.obj %LIBS% /OUT:%OUT_EXE% 
popd
GOTO DONE

REM _____________________________________________________________________________________________________
REM                           LINK ONLY (links with previously created .obj files)
REM _____________________________________________________________________________________________________

:LINK_ONLY
ECHO %DATE% %TIME%    Link Only (Debug)
ECHO ---------------------------------
pushd ..\build\debug
link %LINK_FLAGS% *.obj %LIBS% /OUT:%OUT_EXE% 
popd
GOTO DONE

REM _____________________________________________________________________________________________________
REM                                 RELEASE (compiles with optimization)
REM _____________________________________________________________________________________________________

:RELEASE
ECHO %DATE% %TIME%    Release
@set OUT_DIR="..\build\release"
IF NOT EXIST %OUT_DIR% mkdir %OUT_DIR%
cl /O2 %COMPILE_FLAGS% %DEFINES_RELEASE% %DEFINES_OS% %DEFINES_RENDERER% %INCLUDES% %SOURCES% /Fe%OUT_DIR%/%OUT_EXE% /Fo%OUT_DIR%/ /link %LINK_FLAGS% %LIBS%
GOTO DONE

:DONE
ECHO ---------------------------------
popd

ctime -end misc\go.ctm