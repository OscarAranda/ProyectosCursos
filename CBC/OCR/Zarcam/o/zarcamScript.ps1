#carpeta de salida
$folderOut="C:\Users\zadmin\Desktop\Zarcam\out" #modificar
#nporte-ncliente-fecha.
$data=$args[0] -split "-"
#numero de porte.
$nPorte=$data[0]
#numero de cliente.
$nCliente=$data[1]

#fecha
$fecha=$data[2]
$anio=$fecha.ToString().Substring(4,4)
$mes=$fecha.ToString().Substring(2,2)

#$string="$($nCliente) $($nPorte) $($anio)/$($mes)"


 #****Configure SQL***#
 #ip or hostname.
 $hostServer="srv-db00" #modificar
 #database name.
 $userName="cbcgroup"
 $password="CBC$_2019"
 $db="zarcam_dbimplemen" #modificar
 #sql query.
 $query="SELECT replace(rtrim(nombre),' ',CHAR(32)) as nombre FROM clientes where codigo='$($nCliente)'" #modificar

 #**** FUNCTION QUERY TO DATABASE ****#
function Invoke-SQL {
     param(
         [string] $dataSource = $hostServer,
         [string] $database = $db,
         [string] $uid=$userName,
         [string] $pwd=$password,
         [string] $sqlCommand =$query
       )

     $connectionString = "Data Source=$dataSource; User ID = $uid; Password = $pwd;" +
             "Integrated Security=SSPI; " +
             "Initial Catalog=$database"

     $connection = new-object system.data.SqlClient.SQLConnection($connectionString)
     $command = new-object system.data.sqlclient.sqlcommand($sqlCommand,$connection)
     $connection.Open()

     $adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
     $dataset = New-Object System.Data.DataSet
     $adapter.Fill($dataSet) | Out-Null

     $connection.Close()     
     #retorno json
     return  New-CustomObject -DataTable $dataSet[0].Tables[0]  
     

     
    
}

############################# MAIN #############################
$respSql=Invoke-SQL
$empresa=$respSql.nombre; #modificar
#\2019\cliente S.A.\09\00149747.pdf
$path="\$($anio)\$($empresa)\$($mes)"
$fileName="\$($nPorte).pdf"
$pathSave="$($folderOut)$($path)"

$pathExist=Test-Path  $pathSave;
if($pathExist)
{
    #mover
    $carpetaActual="$($folderOut)\$($args[0]).pdf"
    $carpetaDestino="$($pathSave)$($fileName)"    
    Move-Item -Path $carpetaActual -Destination $($carpetaDestino)
}else 
{
    #crear carpeta
    mkdir $pathSave  | Out-Null
    $carpetaActual="$($folderOut)\$($args[0]).pdf"
    $carpetaDestino="$($pathSave)$($fileName)"    
    Move-Item -Path $carpetaActual -Destination $($carpetaDestino)
    
    
    #mover archivo
}