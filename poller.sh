#/bin/bash

FILE=/home/006108r1/moni.txt
IP_NAGIOS="12.85.84.128"
PORTA_NAGIOS="8080"

TMP_FILE=/tmp/.$$.file
TMP_FILE_ALERT=/tmp/.$$.file.alert

MIN_ATUAL=$(date +%M)
MIN_PASSADO=$(date +%M --date='40 min ago')

echo "" > $TMP_FILE
echo "[$(date +%s)] PROCESS_SERVICE_CHECK_RESULT;localhost;poc;2;" > $TMP_FILE_ALERT

function verifica_datasource() {
        MAX=$(echo $1 |awk -F'#' '{print $9}')
        EN_USO=$(echo $1 |awk -F'#' '{print $10}')

        if [ $EN_USO -gt $(( $MAX / 2)) ]; then
                STR=$(echo $i |awk -F"#" '{print $1 " " $6 " " $7 " " $8 " " $10}')
                echo "$STR <br>" >> $TMP_FILE_ALERT
        fi
}

function buscar_datasources() {
        for i in $(seq $MIN_DIFF); do
                STR_BUSCA=$(date +%Y-%m-%dT%H:%M --date="$i min ago")
                grep $STR_BUSCA $FILE |grep "DATASOURCE" |sed 's/ /#/g' >> $TMP_FILE
        done
}

function start() {
        if [ $MIN_ATUAL -lt $MIN_PASSADO ]; then
                MIN_DIFF=$(( $((60 - $MIN_PASSADO)) + $MIN_ATUAL ))
        else
                MIN_DIFF=$(( $MIN_ATUAL - $MIN_PASSADO))
        fi

        buscar_datasources

        for i in $(sort $TMP_FILE |uniq); do
                verifica_datasource $i
        done

        if [ $(grep -v '^$' $TMP_FILE_ALERT |wc -l) -gt 1 ]; then
                STR_RETORNO=$(cat $TMP_FILE_ALERT | sed 's/#/ /g; s/"//g' |tr '\n' ' ')
                #echo ${STR_RETORNO:0:250} |nc $IP_NAGIOS $PORTA_NAGIOS
                echo ${STR_RETORNO:0:250}
        fi

        rm -rf $TMP_FILE $TMP_FILE_ALERT
}

start
