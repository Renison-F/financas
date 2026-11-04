<#
.SYNOPSIS
  Prepara um PC Windows para desenvolver, compilar, executar e testar o SerenaCash (Flutter).

.DESCRIPTION
  Script idempotente e verificavel. Cada etapa:
    - inspeciona antes de agir e pula o que ja esta correto;
    - pede aprovacao antes de qualquer alteracao (use -AutoApprove para nao perguntar);
    - registra tudo em um log e gera um relatorio final em Markdown.
  Nada e apagado. Nenhum outro projeto ou ferramenta e alterado: so o Flutter em -FlutterDir, variaveis de
  ambiente do USUARIO (Path, ANDROID_HOME, ANDROID_SDK_ROOT) e o clone do SerenaCash em -ProjectDir.

.PARAMETER DownloadsDir   Pasta onde estao o zip do Flutter SDK e o instalador do Android Studio (padrao: E:\).
.PARAMETER FlutterDir     Destino do Flutter SDK (padrao: C:\dev\flutter). Evite espacos e "Program Files".
.PARAMETER ProjectDir     Destino do clone do SerenaCash (padrao: C:\dev\financas).
.PARAMETER Branch         Branch a usar (padrao: refactor/flutter-serenacash).
.PARAMETER OutputDir      Onde copiar o APK e os logs (padrao: E:\SerenaCash).
.PARAMETER DryRun         Apenas mostra o que faria; nao altera nada.
.PARAMETER AutoApprove    Nao pergunta antes de cada etapa.
.PARAMETER SkipEmulator   Nao cria/inicia o emulador.
.PARAMETER ApiLevel       Nivel de API do emulador/plataforma (padrao: 35).

.EXAMPLE
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  .\setup-serenacash.ps1 -DryRun
  .\setup-serenacash.ps1
#>
[CmdletBinding()]
param(
  [string]$DownloadsDir = 'E:\',
  [string]$FlutterDir = 'C:\dev\flutter',
  [string]$ProjectDir = 'C:\dev\financas',
  [string]$Branch = 'refactor/flutter-serenacash',
  [string]$OutputDir = 'E:\SerenaCash',
  [string]$RepoUrl = 'https://github.com/Renison-F/financas.git',
  [int]$ApiLevel = 35,
  [switch]$DryRun,
  [switch]$AutoApprove,
  [switch]$SkipEmulator
)

$ErrorActionPreference = 'Stop'
$script:Results = [ordered]@{}
$script:StartedAt = Get-Date
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }
$script:LogFile = Join-Path $OutputDir ("setup-" + $script:StartedAt.ToString('yyyyMMdd-HHmmss') + ".log")

function Log { param([string]$Message, [string]$Level = 'INFO')
  $line = "[{0}] [{1}] {2}" -f (Get-Date -Format 'HH:mm:ss'), $Level, $Message
  Write-Host $line -ForegroundColor @{INFO='Gray';OK='Green';WARN='Yellow';ERR='Red';STEP='Cyan'}[$Level]
  Add-Content -Path $script:LogFile -Value $line
}
function Step { param([string]$Title) Write-Host ''; Log "== $Title" 'STEP' }
function Result { param([string]$Key, [string]$Value) $script:Results[$Key] = $Value; Log "$Key -> $Value" 'OK' }
function Approve { param([string]$Action)
  if ($DryRun) { Log "DRY-RUN: $Action" 'WARN'; return $false }
  if ($AutoApprove) { return $true }
  $answer = Read-Host "Executar: $Action ? [s/N]"
  return ($answer -match '^[sSyY]')
}
function Run { param([string]$Exe, [string[]]$Args, [string]$WorkDir = $null, [switch]$Capture)
  Log ("> {0} {1}" -f $Exe, ($Args -join ' '))
  if ($DryRun) { return '' }
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = $Exe; $psi.Arguments = ($Args | ForEach-Object { if ($_ -match '\s') { '"' + $_ + '"' } else { $_ } }) -join ' '
  if ($WorkDir) { $psi.WorkingDirectory = $WorkDir }
  $psi.UseShellExecute = $false; $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true
  $p = [System.Diagnostics.Process]::Start($psi)
  $out = $p.StandardOutput.ReadToEnd(); $err = $p.StandardError.ReadToEnd(); $p.WaitForExit()
  Add-Content -Path $script:LogFile -Value $out; if ($err) { Add-Content -Path $script:LogFile -Value $err }
  if (-not $Capture) { Write-Host $out; if ($err) { Write-Host $err -ForegroundColor DarkYellow } }
  if ($p.ExitCode -ne 0) { throw "Comando falhou (exit $($p.ExitCode)): $Exe $($Args -join ' ')`n$err" }
  return $out
}
function Get-UserEnv { param([string]$Name) [Environment]::GetEnvironmentVariable($Name, 'User') }
function Set-UserEnv { param([string]$Name, [string]$Value)
  if ((Get-UserEnv $Name) -eq $Value) { Log "$Name ja esta definido" ; return }
  if (Approve "definir variavel de usuario $Name = $Value") { [Environment]::SetEnvironmentVariable($Name, $Value, 'User'); Set-Item -Path "Env:$Name" -Value $Value; Result $Name $Value }
}
function Add-UserPath { param([string]$Dir)
  $current = Get-UserEnv 'Path'; $parts = @(); if ($current) { $parts = $current -split ';' | Where-Object { $_ } }
  if ($parts -contains $Dir) { Log "PATH ja contem $Dir"; return }
  if (Approve "adicionar ao PATH do usuario: $Dir") {
    [Environment]::SetEnvironmentVariable('Path', (($parts + $Dir) -join ';'), 'User')
    $env:Path = "$env:Path;$Dir"; Result "PATH += $Dir" 'ok'
  }
}

try {
# ---------------------------------------------------------------- 1. Inspecao
Step '1. Inspecao do ambiente'
$os = Get-CimInstance Win32_OperatingSystem
Log ("Windows: {0} build {1}, {2} GB RAM" -f $os.Caption, $os.BuildNumber, [math]::Round($os.TotalVisibleMemorySize/1MB))
if ($os.BuildNumber -lt 19041) { Log 'Flutter exige Windows 10 versao 1903+ (build 18362+).' 'WARN' }
$free = (Get-PSDrive -Name ($FlutterDir.Substring(0,1))).Free / 1GB
Log ("Espaco livre em {0}: {1:N1} GB (recomendado >= 15 GB para SDK + Android)" -f $FlutterDir.Substring(0,2), $free)
if ($free -lt 10) { Log 'Pouco espaco em disco.' 'WARN' }
$existing = @{}
foreach ($tool in 'git','flutter','dart','java','adb','sdkmanager') {
  $cmd = Get-Command $tool -ErrorAction SilentlyContinue
  $existing[$tool] = if ($cmd) { $cmd.Source } else { $null }
  Log ("{0}: {1}" -f $tool, ($(if ($cmd) { $cmd.Source } else { 'nao encontrado no PATH' })))
}
$studioCandidates = @("$env:LOCALAPPDATA\Programs\Android Studio", "$env:ProgramFiles\Android\Android Studio", "${env:ProgramFiles(x86)}\Android\Android Studio")
$studioDir = $studioCandidates | Where-Object { Test-Path (Join-Path $_ 'bin\studio64.exe') } | Select-Object -First 1
Log ("Android Studio: {0}" -f $(if ($studioDir) { $studioDir } else { 'nao instalado' }))
$sdkDir = Get-UserEnv 'ANDROID_HOME'; if (-not $sdkDir) { $sdkDir = $env:ANDROID_HOME }
if (-not $sdkDir -or -not (Test-Path $sdkDir)) { $sdkDir = "$env:LOCALAPPDATA\Android\Sdk" }
Log ("Android SDK: {0} ({1})" -f $sdkDir, $(if (Test-Path $sdkDir) { 'existe' } else { 'ausente' }))
Log ("Downloads: {0}" -f $DownloadsDir)
if (Test-Path $DownloadsDir) { Get-ChildItem $DownloadsDir -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'flutter|android-studio' } | ForEach-Object { Log ("  encontrado: {0} ({1:N0} MB)" -f $_.Name, $_.Length/1MB) } }
Result 'Inspecao' 'concluida'

# ---------------------------------------------------------------- 2. Git (pre-requisito do Flutter)
Step '2. Git'
if (-not $existing['git']) {
  Log 'Flutter exige o Git. Instalar via winget (Git.Git).' 'WARN'
  if (Approve 'instalar Git com winget') { Run 'winget' @('install','--id','Git.Git','-e','--source','winget','--accept-package-agreements','--accept-source-agreements'); $env:Path += ";$env:ProgramFiles\Git\cmd"; Result 'Git' 'instalado' }
} else { Result 'Git' "ja presente: $($existing['git'])" }

# ---------------------------------------------------------------- 3. Flutter SDK
Step '3. Flutter SDK'
$flutterBat = Join-Path $FlutterDir 'bin\flutter.bat'
if ($existing['flutter'] -and -not (Test-Path $flutterBat)) {
  Log "Ja existe um Flutter no PATH em $($existing['flutter']); ele sera usado e o zip nao sera extraido." 'WARN'
  $FlutterDir = Split-Path (Split-Path $existing['flutter'] -Parent) -Parent; $flutterBat = Join-Path $FlutterDir 'bin\flutter.bat'
}
if (-not (Test-Path $flutterBat)) {
  # Pasta ja extraida (E:\flutter ou E:\flutter_windows_<versao>\flutter) tem prioridade sobre o zip: evita extrair 1,9 GB de novo.
  $extracted = @((Join-Path $DownloadsDir 'flutter')) + @(Get-ChildItem $DownloadsDir -Directory -Filter 'flutter_windows_*' -ErrorAction SilentlyContinue | ForEach-Object { Join-Path $_.FullName 'flutter' }) |
    Where-Object { Test-Path (Join-Path $_ 'bin\flutter.bat') } | Select-Object -First 1
  $zip = if ($extracted) { $null } else { Get-ChildItem $DownloadsDir -File -Filter 'flutter_windows_*.zip' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1 }
  if (-not $zip -and -not $extracted) { throw "Nao encontrei flutter_windows_*.zip nem uma pasta flutter\ extraida em $DownloadsDir. Baixe em https://docs.flutter.dev/get-started/install/windows" }
  if (Approve "instalar o Flutter SDK em $FlutterDir a partir de $(if ($zip) { $zip.FullName } else { $extracted })") {
    New-Item -ItemType Directory -Path (Split-Path $FlutterDir -Parent) -Force | Out-Null
    if ($zip) {
      $tmp = Join-Path (Split-Path $FlutterDir -Parent) '_flutter_extract'
      if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
      Log "Extraindo $($zip.Name) (pode levar alguns minutos)..."
      Expand-Archive -Path $zip.FullName -DestinationPath $tmp -Force
      Move-Item (Join-Path $tmp 'flutter') $FlutterDir; Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
    } else { Copy-Item $extracted $FlutterDir -Recurse }
    Result 'Flutter SDK' "instalado em $FlutterDir"
  }
} else { Result 'Flutter SDK' "ja presente em $FlutterDir" }
Add-UserPath (Join-Path $FlutterDir 'bin')
if (-not $DryRun) {
  $ver = Run $flutterBat @('--version') -Capture; Log ($ver.Trim())
  if ($ver -notmatch 'Flutter 3\.(4[7-9]|[5-9]\d)') { Log 'O projeto foi validado com Flutter 3.47.9; versoes mais antigas podem falhar no pub get.' 'WARN' }
  Result 'flutter --version' (($ver -split "`n")[0].Trim())
}

# ---------------------------------------------------------------- 4. Android Studio
Step '4. Android Studio'
if (-not $studioDir) {
  $installer = Get-ChildItem $DownloadsDir -File -Filter 'android-studio-*.exe' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if (-not $installer) { throw "Android Studio nao esta instalado e nao encontrei android-studio-*.exe em $DownloadsDir." }
  if (Approve "executar o instalador $($installer.Name) (modo silencioso /S; instala em C:\Program Files\Android\Android Studio)") {
    Start-Process -FilePath $installer.FullName -ArgumentList '/S' -Wait
    $studioDir = $studioCandidates | Where-Object { Test-Path (Join-Path $_ 'bin\studio64.exe') } | Select-Object -First 1
    if (-not $studioDir) { throw 'Instalador terminou mas o Android Studio nao foi encontrado. Instale manualmente e rode o script de novo.' }
    Result 'Android Studio' "instalado em $studioDir"
  }
} else { Result 'Android Studio' "ja presente em $studioDir" }
$jbr = if ($studioDir) { Join-Path $studioDir 'jbr' } else { $null }
if ($jbr -and (Test-Path $jbr)) { Set-UserEnv 'JAVA_HOME' $jbr } else { Log 'JBR do Android Studio nao encontrado; JAVA_HOME nao alterado.' 'WARN' }

# ---------------------------------------------------------------- 5. Android SDK e componentes
Step '5. Android SDK'
Set-UserEnv 'ANDROID_HOME' $sdkDir
Set-UserEnv 'ANDROID_SDK_ROOT' $sdkDir
$sdkmanager = Get-ChildItem (Join-Path $sdkDir 'cmdline-tools') -Recurse -Filter 'sdkmanager.bat' -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not (Test-Path $sdkDir) -or -not $sdkmanager) {
  Log 'O SDK ainda nao tem as "Android SDK Command-line Tools".' 'WARN'
  Log 'Abra o Android Studio uma vez (assistente inicial instala o SDK), depois: More Actions > SDK Manager > SDK Tools > marque "Android SDK Command-line Tools (latest)" e "Android Emulator" > Apply.' 'WARN'
  Log 'Em seguida rode este script de novo; ele continua de onde parou.' 'WARN'
  if (Approve 'abrir o Android Studio agora') { Start-Process (Join-Path $studioDir 'bin\studio64.exe') }
  Result 'Android SDK' 'pendente: instalar cmdline-tools pelo SDK Manager e rodar o script novamente'
  throw 'Interrompido de proposito: termine a instalacao do SDK no Android Studio e rode o script de novo.'
}
$needed = @('platform-tools', "platforms;android-$ApiLevel", "build-tools;$ApiLevel.0.0", 'emulator', "system-images;android-$ApiLevel;google_apis;x86_64")
$installedList = Run $sdkmanager.FullName @("--sdk_root=$sdkDir", '--list_installed') -Capture
$missing = $needed | Where-Object { $installedList -notmatch [regex]::Escape($_) }
if ($missing.Count -gt 0) {
  Log ("Componentes ausentes: {0}" -f ($missing -join ', '))
  if (Approve ("instalar com sdkmanager: " + ($missing -join ' '))) { Run $sdkmanager.FullName (@("--sdk_root=$sdkDir") + $missing); Result 'SDK componentes' "instalados: $($missing -join ', ')" }
} else { Result 'SDK componentes' 'todos presentes' }
Add-UserPath (Join-Path $sdkDir 'platform-tools')

# ---------------------------------------------------------------- 6. Plugins Flutter e Dart no Android Studio
Step '6. Plugins Flutter/Dart'
$pluginsDir = Get-ChildItem "$env:APPDATA\Google" -Directory -Filter 'AndroidStudio*' -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
$hasFlutterPlugin = $pluginsDir -and (Test-Path (Join-Path $pluginsDir.FullName 'plugins\flutter-intellij'))
$hasDartPlugin = $pluginsDir -and (Test-Path (Join-Path $pluginsDir.FullName 'plugins\Dart'))
if ($hasFlutterPlugin -and $hasDartPlugin) { Result 'Plugins' 'Flutter e Dart ja instalados' }
else {
  Log 'Instalando plugins pela linha de comando do Android Studio (ele precisa estar FECHADO).' 'WARN'
  if (Approve 'instalar plugins Dart e Flutter via "studio64.exe installPlugins"') {
    Run (Join-Path $studioDir 'bin\studio64.exe') @('installPlugins','Dart','io.flutter')
    Result 'Plugins' 'instalados (Dart, io.flutter)'
  } else { Log 'Alternativa manual: Android Studio > Settings > Plugins > Marketplace > "Flutter" (instala o Dart junto).' 'WARN' }
}

# ---------------------------------------------------------------- 7. Licencas
Step '7. Licencas do Android SDK'
Run $flutterBat @('config','--android-sdk', $sdkDir) | Out-Null
if ($studioDir) { Run $flutterBat @('config','--android-studio-dir', $studioDir) | Out-Null }
Log 'As licencas exigem que VOCE leia e responda "y" a cada uma (nao sao aceitas automaticamente).' 'WARN'
if (Approve 'abrir "flutter doctor --android-licenses" para voce aceitar as licencas') {
  & $flutterBat doctor --android-licenses
  Result 'Licencas' 'processo de aceite executado (confira no flutter doctor)'
}

# ---------------------------------------------------------------- 8. flutter doctor
Step '8. flutter doctor -v'
$doctor = Run $flutterBat @('doctor','-v') -Capture; Write-Host $doctor
Set-Content -Path (Join-Path $OutputDir 'flutter-doctor.txt') -Value $doctor
$androidOk = $doctor -match '\[\u221a\] Android toolchain'
Result 'flutter doctor' $(if ($androidOk) { 'Android toolchain OK' } else { 'ver pendencias em flutter-doctor.txt' })
if ($doctor -match 'Visual Studio|Chrome') { Log 'Avisos sobre Visual Studio/Chrome nao afetam o build Android.' }

# ---------------------------------------------------------------- 9. Projeto
Step "9. Projeto SerenaCash ($Branch)"
if (Test-Path (Join-Path $ProjectDir '.git')) {
  if (Approve "atualizar o clone em $ProjectDir (fetch + checkout $Branch + pull)") {
    Run 'git' @('fetch','origin',$Branch) $ProjectDir
    Run 'git' @('checkout',$Branch) $ProjectDir
    Run 'git' @('pull','--ff-only','origin',$Branch) $ProjectDir
    Result 'Projeto' "atualizado em $ProjectDir"
  }
} else {
  if (Approve "clonar $RepoUrl em $ProjectDir") {
    New-Item -ItemType Directory -Path (Split-Path $ProjectDir -Parent) -Force | Out-Null
    Run 'git' @('clone','--branch',$Branch,$RepoUrl,$ProjectDir)
    Result 'Projeto' "clonado em $ProjectDir"
  }
}
$app = Join-Path $ProjectDir 'apps\serenacash_flutter'
if (-not (Test-Path (Join-Path $app 'pubspec.yaml'))) { throw "Projeto Flutter nao encontrado em $app" }
$commit = Run 'git' @('rev-parse','--short','HEAD') $ProjectDir -Capture; Result 'Commit' $commit.Trim()

# ---------------------------------------------------------------- 10. Dependencias e geracao
Step '10. Dependencias e codigo gerado'
Run $flutterBat @('pub','get') $app
Run (Join-Path $FlutterDir 'bin\dart.bat') @('run','build_runner','build','--delete-conflicting-outputs') $app
Run $flutterBat @('gen-l10n') $app
Result 'Dependencias' 'pub get + build_runner + gen-l10n ok'

# ---------------------------------------------------------------- 11. Analise e testes
Step '11. Analise estatica e testes'
$fmt = Run (Join-Path $FlutterDir 'bin\dart.bat') @('format','--set-exit-if-changed','lib','test') $app -Capture; Result 'dart format' 'sem alteracoes'
$an = Run $flutterBat @('analyze','--fatal-infos') $app -Capture; Result 'flutter analyze' (($an -split "`n" | Where-Object { $_ -match 'issues|No issues' } | Select-Object -Last 1).Trim())
$testLog = Join-Path $OutputDir 'flutter-test.txt'
$tests = Run $flutterBat @('test') $app -Capture; Set-Content -Path $testLog -Value $tests
$summary = ($tests -split "`n" | Where-Object { $_ -match 'All tests passed|Some tests failed' } | Select-Object -Last 1).Trim()
Result 'flutter test' "$summary (log: $testLog)"

# ---------------------------------------------------------------- 12. APK
Step '12. flutter build apk --debug'
Run $flutterBat @('build','apk','--debug') $app
$apk = Join-Path $app 'build\app\outputs\flutter-apk\app-debug.apk'
if (-not (Test-Path $apk)) { throw 'APK nao foi gerado.' }
$apkOut = Join-Path $OutputDir ("serenacash-debug-" + $commit.Trim() + ".apk")
Copy-Item $apk $apkOut -Force
$hash = (Get-FileHash $apkOut -Algorithm SHA256).Hash
Result 'APK' ("{0} ({1:N1} MB, SHA-256 {2})" -f $apkOut, (Get-Item $apkOut).Length/1MB, $hash)

# ---------------------------------------------------------------- 13. Emulador
Step '13. Emulador Android'
if ($SkipEmulator) { Result 'Emulador' 'pulado (-SkipEmulator)' }
else {
  $avdmanager = Get-ChildItem (Join-Path $sdkDir 'cmdline-tools') -Recurse -Filter 'avdmanager.bat' | Select-Object -First 1
  $emulatorExe = Join-Path $sdkDir 'emulator\emulator.exe'
  $adb = Join-Path $sdkDir 'platform-tools\adb.exe'
  $avdName = "serenacash_api$ApiLevel"
  $avds = Run $emulatorExe @('-list-avds') -Capture
  if ($avds -notmatch $avdName) {
    if (Approve "criar o AVD $avdName (Pixel 7, API $ApiLevel, x86_64)") {
      $null = "no" | & $avdmanager.FullName create avd -n $avdName -k "system-images;android-$ApiLevel;google_apis;x86_64" -d pixel_7
      Result 'AVD' "criado: $avdName"
    }
  } else { Result 'AVD' "ja existe: $avdName" }
  if (Approve "iniciar o emulador $avdName e instalar o APK") {
    Start-Process $emulatorExe -ArgumentList @('-avd', $avdName, '-no-snapshot-load')
    Log 'Aguardando o emulador iniciar (ate 5 min)...'
    & $adb wait-for-device
    $booted = ''; $tries = 0
    while ($booted.Trim() -ne '1' -and $tries -lt 100) { Start-Sleep 3; $booted = (& $adb shell getprop sys.boot_completed 2>$null); $tries++ }
    if ($booted.Trim() -ne '1') { throw 'Emulador nao terminou o boot. Verifique virtualizacao (Hyper-V/WHPX) nas configuracoes do BIOS/Windows.' }
    Run $adb @('install','-r',$apkOut)
    Run $adb @('shell','am','start','-n','br.com.serenacash.mobile/.MainActivity')
    Result 'Emulador' "$avdName em execucao com o SerenaCash instalado"
    Log "Para desenvolver com hot reload: cd $app ; flutter run" 'OK'
  }
}
} catch {
  Log $_.Exception.Message 'ERR'
  Result 'ERRO' $_.Exception.Message
} finally {
# ---------------------------------------------------------------- 14. Relatorio
$report = Join-Path $OutputDir 'relatorio-setup.md'
$lines = @("# SerenaCash — relatorio de preparacao do ambiente Windows", "", ("Executado em {0} em {1}" -f $script:StartedAt, $env:COMPUTERNAME), "", "| Etapa | Resultado |", "|---|---|")
foreach ($k in $script:Results.Keys) { $lines += ("| {0} | {1} |" -f $k, ($script:Results[$k] -replace '\|','/')) }
$lines += @("", "Log completo: $script:LogFile", "flutter doctor: $(Join-Path $OutputDir 'flutter-doctor.txt')", "Testes: $(Join-Path $OutputDir 'flutter-test.txt')")
Set-Content -Path $report -Value $lines -Encoding UTF8
Write-Host ''; Log "Relatorio: $report" 'STEP'
Get-Content $report | Write-Host
}
