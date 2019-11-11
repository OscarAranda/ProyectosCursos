$arg1 = $args[0]

$nombre = $arg1.ToString().Substring(4, 8)

$numero = [int]$nombre

Write-Host $numero