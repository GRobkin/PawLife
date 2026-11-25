<#
  Crea la clave de firma de PawLife, la carga como secretos de GitHub y muestra
  las huellas que hay que registrar en Firebase. Se corre UNA vez.

  Qué hace:
    1. Crea una clave nueva en %USERPROFILE%\.pawlife-firma\upload.jks. La
       contraseña la elegís vos y no se guarda en ningún archivo.
    2. Sube a los secretos del repositorio lo que el workflow necesita:
       ANDROID_KEYSTORE_BASE64, ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS y
       ANDROID_KEY_PASSWORD. Usa `gh`, que tiene que estar con sesión iniciada.
    3. Imprime el SHA-1 y el SHA-256 para registrarlos en Firebase.

  Antes de correrlo:
    - Tener el JDK 17 (keytool) y la CLI de GitHub (gh) instalados.
    - `gh auth login`, con una cuenta que pueda editar los secretos del repo.

  La clave y su contraseña no se pueden recuperar. Guardá una copia de la
  carpeta .pawlife-firma y de la contraseña fuera de esta PC: si se pierden, las
  versiones ya instaladas no se pueden actualizar.

  Uso:   powershell -ExecutionPolicy Bypass -File tool\configurar-firma.ps1
#>
param(
  [string]$Repo = 'GRobkin/PawLife',
  [string]$Carpeta = (Join-Path $env:USERPROFILE '.pawlife-firma')
)

$ErrorActionPreference = 'Stop'

function Exigir($comando, $ayuda) {
  if (-not (Get-Command $comando -ErrorAction SilentlyContinue)) { throw "No encuentro '$comando'. $ayuda" }
}

Exigir 'keytool' 'Instalá el JDK 17 (el de Android Studio también sirve).'
Exigir 'gh' 'Instalá la CLI de GitHub: https://cli.github.com'

& gh auth status *> $null
if ($LASTEXITCODE -ne 0) { throw "gh no tiene sesión iniciada. Corré 'gh auth login' y volvé a intentar." }

$jks = Join-Path $Carpeta 'upload.jks'
if (Test-Path $jks) {
  throw "Ya existe $jks. No lo piso: si es la clave de siempre, no hace falta correr esto de nuevo."
}

function LeerClave($pregunta) {
  $s = Read-Host $pregunta -AsSecureString
  $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($s)
  try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr) }
  finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }
}

$clave = LeerClave 'Elegí una contraseña para la clave (mínimo 8 caracteres)'
if ($clave.Length -lt 8) { throw 'La contraseña tiene que tener al menos 8 caracteres.' }
if ($clave -ne (LeerClave 'Repetila')) { throw 'Las contraseñas no coinciden.' }

New-Item -ItemType Directory -Force -Path $Carpeta | Out-Null

& keytool -genkeypair -keystore $jks -storetype PKCS12 -alias upload `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -storepass $clave -keypass $clave `
  -dname 'CN=PawLife, O=PawLife, C=UY'
if ($LASTEXITCODE -ne 0) { throw 'keytool no pudo crear la clave.' }

# Las contraseñas entran por la entrada estándar: así no quedan en la línea de comandos.
[Convert]::ToBase64String([IO.File]::ReadAllBytes($jks)) | & gh secret set ANDROID_KEYSTORE_BASE64 --repo $Repo
$clave | & gh secret set ANDROID_KEYSTORE_PASSWORD --repo $Repo
'upload' | & gh secret set ANDROID_KEY_ALIAS --repo $Repo
$clave | & gh secret set ANDROID_KEY_PASSWORD --repo $Repo

$huellas = & keytool -list -v -keystore $jks -alias upload -storepass $clave |
  Select-String -Pattern 'SHA1:|SHA256:' | ForEach-Object { $_.Line.Trim() }
$clave = $null

Write-Host ''
Write-Host 'Listo. Secretos cargados en' $Repo -ForegroundColor Green
Write-Host ''
Write-Host 'Registrá estas huellas en Firebase:' -ForegroundColor Yellow
Write-Host '  Firebase > Configuración del proyecto > Tus apps > Android > Agregar huella digital'
$huellas | ForEach-Object { Write-Host "  $_" }
Write-Host ''
Write-Host "Clave guardada en: $jks"
Write-Host 'Copiala a un lugar seguro junto con la contraseña. Si se pierde, no se puede recuperar.'
