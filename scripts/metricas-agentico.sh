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

# Uma única chamada à API. Sai em TSV com 4 colunas:
#   1 horas_ate_merge  2 vozes_humanas  3 vozes_automatizadas  4 tamanho_diff
# Separar humano de bot é o que impede o número de mentir: comentário de deploy
# preview do Netlify não é revisão, e comentário do próprio autor também não.
gh pr list --state merged --limit 200 \
  --json number,author,createdAt,mergedAt,comments,reviews,additions,deletions \
  --jq "
    .[]
    | select(.mergedAt >= \"${DESDE}\")
    | (.author.login) as \$autor
    | ([ (.comments[]?.author.login), (.reviews[]?.author.login) ]) as \$vozes
    | ([ \$vozes[]
         | select(. != \$autor)
         | select(endswith(\"[bot]\") | not)
         | select(. as \$l | [\"netlify\",\"github-actions\",\"dependabot\",\"renovate\",\"codecov\",\"vercel\",\"sonarcloud\",\"coderabbitai\",\"claude\"] | index(\$l) | not)
       ] | length) as \$humanos
    | [ (((.mergedAt|fromdate) - (.createdAt|fromdate)) / 3600)
      , \$humanos
      , ((\$vozes|length) - \$humanos)
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
MEDIA_H=$(cut -f1 "$TMP" | awk '{s+=$1} END{print s/NR}')
# Abaixo de 1h a unidade "hora" esconde a informação: num repo solo todos os PRs
# são mergeados em minutos, e tudo vira 0.0.
echo "$MED_H $MEDIA_H" | awk '{
  if ($1 < 1) printf "Tempo até merge: mediana %.0f min  média %.0f min\n", $1*60, $2*60;
  else        printf "Tempo até merge: mediana %.1f h  média %.1f h\n", $1, $2 }'

# 2. Fatia de PRs com comentário substantivo — sinal de escrutínio real.
#    Referência pública: na Anthropic esse número subiu de 16%% para 54%%
#    conforme a automação cresceu. Caindo = revisão virou carimbo.
cut -f2 "$TMP" | awk -v t="$TOTAL" '$1>0{c++} END{printf "PRs com revisão HUMANA: %d/%d (%d%%)   <-- a métrica que importa\n", c, t, (c*100)/t}'
cut -f3 "$TMP" | awk -v t="$TOTAL" '$1>0{c++} END{printf "PRs com comentário automatizado: %d/%d (bot de deploy, revisor de IA — informativo)\n", c, t}'

# 3. Tamanho do diff — lote pequeno é uma das sete práticas que a DORA
#    associa a ganho real com IA.
MED_D=$(mediana 4)
MAX_D=$(cut -f4 "$TMP" | sort -n | tail -1)
echo "Tamanho do PR (linhas): mediana ${MED_D}  máximo ${MAX_D}"

# 4. Retrabalho — commits de correção depois do merge.
RETRABALHO=$(git log --since="${DESDE}" --oneline --no-merges \
  --grep='^fix' --grep='^revert' --grep='hotfix' -i | wc -l | tr -d ' ')
echo "Commits de correção/revert no período: ${RETRABALHO}"
echo "$RETRABALHO $TOTAL" | awk '{printf "Razão retrabalho/PR: %.2f\n", $1/$2}'

echo
echo "Anote estes números ANTES de automatizar mais disparo de agente."
echo "Linha de base não se coleta retroativamente."
