#Lectura de parametros
$PATHSAVE=$args[0]
$PDFNAME=$args[1]
#Configuraciones carpeta de salida 
$FolderOut="C:\Aplicaciones\Umango\clientes\casinobsas\out\"
#Ubicacion del programa conversor de archivo.
$GS="C:\Aplicaciones\Umango\clientes\casinobsas\Scripts\pdf_to_jpg\bin\gswin32c.exe"
#Configuracion de calidad de img.
$DPI=600
$ALPHABITS=2
$QUALITY=100
$FIRSTPAGE=1
$LASTPAGE=9999
$MEMORY=300
#Muevo el pdf de la ruta raiz a el destino.
$PDF_ACTUAL="$FolderOut$($PDFNAME)"
$PDF_DESTINO="$FolderOut\$($PATHSAVE)\$PDFNAME"
Move-Item -Path $PDF_ACTUAL -Destination $PDF_DESTINO
#Remplazo el nombre del archivo por un jpg
$JPGFILE="$($PDF_DESTINO.replace(".pdf",".jpg"))"
$Argument="-sDEVICE=jpeg -sOutputFile=$($JPGFILE) -r$($DPI) -dNOPAUSE -dFirstPage=$($FIRSTPAGE) -dLastPage=$($LASTPAGE) -dJPEGQ=$($QUALITY) -dGraphicsAlphaBits=$($ALPHABITS)  -dTextAlphaBits=$($ALPHABITS)  -dNumRenderingThreads=4 -dBufferSpace=$($MEMORY)000000  -dBandBufferSpace=$($MEMORY)000000 -c $($MEMORY)000000 setvmthreshold -f $($PDF_DESTINO) -c quit"
#Ejecuto el conversor de pdf con parametros de configuracion
Start-Process $GS -ArgumentList $Argument -NoNewWindow -Wait
#Espero que el programa termine de convertir el archivo pdf a Jpg .
#elimino el archivo pdf.
rm $PDF_DESTINO
