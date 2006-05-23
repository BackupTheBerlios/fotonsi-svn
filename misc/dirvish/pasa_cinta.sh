#!/bin/bash  


# Ruta al proceso en ejecución
PROGPATH=`echo $0 | /bin/sed -e 's,[\\/][^\\/][^\\/]*$,,'`

# Revisión del programa en ejecución
REVISION=`echo '$Revision: 1 $' | /bin/sed -e 's/[^0-9.]//g'`
#Donde lo crea OJO BORRATODO
CINTA=/home/copias/cinta
FECHA_COPIA=`date +"%Y%m%d%H%M"`

# Modo de uso
print_usage() {
        echo "Usage: $PROGNAME"
        echo ""
}

# Ayuda
print_help() {
        echo "$PROGNAME: Version $REVISION"
        echo "Crea un subdirectorio en $CINTA y dentro de el pone enlaces simbolicos a los ultimos subdirectorios creados por el dirvish"
        echo ""
        print_usage
}

# Iteramos sobre cada entrada del runall
RAIZ=`cat /etc/dirvish/master.conf | grep -A 1 "bank:" | grep -v "bank:" | awk '{print $1}'`

# Cogemos las entradas de runall y eliminamos los caracteres superfluos ("", :, etc...) de las fechas
RUNALL=`dirvish-runall --no-run | tr " " "." | tr -d "\"" | tr -d ":" |grep -v ".done$"`
#Limpiamos la variable de backup
backupdirs=

echo "`date  +"%Y%m%d-%T"` Sacando de la configurcion del dirvish nuestro plan de trabajo..." >>$CINTA/$FECHA_COPIA.log
# Iteramos sobre cada entrada de runall
for ENTRADA in $RUNALL
do
        # Cliente actual
        CLIENTE=`echo $ENTRADA | cut -f4 -d"."`
        RUTA_ENTRADA="$RAIZ/$CLIENTE"
        # Buscamos el nombre del subdirectroio donde se hizo la copia por ultima vez
	CLIENTE_SUB=`tail -1 $RUTA_ENTRADA/dirvish/daily.hist |awk '{print $1}'`
	#Escribimos lo que vamas a copias
	backupdirs=" $RAIZ/$CLIENTE/$CLIENTE_SUB `echo $backupdirs`"
	echo $RAIZ/$CLIENTE/$CLIENTE_SUB >>$CINTA/$FECHA_COPIA.plan
done

#Para abreviar
backupdirs="$CINTA/$FECHA_COPIA.plan `echo $backupdirs` $CINTA"
#backupdirs="$CINTA/$FECHA_COPIA.plan /home/copias/nagios_all/20060522215000/ /home/copias/svn_all/20060521215000/ $CINTA"
#Resumen de lo que se va a copiar
echo  "`date  +"%Y%m%d-%T"` Se va a copiar:" >>$CINTA/$FECHA_COPIA.log
echo  "`du -csh  $backupdirs`" >>$CINTA/$FECHA_COPIA.log
echo "`date  +"%Y%m%d-%T"` Vamos a rebobinar la cinta para iniciar la copia..." >>$CINTA/$FECHA_COPIA.log
mt-st rewind
echo "`date  +"%Y%m%d-%T"` Cinta rebobinada." >>$CINTA/$FECHA_COPIA.log


for path in $backupdirs
do
    echo "`date  +"%Y%m%d-%T"` Voy a copiar:" $path >>$CINTA/$FECHA_COPIA.log
    tar cf /dev/nst0 $path 1>/dev/null
    echo "`date  +"%Y%m%d-%T"` Copiado:" $path >>$CINTA/$FECHA_COPIA.log
    sleep 2
done

echo "`date  +"%Y%m%d-%T"` Vamos rebobinar la cinta para iniciar la verificacion..." >>$CINTA/$FECHA_COPIA.log
mt-st rewind
echo "`date  +"%Y%m%d-%T"` Cinta rebobinada." >>$CINTA/$FECHA_COPIA.log

for path in $backupdirs
do
    echo "`date  +"%Y%m%d-%T"` Voy a verificar $path..." >>$CINTA/$FECHA_COPIA.log
    if tar tfv /dev/nst0 1>>$CINTA/$FECHA_COPIA.ficheros;  then
      echo "`date  +"%Y%m%d-%T"` Verificado $path..." >>$CINTA/$FECHA_COPIA.log
    else
    	echo "`date  +"%Y%m%d-%T"` Problema verificando en $path..." >>$CINTA/$FECHA_COPIA.log
    	echo "`date  +"%Y%m%d-%T"` Problema verificando en $path..." >>$CINTA/$FECHA_COPIA.err
    fi

    echo "`date  +"%Y%m%d-%T"` Le mando el comando:mt-st fsf 1 ..." >>$CINTA/$FECHA_COPIA.log
    mt-st fsf 1
    echo "`date  +"%Y%m%d-%T"` Mandado el comando:mt-st fsf 1 ..." >>$CINTA/$FECHA_COPIA.log
done

#Enviamos el resultado por correo
mail noc@fundescan.com -s "Resultado del pase a cinta de $FECHA_COPIA" <$CINTA/$FECHA_COPIA.log




