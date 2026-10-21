# PRD: Contador de caracteres no input do nome

## Contexto
O input de nome na feature `greeting` (de `greeting-nome-editavel.md`) não dá nenhum
feedback visual sobre quantos caracteres foram digitados.

## Objetivo
Mostrar, abaixo do input, um contador no formato "N caracteres" que atualiza em
tempo real conforme o usuário digita.

## Escopo
- Exibir o contador sempre, mesmo com o campo vazio (nesse caso, "0 caracteres")
- O contador reflete o texto digitado no input, não o valor já "normalizado"
  (ou seja, mesmo que o fallback vire "visitante" na saudação, o contador mostra
  o tamanho real do que está no campo)

## Fora de escopo
- Limite máximo de caracteres
- Validação de qualquer tipo

## Critérios de aceite
1. Campo vazio → mostra "0 caracteres"
2. Usuário digita "Ana" → mostra "3 caracteres"
3. Teste automatizado cobrindo os dois casos acima

## Onde implementar
- `src/features/greeting/Greeting.tsx`
- `src/features/greeting/Greeting.styles.ts` (estilo do texto do contador, se necessário)
- `src/features/greeting/Greeting.test.tsx`
