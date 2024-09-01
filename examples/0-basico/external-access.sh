#!/bin/sh

# Exemplo de comandos para criação de um canal de acesso externo ao container

# Para executar este script, execute:
# chmod u+x external-access.sh
# ./external-access.sh

# -------------------
# VARIÁVEIS DESTE CONTEXTO
IMAGE="mysql"
VERSION="9.0.1"
CONTAINER_ID="DATABASE"

HOST_PORT="3333"
# Variáveis específicas da imagem MYSQL
ROOT_PASS="PASS123"
# -------------------

# Preparando imagem
docker image pull $IMAGE:$VERSION

# Preparando container e capturando ID
docker container run \
    --name=$CONTAINER_ID \
    -e MYSQL_ROOT_PASSWORD=$ROOT_PASS \
    -p $HOST_PORT:3306 \
    -d $IMAGE:$VERSION

# Acessando MYSQL diretamente do HOST (com loop de tentativa de acesso)
_STATUS=1
_COUNTER=0
mysql -u root \
    --password=$ROOT_PASS \
    --protocol=tcp \
    -P $HOST_PORT && _STATUS=0

while [ $_STATUS -ne 0 -a $_COUNTER -lt 10 ]; do
    ( (_COUNTER++))
    echo "Trying connection - ($_COUNTER/10)"
    sleep $(expr 5 + $_COUNTER)
    mysql -u root --password=$ROOT_PASS --protocol=tcp -P $HOST_PORT && _STATUS=0
done
