# Runbook — Sandbox do Bash (Plano P2)

## Por que isso existe

Hoje o que impede o agente de rodar um comando destrutivo é a lista `deny` do
`.claude/settings.json`, que casa **texto de comando**. Esse mecanismo já falhou uma vez
neste repositório: o `allow` liberava `git commit` sem checar em qual branch estávamos, e
saiu um commit direto na `main`. A correção foi um hook que lê o estado do repo — melhor,
mas ainda é uma regra nossa, escrita à mão, para um caso que já aconteceu.

O sandbox é diferente em natureza: quem aplica é o sistema operacional, e vale para
qualquer comando, inclusive os que ninguém previu. Duas fronteiras:

- **Filesystem** — comandos escrevem só dentro do diretório de trabalho.
- **Rede** — não existe rota direta de saída. Tudo passa por um proxy local que confere o
  host contra uma allowlist que **começa vazia**.

As duas juntas, não uma só: com rede livre, um agente induzido por conteúdo malicioso
exfiltra arquivo; com disco livre, ele escapa e alcança a rede.

O efeito colateral bom é o que torna isso atraente além da segurança: dentro da fronteira,
o agente roda comando **sem pedir aprovação**. Aprovação a cada comando produz fadiga — a
pessoa para de ler o que aprova, e o portão vira carimbo.

## A pegadinha que decide como a equipe trabalha

**O sandbox roda em macOS, Linux e WSL2. Em Windows nativo, não existe.** O Claude Code
roda os comandos sem sandbox e não avisa a cada vez.

Como a equipe trabalha em Windows, a consequência é direta: **as sessões de agente precisam
rodar dentro do WSL2**, ou esta camada inteira é decorativa. Não é preferência de ferramenta,
é a condição para o plano P2 existir.

## Como está configurado

Em `.claude/settings.json`:

```json
"sandbox": {
  "enabled": true,
  "network": {
    "allowedDomains": [
      "registry.npmjs.org",
      "github.com",
      "api.github.com",
      "codeload.github.com",
      "objects.githubusercontent.com"
    ]
  }
}
```

A allowlist tem só o mínimo para `npm ci` e operações de git. Qualquer outro host é
bloqueado e o Claude Code avisa qual foi — é assim que a lista cresce: por uso real, não
por adivinhação.

## Passo a passo

1. **Rodar a sessão no WSL2** (Windows). Dentro da distribuição, navegue até o repositório
   e abra o `claude` ali — não pelo PowerShell.
2. **Conferir que ligou**: rode `/sandbox` na sessão. O painel mostra o estado, o modo e as
   abas de domínios e overrides.
3. **Uma semana de uso normal.** Toda vez que um comando for bloqueado por domínio, anote o
   host. No fim da semana, acrescente ao `allowedDomains` os que forem legítimos — essa é a
   lista real do projeto.
4. **Só então considerar o modo estrito** (`"allowUnsandboxedCommands": false`), que desliga
   a possibilidade de o agente repetir um comando fora do sandbox quando ele falha dentro.
   Ligar isso antes da allowlist estar madura trava o trabalho sem ensinar nada.

## Como validar

Dentro de uma sessão com sandbox ligado, peça ao agente para escrever um arquivo fora do
repositório (por exemplo em `~/teste-sandbox.txt`). O comando deve falhar na camada do SO,
não por boa vontade do agente. Se ele escrever, o sandbox não está ativo — quase sempre
porque a sessão está em Windows nativo.

## Como reverter

Remova o bloco `"sandbox"` do `.claude/settings.json`. Nada mais depende dele; as listas
`allow`/`ask`/`deny` e o hook `PreToolUse` continuam funcionando sozinhos.

## O que isso NÃO protege

O sandbox cobre comandos de shell. Ferramentas de arquivo do próprio Claude, servidores MCP
e hooks rodam fora dele. Por isso as listas `ask`/`deny` continuam no arquivo: elas cobrem
o que o sandbox não alcança. As duas camadas são complementares, não alternativas.
