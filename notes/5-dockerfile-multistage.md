# Imagens Docker MULTISTAGE

Ao criar imagens a partir de outras imagens, logo se percebe o aumento rápido do consumo de armazenamento do host.

Utilizar imagens-base robustas é útil para estudos e compilação de binários, porém para transmissão e execução nem tanto.

Para lidar com esse problema, existe o conceito de `multistage` dentro do Dockerfile, que significa:
- Criação de containers **intermediários temporários**
- Transferência de arquivos e configurações entre containers temporários
- Preparo rápido de ambiente

Para tanto, basta adicionar novos `FROM ${image} e RUN` antes da definição do ENTRYPOINT, que deverá ficar sempre ao final da imagem.

```shell
# Tags opcionais importantes para este processo:

FROM image AS $NAME # Reserva um nome-ID de acesso rapido ao container

COPY --from=$NAME path/to/file # Acessará os arquivos do container anterior
```

### Demonstração no Dockerfile:

```shell
# Prepara container DenoJS temporário
FROM denoland/deno:1.45.5 AS container_step1

WORKDIR /app

COPY main.ts .

# Compila o source code em um executável linux
RUN apt-get update -y ; 
    apt-get install -y zip ; 
    deno compile -o exec --target=x86_64-unknown-linux-gnu main.ts

# Cria novo container ubuntu
FROM ubuntu:24.10

WORKDIR /opt/app

# Recupera o binário executável do container anterior
COPY --from=container_step1 /app/prod_exec .

RUN chmod -R 755 /opt/app

ENTRYPOINT ./prod_exec
```

 Com isso, ao executar o container desta imagem, ele executará o binário gerado pelo container intermediário DENO:

 ```shell
 # Compilando dockerfile
 docker image build . -t deno_image

 docker container run --rm -ti deno_image
 ```