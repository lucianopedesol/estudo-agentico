# Arquitetura agentic de referência — alvo, mercado e caminho de adoção

Documento de arquitetura para a equipe (3 devs React). Desenha a arquitetura-alvo **do zero**, mostra o que o mercado está de fato fazendo em outubro de 2026, e mede a distância entre o alvo e o laboratório atual (`estudo-agentico`).

Companheiro de `desenvolvimento-agentic-guia.md`, que registra o passo a passo já executado. Este aqui é o mapa de para onde ir.

---

## 1. O que o mercado está fazendo (estado em out/2026)

### 1.1 Os harnesses se dividiram em quatro famílias

| Família | Ferramentas | Para que serve |
|---|---|---|
| CLI / terminal | Claude Code, Codex CLI, Cline, Warp | Autonomia alta, sessões longas, integração com CI e scripts |
| IDE nativo | Cursor, Windsurf, Antigravity, JetBrains Junie | Supervisão linha a linha, ciclo curto, bom para quem está aprendendo o fluxo |
| PR / revisão | Copilot coding agent + Agent HQ, Claude Code Review, CodeRabbit, Greptile | Revisão automática do diff, sem humano abrindo sessão |
| Builders de app | Replit Agent, Bolt, Lovable | Protótipo descartável, fora do fluxo de produção |

Internamente quase todos têm a mesma anatomia: **planner → tool runner → verifier**, exposta como modo Plan / modo Act. A diferença entre eles é menos "qualidade do modelo" e mais **que fronteiras o harness consegue impor** e **onde ele roda**.

### 1.2 Três convergências que já se consolidaram

**`AGENTS.md` virou o formato de regras versionadas.** Arquivo em git, agnóstico de ferramenta, lido por Cursor, Codex, Copilot e companhia. O GitHub o adotou formalmente no Agent HQ como o lugar de "set clear rules and guardrails". Para quem usa mais de um harness — e a equipe usa Cursor e Claude Code — manter regra só no `CLAUDE.md` significa que metade das sessões roda sem regra nenhuma.

**O plano de controle saiu do IDE.** O GitHub Agent HQ é um "mission control" único: agentes da Anthropic, OpenAI, Google, Cognition e xAI atribuídos em paralelo, acompanhados de VS Code, mobile ou CLI; *branch controls* para decidir quando o CI roda em código de agente; camada de governança com política de segurança, audit log e dashboard de métricas. O Linear e o Jira foram pelo mesmo caminho: você atribui a issue a `@Cursor` ou ao Copilot e o agente volta com o PR; a Cursor usa regra de triagem automática para mandar bug de produto direto ao agente.

**Spec-driven development virou disciplina formal.** Spec Kit (GitHub), Kiro (AWS), OpenSpec, Tessl — todos com o mesmo pipeline: *constitution → specify → plan → tasks → implement*, com critérios de aceite em notação EARS, spec de 1 a 3 páginas e **out-of-scope explícito**. Os modos de falha catalogados são exatamente os que uma PRD solta produz: *specification drift* em sessão longa, *scope creep*, spec grande demais para caber no contexto, e o mais caro de todos — implementar uma spec errada com perfeição.

### 1.3 Verificação é onde as empresas sérias estão investindo

O padrão que emergiu não é "um agente revisa". É um pipeline de quatro passos, que é o que a Anthropic roda no Code Review: **find** (vários agentes leem o diff em paralelo, cada um com seu próprio contexto) → **verify** (um passo separado confere cada achado contra o código e descarta falso positivo) → **rank** (dedup e severidade) → **post** (comentário inline + check run). Detalhe de desenho importante: **a revisão nunca aprova nem bloqueia o PR** — ela informa, e a decisão de merge continua do time.

Três práticas que acompanham isso:

- **Shadow mode**: revisor novo entra comentando sem autoridade até ser confiável; e é testado com mudanças deliberadamente maliciosas.
- **Tiering de risco**: código regulado ou crítico exige revisão humana sempre; o resto é amostrado.
- **Testes invariantes** ("usuário A nunca lê dado do usuário B") que, quando tocados, forçam revisão humana independentemente do resto.

### 1.4 Isolamento: a fronteira saiu do prompt e foi para o SO

A tese que o mercado adotou: pedir aprovação a cada comando produz *approval fatigue* — a pessoa para de ler o que aprova. A alternativa é dar liberdade dentro de uma fronteira que o sistema operacional impõe.

No Claude Code isso é o sandbox do Bash: isolamento de **filesystem** (escreve só no diretório de trabalho) + isolamento de **rede** (sem rota direta; todo tráfego passa por um proxy local que confere o host contra uma allowlist que **começa vazia**), aplicados via bubblewrap no Linux e seatbelt no macOS, cobrindo subprocessos. Como o SO aplica, o agente pode rodar comando sem perguntar. O Codex usa sandbox por tarefa; o Claude Code na web roda cada sessão em sandbox de nuvem onde as credenciais de git nem entram — um proxy assina a operação do lado de fora.

**Pegadinha direta para a equipe:** o sandbox roda em macOS, Linux e WSL2. **No Windows nativo o Claude Code roda sem sandbox.** Num time que trabalha em Windows, essa camada só existe se as sessões rodarem dentro do WSL2.

### 1.5 Observabilidade: existe, e quase ninguém liga

O Claude Code exporta OpenTelemetry com métricas que respondem as perguntas que a liderança faz: `claude_code.cost.usage` (USD), `claude_code.token.usage`, `claude_code.lines_of_code.count`, `claude_code.commit.count`, `claude_code.pull_request.count`, `claude_code.code_edit_tool.decision` (quanto do que o agente propõe é aceito ou rejeitado) e `claude_code.active_time.total`. Liga-se com `CLAUDE_CODE_ENABLE_TELEMETRY=1` + um endpoint OTLP, e dá para fatiar por time com `OTEL_RESOURCE_ATTRIBUTES`. As convenções GenAI do OpenTelemetry ainda não estão estáveis, então o acoplamento deve ser raso.

### 1.6 Os números que importam para decidir

**Teto do que é possível** — Anthropic, sobre o próprio SDLC: Claude escreve ~80% do código mergeado; mais da metade é mergeada pelo agente interno; engenheiros entregam em média 8x mais código por trimestre do que no período 2021-2025. E o número mais revelador do conjunto: a fatia de PRs que recebem **comentário substantivo de revisão subiu de 16% para 54%**. Mais código automatizado veio junto com *mais* escrutínio, não menos.

**Teto do que é realista hoje** — relatório de tendências da Anthropic (2026): devs usam IA em ~60% do trabalho, mas conseguem **delegar totalmente apenas 0-20% das tarefas**; ~27% do trabalho assistido por IA é trabalho que não teria sido feito de outro jeito. Rakuten rodou Claude Code por 7 horas autônomas num caso; TELUS reporta 30% mais rápido em código de engenharia.

**O contrapeso** — DORA: adoção de IA entre devs subiu de 76% (2024) para 90% (2025); mais de 80% relatam mais produtividade. Mas na medição de 2024, cada +25% de adoção de IA se associou a **-1,5% de throughput e -7,2% de estabilidade de entrega**. Em 2025 o throughput se recuperou; **a estabilidade ainda não**. A confiança declarada nos outputs caiu de 87,9% para 70% — recalibragem saudável. A conclusão da DORA é a frase que deve guiar o rollout: *IA amplifica o que a organização já é*. As sete práticas que separam quem ganha de quem piora: postura declarada sobre IA, ecossistema de dados saudável, dados internos acessíveis, **controle de versão forte**, **lotes pequenos**, foco no usuário e plataforma interna de qualidade.

**A lição de incidente mais útil do ano** (Anthropic): um agente pediu a outro agente, via Slack, que desse push no código. Foi barrado no portão humano. A conclusão que eles tiraram — e que vale copiar inteira — é **desenhar as fronteiras em torno de acesso e de ações, não em torno das instruções dadas ao modelo**.

---

## 2. Arquitetura-alvo

Desenhada do zero, em sete planos. Cada plano responde a uma pergunta diferente, e cada um falha de um jeito diferente.

```
                         ┌───────────────────────────────────────┐
  P0  CONTRATO           │ AGENTS.md (constituição)              │
      o que é verdade    │ PRD em EARS · 1-3 páginas             │
                         │ out-of-scope · arquivos permitidos    │
                         └───────────────┬───────────────────────┘
                                         │
                         ┌───────────────▼───────────────────────┐
  P1  CONTROLE           │ de onde o trabalho entra e quem        │
      quem dispara       │ pode disparar: issue/board/push/cron   │
                         │ + planejador (quebra em PRDs atômicas) │
                         └───────────────┬───────────────────────┘
                                         │
                         ┌───────────────▼───────────────────────┐
  P2  EXECUÇÃO           │ ambiente descartável por tarefa        │
      onde roda          │ sandbox FS+rede  |  job de CI isolado  │
                         │ 1 tarefa = 1 branch = 1 ambiente       │
                         └───────────────┬───────────────────────┘
                                         │
                         ┌───────────────▼───────────────────────┐
  P3  VERIFICAÇÃO        │ a) auto-verificação (loop do agente)   │
      o que substitui    │ b) portão determinístico (CI)          │
      o dev olhando      │ c) revisor IA independente (find→      │
                         │    verify→rank→post, shadow mode)      │
                         │ d) humano por tier de risco            │
                         └───────────────┬───────────────────────┘
                                         │
                         ┌───────────────▼───────────────────────┐
  P4  ENTREGA            │ preview por PR · main protegida ·      │
                         │ prod só após CI verde · rollback       │
                         └───────────────┬───────────────────────┘
                                         │
                         ┌───────────────▼───────────────────────┐
  P5  OBSERVABILIDADE    │ custo/tarefa · aceite vs rejeição ·    │
                         │ retrabalho · falha pós-deploy          │
                         └───────────────┬───────────────────────┘
                                         │
                         ┌───────────────▼───────────────────────┐
  P6  GOVERNANÇA         │ erro recorrente → vira regra em P0     │
      o loop de volta    │ shadow mode · amostragem · log         │
                         └────────────────────────────────────────┘
```

### P0 — Contrato: a spec é a interface

**Princípio:** o agente não erra por falta de inteligência, erra por falta de contrato. O custo de uma spec ruim é implementação perfeita da coisa errada.

Dois artefatos:

- **Constituição** (`AGENTS.md`, espelhado para o harness que precisar): stack, convenções, comandos, definição de pronto, o que exige aprovação humana. Estático, muda devagar, lido em toda sessão — logo, curto.
- **PRD por unidade de trabalho**, com quatro seções que não são negociáveis: critérios de aceite verificáveis (EARS — "Quando X, o sistema deve Y"), **fora de escopo explícito**, **arquivos que esta PRD pode tocar** (é isso que torna duas PRDs paralelizáveis sem conflito), e definição de pronto.

**Decisão sua:** quem escreve a PRD. O caminho que escala é o dev escrever o pedido bruto e um subagente planejador converter em PRDs atômicas — que é exatamente o que o `planejador.md` já faz no laboratório. Falta o formato de saída ser verificável.

### P1 — Controle: onde o trabalho entra

Quatro portas possíveis, em ordem de maturidade:

1. Humano abre sessão e acompanha (nível 1 — já rodando)
2. Push em `prds/*.md` dispara o agente, que abre PR (nível 2 — implementado, desativado)
3. Issue/card atribuído ao agente dispara (nível 3 — padrão Linear/Jira do mercado)
4. Wave: vários cards em paralelo, um job isolado por card (Caminho B — implementado, modo simulado)

**O controle que falta em todos eles é o mesmo: quem pode disparar.** O `claude-code-action` já traz isso de fábrica — exige **write access** no repositório do ator que dispara e **rejeita ator bot** por padrão, justamente para evitar loop de agente chamando agente. Em pipeline caseiro, essa checagem é sua.

### P2 — Execução: um ambiente descartável por tarefa

**Princípio:** a unidade de isolamento é a tarefa, não a máquina. Duas tarefas nunca compartilham diretório de trabalho.

Três implementações, e a escolha é por escala:

| | Isolamento | Escala | Classe de problema |
|---|---|---|---|
| `git worktree` | diretório separado, mesmo `.git` | 2-3 agentes, uma máquina | caminho absoluto não portável entre contextos |
| Job de CI (matrix) | VM limpa por job | dezenas de cards, time inteiro | permissões do Actions, reentrância entre execuções |
| Sandbox do harness | FS + rede impostos pelo SO | ortogonal — vale nos dois | não existe em Windows nativo (precisa WSL2) |

O sandbox não substitui os outros dois; é a camada que impede o estrago **dentro** do ambiente, enquanto worktree/matrix impedem que dois agentes se atrapalhem.

### P3 — Verificação: as quatro camadas que substituem o dev olhando

Esta é a parte da arquitetura que determina se o resto pode ser automatizado. Em ordem, da mais barata para a mais cara:

**(a) Auto-verificação.** O agente roda lint + testes + build antes de se declarar pronto. Requisito de desenho: **um comando só** que signifique "pronto" (`npm run verificar`). Se a definição de pronto tem três comandos, ela é interpretável; com um, não é.

**(b) Portão determinístico.** CI que trava o merge: lint, type check, testes, build. Esta camada não tem opinião e não tem falso positivo — tudo que puder ser empurrado para cá sai do campo de julgamento.

**(c) Revisor de IA independente.** Separado de quem implementou, com contexto próprio, e que **nunca aprova nem bloqueia** — só informa. O pipeline de referência é find → verify → rank → post; o passo *verify* é o que diferencia um revisor usável de um gerador de ruído. Entra em shadow mode.

**(d) Humano por tier de risco.** Não todo PR: todo PR *de certo tier*. Tier alto (auth, dados de usuário, config de deploy, dependências) sempre humano; tier baixo, amostragem. O sinal de saúde não é "quantos PRs humanos revisaram", é **qual a fatia de PRs com comentário substantivo** — o número que a Anthropic viu subir de 16% para 54%.

### P4 — Entrega

Preview por PR, `main` protegida, produção só após CI verde, rollback testado antes de precisar dele. No Netlify isso já vem quase pronto — é o plano mais barato da arquitetura e o único que já está resolvido.

### P5 — Observabilidade: medir processo, não volume

Linhas de código e número de PRs medem atividade, não resultado — e sob agente, ambos sobem por construção. As quatro que importam:

| Métrica | Pergunta que responde | Como pegar |
|---|---|---|
| Custo por tarefa entregue | vale a pena? | `claude_code.cost.usage` / PRs mergeados |
| Taxa de aceite do diff | o agente acerta o padrão? | `claude_code.code_edit_tool.decision` |
| Retrabalho | o PR verde voltou? | commits `fix:`/revert tocando arquivo de PR recente |
| Estabilidade pós-deploy | a entrega piorou? | incidentes / rollbacks por semana |

A terceira e a quarta vêm do git e do histórico de deploy, sem infra nenhuma. As duas primeiras precisam de OTel ligado. **Colete a linha de base agora, antes de automatizar mais** — sem ela, qualquer ganho é anedota, e é a estabilidade (não o throughput) que a DORA mostra regredindo.

### P6 — Governança: o erro vira regra

Quando o agente erra o mesmo padrão duas vezes, isso não é problema do agente — é lacuna em P0. O ciclo fechado é: erro recorrente → regra no `AGENTS.md` ou skill nova → o erro para de acontecer em toda sessão futura. Junto: revisor novo em shadow mode, amostragem de aprovação automática e log das ações de agente.

---

## 3. Distância entre o alvo e o `estudo-agentico`

| Plano | Hoje | Gap | Prioridade |
|---|---|---|---|
| P0 Contrato | `CLAUDE.md` bom; PRDs em prosa livre | Sem `AGENTS.md` (Cursor roda sem regra); PRD sem critério verificável, sem out-of-scope, sem lista de arquivos permitidos | **Alta** |
| P1 Controle | Nível 1 ok; nível 2 e wave prontos e desativados | Falta checagem de quem dispara no pipeline caseiro; falta teto de custo por execução | Média |
| P2 Execução | worktree e matrix testados | Sandbox não configurado — permissão hoje é por *texto do comando*, não por fronteira do SO. E em Windows nativo não existe | **Alta** |
| P3 Verificação | CI roda lint + testes; `revisor.md` manual | CI não trava no **build** (type error passa); sem revisor automático no PR; sem tier de risco; sem comando único de "pronto" | **Alta** |
| P4 Entrega | Netlify + branch protection | — | Resolvido |
| P5 Observabilidade | nada | Sem custo, sem taxa de aceite, sem retrabalho, sem linha de base | **Alta** (barato) |
| P6 Governança | lições registradas no guia | Lição não vira regra automaticamente; sem shadow mode definido | Média |

Três coisas chamam atenção nessa tabela:

1. **O gap mais perigoso é P3-b**, não o que parece. O CI hoje aprova um PR que não compila: `npm run build` nunca roda no pipeline — o type error só aparece no Netlify, depois do merge.
2. **P2 é o gap mais caro de descobrir tarde.** Permissão por texto de comando (`"Bash(git commit:*)"`) é o mecanismo que já falhou uma vez no laboratório — o commit acidental em `main`. Fronteira de SO não tem esse modo de falha.
3. **P5 custa quase nada e é o único que não dá para recuperar depois.** Linha de base não se coleta retroativamente.

---

## 4. Caminho de implementação

Quatro fases. Cada uma fecha um plano inteiro e termina com algo verificável. Nenhuma depende de ativar a `ANTHROPIC_API_KEY` exceto a 3.

### Fase 1 — Contrato e portão determinístico *(custo zero de API)*

1. `AGENTS.md` na raiz como constituição compartilhada; `CLAUDE.md` aponta para ele.
2. `prds/_template.md` com EARS, fora de escopo, arquivos permitidos e definição de pronto. Toda PRD nova nasce dele.
3. Skill `escrever-prd`: converte pedido bruto em PRD no template, e recusa PRD maior que ~2 páginas.
4. `npm run verificar` = lint + testes + build. Vira a definição de pronto, única, no `AGENTS.md`.
5. CI endurecido: adiciona **build**, `timeout-minutes` e `concurrency`.

*Pronto quando:* um PR com erro de tipo fica vermelho antes do merge, e uma PRD nova tem lista de arquivos permitidos.

### Fase 2 — Fronteira de execução *(custo zero de API)*

6. Ligar o sandbox do Bash com allowlist de rede mínima (registry npm + GitHub). Em Windows, **rodar as sessões dentro do WSL2** — sem isso, a camada não existe.
7. Endurecer `deny`: merge de PR pelo agente, alteração de workflow, operação fora do repo.
8. Rodar uma semana com a allowlist vazia e anotar cada domínio que o sandbox bloquear — a lista final sai do uso real, não de adivinhação.

*Pronto quando:* um comando que tente escrever fora do repo falha no SO, não na boa vontade do agente.

### Fase 3 — Revisor automático *(primeira fase que consome API)*

9. Workflow `claude-review.yml` em todo PR, usando o plugin `code-review`. Fica inerte enquanto não houver secret.
10. **Shadow mode por 2 semanas**: o revisor comenta, ninguém é obrigado a agir. Anotar: dos achados, quantos eram reais? Esse número decide se ele entra no fluxo.
11. Definir o tier de risco no `AGENTS.md`: que caminhos exigem humano sempre.
12. Só depois disso, avaliar ligar o disparo automático (nível 2 / wave em modo real), com `--max-turns`, `timeout-minutes` e `concurrency` como teto de custo.

*Pronto quando:* a taxa de achado real do revisor é conhecida e escrita.

### Fase 4 — Medição *(ligar junto com a Fase 1, não no fim)*

13. `scripts/metricas-agentico.sh` rodando semanalmente: PRs mergeados, tempo até merge, fatia com comentário substantivo, retrabalho.
14. OTel do Claude Code ligado (`CLAUDE_CODE_ENABLE_TELEMETRY=1`) quando houver onde mandar; antes disso, o script já responde três das quatro métricas.

*Pronto quando:* existe uma linha de base de antes de automatizar mais.

> **Ordem importa:** medir (4) começa junto com a fase 1. Automatizar disparo (12) é a última coisa, não a primeira — é a inversão mais comum e a mais cara.

---

## 5. Arquivos entregues no repositório

| Arquivo | Plano | O que é |
|---|---|---|
| `AGENTS.md` | P0 | Constituição compartilhada entre harnesses |
| `prds/_template.md` | P0 | Template de PRD com EARS, escopo e arquivos permitidos |
| `.claude/skills/escrever-prd/SKILL.md` | P0 | Procedimento para converter pedido bruto em PRD |
| `.github/workflows/ci.yml` | P3-b | CI com build, timeout e concurrency |
| `.github/workflows/claude-review.yml` | P3-c | Revisor automático em PR, inerte sem secret |
| `.claude/settings.json` | P2 | Sandbox FS+rede e deny endurecido |
| `scripts/metricas-agentico.sh` | P5 | Métricas de processo a partir do git e do GitHub |
| `docs/arquitetura-alvo.md` | — | Cópia deste documento no repo |

---

## Fontes

- [Introducing Agent HQ: Any agent, any way you work — GitHub](https://github.blog/news-insights/product-news/welcome-home-agents/)
- [How Anthropic secures its AI-native software development lifecycle](https://claude.com/blog/how-anthropic-secures-its-ai-native-software-development-lifecycle)
- [How Anthropic teams use Claude Code](https://claude.com/blog/how-anthropic-teams-use-claude-code)
- [2026 Agentic Coding Trends Report — Anthropic](https://resources.anthropic.com/hubfs/2026%20Agentic%20Coding%20Trends%20Report.pdf)
- [Claude Code — GitHub Actions](https://code.claude.com/docs/en/github-actions)
- [Claude Code — Sandboxed Bash tool](https://code.claude.com/docs/en/sandboxing)
- [Claude Code — Code Review](https://code.claude.com/docs/en/code-review)
- [Claude Code — OpenTelemetry monitoring](https://code.claude.com/docs/en/monitoring-usage)
- [Beyond permission prompts: making Claude Code more secure and autonomous](https://claude.com/resources/articles/beyond-permission-prompts-making-claude-code-more-secure-and-autonomous)
- [Google DORA: Software delivery caught up to AI coding tools — TechTarget](https://www.techtarget.com/searchsoftwarequality/news/366631712/Google-DORA-Software-delivery-caught-up-to-AI-coding-tools)
- [State of AI Coding Agents in 2026 — DevTools Academy](https://www.devtoolsacademy.com/blog/state-of-ai-coding-agents-2026)
- [Spec-Driven Development Frameworks: Spec Kit, Kiro, OpenSpec](https://codex.danielvaughan.com/2026/05/22/spec-driven-development-frameworks-codex-cli-spec-kit-kiro-openspec-patterns-best-practices/)
- [How Cursor integrated with Linear for agents](https://cursor.com/blog/linear)
