# Sobre Logs e Infos

Para coletar informações diversas no Docker, existem 4 comandos principais:

```shell
docker info
# Trará um panorama geral do Docker-engine instalado no Host, com informações importantes como:
# --> Versão do Docker
# --> Imagens e containers (ativos e suspensos)
# --> Consumo de recursos do sistema

docker container logs ${CONTAINER-ID} | (vazio)
# Trará histórico de logs do container
# Se não especificar o container, mostrará um panorama de todos os ativos

docker container top ${CONTAINER-ID}
# Trará lista de processos ativos no container

docker [container | network | volume | ...] inspect ${ID}
# Trará dados detalhados de preparo e execução do elemento sinalizado
```

>[!NOTE] Utilização
> A partir destes dados de logs, processos e infos, é possível rastrear possíveis inconsistências no projeto causadas por má-execução ou algum bug novo
>
> Através do `info` é possível verificar o consumo geral de recursos do docker
>
> Através do `stats` é possível verificar em tempo real o consumo de cad container
>
> Através do `logs` é possível revisar exatamente o que está ocorrendo no container e/ou o que ocorreu
>
> Através do `inspect` é possível revisar ponto-a-ponto da execução de um container, consumo de um volume ou rede