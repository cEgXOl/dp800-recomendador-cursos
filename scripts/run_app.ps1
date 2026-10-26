$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot

if (-not $env:COURSE_RECOMMENDER_SQL_CONNECTION_STRING) {
    $env:COURSE_RECOMMENDER_SQL_CONNECTION_STRING = 'Driver={ODBC Driver 18 for SQL Server};Server=localhost\SQLEXPRESS;Database=CourseRecommender;Trusted_Connection=yes;Encrypt=yes;TrustServerCertificate=yes;'
}

$python = Join-Path $projectRoot '.venv\Scripts\python.exe'
if (-not (Test-Path $python)) {
    throw 'No se encuentra .venv. Crea el entorno e instala requirements.txt primero.'
}

Push-Location $projectRoot
try {
    & $python app.py
}
finally {
    Pop-Location
}
