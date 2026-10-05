param(
    [ValidateSet('Win32', 'Win64')]
    [string]$Platform = 'Win32',
    [string]$StudioRoot = $env:BDS,
    [switch]$SelfTest
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($StudioRoot)) {
    $versions = Get-ChildItem 'HKCU:\Software\Embarcadero\BDS' -ErrorAction SilentlyContinue |
        Sort-Object { [version]$_.PSChildName } -Descending
    foreach ($version in $versions) {
        $installation = Get-ItemProperty -LiteralPath $version.PSPath
        if ($installation.RootDir) {
            $StudioRoot = $installation.RootDir
            break
        }
    }
}
if ([string]::IsNullOrWhiteSpace($StudioRoot)) {
    throw 'Укажите путь к RAD Studio через -StudioRoot или переменную BDS.'
}
$compilerName = if ($Platform -eq 'Win32') { 'dcc32.exe' } else { 'dcc64.exe' }
$compiler = Join-Path $StudioRoot "bin\$compilerName"
if (-not (Test-Path -LiteralPath $compiler)) { throw "Компилятор не найден: $compiler" }
$outputDirectory = Join-Path $PSScriptRoot "$Platform\Debug"
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
Push-Location -LiteralPath $PSScriptRoot
try {
    & $compiler '-B' '-NSSystem;Winapi' "-E$outputDirectory" "-NU$outputDirectory" 'StyleBookDesigner.dpr'
    if ($LASTEXITCODE -ne 0) { throw "Ошибка сборки: $LASTEXITCODE" }
    $executable = Join-Path $outputDirectory 'StyleBookDesigner.exe'
    if ($SelfTest) {
        $resultFile = Join-Path $outputDirectory 'selftest-result.txt'
        if (Test-Path -LiteralPath $resultFile) { Remove-Item -LiteralPath $resultFile }
        $process = Start-Process -FilePath $executable -ArgumentList '-self-test' `
            -WorkingDirectory $PSScriptRoot -WindowStyle Hidden -PassThru
        if (-not $process.WaitForExit(60000)) {
            Stop-Process -Id $process.Id
            throw 'Самопроверка не завершилась за 60 секунд.'
        }
        if ($process.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $resultFile)) {
            if (Test-Path -LiteralPath $resultFile) { Get-Content -LiteralPath $resultFile }
            throw "Ошибка самопроверки: $($process.ExitCode)"
        }
        $result = Get-Content -LiteralPath $resultFile -Raw
        if ($result.Trim() -ne 'PASS') { throw $result }
        Write-Output "Самопроверка ${Platform}: PASS"
    }
    Write-Output "Готово: $executable"
}
finally {
    Pop-Location
}
