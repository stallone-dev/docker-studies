#!/bin/sh

# Exemplo de comandos para controle de containers no Docker Engine

# Para executar este script, execute:
# chmod u+x containers.sh
# ./containers.sh

# -------------------
# VARIÁVEIS DESTE CONTEXTO
IMAGE="alpine"
VERSION="3.17"
CONTAINER_ID="MEMO"

SHELL_COMMAND="free -ht"
# -------------------

# Baixando imagem do Docker Hub
docker image pull $IMAGE:$VERSION

# Executando a imagem de forma persistente e capturando seu ID
docker container run --name=$CONTAINER_ID -dti $IMAGE:$VERSION

# Listando os containers ativos
docker container ls

# Enviando um sinal para desligamento seguro do container (não exclui ele)
docker container stop $CONTAINER_ID

# Enviando um sinal para reativação segura de um container desligado
docker container start $CONTAINER_ID

# Enviando um comando para ser executado dentro do container
# Comando: free (Apresentar consumo de memória do sistema)
docker container exec $CONTAINER_ID $SHELL_COMMAND

# OBS: Se quiser executar um comando mais longo, ou uma cadeia de comandos, pode-se emular a interação direta com um terminal Linux ao substituir o SHELL_COMMAND pelo comando "bash -c", assim, você pode enviar para o SHELL interno do container uma cadeia de comandos.

# OBS2: O container "Alpine", especificamente, substituiu o interpretador "bash" pelo interpretador "ash", visando deixar mais enxuto os binários do sistema.
docker container exec $CONTAINER_ID ash -c "$SHELL_COMMAND"

# Desligando o container à força (RISCO DE PERDA DE DADOS)
docker container kill $CONTAINER_ID

# Excluindo o container (não apaga a imagem baixada, só o container compilado em si)
docker container rm $CONTAINER_ID

# Excluindo todos os containers atualmente desligados
docker container prune
