#!/bin/sh

# Exemplo de comandos que o usuário realizaria para controlar imagens no Docker Engine

# Para executar este script, execute:
# chmod u+x images.sh
# ./images.sh

# -------------------
# VARIÁVEIS DETES CONTEXTO
IMAGE="hello-word"
VERSION="latest"
# -------------------

## Clonando uma imagem do Docker Hub
docker image pull $IMAGE

## Clonando uma imagem em uma versão específica
docker image pull $IMAGE:$VERSION

## Listando as imagens atuais no compusador
docker image ls

## Executando uma imagem para transformá-la em container
docker container run $IMAGE #Execução simples, sem persistênica

## Excluindo uma imagem do computador
docker image rm $IMAGE:$VERSION
