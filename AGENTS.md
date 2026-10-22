# AGENTS.md — constituição do projeto

Regras compartilhadas por qualquer harness agentic usado neste repositório
(Claude Code, Cursor, Codex, Copilot). Lido em toda sessão — por isso é curto.
O `CLAUDE.md` complementa este arquivo com detalhes específicos do Claude Code.

## Projeto

`estudo-agentico` — projeto React usado para validar na prática um fluxo de
desenvolvimento agentic: planejamento → código → revisão → testes → publicação.

## Stack

- React + Vite + TypeScript
- Estado: Context API · Estilo: styled-components · Testes: Jest + Testing Library
- Deploy: Netlify (preview por PR, produção após merge em `main` com CI verde)

## Convenções

- Organização por feature: `src/features/<feature>/` com componente, estilos e teste juntos
- Estilos em arquivo separado com sufixo `.styles.ts` — nunca inline
- Estado compartilhado via Context; verificar se já existe Provider antes de criar outro
- Todo componente relevante tem `.test.tsx` na mesma pasta
- Nunca criar componente novo se já existir equivalente

## Definição de pronto

Uma tarefa só está pronta quando **`npm run verificar`** passa (lint + testes + build).
Comando único, de propósito: definição de pronto com três comandos é interpretável.

## Como implementar a partir de uma PRD

1. Ler a PRD em `prds/<feature>.md`
2. Respeitar a seção **Arquivos que esta PRD pode tocar** — não editar nada fora dela
3. Respeitar a seção **Fora de escopo** — não "melhorar" o que não foi pedido
4. Implementar na pasta da feature correspondente
5. Rodar `npm run verificar` antes de se declarar pronto
6. Citar o caminho da PRD na mensagem de commit (rastreabilidade)

Se a PRD não tiver critérios de aceite verificáveis, **pare e peça o ajuste** em vez
de inferir — implementar com perfeição a spec errada é o erro mais caro do fluxo.

## Comandos

| | |
|---|---|
| Dev | `npm run dev` |
| Lint | `npm run lint` |
| Testes | `npm run test` |
| Build | `npm run build` |
| **Verificação completa** | **`npm run verificar`** |

## Guardrails

Livre: ler arquivos, buscar, rodar lint/testes/build, criar branch, commitar em branch.

Exige aprovação humana: `git push`, instalar dependência, editar `package.json`,
`netlify.toml`, qualquer `.env`, qualquer arquivo em `.github/workflows/`.

Proibido: commit direto em `main`, `git push --force`, mergear o próprio PR,
deploy direto em produção, qualquer comando fora do diretório do repositório.

## Tiers de risco — o que exige revisão humana sempre

Independentemente do CI estar verde e do revisor automático não ter achado nada:

- `.github/workflows/**`, `netlify.toml`, `.claude/settings.json`, `.githooks/**`
- `package.json`, `package-lock.json` (mudança de dependência)
- Qualquer código que lide com autenticação ou dado de usuário

O resto é revisado por amostragem.

## Quando o agente erra o mesmo padrão duas vezes

Isso não é problema do agente — é lacuna deste arquivo. Corrija aqui ou numa skill,
e o erro para de acontecer em toda sessão futura.
