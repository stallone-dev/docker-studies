# Sobre gestão de armazenamento com Docker

### Resumo
>
> No contexto do Docker, o armazenamento, chamado `mount`, é gerenciado de maneira similar ao container em si: **Isolado e auto-destrutivo**.
>
> Ao excluir o container, ele apagará todos os dados latentes e persistenes internos a ele.
> 
> Para evitar perda de dados, há como redirecionar os arquivos criados e/ou acessar os mesmos arquivos de diferentes máquinas utilizando a tag `--mount`
> 
### Demonstração:

```shell
docker volume create DATA-HOUSE
# Cria um "volume" de memória no HOST que será persistente, equivalente a uma pasta com um link simbólico

docker container run -e MYSQL_ROOT_PASSWORD=senha123 --mount type=volume, src=DATA-HOUSE, target=/var/lib/mysql -d mysql # OU
docker container run -e MYSQL_ROOT_PASSWORD=senha123 --volume DATA-HOUSE:/var/lib/mysql -d mysql
# Vincula os dados INTERNOS criados na pasta "/var/lib/mysql" para o novo endereço EXTERNO "DATA-HOUSE"

# Criando algum dado para teste
docker container exec -ti ${ID} /bin/bash # acesso como root
$ mysql -u root -p --protocol=tcp # Acessa o mysql

mysql> CREATE DATABASE some_data;
mysql> USE some_data;
mysql> CREATE TABLE data(
    -> id int NOT NULL,
    -> name tinytext,
    -> sourname tinytext,
    -> age tinyint(200)
);
mysql> INSERT INTO data (id, name, sourname, age)
    -> VALUES (1, "Stallone", "Souza", 24);
mysql> SELECT * FROM data; # Exibe a tabela criada
# ====================

# Ao ter vinculado o "volume" DATA-HOUSE durante a criação do container, o database MySQL foi criado dentro do HOST, externo ao container

# Reabrindo dados em outro container
docker container stop ${ID}
# Para a execução do container

docker container rm ${ID}
# Exclui o container

docker container run -e MYSQL_ROOT_PASSWORD=senha123 --volume DATA-HOUSE:/var/lib/sql -d mysql --name NEW_SQL
# Cria um novo container MySQL

docker container exec -ti NEW_SQL /bin/bash
$ mysql -u root --password=senha123 --protocol=tcp 
mysql> SHOW DATABASES; # aparecerá na listagem o database some_data, criado no container excluído
mysql> SHOW TABLES; # aparecerá a tabela "data"
mysql> USE some_data;
mysql> SELECT * FROM data;
# | 1 | "Stallone" | "Souza" | 24 | 

# Dessa forma, os dados foram persistidos mesmo após a exclusão do Container original que incializou e populou o database
```

### Conceitos sobre armazenamento

Para gerenciar dados persistentes, o armazenamento do Docker funciona como um container em si mesmo: ele é inicializável e auto-destrutivo caso não seja corretamente configurado.

No Docker, é possível especificar a forma como os dados **internos ao container** serão tratados através da ferramenta `mount`, que terá o propósito de conectar 'canais' entre o container e o contexto externo a ele (host e/ou serviço de armazenamento).

Através do `mount`, é possível conectar uma ou mais pastas do container diretamente para uma ou mais pastas geridas pelo HOST.

Para
Ex:
`docker container run --volume  DATADOG:var/lib/run -dti ${IMAGE}`

É possível verificar onde os dados estão sendo salvo através do comando `docker container inspect ${CONTAINER-ID}`, na parte de **"mounts"**
- **"Source"** -> Local onde os dados estão sendo armazenados no HOST
- **"Destination"** -> Pasta do CONTAINER que está sendo vinculada

>[!TIP] Exemplo
> ```shell
> docker container inspect mysql-guest-01
>
>[
>   ...
>        "Mounts": [
>            {
>                "Type": "volume",
>                "Name": "test_v",
>                "Source": "/var/lib/docker/volumes/test_v/_data",
>                "Destination": "/var/lib/mysql",
>                "Driver": "local",
>                "Mode": "z",
>                "RW": true,
>                "Propagation": ""
>            }
>        ],
>   ...
>],
>
># Este caminho `/var/lib/mysql` indica o local onde os arquivos estão DENTRO do container
> ```

#### Salvando arquivos fora do Container

```shell
docker container run --mount type=${VOLUME-TyPE}, src=${ABSOLUTE-HOST-PATH}, target=${ABSOLUTE-CONTAINER-PATH} -d ${IMAGE}
docker container run --volume ${ABSOLUTE-HOST-PATH}:${ABSOLUTE-CONTAINER-PATH} -d ${IMAGE}
# Aqui os arquivos estão sendo redirecionados para a pasta especificada pelo HOST os arquivos que forem criados em "${ABSOLUTE-CONTAINER-PATH}"
# EX: docker container run --volume /home/$USER/DOCKER-DATA/guest1:/var/lib/mysql -d mysql
```

#### Tipos de volumes no Docker

##### **Bind** -> mameamento direto HOST-CONTAINER

Neste tipo de vinculação é feita a vinculação direta de uma pasta do CONTAINER para uma posta dentro do HOST

```shell
docker cotnainer run --volume=${HOST-PATH}:${CONTAINER-PATH} -d ${IMAGE} # OU
docker container run --mount type=volume, src=${HOST-PATH}, target=${CONTAINER-PATH} -d ${IMAGE}
# Pontos forte: controle manual e preciso do fluxo de dados
# Pontos fraco: necessário informar caminho absoluto sempre, a partir da raiz "/"
```

>[!TIP] Exemplo de bind
>```shell
>docker container run --volume=/logs/guest-01:/var/lib/mysql -d mysql
># Salva os dados gerados no container dentro da pasta '/logs/guest-01' do HOST
>```

##### **Named** -> pré-alocamento de volume especial

Neste tipo, é criado um volume especial dentro do diretório "**volumes**" do Docker para simplificar o caminho fora do container:

```shell
docker volume create ${VOLUME-NAME}
# Cria uma pasta especial que pode ser rerenciada diretamente pelo NOME sem informar o caminho absoluto

docker container run --volume=${VOLUME-NAME}:${CONTAINER-PATH} -d ${IMAGE}
# Vincula o volume criado pelo 'docker volume'
```

>[!TIP] Exemplo de uso do 'docker volume' 
>```shell
>docker volume create DATA-LOGS
>docker container run --volume=DATA-LOGS:/var/lib/mysql -d mysql
>#Cria um volume chamado 'DATA-LOGS' e utiliza ele para salvar os arquivos do mysql do container
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
```

Existe uma tag opcional dentro do `--mount` que aciona o "**modo apenas leitura**", que limita os poderes do container a apenas ler o que está nos arquivos:

```shell
docker container run --mount type=volume, src=DATA-LOGS, target=/var/lib/mysql, readonly
# Sinaliza que vai vincular o 'target' ao arquivo definido em 'DATA-LOGS'

 #Versão resumida:
 docker run --mount type=volume src=DATA-LOGS, dst=/var/lib/mysql, ro
```