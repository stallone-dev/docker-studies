# Panorama sobre o Dockerfile

### Resumo

> Através do DOCKERFILE é possível automatizar o processo de preparo e utilização de containers, tornando simples o processo de replicação.
>
> Para melhorar o fluxo de integração contínua (CI) é possível utilizar o DOCKERFILE para criar containers intermediários, voltados para compilação de `source codes` em binários executáveis
>
> Ao término da configuração do DOCKERFILE, utiliza-se o comando: `docker image build . -t ${NAME}` para construir localmente a imagem, permitindo uso dos demais comandos como `docker container run`

### Demonstração

```shell
# Será criado um binário executável DENOJS e transferido para um container Debian para ser executado

$ APP=project_deno ; mkdir $APP ; cd $APP
$ echo "console.log('Hello, nice to meet you!')" > main.ts
$ nano dockerfile

# Contexto --> dentro do DOCKERFILE
#==================================
FROM denoland/deno:debian-1.45.5 AS step_1

WORKDIR /app

COPY main.ts .

RUN apt update -y ; apt install -y unzip ; apt clean ; deno compile -o exec ./main.ts

# Container final
FROM ubuntu:24.10

ENV BASE_DIR="/opt/production"

WORKDIR $BASE_DIR

COPY --from=step_1 /app/exec .

RUN chmod -R 755 $BASE_DIR ; echo -e "\n"

ENTRYPOINT ./exec

#==================================

$ docker image build . -t deno_binary_image
$ docker container run --name test_deno --rm deno_binary_image
# Resultado esperado:
# >
# > Hello, nice to meet you!
```

### Sobre automação do Docker

O processo de criar e preparar um container manualmente é interessante e útil para estudos e projetos pessoais, porém, para uso profissional e Integração Contínua (CI) é necessário que haja doses de automação no processo.

O Docker, além das ferramentas de isolamento e manipulação de containers, fornece também uma poderosa ferramenta de **building**, que permite configurar e replicar rapidamente configurações complexas de um container.

Essas ferramentas são:

```shell
docker build ${DOCKERFILE}
# Compilador que executará um dockerfile e gerará uma imagem local no processo

dockerfile
# Arquivo padrão para configurações de uma imagem a partir de comandos e outras bases
```

### Sobre o Dockerfile

Para utilizar o `docker build`, é preciso primeiro ter um `dockerfile` configurado.

**Dockerfile** é uma abstração de scripts internos do Docker-engine, utilizado para simplificar o preparo de imagens locais e/ou privadas, útil também para integração contínua em processos.

> [!TIP] Referências
> No próprio docker.com pode-se encontrar detalhes sobre o [funcionamento e configuração do dockerfile](https://docs.docker.com/reference/dockerfile/)

Para utilizá-lo, basta criar um arquivo chamado `dockerfile` na pasta-raiz do projeto, e trabalhá-lo com os comandos abaixo:

```shell
FROM ${IMAGE}
# Define a imabem-base que o container utilizará, útil para preparo de certos tipos de binários executáveis

RUN ${SHELL-COMMAND}
# Executará um comando dentro do container, útil para coisas como: atualização de pacotes e preparo de configurações internas do SO

WORKDIR ${PATH}
# Cria e acessa uma pasta onde os demais comandos serão executados dentro do container

COPY ${HOST-FILE-PATH} ${CONTAINER-PATH}
# Copiará um único arquivo do HOST para dentro do container

ADD ${FILES-PATH} ${CONTAINER-PATH}
# Similiar ao COPY, porém permitindo operçaões complexas com múltiplos arquivos, origem fora do host e acessos SSH 

ENTRYPOINT ${SHELL-COMMAND}
# Comando principal que será executado ao inicializar um container a partir da imagem gerada

CMD ${SHELL-COMMAND}
# Comando auxiliar que pode ser acionado durante a execução de um container a partir da imagem gerada

ENV ${KEY}=${VALUE}
# Criará e/ou alterará variáveis de ambiente dentro do contexto do container

EXPOSE ${PORT}
# Indicará uma porta que poderá ser usada para se conectar dentro do container

VOLUME ${VOLUME-NAME}
# Criará pontos de conexão de dados para melhor trabalho com databases externos ao container 

USER ${USER-NAME}
# Altera o usuário (e privilégios) que serão utilizados dentro do container durante a execução (útil para configurações de privilégio)

LABEL ${KEY}=${VALUE}
# Adicionará metadados ao dockerfile, facilitando identificação de informações úteis como licenças, autoria, versão e descrição
```

> [!NOTE] Exemplo de Dockerfile
>```shell
># Definição da imagem-base do projeto
>FROM ubuntu:24.10
>
># Descrições auxiliares para metadados
>LABEL author="Stallone L.S."
>LABEL version="0.1.0"
>LABEL description="Demo dockerfile for Python development"
>
># Definição das variáveis de ambiente
>ENV MAIN_DIR=/opt/app
>
># Comando interno ao container a ser executado
>RUN yes | (apt-get update ; apt-get install python3 ; apt-get autoremove) ; apt-get clean
>
># Definição do volume indicado para conexão de dados
>VOLUME $MAIN_DIR/database
>
># Definição e acesso do diretório principal a ser utilizado
>WORKDIR $MAIN_DIR/src
># OBS: Equivalente ao comando "mkdir $MAIN_DIR/src ; cd $MAIN_DIR/scr"
>
># Copia arquivo do host para o diretório
>COPY ./main.py .
>
># Define o comando a ser executado quando o container for inicializado
>ENTRYPOINT python3 ./main.py
>```
>
> Agora, criando uma imagem e container:
> 
> ```shell
> docker build . -t image_test
> docker image ls
> # Deverá mostrar a imagem_test disponível
>
> docker container run --name TEST -ti image_test
> # Deverá acionar diretametne o comando do ENTRYPOINT
> ```