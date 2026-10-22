#!/bin/sh
# Métricas de processo do fluxo agentic (plano P5 da arquitetura-alvo).
#
# Mede processo, não volume: linhas de código e número de PRs sobem por construção
# quando se usa agente, e não dizem se o fluxo está saudável.
#
# Requisitos: git, gh (autenticado), awk. NÃO precisa de jq instalado — usa o
# avaliador de expressões que o próprio gh já embute na flag --jq.
# Uso: sh scripts/metricas-agentico.sh [dias]   (padrão: 14)

set -e
DIAS="${1:-14}"
DESDE=$(date -u -d "-${DIAS} days" +%Y-%m-%d 2>/dev/null || date -u -v-"${DIAS}"d +%Y-%m-%d)

command -v gh >/dev/null 2>&1 || { echo "Faltando: gh (https://cli.github.com)"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "gh não autenticado — rode: gh auth login"; exit 1; }

echo "=== Métricas do fluxo agentic — últimos ${DIAS} dias (desde ${DESDE}) ==="
echo

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

# Uma única chamada à API. Sai em TSV: horas_ate_merge, interacoes, tamanho_diff.
# A filtragem e a aritmética de data acontecem dentro do --jq do gh.
gh pr list --state merged --limit 200 \
  --json number,createdAt,mergedAt,comments,reviews,additions,deletions \
  --jq "
    .[]
    | select(.mergedAt >= \"${DESDE}\")
    | [ (((.mergedAt|fromdate) - (.createdAt|fromdate)) / 3600)
      , ((.comments|length) + (.reviews|length))
      , (.additions + .deletions)
      ]
    | @tsv
  " > "$TMP"

TOTAL=$(wc -l < "$TMP" | tr -d ' ')
echo "PRs mergeados: ${TOTAL}"

if [ "$TOTAL" -eq 0 ]; then
  echo "(nada mergeado no período — tente um intervalo maior, ex: sh $0 60)"
  exit 0
fi

mediana() { cut -f"$1" "$TMP" | sort -n | awk '{v[NR]=$1} END{print v[int((NR+1)/2)]}'; }

# 1. Tempo até merge — proxy de lead time
MED_H=$(mediana 1)
MEDIA_H=$(cut -f1 "$TMP" | awk '{s+=$1} END{printf "%.1f", s/NR}')
printf "Tempo até merge (h): mediana %.1f  média %s\n" "$MED_H" "$MEDIA_H"

# 2. Fatia de PRs com comentário substantivo — sinal de escrutínio real.
#    Referência pública: na Anthropic esse número subiu de 16%% para 54%%
#    conforme a automação cresceu. Caindo = revisão virou carimbo.
cut -f2 "$TMP" | awk -v t="$TOTAL" '$1>0{c++} END{printf "PRs com comentário/review: %d/%d (%d%%)\n", c, t, (c*100)/t}'

# 3. Tamanho do diff — lote pequeno é uma das sete práticas que a DORA
#    associa a ganho real com IA.
MED_D=$(mediana 3)
MAX_D=$(cut -f3 "$TMP" | sort -n | tail -1)
echo "Tamanho do PR (linhas): mediana ${MED_D}  máximo ${MAX_D}"

# 4. Retrabalho — commits de correção depois do merge.
RETRABALHO=$(git log --since="${DESDE}" --oneline --no-merges \
  --grep='^fix' --grep='^revert' --grep='hotfix' -i | wc -l | tr -d ' ')
echo "Commits de correção/revert no período: ${RETRABALHO}"
echo "$RETRABALHO $TOTAL" | awk '{printf "Razão retrabalho/PR: %.2f\n", $1/$2}'

echo
echo "Anote estes números ANTES de automatizar mais disparo de agente."
echo "Linha de base não se coleta retroativamente."
