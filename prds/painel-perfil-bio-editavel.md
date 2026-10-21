# PRD: Bio editável no painel de perfil

## Contexto
O painel de perfil (`painel-perfil-avatar-iniciais.md`) já existe, com um `Bio.tsx`
criado como stub (placeholder sem lógica) e já renderizado dentro de
`ProfilePanel.tsx`. **Esta PRD depende da anterior já estar implementada** — ela só
edita os arquivos próprios do componente `Bio`, sem tocar em `ProfilePanel.tsx`,
`Avatar.tsx` ou `MemberSince.tsx`.

O pedido original pede um campo de "bio" curta (texto livre, até um parágrafo),
editável, que a pessoa digita e vê salvo localmente — por enquanto só em memória
(sem backend, sem localStorage).

## Objetivo
Usuário digita um texto curto (bio) em uma área de texto dentro do painel de perfil e
vê o texto refletido imediatamente, mantido em estado enquanto o componente estiver
montado (sem persistir entre reloads da página).

## Escopo
- Substituir o stub de `Bio.tsx` por um componente funcional com um `<textarea>`
  controlado (estado local via `useState`, não precisa de Context — a bio não é usada
  por nenhum outro componente nesta fase)
- Texto vazio por padrão, com placeholder (ex.: "Escreva algo sobre você...")
- Sem limite de caracteres explícito, mas a área de texto deve se comportar como um
  campo de parágrafo curto (ex.: `rows` pequeno, tipo 3)
- O valor digitado deve ser refletido na tela conforme o usuário digita (controlado)

## Fora de escopo
- Persistência entre reloads (localStorage ou backend) — o pedido bruto já deixa
  isso para depois
- Limite máximo de caracteres ou validação de conteúdo
- Contador de caracteres (se for desejado, é uma PRD própria futura, análoga a
  `greeting-contador-caracteres.md`)
- Qualquer alteração em `ProfilePanel.tsx`, `Avatar.tsx` ou `MemberSince.tsx`

## Critérios de aceite
1. Campo renderiza vazio por padrão, mostrando o placeholder
2. Usuário digita um texto (ex.: "Gosto de React") → o texto aparece refletido no
   campo imediatamente
3. O estado da bio não é compartilhado com outros componentes (fica local ao `Bio`)
4. Teste automatizado cobrindo os dois primeiros casos

## Onde implementar
- `src/features/profile-panel/Bio.tsx` (substituir o stub pela lógica real)
- `src/features/profile-panel/Bio.styles.ts` (novo — estilo do textarea)
- `src/features/profile-panel/Bio.test.tsx` (novo)
- Não deve exigir mudança em `ProfilePanel.tsx`, `AppContext.tsx`, `Avatar.tsx` ou
  `MemberSince.tsx`
