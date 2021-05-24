[apebs@vm01l-paebs bin]$ vi remessabbcripto1.sh
#!/bin/bash
#
DT=`date +%d%m%y%H%M%S`
DT1=`date +%Y%m%d%H%M%S`
DT2=`date +%d/%m/%Y`
DT3=`date +%H:%M`
FLOG=$APPLCSF/REMESSA/bb/log/remcript_${DT1}.log
DBKP=$APPLCSF/REMESSA/bb/backup
DREM=$APPLCSF/REMESSA/bb
DCRTSMB=$APPLCSF/REMESSA/bb/dcriptsmb
DCRT=$APPLCSF/REMESSA/bb/dcript
DSHL=$XBOL_TOP/bin
HOST=170.66.50.11
BMAIL="Os arquivos de remessa abaixo foram transmitidos com sucesso para o Banco do Brasil em ${DT2} as ${DT3}.\n\n"

_checkfiles() {
x=`du -b "$1" | awk '{ print $1 }'`
sleep 5
y=2
while [ "$x" != "$y" ]
do
y=`du -b "$1" | awk '{ print $1 }'`
sleep 6
x=`du -b "$1" | awk '{ print $1 }'`
done
}

if [ -n "$(ls -A ${DREM}/*.rem 2>/dev/null)" ]
then
echo "ARQUIVOS DE REMESSA ENCONTRADOS" >> $FLOG
else
echo "ARQUIVOS DE REMESSA NAO ENCONTRADOS" >> $FLOG
echo "ARQUIVOS DE REMESSA NAO ENCONTRADOS"
exit 0
fi

r=$(bash -c 'exec 3<> /dev/tcp/'$HOST'/'21';echo $?' 2>/dev/null)
if [ "$r" = "0" ]
then
echo "FTP $HOST OK" >> $FLOG
else
echo "SEM ACESSO AO FTP $HOST" >> $FLOG
echo "SEM ACESSO AO FTP $HOST"
