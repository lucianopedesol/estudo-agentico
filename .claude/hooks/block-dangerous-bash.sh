#!/bin/sh
# Hook PreToolUse do Claude Code — roda ANTES de qualquer chamada de Bash.
# Recebe no stdin um JSON com a chamada de ferramenta (tool_name, tool_input).
# Bloqueia (exit code 2) o que settings.json não consegue expressar:
# decisões que dependem do ESTADO do repo, não só do texto do comando.

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')

case "$command" in
  "git commit"*)
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
      echo "Bloqueado pelo hook de guardrails: commit direto na branch '$branch'." >&2
      echo "Crie uma branch antes de commitar, ex.: git checkout -b feature/minha-mudanca" >&2
      exit 2
    fi
    ;;
esac

exit 0
