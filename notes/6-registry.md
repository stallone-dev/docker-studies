# Configuração e uso do Docker Registry

Existe uma imagem especial do docker chamada "[Registry](https://hub.docker.com/_/registry)", voltada para armazenamento local de imagens.

A principal finalidade desta imagem é permitir que equipes/pessoas possam armazenar em uma rede local imagens personalizadas e automatizadas.

Principais aplicações:
- Controle e gerenciamento dos projetos em desenvolvimento
- Integração contínua em self-hosteds (CI)
- Finalidades de segurança e backup

### Configuração rápida

```shell
# Carregando imagem do Docker Hub
docker image pull registry:2

# Inicializando container
docker container run \
    --restart=always \
    --name=self_hub2 \
    -p 5411:5000 \
    -d \
    registry:2

# Utilizando container
# Criando uma tag local para a imagem desejada
$ docker image tag $PERSONAL_IMAGE localhost:5411/$PERSONAL_IMAGE 

# enviando a imagem para o registry
$ docker push localhost:5411/$PERSONAL_IMAGE

# Verificando imagnes salvas no servidor
$ curl localhost:5411/v2/_catalog
```

### Detalhes da configuração

Maiores detalhes sobre como personalizar a configuração, hospedar em diferentes Hosts externos e tratar autenticação podem ser encontradas na [documentação oficial do Registry](https://distribution.github.io/distribution/about/configuration/)

Aqui, ficam algumas recomendações para utilizar nesta ferramenta:

```shell
# Separar uma rede e um volume isolados para utilizar neste container
$ docker volume create $REGISTRY_VOLUME
$ docker network create $REGISTRY_NET

# Criar um container configurado por completo
$ docker container run \
    --mount type=volume,src=$REGISTRY_VOLUME,target=/var/lib/registry \
    --network $REGISTRY_NET \
    --name $my_personal_hub \
    -d \
    registry:2

# Restringir recursos computacionais
$ docker container update \
    --cpus=0.3 \
    --memory=300M \
    --memory-swap=600M \
    --memory-reservation=300M \
    --restart=always \
    $my_personal_hub 
```