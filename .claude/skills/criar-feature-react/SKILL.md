---
name: criar-feature-react
description: Use ao implementar uma nova feature React a partir de uma PRD em /prds/. Garante organização por pasta, estilo com styled-components, uso correto do Context e teste Jest obrigatório.
---

# Criar feature React seguindo o padrão do time

## Quando usar
Sempre que for implementar algo a partir de uma spec em `/prds/<feature>.md`.

## Passos

1. Ler a PRD completa antes de escrever qualquer código — identificar objetivo, escopo, fora de escopo e critérios de aceite.
2. Verificar se já existe uma pasta para essa feature em `src/features/`. Se não existir, criar:
   - `src/features/<feature>/<Componente>.tsx`
   - `src/features/<feature>/<Componente>.styles.ts`
   - `src/features/<feature>/<Componente>.test.tsx`
3. Estilo sempre em arquivo `.styles.ts` separado, usando `styled-components`. Nunca estilo inline.
4. Antes de criar um novo Context, verificar em `src/context/` se já existe um Provider que cobre o caso. Só criar um novo se a necessidade for genuinamente diferente.
5. Implementar exatamente o que a PRD pede — nada do que está em "fora de escopo".
6. Escrever testes Jest cobrindo cada critério de aceite listado na PRD, um teste por critério quando possível.
7. Rodar `npm run lint` e `npm run test` antes de considerar a tarefa concluída.
8. Nunca commitar direto em `main` — sempre numa branch nova (`git checkout -b feature/<nome>`).

## Checklist final (usar como revisão antes de abrir o PR)
- [ ] Todos os critérios de aceite da PRD têm teste correspondente
- [ ] Nada fora do escopo foi implementado
- [ ] Estilo em arquivo `.styles.ts`, não inline
- [ ] Não criou Context duplicado
- [ ] `npm run lint` e `npm run test` passando
