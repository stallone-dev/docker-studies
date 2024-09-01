# Básico sobre o Docker

### Resumo
>
> Docker é uma ferramenta de virtualização de ambientes isolados, focada em performance e economia de recursos para execução de softwares.
>
> Através dele é possível construir contextos rigorosamente controlados, chamados `containers`, onde projetos e serviços podem ser hospedados.
>
> O Docker pode ser controlado via `CLI`, através de comandos semânticos como `docker container run` e `docker image pull`, permitindo a rápida assimilação e compreensão do que está sendo comandado.
>

|**EXEMPLO dos conceitos apresentados**|
|:-:|
|[Download de imagens](../examples/0-basico/images.sh)|
|[Preparo de containers](../examples/0-basico/containers.sh)|
|[Manipulando arquivos](../examples/0-basico/files-manipulating.sh)|
|[Gerindo permissões de usuário](../examples/0-basico/permissions.sh)|
|[Gerindo acesso externo](../examples/0-basico/external-access.sh)|

### Conceitos inicais

Docker é uma plataforma de virtualização de visa emular um `SO` leve que seja ao mesmo tempo funcional e isolado do restante do sistema gerenciador.

A principal funcionalidade do Docker é a capacidade de configurar um contexto completo, de forma rápida, consistente e reciplável, ideal para testes e deploy.

_Em analogia, o Docker se comporta como uma "**régua de controle**", estabelecendo critérios rigorosos de recursos, privilégios e funcionalidades disponíveis, independente de qual máquina rode o projeto._

### Instalação

> [!TIP] Script conveniente
> Se o objetivo for uma instalação rápida, sem rodeios, existe o [script conveniente para Ubuntu](https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script) desenvolvido pela própria Docker.
>
> ```shell
> curl -fsSL https://get.docker.com -o get-docker.sh
> sudo sh ./get-docker.sh --dry-run
> ```

>Para instalações mais complexas e detalhadas, é interessante visitar a documentação oficinal da Docker:
https://docs.docker.com/engine/install/

### Docker Hub

No ecossistema Docker, existe um projeto comunitário chamado "[Docker Hub](https://hub.docker.com/)", que visa hospedar imagens prontas ou semi-prontas para construção de containers seguros.

Lá é possível hospedar projetos de forma pública e privada, para compartilhamento de containers de forma segura e centralizada.

>[!TIP] Exemplos:
> [Hello-world - `docker pull hello-world`](https://hub.docker.com/_/hello-world)
> 
> [NodeJS - `docker pull node`](https://hub.docker.com/_/node)
>
> [DenoJS - `docker pull denoland/deno`](https://hub.docker.com/r/denoland/deno)
>
> [Rust - `docker pull rust`](https://hub.docker.com/_/rust)
>
> [Python - `docker pull python`](https://hub.docker.com/_/python)

### Comandos básicos

#### Manipulando de imagens
```shell
docker pull ${IMAGE} # OU
docker image pull ${IMAGE}
# clona imagem do Docker Hub
# EX: docker image pull hello-world

docker ls # OU
docker image ls
# lista as imagens disponíveis no host

docker run ${IMAGE} # OU
docker container run ${IMAGE}
# executa uma imagem e a transforma em um container
# EX: docker container run

docker rmi ${IMAGE} # OU
docker image rm ${IMAGE}
# exclui uma imagem dos arquivos locais
# EX: docker image rm hello-word
# OBS: Caso exista algum container ativo/suspenso que utilize a imagem, ele deverá ser excluido antes da imagem
```

> [!NOTE] Sobre TAGs de imagens
> No Docker Hub a maioria das imagens possuirão **tags** para especificar a versão desejada de determinada imagem/software
> 
> Para aplicá-las, é necessário especificar a tag logo após o nome da imagem, utilizando a flag " `:` "
>
> Exemplos: 
> 
> `docker image pull ubuntu:focal`
> 
> `docker image pull alpine:3.17`
> 
> `docker image pull wordpress:6-php8.1`
>
> Da mesma forma, é necessário indicar a imagem específica para excluí-la do HOST
>
> Ex: `docker image rm alpine:3.17`

#### Manipulando containers

```shell
docker container run ${IMAGE} sleep 10
# Este comando deixará o container "ocioso" por 10 segundos, impossibilitando qualquer interação pelo shell atual
# É possivel parar a execução através do "docker stop"

docker ps # OU
docker container ls
# lista os containers em execução no momento
# OBS: lista somente as imagens em atividade
# Para listar imagens executadas anteriormente, adicionar a tag "-a"
#   -> docker container ls -a

docker stop ${CONTAINER-ID/NAME} # OU
docker container stop ${CONTAINER-ID/NAME}
# Envia um sinal para o container finalizar suas atividades e desligar, equivalente a apertar o botão "suspender" de um sistema qualquer

docker start ${CONTAINER-ID/NAME} # OU
docker container start ${CONTAINER-ID/NAME}
# Reativa um container anteriormente suspendido

docker kill ${CONTAINER-ID/NAME} # OU
docker container kill ${CONTAINER-ID/NAME}
# Envia um sinal para o processo do container ser encerrado de imediato (RISCO DE PERDA DE DADOS)

docker rm ${CONTAINER-ID/NAME} # OU
docker container rm ${CONTAINER-ID/NAME}
# Exclui o container e todas as suas configurações
# OBS: é necessário excluir todos os containers de uma IMAGEM antes de excluir a IMAGEM em si

docker container prune
# Exclui todos os containers inativos
```

>[!NOTE] Interagindo com o container
> É possível interair com um container ao acessá-lo utilizando a tag "`-it`"
>  
>> `-i` --> Modo interativo
>>
>> `-t` --> Ativar pseudo-terminal interno ao container
>>
>> `-it` --> Acionar peuso-terminal e interage com ele

> [!TIP] Exemplo
>
> ```shell
> docker image pull ubuntu # Clonando imagem do ubuntu 
> docker container run -it ubuntu # Criando o container e entrando no terminal dele
> 
> # Neste ponto, já é possível interagir como se estivesse em um ubuntu server
> ```

#### Manipulando execuções contínuas    

De modo geral, a execução contínua de um conteiner é o acionamento dele em **2º plano**, o comando para isso é a tag `-d` associada ao `docker run`:

```shell
docker container run -dti ${IMAGE}
# d --> Enviar para background
# t --> Ativar peuso-terminal no container
# i --> Acionar modo interativo
# dti --> Preparar contexto interativo com terminal + enviar para background 
# (não entra no container imediatamente)
```

A partir deste comando, é necessário usar a tag `exec` para acessar o container:

```shell
docker container exec -it ${CONTAINER-ID/NAME} ${COMMAND}
# Acionar um comando dentro de um container já ativo
# Caso tenha poucos containers, basta indicar os 3 primeiros digitos do ID que ele já acessará

docker container exec ${CONTAINER-ID/NAME} bash -c "${LONG-COMMAND}"
# Utilizar quando for executar uma cadeia longa de comandos, 
# EX: node run --env-file=.env main.js
# --> docker container exec ABC bash-c "node run --env-file=.env main.js"
```
>[!TIP] Exemplo 
>```shell
>docker container run -di ubuntu # Levantando container
># ID: ABC123...
>docker container exec -it  ABC /bin/bash
># Envia um sinal para o container acionar o terminal (bash) e trazê-lo para o nível do usuário
>
># Neste ponto já se está dentro do terminal do container
>```

#### Ajustando acessos ao container

```shell
# Para o contexto do UBUNTU SERVER 
docker container run -di ubuntu

docker container exec ${ID} bash -c "useradd -p ${PASSWORD} -ms /bin/bash ${USER}"
# Cria um novo usuário SEM ACESSO AO SUDO
# para acessar o sudo, adicionar comandos: 
# apt update -y ; apt upgrade -y ; apt install -y sudo
# usermod -aG sudo ${USER}

# por padrão, a imagem do UBUNTU não vem com o comando "sudo" instalado, e nem com os repositórios para instalá-lo, por isso é necessário atualizar tudo e instalar

docker container exec ${ID} bash -c "yes | (apt update ; apt upgrade ; apt install sudo ; apt autoremove) ; useradd -G sudo -p ${PASSWORD} -ms /bin/bash ${USER}"
# versão "expressa" do comando para adicionar usuário com permissão para SUDO

docker container exec --user ${USER} -ti ${ID} ${COMMAND}
# Executa um comando dentro do container através das permissões de outro usuário que não o ROOT

docker container rename ${ID} ${NEW-NAME}
# Renomeia um container para ele ser mais facilmente comandado
```

#### Manipulando arquivos entre Host e Container

```shell
docker cp ${FILE} ${CONTAINER-ID}:/${FOLDER} # OU
docker container cp ${FILE} ${CONTAINER-ID}:/${FOLDER}
# Copia um arquivo do HOST para dentro do CONTAINER-alvo na pasta especificada
# Capaz de copiar somente 1 arquivo p/vez, (recomendado zipar arquivos se for muitos)
# EX: docker container cp MYTEXT.txt ubuntu-ctn:/archive

# Para zipar, pode-se utilizar a biblioteca "zip":
apt install zip
zip NAME.zip files-to-zip.any # Cria arquivo ZIP
unzip NAME.zip -d folder/ # Extrai arquivo ZIP

EX: zip project.zip ./pokedex/{poke-*}.ts
# Zipará todos os arquivos "poke-[qualquercoisa].ts" para dentro do arquivo "project.zip"
EX unzip project.zip -d ./container-project/
# Extrairá todos os arquviso dentro da pasta "container-project"

docker container cp ${CONTAINER-ID}:/${FOLDER} ${HOST-FOLDER}/${NEW-FILE-NAME}
# Copia um arquivo do CONTAINER para o HOST
# EX: docker container cp ubuntu-ctn:/archive/main.any ~/backup/container-main.any
```

#### Acessando um container externamente

Acessar externamente um container envolve expor uma **PORTA** do sistema para controlar outra porta dentro do container, onde existirá o processo em si.

Esse processo é feito através da tag " `-p ${HOST-PORT}:${CONTAINER-PORT}`" durante a criação do container

> [!TIP] Exemplo
>```shell
>docker container run -p 3331:3306 -d mysql
>docker container run --name MYSQL -p 3399:3306 -d mysql
>docker container run --name MYPROJECT -p 4433:3000 -di node:latest
>```

```shell
docker container run -p ${HOST-PORT}:${INTERNAL-PORT} -d ${IMAGE}
# Cria uma imagem em background e expõe a porta ${HOST-PORT} para acessá-la

# EXEMPLO MSQL:
docker container run --name mysql-test -p 4441:3306 -d mysql:latest
# Criará um container MySQL com a porta 3306 (padrão MySQL) acessível através da porta 4441

docker container exec -ti mysql-test bash
# Acessa o bash desse container

$ mysql -u root -p --protocol=tcp
# Comandos:
# -u --> Acessar usuário específico (root no caso)
# -p --> Força pedido de senha para acesso
# --protocol=tcp --> Define protocolo de acesso como TCP

# É possível utilizar o mesmo comando para acessar diretamente o MySQL a partir do HOST, adicionando a tag '-P':
# -P --> Se conecta em uma porta específica
# EX: mysql -u root -p --protocol=tcp -P 4441

>SHOW DATABASES; # Neste ponto já está dentro do MySQL do container 
```