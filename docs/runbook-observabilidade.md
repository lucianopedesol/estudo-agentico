# Runbook — Observabilidade e custo (Plano P5)

## Por que isso existe, e por que agora

Duas razões, e a segunda é a urgente:

1. **Sem número, ganho é anedota.** "Pareceu mais rápido" não sobrevive à primeira pergunta
   de um sócio sobre a conta da API.
2. **Linha de base não se coleta retroativamente.** Se a medição começar depois de
   automatizar o disparo, nunca mais dá para saber o que mudou. Por isso esta fase começa
   **junto com a Fase 1**, não no fim.

Há um motivo concreto para medir estabilidade e não só velocidade: a pesquisa da DORA
mostra que, conforme a adoção de IA cresce, o throughput se recupera mas a **estabilidade
de entrega continua sofrendo**. É o indicador que regride calado.

## O que medir — e o que não medir

Linhas de código e número de PRs medem atividade. Sob agente, os dois sobem por construção
e não dizem nada sobre saúde. As quatro que importam:

| Métrica | Pergunta | Fonte |
|---|---|---|
| Custo por tarefa entregue | Vale a pena? | OTel `claude_code.cost.usage` ÷ PRs mergeados |
| Taxa de aceite do diff | O agente acerta o padrão do projeto? | OTel `claude_code.code_edit_tool.decision` |
| Retrabalho | O PR que ficou verde voltou? | git — commits `fix:`/`revert` |
| Escrutínio | A revisão ainda é revisão? | % de PRs com comentário substantivo |

As duas últimas saem do git e do GitHub, sem infraestrutura nenhuma — é o que o script faz.

## Parte 1 — Métricas de processo (já funciona, custo zero)

```sh
sh scripts/metricas-agentico.sh        # últimos 14 dias
sh scripts/metricas-agentico.sh 30     # últimos 30 dias
```

Requer `gh` autenticado e `jq`. Reporta: PRs mergeados, tempo até merge (mediana e média),
fatia de PRs com comentário/review, tamanho mediano do PR e razão de retrabalho.

**Rode hoje, antes de mexer em mais qualquer coisa.** O número de hoje é a linha de base.
Depois, semanalmente — cinco minutos de sexta-feira.

Sobre duas das saídas:

- **Tamanho mediano do PR** importa porque "trabalhar em lotes pequenos" é uma das sete
  práticas que a DORA associa a ganho real com IA. PR crescendo é sinal de PRD mal quebrada.
- **Razão retrabalho/PR** é o alarme principal. Subindo, o fluxo está entregando rápido e
  errado — exatamente a regressão de estabilidade que a pesquisa prevê.

## Parte 2 — Telemetria do Claude Code (quando houver onde mandar)

O Claude Code exporta OpenTelemetry. Liga-se por variável de ambiente:

```sh
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_RESOURCE_ATTRIBUTES="team.id=frontend"
```

Métricas que respondem às perguntas da tabela acima:

| Métrica | O que é |
|---|---|
| `claude_code.cost.usage` | Custo da sessão, em USD |
| `claude_code.token.usage` | Tokens por tipo (input, output, cache) |
| `claude_code.code_edit_tool.decision` | Aceite/rejeição de Edit, Write |
| `claude_code.pull_request.count` | PRs criados |
| `claude_code.commit.count` | Commits criados |
| `claude_code.active_time.total` | Tempo ativo, separando pessoa e CLI |

Três coisas a saber antes de investir nisso:

- **Isso não entra no `.claude/settings.json` do repositório.** Configuração de telemetria
  em settings de projeto é ignorada de propósito — um repositório não deve poder decidir
  para onde manda dado da máquina de quem o clonou. Vai em `~/.claude/settings.json` ou no
  ambiente.
- **Por padrão prompt, resposta e parâmetro de ferramenta vêm redigidos.** Existem flags
  para abrir (`OTEL_LOG_USER_PROMPTS`, `OTEL_LOG_TOOL_DETAILS`). Com código de cliente em
  jogo, pense duas vezes antes de ligar.
- **As convenções GenAI do OpenTelemetry ainda não estão estáveis.** Mantenha o acoplamento
  raso: um coletor e um painel simples, não um pipeline caro em cima de nomes que mudam.

## Ordem recomendada

1. Rodar o script hoje e guardar a saída (linha de base).
2. Semanalmente, mesma coisa. Quatro semanas = tendência.
3. Só ligar OTel quando as métricas de custo começarem a ser perguntadas — o script já
   responde três das quatro.

## Como reverter

O script não escreve nada, só lê. Telemetria se desliga removendo as variáveis de ambiente.
