# Runbook — Shadow mode do revisor automático (Plano P3-c)

## Por que isso existe

Um revisor automático que erra muito não é neutro: ele é pior que não ter revisor. A equipe
aprende, em duas semanas, que os comentários dele não valem leitura — e a partir daí ignora
junto os achados que eram verdadeiros. O dano é permanente e difícil de desfazer.

Shadow mode é o período em que o revisor opina **sem autoridade nenhuma**, enquanto a
equipe mede se ele acerta. É o mesmo procedimento que equipes maduras usam: revisor novo
entra comentando para aprovação humana até ser confiável.

## O que já está no repositório

- `.github/workflows/claude-review.yml` — roda em todo PR, comenta inline, **nunca aprova
  nem bloqueia**. Fica inerte enquanto a secret `ANTHROPIC_API_KEY` não existir.
- `.claude/agents/revisor.md` — revisor local, para sessão manual (passo *find*).
- `.claude/agents/verificador.md` — confere os achados do revisor e descarta falso positivo
  (passo *verify*). É este passo que separa revisor útil de gerador de ruído.

## Passo a passo

### Semana 0 — ligar

1. Gerar a chave e configurar a secret `ANTHROPIC_API_KEY` no repositório
   (Settings → Secrets and variables → Actions). Sem isso o workflow roda e sai verde sem
   fazer nada — de propósito.
2. Abrir um PR qualquer e confirmar que o revisor comentou.

### Semanas 1 e 2 — observar sem obedecer

Regra do período: **ninguém é obrigado a agir sobre um comentário do revisor.** Quem abriu
o PR decide, e registra.

Para cada PR, anotar três números numa planilha ou no próprio PR:

| PR | Achados | Reais | Falsos |
|----|---------|-------|--------|

"Real" significa: você teria mudado o código por causa disso se um colega tivesse
apontado. Não é "está tecnicamente correto" — é "valeu a interrupção".

### Fim da semana 2 — decidir com o número na mão

Calcule a taxa de acerto: `reais / achados`.

- **Acima de ~70%** — o revisor entra no fluxo. Os comentários passam a ser respondidos
  (concordando ou discordando por escrito), ainda sem poder bloquear merge.
- **Entre ~40% e 70%** — ajuste antes de promover. O ajuste é quase sempre no contexto, não
  no revisor: o `AGENTS.md` não diz o que o projeto considera erro. Acrescente lá e repita
  uma semana.
- **Abaixo de ~40%** — mantenha em shadow mode e investigue. Revisor ruim nesse nível
  normalmente está revisando sem saber as regras do projeto.

Escreva o número decidido no `AGENTS.md`. Métrica que não fica escrita vira opinião em três
semanas.

## Regra que não muda, mesmo depois de promovido

O revisor **nunca aprova nem bloqueia o PR**. Ele informa; a decisão de merge continua da
pessoa. Isso não é cautela temporária de rollout — é desenho. Quando o número a maximizar
vira "PRs aprovados automaticamente", a revisão deixa de ser revisão.

O sinal de saúde a acompanhar é o oposto do que parece: a **fatia de PRs que recebem
comentário substantivo**. Numa equipe que automatizou bem, esse número **sobe** — na
Anthropic foi de 16% para 54% conforme o volume de código gerado cresceu. Se ele cair
enquanto o volume sobe, a revisão virou carimbo.

## Como reverter

Apague `.github/workflows/claude-review.yml` ou remova a secret. Sem a secret, o workflow
já volta sozinho ao estado inerte.
