# Panorama sobre o docker compose

## Resumo

A ferramenta `compose` é um utilitário para gerenciar múltiplas imagens/containers que precisam ser inicializados e configurados de forma simultânea.

Essa ferramenta utiliza arquivos `.yml` para configuração dos scripts utilizados para manipular o compose.

**Principais aplicações:**
- Preparo de múltiplos containers com configurações individuais
- Simplificação de configurações para cenários complexos
- Abstração de configurações

[Exemplo de uso do docker compose](https://github.com/stallone-dev/DIO-docker-desafio-02)

### Estrutura do utilitário

No shell, se utiliza o comando `docker compose up` para preparar toda a configuração descrita no arquivo `docker-compose.yml` na **pasta atual**.

```bash
# Inicialização do compose nas configurações atuais e envia para 2º plano
docker compose up -d
```

Outros comandos shell importantes são:
- `docker compose stop` -> Irá desligar os containers
- `docker compose down` -> Irá desligar e apagar os containers
- `docker compose top` -> Exibe os processos ativos nos contaiers
- `docker compose stats` -> Exibe o atual uso de recursos do host pelos containers

### Principais configurações do docker-compose.yml

Dentro do arquivo de configurações `docker-compose.yml`, os principais comandos a serem inclusos são:

**services:**
- Discrimina como cada container será nomeado e configurado
- Suporta configurações de ambiente, similar ao `docker container run`

**networks:**
- Prepara configurações de rede
- Similar ao comandos do `docker network`

**volumes:**
- Prepara configurações de armazenamento persistente
- Similar aos comandos do `docker volume`

**secrets:**
- Configura controladores de variáveis de ambiente
- Pode tratar diretamente uma variável ou utilizar um arquivo que as contém

#### Exemplo prático:
```yml
networks:
  test-network:
    driver: bridge

volumes:
  backup-data:
    driver: local

secrets:
  db_password:
    file: db_password.txt

services:
  # MySql
  my-db-sql:
    image: mysql:9.0.1
    environment:
      MYSQL_ROOT_PASSWORD: /run/secrets/db_password
      MYSQL_DATABASE: "testedb"
    secrets:
      - db_password
    ports:
      - 3331:3306
    volumes:
      - backup-data:/var/lib/mysql
    networks:
      - rede-teste
```