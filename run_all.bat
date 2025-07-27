@echo off
REM This script runs the entire Groth16 workflow on Windows.
REM It sets the code page to UTF-8 to correctly display special characters.
chcp 65001 > nul

SETLOCAL

REM Define colors for CMD output (won't work in older versions)
powershell -Command "Write-Host ' ' " >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
        set "ESC=%%b"
    )
) else (
    goto :no_color
)

set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "RED=%ESC%[91m"
set "NC=%ESC%[0m"
goto :start

:no_color
set "GREEN="
set "YELLOW="
set "RED="
set "NC="

:start
cls
echo %YELLOW%====================================================%NC%
echo %YELLOW%  Poseidon2 Circom ZK-SNARK Workflow (Windows)      %NC%
echo %YELLOW%====================================================%NC%
echo.

REM Create build directory if it doesn't exist
if not exist build mkdir build

REM Check for the Powers of Tau file
IF NOT EXIST build\pot12_final.ptau (
    echo %RED%错误：缺少可信设置文件！%NC%
    echo.
    echo 请先手动下载 Powers of Tau 文件。
    echo 1. 从以下链接下载:
    echo    %YELLOW%https://storage.googleapis.com/zkevm/ptau/powersOfTau28_hez_final_12.ptau%NC%
    echo 2. 将下载的文件重命名为: %YELLOW%pot12_final.ptau%NC%
    echo 3. 将文件移动到项目下的 `build` 文件夹中。
    echo.
    goto :end
)

echo %GREEN%[OK]%NC% 可信设置文件 'pot12_final.ptau' 已找到。
echo.

echo %YELLOW%[1/5] 正在编译电路...%NC%
call npm run compile
if %errorlevel% neq 0 (
    echo %RED%电路编译失败！%NC%
    goto :end
)
echo %GREEN%电路编译成功！%NC%
echo.

echo %YELLOW%[2/5] 正在执行可信设置...%NC%
call npm run setup
if %errorlevel% neq 0 (
    echo %RED%可信设置失败！%NC%
    goto :end
)
echo %GREEN%可信设置完成！%NC%
echo.

echo %YELLOW%[3/5] 正在生成 Witness...%NC%
call npm run witness
if %errorlevel% neq 0 (
    echo %RED%Witness 生成失败！%NC%
    goto :end
)
echo %GREEN%Witness 生成成功！%NC%
echo.

echo %YELLOW%[4/5] 正在生成证明...%NC%
call npm run prove
if %errorlevel% neq 0 (
    echo %RED%证明生成失败！%NC%
    goto :end
)
echo %GREEN%证明生成成功！%NC%
echo.

echo %YELLOW%[5/5] 正在验证证明...%NC%
call npm run verify >nul
if %errorlevel% neq 0 (
    echo %RED%证明验证失败！%NC%
    echo.
    echo 请检查 'input.json' 中的 'publicHash' 是否与 'preimage' 对应。
    echo 你可以查看 'build\public.json' 文件获取正确的哈希值。
) else (
    echo %GREEN%=========================%NC%
    echo %GREEN%  证明验证成功！OK!   %NC%
    echo %GREEN%=========================%NC%
)
echo.

:end
echo 按任意键退出...
pause > nul