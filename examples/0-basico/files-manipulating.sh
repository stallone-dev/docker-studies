#!/bin/sh

# Exemplo de comandos para gestão de arquivos entre HOST e CONTAINER

# Para executar este script, execute:
# chmod u+x files-manipulating.sh
# ./files-manipulating.sh

# -------------------
# VARIÁVEIS PARA ESTE CONTEXTO
IMAGE="alpine"
VERSION="3.17"
CONTAINER_ID="ZIPPER"

FILE="./any.txt"
HOST_FOLDER="/tmp"
# -------------------

# Preparando imagem docker
docker image pull $IMAGE:$VERSION

# Preparando container e capturando a ID dele
docker container run --name=$CONTAINER_ID -dti $IMAGE:$VERSION

# -----------------------------------------
# Criando um arquivo qualquer para exemplo
echo "Hello pos-pandemic world!" >>$FILE
# -----------------------------------------

# Copiando um arquivo para dentro do container
docker container cp $FILE $CONTAINER_ID:/tmp

# Copiando um arquivo de dentro do container para o HOST
docker container cp $CONTAINER_ID:/tmp/$FILE $HOST_FOLDER/$FILE

# -----------------------------------------

# Estes comandos só permitem tratar 1 arquivo p/vez, para copiar um grupo de arquivos é necessário compactá-lo com um ZIP:

# Instalando bibliotecas ZIP no container (alpine)
docker container exec $CONTAINER_ID \
    ash -c "apk --no-cache add zip"

# Preparando arquivos para compactação (HOST)
zip ZIP_NAME.zip $FILE #Cria o zip compactado

# Copiando ZIP para o container
docker container cp ZIP_NAME.zip $CONTAINER_ID:/tmp

# Descompactando ZIP dentro do container
docker container exec $CONTAINER_ID \
    ash -c "unzip /tmp/ZIP_NAME.zip -d /tmp/unziped-folder/"
