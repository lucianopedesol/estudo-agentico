# PRD: Nome editável na saudação

## Contexto
A feature `greeting` hoje mostra "Olá, visitante!" com o nome fixo vindo do Context
(`AppContext`). Queremos permitir que o usuário digite o próprio nome e veja a
saudação atualizar em tempo real.

## Objetivo
Usuário digita o nome em um input e o `Greeting` passa a mostrar "Olá, <nome>!"
imediatamente, sem precisar salvar ou recarregar.

## Escopo
- Adicionar um `<input>` controlado dentro do componente `Greeting`
- Ao digitar, chamar `setUserName` do `AppContext` (já existe, não precisa criar)
- Se o campo estiver vazio, mostrar "visitante" como nome (fallback, não string vazia)

## Fora de escopo
- Persistência do nome (localStorage, backend) — fica para uma PRD futura
- Validação de caracteres especiais ou tamanho máximo

## Critérios de aceite
1. Input vazio → saudação mostra "Olá, visitante!"
2. Usuário digita "Ana" → saudação atualiza para "Olá, Ana!" sem reload
3. Teste automatizado cobrindo os dois casos acima

## Onde implementar
- `src/features/greeting/Greeting.tsx` (adicionar input)
- `src/features/greeting/Greeting.styles.ts` (estilo do input, se necessário)
- `src/features/greeting/Greeting.test.tsx` (atualizar/adicionar testes)
- Não deve exigir mudança em `AppContext.tsx` — a função `setUserName` já existe
