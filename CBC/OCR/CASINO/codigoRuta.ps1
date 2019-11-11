$arg1 = $args[0]


$codigo =$arg1.ToString().substring(0, 4)

$csv = Import-CSV -Path "C:\Aplicaciones\Umango\clientes\casinobsas\Scripts\configuracion1.txt" -Delimiter " "

$csv | ForEach-Object {
    if($codigo -eq $_.codigo) {
        Write-Host $_.ruta
    }
}
