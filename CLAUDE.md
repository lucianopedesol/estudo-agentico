# CLAUDE.md

## Sobre o projeto
estudo-agentico — projeto React usado para aprender e validar, na prática, um fluxo
de desenvolvimento agentic (planejamento → código → revisão → testes → publicação).
Time: 1-3 devs frontend. Fluxo: PRD → Figma (quando houver) → implementação → review → deploy.

## Stack
- React + Vite + TypeScript
- Estado: Context API
- Estilo: styled-components
- Testes: Jest + Testing Library
- Deploy: Netlify

## Convenções do time
- Organização por feature: cada feature tem sua pasta própria com componentes, estilos
  e testes relacionados (ex: `src/features/greeting/`)
- Componentes estilizados com styled-components — arquivo de estilos separado,
  sufixo `.styles.ts` (ex: `Greeting.tsx` + `Greeting.styles.ts`), nunca inline
- Estado compartilhado via Context — verificar se já existe um Provider cobrindo o
  caso antes de criar um novo
- Todo componente novo relevante tem um teste correspondente (`.test.tsx`) na mesma pasta

## Como implementar a partir de uma spec/PRD
1. Ler a spec em `/prds/<feature>.md`
2. Implementar dentro da pasta da feature correspondente em `src/features/`
3. Nunca criar componente novo se já existir um equivalente na mesma feature ou em
   um diretório compartilhado (ex: `src/shared/`, quando existir)

## Comandos
- Dev local: `npm run dev`
- Lint: `npm run lint`
- Testes: `npm run test` (Jest)
- Build: `npm run build`

## Regras obrigatórias (guardrails)
- Rodar lint e testes (Jest) antes de considerar qualquer tarefa concluída
- Nunca commitar direto em `main` — sempre branch + PR (reforçado por hook local, ver abaixo)
- Nunca alterar config de deploy Netlify (`netlify.toml`, env vars) sem aprovação explícita
- PRs devem ter testes Jest cobrindo o que foi alterado

## Setup único por clone
Depois de clonar o repositório, rode uma vez:
```
git config core.hooksPath .githooks
```
Isso ativa o hook de pre-commit que bloqueia commit direto nas branches `main`/`master`.
