# Sobre gestão de armazenamento com Docker

### Resumo
>
> No Docker o armazenamento, assim como o restante do sistema ,é isolado
>
> É possível redirecionar os arquivos, bem como limitá-los para aacessar apenas com permissões de leitura

### Demonstração:

```shell
docker volume create DATA-DOG
# Cria um volume par aos dados armazenados

docker container run --volume DATA-DOG:/var/lib/mysql -d mysql --name DEMONST
# Ergue um container e vincula o volume 'DATA-DOG' à pasta principal '/var/lib/mysql'

docker container stop DEMONST
# Para a execução do container

docker container rm DEMONST
# Exclui o containe

docker container run --volume DATA-DOT:/var/lib/sql -d msqyl ti
# Reabre um novo container utilizando os mesmos dados do anterio como base

docker volume ls
# LIsta os volumes criados

docker container ls 
# Lista se conseguimos realizar a operação
```

### Conceitos sobre armazenamento

No Docker, o container possui armazenamento próprio através do chamado `mount`

Através do `mount`, é possível conectar diretamente uma pasta/diretório do HOST para outra pasta/diretorio dentro do container

Ex:
`docker container run --volume  DATADOG:var/lib/run -dti ${IMAGE}`

É possível verificar onde os dados estão sendo salvo através do comando `docker container inspect ${CONTAINER-ID}`, na parte de **"mounts"**

>[!TIP] Exemplo
> ```shell
> docker container inspect mysql-guest-01
> "Mounts":

>[!NOTE]logística adm

>shell
>[
>        {
>            "Type": "volume",
>            "Name": "$ UPDATE MANEA}",
>            "Source": "/var/lib/docker/volumes/test_v/_data",
>            "Destination": "/var/lib/mysql",
>            "Driver": "local",
>            "Mode": "z",
>            "RW": true,
>            "Propagation": ""
>        }
>    ],
>    ````   
>     
> # ...
>
> # Este caminho `/var/lib/mysql` indica o local onde os arquivos estão DENTRO do container
> ```

#### Salvando arquivos fora do Container

```shell
docker container run --volume ${ABSOLUTE-HOST-PATH}:${ABSOLUTE-CONTAINER-PATH} -d ${IMAGE}
# Aqui estou redirecionando os arquivos que forem criados em "${ABSOLUTE-CONTAINER-PATH}" para uma pasta deinida no HOST, externo ao container
# EX: docker container run --volume /home/$USER/DOCKER-DATA/guest1:/var/lib/mysql -d mysql
```

#### Tipos de `mounts` 

##### **Bind** -> mameamento direto

Neste tipo de mount é feita a transferência de referencial de dentro do container para fora dele, em um diretório especificado pelo HOST

```shell
docker cotnainer run -v ${HOST-PATH}:${CONTAINER-PATH} -d ${IMAGE} # OU
docker container run --volume=${HOST-PATH}:${CONTAINER-PATH} -d ${IMAGE}
# Mapeamento direto de uma pasta do HOST para uma pasta dentro do container

# Pontos forte: controle manual absoluto
# Pontos fraco: necessário informar caminho absoluto sempre, a partir da raiz "/"
```

>[!TIP] Exemplo de bind
>```shell
>docker container run --volume=/logs/guest-01:/var/lib/mysql -d mysql
># Salva os dados do mysql gerados no container dentro da pasta '/logs/guest-01' do HOST
>```

##### **Named** -> mapeamento pré-alocado

Neste tipo, é criado previamente um diretório externo aos containers e gerenciado pelo Docker

```shell
docker volume create ${VOLUME-NAME}
# Cria uma pasta especial na pasta de instalaçao do DOCKER que pode ser rerenciada diretamente sem informar o caminho absoluto

docker container run --volume=${VOLUME-NAME}:${CONTAINER-PATH} -d ${IMAGE}
# Vincula o volume pré-criado pelo 'docker volume' e recebe nele os dados da pasta do container
```

>[!TIP] Exemplo de uso do 'docker volume' 
>```shell
>docker volume create DATA-LOGS
>docker container run --volume=DATA-LOGS:/var/lib/mysql -d mysql
>#Cria um volume chamado 'DATA-LOGS' e utiliza ele para salvar os arquvos do mysql deste container
>```

#### Detalhes da tag `--mount`

Durante a criação do container, é possível definir várias conexões HOST-CONTAINER através da tag `--mount`: 

```shell
docker container run --mount type=volume, src=${VOLUME}, target=${CONTAINER-PATH} -d ${IMAGE}
# Tags:
# --mount -> Aciona o controlador de volumes
# type= -> Define o tipo de volume esperado (bind, volume, tmpfs)
# src | source= -> Define pasta/volume do HOST
# dst | target= -> Define a pasta dentro do container

docker container run --volume=${VOLUME}:${CONTAINER-PATH}
# Define somente 1 volume vinculado
# Útil para contextos mais simples e isolados
```

>[!NOTE] Sobre o `readonly`
>
> Existe uma tag opcional dentro do `--mount` que aciona o "modo apenas leitura", que limita os poderes do container a apenas ler o que está nos arquivos
> 
>>```shell
>>docker container run --mount type=volume, src=DATA-LOGS, target=/var/lib/mysql, readonly
>># Sinaliza que vai vincular o 'target' ao arquivo definido em 'DATA-LOGS'
>>
>> #Versão resumida:
>> docker run --mount type=volume src=DATA-LOGS, dst=/var/lib/mysql, ro
>>```