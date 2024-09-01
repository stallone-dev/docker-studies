#!/bin/sh

# Exemplo de comandos para gestão de permissões no container

# Para executar este script, execute:
# chmod u+x permissions.sh
# ./permissions.sh

# -------------------
# VARIÁVEIS PARA ESTE CONTEXTO
IMAGE="ubuntu"
VERSION="focal"
CONTAINER_ID="ROLE_USER"

SHELL_COMMAND="free -ht"
USERNAME="USER123"
PASSWORD="SENHA123"
# -------------------

# Carregando imagem
docker image pull $IMAGE:$VERSION

# Carregando o container
docker container run --name=$CONTAINER_ID -dti $IMAGE:$VERSION

# Criando novo usuário SEM ACESSO AO SUDO
docker container exec $CONTAINER_ID \
    bash -c "useradd -p $PASSWORD \
    -ms /bin/bash $USERNAME"

# OBS: No container UBUNTU, não há o comando "sudo" configurado, portanto é necessário instalá-lo
docker container exec $CONTAINER_ID \
    bash -c "yes | (apt update ; apt upgrade ; apt install sudo ; apt autoremove)"

# Adicionando permissão do comando "sudo" ao usuário pré-existente
docker container exec $CONTAINER_ID \
    bash -c "usermod -aG sudo $USERNAME"

# Executando um comando através das permissões do NOVO USUÁRIO
docker container exec --user=$USERNAME $CONTAINER_ID $SHELL_COMMAND
