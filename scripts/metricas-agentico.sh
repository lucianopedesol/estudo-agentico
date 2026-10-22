#!/bin/sh
# Métricas de processo do fluxo agentic (plano P5 da arquitetura-alvo).
#
# Mede processo, não volume: linhas de código e número de PRs sobem por construção
# quando se usa agente, e não dizem se o fluxo está saudável.
#
# Requisitos: git, gh (autenticado), jq.
# Uso: sh scripts/metricas-agentico.sh [dias]   (padrão: 14)

set -e
DIAS="${1:-14}"
DESDE=$(date -u -d "-${DIAS} days" +%Y-%m-%d 2>/dev/null || date -u -v-"${DIAS}"d +%Y-%m-%d)

for cmd in gh jq; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Faltando: $cmd"; exit 1; }
done

echo "=== Métricas do fluxo agentic — últimos ${DIAS} dias (desde ${DESDE}) ==="
echo

PRS=$(gh pr list --state merged --limit 200 \
  --json number,title,createdAt,mergedAt,comments,reviews,additions,deletions \
  --jq "[.[] | select(.mergedAt >= \"${DESDE}\")]")

TOTAL=$(echo "$PRS" | jq 'length')
echo "PRs mergeados: ${TOTAL}"

if [ "$TOTAL" -eq 0 ]; then
  echo "(nada mergeado no período)"
  exit 0
fi

# 1. Tempo até merge — proxy de lead time
echo "$PRS" | jq -r '
  [ .[] | ((.mergedAt|fromdate) - (.createdAt|fromdate)) / 3600 ] as $h
  | "Tempo até merge (h): mediana \(($h|sort|.[(length/2|floor)])|.*10|round/10)  média \((($h|add)/($h|length))*10|round/10)"'

# 2. Fatia de PRs com comentário substantivo — sinal de escrutínio real.
#    Referência pública: na Anthropic esse número subiu de 16% para 54%
#    conforme a automação cresceu. Caindo = revisão virou carimbo.
echo "$PRS" | jq -r '
  (map(select((.comments|length) + (.reviews|length) > 0)) | length) as $c
  | "PRs com comentário/review: \($c)/\(length) (\(($c*100/length)|round)%)"'

# 3. Tamanho do diff — lote pequeno é uma das sete práticas que a DORA
#    associa a ganho real com IA.
echo "$PRS" | jq -r '
  [ .[] | .additions + .deletions ] as $d
  | "Tamanho do PR (linhas): mediana \($d|sort|.[(length/2|floor)])  máximo \($d|max)"'

# 4. Retrabalho — commits de correção depois do merge.
RETRABALHO=$(git log --since="${DESDE}" --oneline --no-merges \
  --grep='^fix' --grep='^revert' --grep='hotfix' -i | wc -l | tr -d ' ')
echo "Commits de correção/revert no período: ${RETRABALHO}"
if [ "$TOTAL" -gt 0 ]; then
  echo "Razão retrabalho/PR: $(echo "$RETRABALHO $TOTAL" | awk '{printf "%.2f", $1/$2}')"
fi

echo
echo "Anote estes números ANTES de automatizar mais disparo de agente."
echo "Linha de base não se coleta retroativamente."
