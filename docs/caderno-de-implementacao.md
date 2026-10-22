# Caderno de implementação — arquitetura agentic no `estudo-agentico`

Registro peça por peça do que foi construído: **por que era necessário**, **como foi criado**, **como funciona**, **como validar** e **como reverter**.

Complementa:
- `arquitetura-agentica-alvo.md` — o desenho e o porquê de cada plano
- `desenvolvimento-agentic-guia.md` — o histórico do que foi aprendido antes

Tudo abaixo está numa branch, **sem push e sem merge**: `harness/arquitetura-alvo`.

---

## Índice das peças

| # | Peça | Plano | Estado |
|---|---|---|---|
| 1 | `AGENTS.md` | P0 Contrato | Pronto |
| 2 | `prds/_template.md` | P0 Contrato | Pronto |
| 3 | Skill `escrever-prd` | P0 Contrato | Pronto |
| 4 | `npm run verificar` | P3 Verificação | Pronto |
| 5 | `ci.yml` endurecido | P3 Verificação | Pronto |
| 6 | Sandbox no `settings.json` | P2 Execução | Pronto — exige WSL2 |
| 7 | `deny`/`ask` endurecidos | P2 Execução | Pronto |
| 8 | `claude-review.yml` | P3 Verificação | Pronto — inerte sem secret |
| 9 | Subagente `verificador` | P3 Verificação | Pronto |
| 10 | Tiers de risco | P3 Verificação | Pronto |
| 11 | `agent-implement-prd.yml` reforçado | P1 Controle | Pronto — inerte sem secret |
| 12 | `agent-implement-wave.yml` reforçado | P1 Controle | Pronto |
| 13 | `scripts/metricas-agentico.sh` | P5 Observabilidade | Pronto |
| 14 | Três runbooks | P2/P3/P5 | Pronto |

Três correções de defeito encontradas no caminho estão na seção **Defeitos corrigidos**, no fim.

---

# Fase 1 — Contrato e portão determinístico

## 1. `AGENTS.md` — a constituição compartilhada

**Necessidade.** O projeto tinha `CLAUDE.md`, lido pelo Claude Code. A equipe também usa Cursor, que não lê esse arquivo — ou seja, metade das sessões rodava sem nenhuma regra do projeto carregada, produzindo código que o revisor depois reprovava por convenção. `AGENTS.md` é o formato que o mercado padronizou para isso: arquivo versionado, agnóstico de ferramenta, lido por Cursor, Codex e Copilot. O GitHub o adotou formalmente como o lugar de declarar regras e guardrails.

**Como foi criado.** Partiu do conteúdo do `CLAUDE.md` atual, reorganizado em seções que respondem ao que um agente precisa saber antes de escrever a primeira linha, e acrescido de quatro seções que não existiam: definição de pronto em um comando só, procedimento de leitura de PRD, tiers de risco, e a regra de que erro recorrente vira regra do arquivo. O `CLAUDE.md` ganhou, no topo, um ponteiro para ele e continua existindo para o que é específico do Claude Code.

**Como funciona.** Todo harness carrega o arquivo no começo da sessão. Por isso ele é curto de propósito: arquivo lido em toda sessão custa tokens em toda sessão, e um documento longo é lido com menos atenção, por pessoa e por modelo.

**Como validar.** Abra uma sessão nova no Cursor e pergunte "qual a definição de pronto deste projeto?". A resposta deve ser `npm run verificar`, sem você ter dito nada.

**Como reverter.** Apague `AGENTS.md` e a nota no topo do `CLAUDE.md`. Nada depende dele mecanicamente — é contexto, não código.

---

## 2. `prds/_template.md` — a PRD como contrato verificável

**Necessidade.** As PRDs existentes são prosa livre. Isso produz três falhas catalogadas em qualquer equipe que trabalha com spec: *drift* (em sessão longa o agente se afasta do que foi pedido), *scope creep* (ele "melhora" o que ninguém pediu) e, a mais cara de todas, implementar com perfeição uma spec errada. Nenhuma dessas é falha de modelo; todas são falha de contrato.

**Como foi criado.** Seguiu o pipeline que as ferramentas de spec-driven development convergiram (Spec Kit, Kiro, OpenSpec): critérios em notação EARS, spec de 1 a 2 páginas, fora de escopo explícito. Acrescentei uma quarta seção que vem da lição do seu próprio laboratório, não do mercado: **a lista fechada de arquivos que a PRD pode tocar**. Foi exatamente isso — stubs criados numa PRD base, arquivos separados nas outras duas — que tornou o painel de perfil paralelizável sem conflito de merge.

**Como funciona.** Quatro seções fazem trabalho mecânico:

- **Critérios em EARS** ("Quando X, o sistema deve Y") — cada linha vira um teste. Critério que não vira teste não é critério.
- **Fora de escopo** — a fronteira que o agente usa para recusar expandir.
- **Arquivos permitidos** — o que torna duas PRDs seguras em paralelo. O `AGENTS.md` manda o agente parar e pedir atualização se precisar de arquivo fora da lista, em vez de editar assim mesmo.
- **Definição de pronto** — checklist conferível, não julgamento.

**Como validar.** Pegue uma PRD antiga, por exemplo `prds/painel-perfil-bio-editavel.md`, e tente preenchê-la no template. Onde você não conseguir escrever um critério verificável, é onde o agente estava adivinhando.

**Como reverter.** Apague o arquivo. PRDs existentes não dependem dele.

---

## 3. Skill `escrever-prd` — quem transforma pedido em contrato

**Necessidade.** Template só resolve se alguém o preencher bem. O pedido real chega como "queria uma tela de perfil com foto e bio" — e dentro disso há duas ou três features, uma decisão de produto não tomada e nenhum critério verificável. Sem um procedimento, essa conversão fica no feeling de quem escreve, e o resultado varia por pessoa e por dia.

**Como foi criado.** Como skill (`.claude/skills/escrever-prd/SKILL.md`) e não como instrução no `AGENTS.md`, porque é procedimento usado às vezes — carregar sob demanda, não em toda sessão. O frontmatter `description` é o que decide quando ela é acionada, então foi escrito em termos do gatilho real ("alguém descreveu uma feature em prosa solta"), não do nome da skill.

**Como funciona.** Sete passos, com dois pontos de parada deliberados: se o pedido passar de ~2 páginas, volta e quebra (chamando o subagente `planejador`); se o comportamento esperado não estiver claro, **pergunta em vez de inferir**. Tem uma seção de critério de recusa — skill boa precisa saber quando não produzir.

**Como validar.** Numa sessão, descreva uma feature em duas frases soltas e peça a PRD. A saída tem de vir no template, com fora de escopo preenchido e lista de arquivos fechada.

**Como reverter.** Apague a pasta `.claude/skills/escrever-prd/`.

---

## 4. `npm run verificar` — a definição de pronto em um comando

**Necessidade.** "Pronto" era três comandos (`lint`, `test`, `build`), e cada um aparecia em lugares diferentes do `CLAUDE.md` e dos prompts dos workflows. Definição de pronto com três passos é interpretável: o agente roda dois, considera suficiente, e tecnicamente não desobedeceu. Com um comando, não há interpretação possível.

**Como foi criado.** Script no `package.json`, adicionado por edição programática do JSON (não à mão) para não reordenar nem reformatar o resto do arquivo:

```json
"verificar": "npm run lint && npm run test -- --ci && npm run build"
```

**Como funciona.** Encadeado com `&&`: para no primeiro que falhar. A ordem é por custo crescente — lint é segundos, teste é ~80s, build é o mais lento. Falhar cedo é mais barato.

Esse mesmo comando agora aparece em quatro lugares: no `AGENTS.md` como definição de pronto, nos prompts dos dois workflows de agente, e como portão antes de abrir PR. Um lugar só para mudar quando a definição mudar.

**Como validar.** `npm run verificar` na raiz. Deve passar inteiro. (Detalhe: num clone feito no Windows, o `build` só roda no Windows — o binding nativo do rollup é por plataforma.)

**Como reverter.** Remova a linha do `package.json`.

---

## 5. `ci.yml` endurecido — o portão que aprovava código quebrado

**Necessidade.** Esta é a correção mais importante da Fase 1, e não era conhecida. **O CI aprovava PR que não compila.** Ele rodava `lint` e `test`, nunca `build` — e como `npm run build` executa `tsc -b`, nenhum erro de tipo era barrado. O erro só aparecia no deploy do Netlify, **depois do merge**, com a `main` já quebrada. Um fluxo onde o agente escreve a maior parte do código e o portão não checa tipo é um fluxo sem portão.

**Como foi criado.** Três mudanças no `.github/workflows/ci.yml`:

1. Passo `Build (inclui type check)` ao final — é o portão que faltava.
2. `timeout-minutes: 15` no job — job travado morre sozinho em vez de consumir runner.
3. Bloco `concurrency` com `cancel-in-progress: true` — push novo na mesma branch cancela a execução anterior.

**Como funciona.** O status check do CI já é exigido pela branch protection, então adicionar o build ao job existente faz o botão de merge travar com erro de tipo, sem configurar nada no GitHub.

A ordem dentro do job é a mesma do `verificar`, pela mesma razão: o mais barato primeiro.

**Como validar.** Introduza um erro de tipo de propósito numa branch (uma prop obrigatória que não é passada), abra o PR e confirme que o CI fica vermelho no passo de build. Era o cenário que passava antes.

**Como reverter.** Remova o passo de build. Os outros dois são neutros.

---

# Fase 2 — Fronteira de execução

## 6. Sandbox no `.claude/settings.json`

**Necessidade.** O que impedia estrago era uma lista que casa **texto de comando**. Esse mecanismo já falhou aqui: `allow` liberava `git commit` sem saber em que branch estava, e saiu commit direto na `main`. O hook corrigiu esse caso específico — mas continua sendo regra escrita à mão para um caso que já aconteceu. O sandbox muda a natureza da fronteira: quem aplica é o sistema operacional, e vale para o comando que ninguém previu.

**Como foi criado.** Bloco `sandbox` no `.claude/settings.json`, com allowlist de rede mínima — registry do npm e hosts do GitHub, o suficiente para `npm ci` e git. A lista começa pequena de propósito: ela cresce por uso real, anotando o que o sandbox bloquear durante uma semana.

Não liguei o **modo estrito** (`allowUnsandboxedCommands: false`) agora. Ligar antes da allowlist amadurecer trava o trabalho e ensina a equipe a desligar o sandbox — pior que não ter.

**Como funciona.** Duas fronteiras simultâneas: filesystem (escrita só no diretório de trabalho) e rede (sem rota direta; proxy local confere cada host contra a allowlist). As duas juntas porque uma só não fecha: com rede livre, exfiltra arquivo; com disco livre, escapa e alcança a rede. Em troca, dentro da fronteira o agente roda comando sem pedir aprovação — que é o ganho prático, já que aprovação a cada comando vira carimbo.

**A condição que mais importa:** o sandbox roda em macOS, Linux e WSL2. **Em Windows nativo não existe.** Como a equipe está em Windows, as sessões precisam rodar dentro do WSL2 ou esta camada é decorativa. Detalhado em `docs/runbook-sandbox.md`.

**Como validar.** Com o sandbox ligado, peça ao agente para escrever em `~/teste-sandbox.txt`. Deve falhar no SO. Se escrever, não está ativo — quase sempre porque a sessão está em Windows nativo.

**Como reverter.** Remova o bloco `"sandbox"`. As listas `allow`/`ask`/`deny` e o hook seguem funcionando.

---

## 7. `deny` e `ask` endurecidos

**Necessidade.** O sandbox cobre comandos de shell, mas ferramentas de arquivo, servidores MCP e hooks rodam fora dele. As listas continuam sendo necessárias — e tinham buracos: nada impedia o agente de **mergear o próprio PR** (`gh pr merge`), de alterar um workflow do CI, ou de mexer nas próprias permissões.

**Como foi criado.** Acréscimos em duas listas:

- `deny`: `gh pr merge`, `gh secret`, `gh api -X DELETE`
- `ask`: `gh pr create`, `Edit(.github/workflows/*)`, `Edit(.claude/settings.json)`
- `allow`: `npm run verificar`

**Como funciona.** `deny` bloqueia; `ask` pede aprovação — e, em modo headless (`--permission-mode acceptEdits`), `ask` se comporta como bloqueio, nunca como aprovação automática. Por isso `gh pr create` em `ask` é seguro nos dois mundos: na sessão interativa você aprova; no CI o workflow abre o PR pelo próprio `gh`, fora do controle do agente.

O princípio por trás dos três itens novos de `deny` é o mesmo: **fronteira em torno de ação, não de instrução**. A defesa contra um agente que mergeia o próprio código não é pedir que ele não faça; é ele não ter o comando.

**Como validar.** Numa sessão, peça para mergear um PR. Deve ser recusado pela permissão, não por bom senso do modelo.

**Como reverter.** Remova as linhas acrescentadas.

---

# Fase 3 — Verificação

## 8. `claude-review.yml` — revisor automático no PR

**Necessidade.** O `revisor.md` existe, mas é manual: alguém precisa abrir sessão e pedir. Na prática, isso acontece quando dá tempo. A camada que falta é a que roda sem ninguém lembrar.

**Como foi criado.** Workflow em todo PR (`opened`, `synchronize`, `ready_for_review`, `reopened`), usando o plugin oficial `code-review`. Três decisões:

1. **Inerte sem a secret.** O `secrets` não é acessível em condição de step, então a chave é exposta como `env` no nível do job (`TEM_CHAVE`) e os steps checam isso. Sem secret, o job roda, loga um aviso e sai verde.
2. **`--max-turns 20`** — teto de custo por revisão.
3. **`concurrency` por número do PR** — push novo cancela a revisão anterior do mesmo PR, em vez de pagar duas.

**Como funciona.** O plugin roda o pipeline `find → verify → rank → post`: vários agentes leem o diff em paralelo, cada um com contexto próprio; um passo de verificação confere cada achado contra o código e descarta falso positivo; o que sobra é deduplicado, ordenado por severidade e postado como comentário inline.

A propriedade de desenho mais importante: **ele nunca aprova nem bloqueia o PR**. Informa, e a decisão de merge continua da pessoa. Isso não é cautela de rollout — é o que impede a revisão de virar carimbo.

**Como validar.** Com a secret configurada, abra um PR e confirme os comentários inline. Antes disso, confirme que o job sai verde com o aviso.

**Como reverter.** Apague o arquivo, ou remova a secret — sem ela ele já volta ao estado inerte.

**Procedimento de adoção:** duas semanas em shadow mode antes de qualquer autoridade. Está em `docs/runbook-shadow-mode.md`.

---

## 9. Subagente `verificador` — o passo que falta no revisor local

**Necessidade.** O `revisor.md` levanta achados e ninguém confere se são verdade. Revisor que erra muito não é neutro, é pior que nenhum: a equipe aprende em duas semanas a ignorar os comentários dele — e passa a ignorar junto os que eram verdadeiros. O passo *verify* é o que separa revisor útil de gerador de ruído, e o revisor local não tinha esse passo.

**Como foi criado.** Novo subagente `.claude/agents/verificador.md`, espelhando no fluxo local o que o pipeline do plugin faz na nuvem. Ferramentas só de leitura (mais `npm run test`), para não poder "corrigir" o que está verificando.

**Como funciona.** Recebe a lista do revisor e processa achado por achado: localiza a evidência, reproduz o raciocínio contra o código real, classifica em `CONFIRMADO` / `PLAUSÍVEL` / `FALSO POSITIVO`, atribui severidade usando os tiers de risco do `AGENTS.md`, e deduplica por causa raiz.

A saída obrigatória inclui a contagem do descarte — *"7 achados → 3 confirmados, 1 plausível, 3 falsos positivos"*. Essa razão **é** a métrica que decide se o revisor automático merece entrar no fluxo.

Três regras duras: não verifica achado próprio; falso positivo é descarte, não "deixa aí por via das dúvidas"; não aprova nem bloqueia.

**Como validar.** Rode `revisor` numa branch com mudanças e depois `verificador` sobre a saída dele. Se o verificador confirmar tudo, desconfie — ele está carimbando.

**Como reverter.** Apague o arquivo. O `revisor` continua funcionando sozinho.

---

## 10. Tiers de risco — o que exige humano sempre

**Necessidade.** "Todo PR é revisado por humano" não sobrevive a volume: vira leitura superficial de tudo, que é o mesmo que ler nada. A alternativa que funciona é tiering — caminhos críticos sempre têm humano, o resto é amostrado.

**Como foi criado.** Seção no `AGENTS.md` listando caminhos concretos, não categorias abstratas: workflows do CI, `netlify.toml`, `.claude/settings.json`, `.githooks/**`, `package.json`/`package-lock.json`, e qualquer código de autenticação ou dado de usuário.

**Como funciona.** Por enquanto é convenção lida por humano e por agente. O próximo passo natural — quando o volume justificar — é um `CODEOWNERS` que force revisor nesses caminhos, o que transforma a convenção em portão real do GitHub.

A lista tem uma lógica: são os caminhos onde um erro **desarma as outras camadas**. Um bug num componente React é um bug; uma mudança errada em `.claude/settings.json` desliga os guardrails de todo mundo.

**Como validar.** Pergunte a uma sessão nova: "esta mudança no `netlify.toml` precisa de revisão humana?". A resposta deve ser sim, citando a seção.

**Como reverter.** Remova a seção do `AGENTS.md`.

---

# Fase 1 do controle — disparo com teto e portão

## 11. `agent-implement-prd.yml` reforçado

**Necessidade.** O workflow do Nível 2 estava correto no essencial — abre PR, nunca mergeia — mas tinha quatro lacunas que só aparecem quando ele roda de verdade:

- **Sem portão de quem dispara.** Um merge feito por bot dispararia o agente de novo. O caso público mais instrutivo de 2026 é exatamente esse: um agente pediu a outro, por mensagem, que desse push — e só não aconteceu porque havia portão humano no caminho.
- **Sem teto de custo.** Sem `timeout`, sem `--max-turns`, sem `concurrency`. Um loop do agente rodava até o limite do runner.
- **Sem `npm ci`.** O prompt mandava rodar lint e teste, mas o runner não tinha `node_modules`. O agente não tinha como cumprir a instrução.
- **Sem verificação antes de pedir atenção humana.** Abria PR igual, tendo o agente conseguido fechar ou não.

**Como foi criado.** Reescrito mantendo a estrutura e os comentários originais, com quatro acréscimos:

1. Passo `Recusar disparo por bot`, que falha se `github.actor` casar com `*[bot]`, `*-bot` ou `agente-ci`.
2. `timeout-minutes: 30`, `concurrency` por ref e `--max-turns 40`.
3. `npm ci` antes de acionar o agente.
4. Passo `Verificação determinística` com `continue-on-error: true`, e o PR aberto como **draft** quando ela falha.

O prompt também mudou: aponta para `AGENTS.md` (não `CLAUDE.md`), manda respeitar a lista de arquivos e o fora de escopo, e pede `npm run verificar` em vez dos comandos soltos.

**Como funciona.** O ponto de desenho mais interessante é o draft. `continue-on-error` faz a falha **não cancelar** o PR — ela muda o que o PR comunica. PR normal = o agente fechou, pode revisar. PR draft = o agente não conseguiu, alguém precisa olhar antes. Isso dá um sinal de triagem antes de qualquer pessoa gastar atenção.

Sobre o `--max-turns 40`: é teto de custo, mas também sinal. PRD bem escrita cabe folgada em 40 turnos. Estourar normalmente significa PRD ambígua, não tarefa difícil — e aí é mais barato falhar do que insistir.

**Como validar.** Sem a secret, faça um commit em `prds/` e confirme que o workflow roda, avisa e sai verde. Com a secret, o primeiro teste deve ser com uma PRD pequena, acompanhando a execução.

**Como reverter.** `git checkout origin/main -- .github/workflows/agent-implement-prd.yml`.

---

## 12. `agent-implement-wave.yml` reforçado

**Necessidade.** A wave escala paralelismo — e escala custo junto. Seis cards disparados por engano são seis sessões de API simultâneas. Faltavam o teto e a mesma checagem de disparo.

**Como foi criado.** Quatro acréscimos sobre o arquivo que já estava no `main` (incluindo a correção do `run_number`, que estava no remoto mas não no clone local — ver Defeitos corrigidos):

1. `max-parallel: 3` na matrix — a wave pode ter 6 cards, mas só 3 queimam API ao mesmo tempo.
2. `LIMITE_CARDS: 6` — wave maior é recusada **antes** de montar a matrix.
3. Mesma recusa de disparo por bot, e validação explícita da secret quando o modo é `real` (antes, pedir modo real sem secret falhava lá na frente, em cada job, depois de já ter gasto runner).
4. Verificação determinística antes do PR, com draft em caso de falha — igual ao workflow anterior.

**Como funciona.** `max-parallel` e `fail-fast: false` fazem trabalhos opostos e complementares: um limita quantos rodam juntos, o outro garante que um card falhando não derrube os irmãos. Os dois juntos dão uma wave que é barata e resiliente.

O limite de cards é validado no job `montar-wave`, antes da matrix existir — o erro aparece em segundos, não depois de seis VMs subirem.

**Como validar.** Dispare em modo `simulado` com 7 cards: deve ser recusado com mensagem clara. Com 2 cards: dois jobs, duas branches, dois PRs, sem custo de API.

**Como reverter.** `git checkout origin/main -- .github/workflows/agent-implement-wave.yml`.

---

# Fase 4 — Medição

## 13. `scripts/metricas-agentico.sh`

**Necessidade.** Não havia número nenhum. E o problema não é só "não dá para provar ganho" — é que **linha de base não se coleta retroativamente**. Se a medição começar depois de automatizar o disparo, a comparação está perdida para sempre. Há também um alvo específico: a pesquisa da DORA mostra que, conforme a adoção de IA cresce, o throughput se recupera mas a **estabilidade de entrega continua sofrendo**. É o indicador que regride calado.

**Como foi criado.** Shell script POSIX usando `gh` e `jq`, sem dependência nova no projeto. Mede processo, não volume — linhas de código e número de PRs sobem por construção quando se usa agente e não dizem nada sobre saúde.

**Como funciona.** `sh scripts/metricas-agentico.sh [dias]` (padrão 14). Quatro saídas:

| Saída | Por que está aí |
|---|---|
| Tempo até merge (mediana e média) | Proxy de lead time |
| % de PRs com comentário/review | Escrutínio real. Deve **subir** conforme o volume cresce — na Anthropic foi de 16% para 54%. Caindo, a revisão virou carimbo |
| Tamanho mediano do PR | Lote pequeno é uma das sete práticas que a DORA associa a ganho real. PR crescendo = PRD mal quebrada |
| Razão retrabalho/PR | O alarme principal: PR verde que voltou como `fix:`/`revert` |

**Como validar.** `sh scripts/metricas-agentico.sh 60` com `gh` autenticado. A sintaxe já foi conferida com `sh -n`.

**Como reverter.** Apague o arquivo. Ele só lê.

---

## 14. Os três runbooks

**Necessidade.** Configuração sem procedimento de adoção não é adotada — ou é adotada errada e desligada na primeira fricção. Cada uma das três peças que dependem de ação humana continuada ganhou um runbook.

| Runbook | Responde |
|---|---|
| `docs/runbook-sandbox.md` | Por que WSL2 é condição, como a allowlist cresce por uso real, quando ligar modo estrito |
| `docs/runbook-shadow-mode.md` | Duas semanas medindo acerto, os limiares de decisão (70% / 40%), o que fazer em cada faixa |
| `docs/runbook-observabilidade.md` | O que medir e o que não medir, script agora e OTel depois, por que telemetria não entra em settings de repositório |

Os três têm a mesma estrutura: necessidade, mecânica, passo a passo, validação, reversão.

---

# Defeitos corrigidos no caminho

Três coisas quebradas apareceram durante a implementação. Nenhuma era conhecida.

### D1. `tsc -b` emite configs na raiz e quebra o Jest

Rodar `npm run build` emite `jest.config.js`, `jest.config.d.ts`, `vite.config.js`, `vite.config.d.ts` e dois `.tsbuildinfo` na raiz do projeto. Com `jest.config.ts` **e** `jest.config.js` presentes, o Jest recusa rodar:

```
Implicit config resolution does not allow multiple configuration files.
```

Ou seja: depois de um build, o próximo `npm run test` falha — e o erro não aponta para a causa. Pior num fluxo agentic, onde o agente roda build e teste em sequência sem ninguém olhando.

**Correção:** artefatos removidos e acrescentados ao `.gitignore`. A ordem do `verificar` (lint → test → build) também evita o problema dentro de uma execução.

**Ainda aberto:** a causa raiz é o `tsconfig.node.json` emitindo em vez de usar `noEmit`. Não mexi porque toca configuração de build e cai no tier de risco — é decisão sua.

### D2. O clone local estava atrás do remoto

O `main` local estava em `e5c72b8`; o remoto tinha mais dois commits (PR #16, a correção do `run_number` no nome da branch da wave). O guia descrevia essa correção como feita — e estava, no GitHub, mas não no clone. Eu teria reescrito o arquivo em cima de uma versão antiga e desfeito a correção silenciosamente.

**Correção:** `git merge --ff-only origin/main` antes de editar. A rede desta sessão não alcança o GitHub, mas a referência `origin/main` já estava no clone.

**Lição que vale para o fluxo:** agente que edita arquivo sem conferir se a branch está atualizada desfaz correção sem avisar. Vale acrescentar `git status`/comparação com `origin/main` ao início de qualquer sessão de implementação.

### D3. O workflow do Nível 2 nunca instalava dependências

Descrito na peça 11: o prompt mandava rodar lint e teste, o runner não tinha `node_modules`. Nunca apareceu porque o workflow nunca rodou de verdade (sem secret). Teria sido a primeira falha no dia em que fosse ligado.

---

# O que ainda depende de você

Nada disso o agente pode fazer — são ações na interface do GitHub ou na sua máquina.

| # | Ação | Onde | Quando |
|---|---|---|---|
| 1 | Revisar a branch `harness/arquitetura-alvo` e abrir o PR | local → GitHub | agora |
| 2 | Rodar `sh scripts/metricas-agentico.sh` e guardar a saída | terminal | **antes de tudo** — é a linha de base |
| 3 | Passar a rodar as sessões dentro do WSL2 | máquina | Fase 2 |
| 4 | Confirmar que o status check do CI exigido inclui o build | Settings → Branches | após o merge |
| 5 | Configurar a secret `ANTHROPIC_API_KEY` | Settings → Secrets → Actions | só na Fase 3 |
| 6 | Restaurar `required_approving_review_count: 1` | Settings → Branches | quando o 2º dev entrar |

A ordem importa: **2 antes de tudo**, **5 por último**. Automatizar disparo antes de medir e antes de validar os guardrails é a inversão mais comum — e a mais cara.

## Para subir a branch

```sh
git push -u origin harness/arquitetura-alvo
gh pr create --base main --title "harness: arquitetura-alvo (fases 1-4)" --body "Ver docs/caderno-de-implementacao.md"
```

Não dei push: `git push` está na lista `ask` dos seus próprios guardrails, e essa regra existe exatamente para momentos como este.
