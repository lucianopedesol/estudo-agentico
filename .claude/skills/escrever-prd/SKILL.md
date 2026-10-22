---
name: escrever-prd
description: Converte um pedido bruto e informal em uma PRD estruturada no template do repositório, com critérios de aceite verificáveis, fora de escopo e lista fechada de arquivos. Use sempre que alguém descrever uma feature em prosa solta antes de implementar.
---

# Escrever PRD a partir de um pedido bruto

Objetivo: transformar "queria uma tela de perfil com foto e bio" em um contrato que
um agente consegue implementar sem adivinhar — e sem passar do que foi pedido.

## Procedimento

1. **Leia o pedido bruto inteiro.** Não comece a escrever antes de identificar o que
   está implícito. Pedido informal quase sempre esconde duas ou três features.

2. **Decida se é uma PRD ou várias.** Quebre se: tocar em mais de uma pasta de
   feature, tiver mais de ~6 critérios de aceite, ou misturar partes que dependem
   entre si com partes independentes. Se quebrar, use o subagente `planejador`.

3. **Copie `prds/_template.md`** para `prds/<feature>.md`. Nunca escreva PRD fora do
   template.

4. **Escreva os critérios em EARS.** Cada um precisa virar um teste:
   - ❌ "o avatar deve aparecer bonito"
   - ✅ "Quando o usuário não tem foto, o sistema deve exibir as iniciais do nome
     sobre fundo sólido"

5. **Preencha o fora de escopo antes de considerar terminado.** Se estiver vazio, a
   seção está errada — sempre existe algo adjacente que não é para fazer agora.
   Olhe o que o pedido sugere mas não pede.

6. **Feche a lista de arquivos.** Derive das convenções do `AGENTS.md`: componente,
   `.styles.ts` e `.test.tsx` dentro de `src/features/<feature>/`. Se duas PRDs
   precisarem do mesmo container, crie **stubs vazios** numa PRD base sequencial —
   é isso que torna as outras genuinamente paralelizáveis.

7. **Confira o tamanho.** Se passou de ~2 páginas, volte ao passo 2.

## Critério de recusa

Não escreva a PRD, pergunte antes, se:

- o pedido não deixa claro o comportamento observável esperado
- o pedido depende de decisão de produto que ninguém tomou
- o pedido toca em algo do tier de risco do `AGENTS.md` sem dono humano definido

## Saída

Caminho do arquivo criado e um resumo de três linhas: o que entra, o que fica fora,
e se pode rodar em paralelo com alguma outra PRD aberta.
