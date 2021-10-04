@ECHO OFF
:: Check Windows version
SET Error=This batch file requires Windows XP or later
IF NOT "%OS%"=="Windows_NT" GOTO Syntax
SET Error=
 
SETLOCAL
 
:: Check command line arguments
IF     "%~1"=="" GOTO Syntax
IF NOT "%~2"=="" GOTO Syntax
SET Error=File not found
IF NOT EXIST "%~1" GOTO Syntax
 
:: Check Windows version
SET Error=This batch file requires Windows XP or later
FOR /F "tokens=*" %%A IN ('VER') DO FOR %%B IN (%%~A) DO FOR /F "delims=]" %%C IN ("%%~B") DO SET Ver=%%C
IF %Ver% LEQ 5.1 GOTO Syntax
 
:: Find file type for specified extension
SET Error=No file type is registered for %~x1
SET FileType=
FOR /F "tokens=2*" %%A IN ('REG Query "HKCR\%~x1" /ve 2^>NUL') DO SET FileType=%%B
IF NOT DEFINED FileType GOTO Syntax
:: Remove leading "REG_SZ" if name of default value contains spaces
ECHO.%FileType% | FINDSTR /R /C:"REG.*_SZ" >NUL && FOR /F "tokens=1*" %%A IN ("%FileType%") DO SET FileType=%%B
ECHO.%FileType% | FINDSTR /R /C:"REG.*_SZ" >NUL && FOR /F "tokens=1*" %%A IN ("%FileType%") DO SET FileType=%%B
 
:: Find edit action for that file type
SET Error=No edit action is registered for file type %FileType%
SET Edit=
FOR /F "tokens=*" %%A IN ('REG Query "HKCR\%FileType%\shell" 2^>NUL ^| FIND /I "HKEY_CLASSES_ROOT\%FileType%\shell\edit"') DO SET Edit=%%A
IF NOT DEFINED Edit GOTO Syntax
 
:: Find command for that edit action
SET Error=No command is registered for %Edit% action on %FileType%
SET Command=
FOR /F "tokens=2*" %%A IN ('REG Query "%Edit%\command" /ve 2^>NUL ^| FINDSTR /R /C:"REG.*_SZ"') DO SET Command=%%B
IF NOT DEFINED Command GOTO Syntax
 
:: Remove leading "REG_SZ" if name of default value contains spaces
:: Note: GOTO tries to evade using FOR loops with parenthesis in the command,
:: e.g. "C:\Program Files (x86)\...", which might crash the FOR loop...
ECHO.%Command% | FINDSTR /R /C:"REG.*_SZ" >NUL || GOTO SkipStrip
FOR /F "tokens=1*" %%A IN ("%Command%") DO SET Command=%%B
ECHO.%Command% | FINDSTR /R /C:"REG.*_SZ" >NUL || GOTO SkipStrip
FOR /F "tokens=1*" %%A IN ("%Command%") DO SET Command=%%B
:SkipStrip
 
:: Display and run that command
CALL ECHO %Command%
CALL START "Edit %~nx1" %Command%
 
ENDLOCAL
GOTO:EOF
 
 
:Syntax
IF NOT "%Error%"=="" ECHO.
IF NOT "%Error%"=="" ECHO Error: %Error%
SET Error=
 
ECHO.
ECHO Edit.bat,  Version 1.10 for Windows XP and later
ECHO Open the specified file in the editor registered for its file type
ECHO.
ECHO Usage:  EDIT  filename
ECHO.
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com
 
IF "%OS%"=="Windows_NT" ENDLOCAL
 
