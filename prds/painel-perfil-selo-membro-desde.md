# PRD: Selo "Membro desde" no painel de perfil

## Contexto
O painel de perfil (`painel-perfil-avatar-iniciais.md`) já existe, com um
`MemberSince.tsx` criado como stub (placeholder sem lógica) e já renderizado dentro de
`ProfilePanel.tsx`. **Esta PRD depende da anterior já estar implementada** — ela só
edita os arquivos próprios do componente `MemberSince`, sem tocar em
`ProfilePanel.tsx`, `Avatar.tsx` ou `Bio.tsx`.

O pedido original pede um selo "Membro desde" com uma data fixa de exemplo (não
precisa ser dinâmica ainda).

## Objetivo
Mostrar, no painel de perfil, um selo com o texto "Membro desde Outubro de 2026"
(valor fixo, hardcoded).

## Escopo
- Substituir o stub de `MemberSince.tsx` por um componente funcional que renderiza um
  selo (badge) simples com o texto "Membro desde Outubro de 2026"
- O valor da data é uma constante fixa no componente (string), sem cálculo nenhum

## Fora de escopo
- Data dinâmica (calculada a partir de uma data real de cadastro) — fica para uma PRD
  futura, quando existir um backend ou fonte real dessa informação
- Qualquer formatação de data configurável ou internacionalização
- Qualquer alteração em `ProfilePanel.tsx`, `Avatar.tsx` ou `Bio.tsx`

## Critérios de aceite
1. O painel renderiza o texto exato "Membro desde Outubro de 2026"
2. Teste automatizado verificando a presença desse texto na tela

## Onde implementar
- `src/features/profile-panel/MemberSince.tsx` (substituir o stub pela lógica real)
- `src/features/profile-panel/MemberSince.styles.ts` (novo — estilo do selo/badge)
- `src/features/profile-panel/MemberSince.test.tsx` (novo)
- Não deve exigir mudança em `ProfilePanel.tsx`, `AppContext.tsx`, `Avatar.tsx` ou
  `Bio.tsx`
