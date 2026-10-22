# PRD: <nome da feature>

> Template obrigatório. Toda PRD nasce deste arquivo.
> Alvo: 1 a 2 páginas. PRD maior que isso deve ser quebrada pelo planejador.

## Contexto

<Duas ou três frases: que problema isso resolve e para quem. Sem solução ainda.>

## Critérios de aceite

Formato EARS — cada critério precisa ser verificável por um teste.

- Quando `<evento>`, o sistema deve `<comportamento observável>`
- Enquanto `<estado>`, o sistema deve `<comportamento observável>`
- Se `<condição indesejada>`, então o sistema deve `<resposta>`

> Critério vago ("deve ser rápido", "boa experiência") não é critério — ou vira
> número, ou sai da lista.

## Fora de escopo

Explícito, item a item. Esta seção é o que impede scope creep.

- <o que NÃO deve ser feito nesta PRD>
- <refatoração adjacente que fica para depois>

## Arquivos que esta PRD pode tocar

Lista fechada. É isto que torna duas PRDs paralelizáveis sem conflito de merge.

- `src/features/<feature>/<Componente>.tsx`
- `src/features/<feature>/<Componente>.styles.ts`
- `src/features/<feature>/<Componente>.test.tsx`

> Se a implementação precisar de um arquivo fora desta lista, **pare e peça a
> atualização da PRD** em vez de editar mesmo assim.

## Dependências

- [ ] Depende de: `prds/<outra>.md` (precisa estar mergeada antes)
- [ ] Independente — pode rodar em paralelo com: `prds/<outra>.md`

## Definição de pronto

- [ ] `npm run verificar` passa (lint + testes + build)
- [ ] Existe teste cobrindo cada critério de aceite acima
- [ ] Nenhum arquivo fora da lista permitida foi alterado
- [ ] Commit cita o caminho desta PRD
