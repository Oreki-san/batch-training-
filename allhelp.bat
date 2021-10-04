@ECHO OFF
IF "%OS%"=="Windows_NT" SETLOCAL DISABLEDELAYEDEXPANSION
 
:: Version number for this batch file
SET MyVer=1.40
 
:: Display "about"
ECHO.
ECHO AllHelp.bat,  Version %MyVer% for Windows NT 4 / 2000 / XP
ECHO Generate an HTML help file for "all" available commands
ECHO.
ECHO Note:
ECHO This batch file uses the redirected output of the HELP command to generate the
ECHO HTML file. Because some commands use "special" characters like ^&, ^<, and ^> in
ECHO their help screen, not all output is displayed correctly in the browser.
ECHO Known issues: skipped ^<space^> "tag" in CMD's special character list and skipped
ECHO \^<xyz and xyz\^> word position references in FINDSTR's output.
ECHO.
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com
ECHO.
ECHO Improved white space handling by Johan Parlevliet
ECHO Further improvements for NT 4 by Ulf Lindb�ck
ECHO.
ECHO.
ECHO.
 
IF NOT "%OS%"=="Windows_NT" SET MyVer=
IF NOT "%OS%"=="Windows_NT" GOTO End
 
:: Store current code page and then set code page for European languages
FOR /F "tokens=*" %%A IN ('CHCP') DO FOR %%B IN (%%A) DO SET CHCP=%%B
CHCP 1252 >NUL 2>&1
 
:: Start writing HTML file
ECHO Writing HTML header . . .
> allhelp.htm ECHO ^<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"^>
>>allhelp.htm ECHO ^<HTML^>
>>allhelp.htm ECHO ^<HEAD^>
:: Read Windows version using VER command
FOR /F "tokens=1 delims=[" %%A IN ('VER') DO SET Ver=%%A
FOR /F "tokens=1* delims= " %%A IN ('ECHO.%Ver%') DO SET Ver=%%B
:: Read latest Service Pack from registry
CALL :GetSP
>>allhelp.htm ECHO ^<TITLE^>Help for all %Ver%%SP% commands^</TITLE^>
>>allhelp.htm ECHO ^<META NAME="generator" CONTENT="AllHelp.bat, Version %MyVer%, by Rob van der Woude"^>
>>allhelp.htm ECHO ^</HEAD^>
>>allhelp.htm ECHO.
>>allhelp.htm ECHO ^<BODY^>
>>allhelp.htm ECHO.
>>allhelp.htm ECHO ^<A NAME="Top"^>^</A^>
>>allhelp.htm ECHO.
>>allhelp.htm ECHO ^<CENTER^>
>>allhelp.htm ECHO ^<H1^>%Ver%%SP% commands^</H1^>
FOR /F "tokens=* delims=" %%A IN ('VER') DO SET Ver=%%A
>>allhelp.htm ECHO ^<H3^>%Ver%^</H3^>
>>allhelp.htm ECHO ^</CENTER^>
>>allhelp.htm ECHO.
>>allhelp.htm ECHO ^<P^>^&nbsp;^</P^>
>>allhelp.htm ECHO.
 
ECHO Creating command index table . . .
SET FirstCell=1
>>allhelp.htm ECHO ^<TABLE BORDER="0"^>
:: Skip 1 or 2 lines of HELP command's header
FOR /F "tokens=1 delims=[]" %%A IN ('HELP ^| FIND /N "."') DO IF %%A LEQ 2 SET Skip=+%%A
:: MORE's /T switch translates tabs to a fixed number of spaces; tip by Johan Parlevliet
:: In NT 4, MORE's /E switch may be necessary; tip by Ulf Lindb�ck
:: %Skip% skips 1 or 2 lines of HELP command's header
FOR /F "tokens=* delims=" %%A IN ('HELP ^| MORE /E %Skip% /T8') DO CALL :DispLine "%%A"
>>allhelp.htm ECHO ^</TD^>^</TR^>
>>allhelp.htm ECHO ^</TABLE^>
>>allhelp.htm ECHO.
>>allhelp.htm ECHO ^<P^>^&nbsp;^</P^>
>>allhelp.htm ECHO.
 
ECHO Writing help for each command:
:: MORE's /T switch translates tabs to a fixed number of spaces; tip by Johan Parlevliet
:: In NT 4, MORE's /E switch may be necessary; tip by Ulf Lindb�ck
FOR /F "tokens=* delims=" %%A IN ('HELP ^| MORE /E %Skip% /T8') DO CALL :DispFull "%%A"
 
ECHO Closing HTML file
>>allhelp.htm ECHO.
>>allhelp.htm ECHO ^<DIV ALIGN="Center"^>
>>allhelp.htm ECHO ^<P^>This HTML file was generated by:^<BR^>
>>allhelp.htm ECHO ^<B^>AllHelp.bat^</B^>, Version %MyVer%
>>allhelp.htm ECHO for Windows NT^&nbsp;4^&nbsp;/^&nbsp;2000^&nbsp;/^&nbsp;XP^<BR^>
>>allhelp.htm ECHO Written by Rob van der Woude^<BR^>
>>allhelp.htm ECHO ^<A HREF="http://www.robvanderwoude.com"^>http://www.robvanderwoude.com^</A^>^</P^>
>>allhelp.htm ECHO ^</DIV^>
>>allhelp.htm ECHO.
>>allhelp.htm ECHO ^</BODY^>
>>allhelp.htm ECHO ^</HTML^>
 
ECHO.
ECHO An HTML help file "allhelp.htm" has been created and stored in the current
ECHO directory.
ECHO.
ECHO Now starting display of "allhelp.htm" . . .
START "AllHelp" allhelp.htm
 
:: End of main batch program
CHCP %CHCP% >NUL 2>&1
ENDLOCAL
GOTO:EOF
 
 
:: Subroutines
 
 
:DispLine
SET Line=%1
SET Line=%Line:(=^(%
SET Line=%Line:)=^)%
SET Line=%Line:"=%
SET Command=%Line:~0,8%
SET Command=%Command: =%
IF DEFINED Command CALL :DispCmdLine %Command%
FOR /F "tokens=1* delims= " %%a IN ('ECHO.%*') DO SET Descr=%%b
SET Descr=%Descr:"=%
>>allhelp.htm ECHO.%Descr%
GOTO:EOF
 
 
:DispCmdLine
IF "%FirstCell%"=="0" IF DEFINED Command (>>allhelp.htm ECHO ^</TD^>^</TR^>)
SET Command=%1
IF DEFINED Command (>>allhelp.htm ECHO ^<TR^>^<TH ALIGN="left" VALIGN="top"^>^<A HREF="#%Command%"^>%Command%^</A^>^</TH^>^<TD^>^&nbsp;^&nbsp;^&nbsp;^</TD^>^<TD^>)
SET FirstCell=0
SET Command=
GOTO:EOF
 
 
:DispFull
SET Line=%1
SET Command=%Line:~1,8%
SET Command=%Command: =%
IF DEFINED Command CALL :WriteFull %Command%
SET Command=
GOTO:EOF
 
 
:GetSP
SET SP=
:: Export registry tree to temporary file
START /WAIT REGEDIT.EXE /E "%Temp%.\%~n0.dat" "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
IF NOT EXIST "%Temp%.\%~n0.dat" GOTO:EOF
:: Read value of "CSDVersion" from temporary file
FOR /F "tokens=2 delims==" %%A IN ('TYPE "%Temp%.\%~n0.dat" ^| FIND /I "CSDVersion"') DO SET SP=%%~A
:: Check if value is valid
ECHO.%SP% | FIND /I "Service Pack" >NUL
IF ERRORLEVEL 1 SET SP=
DEL "%Temp%.\%~n0.dat"
:: Use a shorter notation
IF DEFINED SP SET SP=%SP:Service Pack=SP%
GOTO:EOF
 
 
:WriteFull
ECHO.  %1 . . .
>>allhelp.htm ECHO.
>>allhelp.htm ECHO ^<A NAME="%~1"^>^</A^>
>>allhelp.htm ECHO.
>>allhelp.htm ECHO ^<H2^>%1^</H2^>
>>allhelp.htm ECHO.
>>allhelp.htm ECHO ^<PRE^>
>>allhelp.htm HELP %1
>>allhelp.htm ECHO ^</PRE^>
>>allhelp.htm ECHO.
>>allhelp.htm ECHO ^<A HREF="#Top"^>Back to the top of this page^</A^>
>>allhelp.htm ECHO.
>>allhelp.htm ECHO ^<P^>^&nbsp;^</P^>
>>allhelp.htm ECHO.
GOTO:EOF
 
:End
