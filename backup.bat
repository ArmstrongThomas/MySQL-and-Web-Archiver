@echo off
setlocal EnableDelayedExpansion

:: === CONFIGURATION ===
set RETENTION_DAYS=14
set MONTHLY_DAY=26

:: MySQL
set MYSQL_DATABASE=avatar_crusaders
set SQL_CREDS=C:\scripts\conf.cnf

:: Paths
set TEMP_PATH=C:\temp
set SQL_BACKUP_PATH=C:\backup\dev\sql
set WEB_PATH=C:\Apache24\htdocs\websiteYouWantToBackUp
set WEB_BACKUP_PATH=C:\backup\dev\web
set MONTHLY_BACKUP_PATH=C:\backup\dev\monthly
set LOG_PATH=C:\backup\dev\logs
set LOG_FILE=%LOG_PATH%\backup_log.txt

:: Discord webhook (leave empty to disable)
set DISCORD_WEBHOOK=

:: === INIT DIRECTORIES ===
for %%D in ("%TEMP_PATH%" "%SQL_BACKUP_PATH%" "%WEB_BACKUP_PATH%" "%MONTHLY_BACKUP_PATH%" "%LOG_PATH%") do (
    if not exist %%D mkdir %%D
)

:: === TIMESTAMP === 
for /f "tokens=1-4 delims=/ " %%a in ('date /t') do (
    set year=%%d
    set month=%%b
    set day=%%c
)
for /f "tokens=1-2 delims=: " %%a in ('time /t') do (
    set hour=%%a
    set minute=%%b
)
set TIMESTAMP=%year%-%month%-%day%_%hour%-%minute%
call :log "Backup started at !TIMESTAMP!"

:: === SQL BACKUP ===
set SQL_FILENAME=SQL_!MYSQL_DATABASE!_!TIMESTAMP!
set SQL_TEMP=!TEMP_PATH!\!SQL_FILENAME!.sql
set SQL_ZIP=!TEMP_PATH!\!SQL_FILENAME!.7z

mysqldump --defaults-file=%SQL_CREDS% !MYSQL_DATABASE! > "!SQL_TEMP!"
if exist "!SQL_TEMP!" (
    7z a -mx9 "!SQL_ZIP!" "!SQL_TEMP!" >nul
    del "!SQL_TEMP!"
    move /Y "!SQL_ZIP!" "!SQL_BACKUP_PATH!" >nul
    call :getFileSizeMB "!SQL_BACKUP_PATH!\!SQL_FILENAME!.7z" sqlSize
    call :log "SQL backup successful: !SQL_FILENAME!.7z (!sqlSize!)"
    call :notify ":white_check_mark: SQL backup completed: !SQL_FILENAME!.7z (!sqlSize!)"
) else (
    call :log "ERROR: SQL backup failed."
    call :notify ":x: SQL backup FAILED"
)

:: === WEB BACKUP ===
set WEB_FILENAME=WEB_website_!TIMESTAMP!
set WEB_ZIP=!TEMP_PATH!\!WEB_FILENAME!.7z

7z a -mx9 "!WEB_ZIP!" "!WEB_PATH!\*" >nul
if exist "!WEB_ZIP!" (
    move /Y "!WEB_ZIP!" "!WEB_BACKUP_PATH!" >nul
    call :getFileSizeMB "!WEB_BACKUP_PATH!\!WEB_FILENAME!.7z" webSize
    call :log "Web backup successful: !WEB_FILENAME!.7z (!webSize!)"
    call :notify ":white_check_mark: Web backup completed: !WEB_FILENAME!.7z (!webSize!)"
) else (
    call :log "ERROR: Web backup failed."
    call :notify ":x: Web backup FAILED"
)

:: === MONTHLY BACKUP ===
if "!day!"=="%MONTHLY_DAY%" (
    call :log "Monthly backup triggered…"

    set TODAY_SQL=!SQL_BACKUP_PATH!\!SQL_FILENAME!.7z
    set TODAY_WEB=!WEB_BACKUP_PATH!\!WEB_FILENAME!.7z

    if exist "!TODAY_SQL!" if exist "!TODAY_WEB!" (
        set MONTHLY_FILENAME=MONTHLY_Backup_!year!-!month!-!day!
        set MONTHLY_ZIP=!MONTHLY_BACKUP_PATH!\!MONTHLY_FILENAME!.7z

        7z a -mx9 "!MONTHLY_ZIP!" "!TODAY_SQL!" "!TODAY_WEB!" >nul
        call :getFileSizeMB "!MONTHLY_ZIP!" monthlySize
        call :log "Monthly backup created: !MONTHLY_FILENAME!.7z (!monthlySize!)"
        call :notify ":package: Monthly backup created: !MONTHLY_FILENAME!.7z (!monthlySize!)"
    ) else (
        call :log "ERROR: Monthly backup failed—one or both files missing."
        call :notify ":x: Monthly backup FAILED"
    )
) else (
    call :log "Monthly backup skipped (today=!day!, target=%MONTHLY_DAY%)."
)

:: === CLEANUP ===
forfiles /p "%SQL_BACKUP_PATH%" /s /m *.7z /d -%RETENTION_DAYS% /c "cmd /c del @path" >nul
forfiles /p "%WEB_BACKUP_PATH%" /s /m *.7z /d -%RETENTION_DAYS% /c "cmd /c del @path" >nul

call :log "Old backups older than %RETENTION_DAYS% days cleaned."
call :notify ":broom: Cleanup done."

call :log "Backup script completed."
endlocal
exit /b

:: ----------------------------------------------------------------------------
::  Helper Functions
:: ----------------------------------------------------------------------------

:getFileSizeMB
rem %~1=filepath, %~2=out var
for %%F in ("%~1") do set size_bytes=%%~zF
set /a MB=(size_bytes+524288)/1048576, FRAC=(size_bytes*10/1048576)%%10
set "%~2=!MB!.!FRAC! MB"
exit /b

:log
>>"%LOG_FILE%" echo [%date% %time%] %~1
exit /b

:notify
if not defined DISCORD_WEBHOOK exit /b
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"%~1\"}" %DISCORD_WEBHOOK% >nul 2>&1
exit /b
