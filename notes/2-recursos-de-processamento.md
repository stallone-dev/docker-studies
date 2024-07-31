# Sobre gestão de recursos no container

### Resumo

> Embora a criação de um container Docker isole ele do restante do sistema, o **uso de recursos** (CPU, memória) do HOST é ilimitado caso não seja configurado.
>
> Para ajustar esse caso, existem as [Políticas de Recursos](https://docs.docker.com/config/containers/resource_constraints/) que limitam o que cada container pode consumir do HOST, configuradas através do `docker container update ${TAGS}`.
>
> Outro aspecto importante é a comunicação entre containers e entre o container e o HOST: deixá-la configurada com o padrão permitirá que qualquer **container acesse outro**, causando furos de segurança.
>
> Existe para tratar disso a ferramenta `docker network`, que cria e gerencia redes isoladas que limitam a comunicação dos containers via TCP/IP.
> 

### Demonstração

```shell
docker network create MY_NETWORK # criando rede isolada

docker container run \ # Inicializa o container
--name CTN_1 \ # ...com nome "CTN_1"
--cpus=0.5 \ # ...com 50% de 1 núcleo de CPU
--memory=300M \ # ...com 300 megabits de RAM
--network MY_NETWORK \ # ...vinculado à rede "MY_NETWORK"
-dti \ # ...em 2º plano com terminal genérico interativo
ubuntu #... a partir da imagem "ubuntu"

docker container run --name CTN_2 -dti ubuntu
docker network connect MY_NETWORK CTN_2 
# Conecta CTN_2 à rede MY_NETWORK
docker container update CTN_2 --cpus=0.3 --memory=200M
# Limita os recursos de CPU para 30% e memória para 200M do CTN_2

docker container run --name FOO --cpus=0.2 --memory=100M -dti ubuntu
# Cria o container "FOO" com 20% de 1 núcleo e 100 megabits de RAM SEM CONEXÃO com a rede MY_NETWORK

docker container exec -ti CTN_1 \
bash -c "yes | (apt update ; apt upgrade ; apt install iputils-ping)"
# Instala a ferramenta de teste rápido de PING no CTN_1

docker network inspect MY_NETWORK
# Recupera informações da rede criada
# ...
# CTN_1 --> IPv4 = 172.19.0.1
# CTN_2 --> IPv4 = 172.19.0.2
# ...

docker network inspect bridge
# Recupera informações da rede padrão de comunicação com HOST
#...
# FOO --> IPv4 = 172.17.0.2
#...

docker container exec -ti CTN_1 \
bash -c "ping 172.19.0.2"
# Testa conexão entre CTN_1 e CTN_2 pela rede TCP/IP
# Esperado:
# 64 bytes from 172.19.0.2: icmp_seq=1 ttl=64 time=0.072 ms

docker container exec -ti CTN_1 \
bash -c "ping 172.17.0.2"
# Testa conexão entre CTN_1 e FOO pela rede TCP/IP
# Esperado:
# (nada)
```

### Conceitos sobre gestão de recursos

Embora o Docker possa criar containers isolados do restante do sistema, por padrão ele **não irá limitar** o consumo de recursos do HOST.

Um container pode sozinho consumir toda memória do HOST, bem como seus processos e seu armazenamento.

Para contonar isso, é possível informar explicitamente quanto dos recursos do HOST estarão disponíveis para cada container Docker, através das configurações do container.

>[!NOTE] Sobre configurações
> Todas as configurações podem ser definidas durante a criação do container em `docker run ${IMAGE}` através das TAGS.
>
> Após a criação do container, é possível atualizá-las pela ferramenta `update`, onde existirão
>
> Ver: [Docker container update](https://docs.docker.com/reference/cli/docker/container/update/)
>
> **Exemplo**: `docker container update -m 800M` #definirá limite de memória RAM para 800 megabits.

No aspecto de **networking**, o Docker permite a criação e gerenciamento de redes internas para agrupamento de containers, com objetivo de isolar a comunicação via TCP/IP entre containers

Para isso, existe a ferramenta `docker network` que visa gerenciar esse aspecto.



#### Configurações de recursos computacionais

É possível configurar rapidamente:
- Disponibilidade de CPU (inclusive %)
- Disponibilidade de memória (RAM, SWAP)
- Regras de reinicialiazação do container

```shell
# Comandos aplicados durante:
docker container update # OU
docker container run

--cpus ${DECIMAL} # Define o % relativo de CPUs que podem ser utilizada
# --> EX: 1.25 = 1 núcleo + 25% do 2ª núcleo

--memory ${INTEGER} # Define a quantidade máxima de memória RAM que o container pode utilizar
# --> EX: 800M = 800 megabits de memória RAM máxima

--memory-swap ${INTEGER} # Define a memória SWAP utilizável
# --> EX: 800M = 800 megabits de memória SWAP disponível

--memory-reservation ${INTEGER} # Define uma reserva de memória que pode ser requisitada pelo sistema para além da pré-alocada
# --> EX: 400M = 400 megabits a mais de memória RAM requisitável caso não esteja em uso

--restart ${RULE} # Define uma política de reboot para o container (ver mais em Restart Policy)
# Regras:
# --> no > Nunca reinicia automaticamente
# --> always > Sempre reinicia caso o container caia (exceto se for parado manualmente)
# --> unless-stopped > Similar ao 'always', porém não reinicia quando o serviço Docker é reinicializado
# --> on-failure:${INT} > Reinicia o container até um certo limite de vezes caso ocorra um erro
# ----> EX: on-failure:3
```

>[!TIP] Exemplos de uso
>```shell
>docker container run --name test --cpus=0.3 --memory=800M --memory-swap=800M --restart=on-failure:3 -d ubuntu
># Inicia um container ubuntu com:
># --> CPU = 30% de 1 núcleo
># --> RAM = 800 megabits
># --> SWAP = 800 megabits
># --> RESTART POLICY = limite de 3 falhas antes do container ser desligado sem retorno
>
>docker container run --name test2 -d ubuntu
>docker container update test2 --cpus=2.9 --memory=3000M --memory-swap=5000M --memory-reservation=500M --restart=on-failure:2
># Atualiza o container "test2" já criado anteriormente, novas regras:
># --> CPU = 2 núcleos + 90% do 3º núcleo
># --> RAM = 3 gigabits
># --> SWAP = 5 gigabits
># --> RESTART POLICY = limite de 2 falhas antes do container ser desligado sem retorno
>```

#### Configurações de recursos de rede

Quanto às redes, é possível configurar redes isoladas para agrupamento de containers.

O objetivo disso é isolar a comunicação entre containers via **protocolo TCP/IP**, de modo a permitir que certos containers se comuniquem entre si, porém não possam acessar outros containers do HOST.

Para isso, se utiliza a ferramenta `docker network`:

```shell
docker network create ${NETWORK-NAME}
# Cria uma nova rede, com máscara de rede própria, em modo bridge

docker network ls 
# Lista as redes existentes no HOST

docker network inspect ${NETWORK-NAME}
# Exibe as informações e configurações da rede especificada

docker network connect ${NETWORK-NAME} ${CONTAINER-ID/NAME}
# Conecta um container a rede especificada, permitindo que o container se comunique com os outros da rede

docker network disconnect ${NETWORK-NAME} ${CONTAINER-ID/NAME}
# Retira da rede o container especificado

docker network rm ${NETWORK-NAME}
# Encerra a rede especificada

docker network prune
# Encerra todas as redes sem containers vinculados

# Configura a rede durante criação do container:
docker container run --network ${NETWORK-NAME} -d ${IMAGE}
# Inicializa o container já vinculado à rede especificada
```

>[!TIP] Exemplo de configuração e uso
>
>```shell
>docker network create MY_NET 
># Criando a nova rede
>
>docker container run --name TEST_1 --network MY_NET -d ubuntu
># Criando um novo container já vinculado à rede MY_NET
>
>docker container run --name TEST_2 -d ubuntu
># Criando um container vinculado somente ao HOST
>
>docker container run --name TEST_3 -d ubuntu
>docker network connect MY_NET TEST_3
># Conectando o container TEST_3 à rede MY_NET
>
>docker network inspect MY_NET
># Verificando containers conectados
># TIP: Verificar máscara IP definida em "IPAM -> config -> subnet"
># TIP2: Observar "Containers -> Name | IPv4Address"
>
>EXEMPLO SUBNET: 172.18.0.0
>--> TEST_1 == 172.18.0.1
>--> TEST_2 == 172.17.0.1 (vinculado somente ao HOST)
>--> TEST_3 == 172.18.0.2
>
>docker container exec -ti TEST_1 bash -c "yes | (apt update ; apt upgrade ; apt install iputils-ping) ; clear ; ping 172.18.0.2" 
># Instalando ferramenta de teste rápido de ping
># Esperado ter retornos de PINGs testando a conexão com o TEST_3
>
>docker container exec -ti TEST_1 bash -c "ping 172.17.0.1"
># Esperado não ter retorno, por falta de conexão com a rede do TEST_2
>```