# Panorama sobre o Docker Swarm

## Resumo

### Conceito

Docker Swarm é um utilitário para orquestração de containers em uma rede cluster dentro do host.

Cluster é um conceito ligado ao agrupamento de sistemas (físicos ou virtuais) para realização de uma tarefa, utilizando recursos controlados de cada um deles.

A principal aplicação de um Cluster é a distribuição de carga de uma mesma tarefa, tornando-a mais confiável e escalável pela redudância e paralelismo

>[!info] Swarm na prática
> É um container especial, chamado `gerenciador/maneger` que centralizará os comandos enviados aos demais containers, chamados `trabalhadores/workers`

O papel principal do Swarm é gerenciar e preservar o estado desejado dos containers, realocando-os entre máquinas, "nós do cluster", caso alguma delas caia

O container `maneger` pode também ser um `worker`, desde que hajam outros gerenciadores de backup para preservar o funcionamento caso algo dê errado

Por padrão, caso um `maneger` pare de funcionar e haja backups, é necessário ter ao menos 51% deles funcionando (2 em 3, 3 em 5, 4 em 7), caso conrário o cluster Swarm deixará de operar.
