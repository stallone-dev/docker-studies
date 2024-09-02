# Panorama sobre o docker compose

### Resumo

### Demonstração

## Conceitos

A ferramenta `compose` é um utilitário para gerenciar múltiplas imagens/containers que precisam ser inicializados e configurados de forma simultânea.

Essa ferramenta utiliza arquivos `.yml` para configuração dos scripts utilizados para manipular o compose.

**Principais aplicações:**
- Preparo de múltiplos containers com configurações individuais
- Simplificação de configurações para cenários complexos
- Abstração de configurações

### Estrutura do utilitário

No bash, se utiliza o comando `docker compose up` para preparar toda a configuração descrita no arquivo `docker-compose.yml` na **pasta atual**.

```bash
# Inicialização do compose nas configurações atuais e envia para 2º plano
docker compose up -d
```

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

