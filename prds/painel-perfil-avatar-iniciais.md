# PRD: Painel de perfil — estrutura base e avatar com iniciais

## Contexto
Hoje a tela principal só renderiza a feature `greeting`. O pedido bruto
(`_entrada-painel-perfil.md`) pede um "painel de perfil" abaixo do Greeting, com três
partes: avatar com iniciais, bio editável e selo "Membro desde". Esta PRD cria a
estrutura da nova feature `profile-panel` (seguindo a convenção de organização por
feature do projeto) e entrega a primeira parte funcional: o avatar com iniciais
derivadas do nome já disponível no `AppContext` (`userName`).

As outras duas partes (bio editável e selo "Membro desde") são tratadas em PRDs
próprias (`painel-perfil-bio-editavel.md` e `painel-perfil-selo-membro-desde.md`), que
**dependem desta PRD já estar implementada** — elas só editam os arquivos de `Bio` e
`MemberSince` criados aqui como stubs, sem tocar no container `ProfilePanel.tsx`.

## Objetivo
Exibir, abaixo do `Greeting`, um painel de perfil contendo um avatar circular com as
iniciais do nome atual do usuário (lido do `AppContext`), já com a estrutura do
container pronta para receber a bio e o selo "Membro desde" nas próximas PRDs.

## Escopo
- Criar a pasta `src/features/profile-panel/`
- Criar `ProfilePanel.tsx`: container que renderiza, nesta ordem, `<Avatar />`,
  `<Bio />` e `<MemberSince />`
- Criar `Avatar.tsx`: lê `userName` do `AppContext` (via `useAppContext`, já existe) e
  deriva as iniciais:
  - Nome com uma palavra (ex.: "Ana") → primeira letra em maiúscula ("A")
  - Nome com duas ou mais palavras (ex.: "Ana Souza") → primeira letra da primeira e
    da última palavra, em maiúsculas ("AS")
  - Nome vazio / fallback "visitante" → "V"
- Criar `Bio.tsx` e `MemberSince.tsx` como **stubs mínimos** nesta PRD: cada um
  renderiza apenas um placeholder simples (ex.: `null` ou um comentário JSX), sem
  lógica nenhuma — a lógica real é escopo das PRDs dedicadas a eles. O objetivo de
  criá-los aqui é apenas fixar o contrato de import do `ProfilePanel.tsx`, para que as
  próximas PRDs não precisem alterar o container.
- Criar os arquivos de estilo correspondentes: `ProfilePanel.styles.ts`,
  `Avatar.styles.ts` (estilo circular simples para o avatar)
- Criar os testes: `ProfilePanel.test.tsx` (verifica que o painel renderiza e contém o
  avatar) e `Avatar.test.tsx` (cobre os três casos de iniciais acima)
- Atualizar `src/App.tsx` para renderizar `<Greeting />` seguido de `<ProfilePanel />`

## Fora de escopo
- Lógica real de `Bio` (campo editável) — fica para `painel-perfil-bio-editavel.md`
- Lógica real de `MemberSince` (selo com data) — fica para
  `painel-perfil-selo-membro-desde.md`
- Qualquer persistência (localStorage, backend)
- Estilo visual refinado do painel como um todo (layout, espaçamento entre avatar/bio/selo) —
  pode ficar simples/funcional nesta PRD

## Critérios de aceite
1. `userName` = "visitante" (valor padrão do Context) → avatar mostra "V"
2. `userName` = "Ana" → avatar mostra "A"
3. `userName` = "Ana Souza" → avatar mostra "AS"
4. `ProfilePanel` renderiza sem erros e contém o `Avatar` na tela
5. Teste automatizado cobrindo os três casos de iniciais e a renderização do painel

## Onde implementar
- `src/features/profile-panel/ProfilePanel.tsx` (novo)
- `src/features/profile-panel/ProfilePanel.styles.ts` (novo)
- `src/features/profile-panel/ProfilePanel.test.tsx` (novo)
- `src/features/profile-panel/Avatar.tsx` (novo)
- `src/features/profile-panel/Avatar.styles.ts` (novo)
- `src/features/profile-panel/Avatar.test.tsx` (novo)
- `src/features/profile-panel/Bio.tsx` (novo, stub)
- `src/features/profile-panel/MemberSince.tsx` (novo, stub)
- `src/App.tsx` (adicionar `<ProfilePanel />`)
- Não deve exigir mudança em `AppContext.tsx` — `userName` já existe e é suficiente
