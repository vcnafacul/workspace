#!/usr/bin/env bash
# Cria UM draft no Project #2 (sem issue em repo) e seta os campos numa mutation só. 2 escritas, em série, sem retry.
# Uso: criar-card.sh "<título>" <arquivo-do-corpo.md>
# Variáveis (ids em references/campos-do-board.md); vazias = não seta:
#   STATUS   (default 61e4505c = To Do)   PRIORITY (default 0a877460 = Internal-P1)
#   FLAG     (default c5e82f1d = Task)    EPIC  STORY  AREA
#   DRY_RUN=1 → só imprime os comandos, não escreve nada.
set -euo pipefail

[[ "${1:-}" == "--help" || $# -ne 2 ]] && { sed -n '2,8p' "$0"; exit 1; }
TITLE="$1"; BODY_FILE="$2"
[[ -f "$BODY_FILE" ]] || { echo "corpo não encontrado: $BODY_FILE" >&2; exit 1; }

PROJECT_ID="PVT_kwDOB6mE5M4AjJiB"
F_STATUS="PVTSSF_lADOB6mE5M4AjJiBzgbjmb8"; F_PRIORITY="PVTSSF_lADOB6mE5M4AjJiBzgbjmec"
F_FLAG="PVTSSF_lADOB6mE5M4AjJiBzgbuh3s";   F_AREA="PVTSSF_lADOB6mE5M4AjJiBzgbjmeg"
F_EPIC="PVTSSF_lADOB6mE5M4AjJiBzgcwalQ";   F_STORY="PVTSSF_lADOB6mE5M4AjJiBzgcwbO4"
STATUS="${STATUS-61e4505c}"; PRIORITY="${PRIORITY-0a877460}"; FLAG="${FLAG-c5e82f1d}"
EPIC="${EPIC-}"; STORY="${STORY-}"; AREA="${AREA-}"
DRY_RUN="${DRY_RUN:-0}"

# 1/2 — draft no board
echo "1/2 gh project item-create 2 --owner vcnafacul (draft)"
if [[ "$DRY_RUN" == "1" ]]; then
  echo "[dry-run] gh project item-create 2 --owner vcnafacul --title $(printf %q "$TITLE") --body \"\$(cat $BODY_FILE)\" --format json"
  ITEM_ID="PVTI_dry"
else
  ITEM_ID=$(gh project item-create 2 --owner vcnafacul --title "$TITLE" --body "$(cat "$BODY_FILE")" --format json \
            | python3 -c 'import sys,json; print(json.load(sys.stdin)["id"])')
fi
echo "   item: $ITEM_ID"
sleep 2

# 2/2 — campos numa mutation só (aliases)
build() { # alias field option
  [[ -z "$3" ]] && return 0
  printf '%s: updateProjectV2ItemFieldValue(input:{projectId:"%s", itemId:"%s", fieldId:"%s", value:{singleSelectOptionId:"%s"}}){ projectV2Item { id } }\n' "$1" "$PROJECT_ID" "$ITEM_ID" "$2" "$3"
}
MUT="mutation {
$(build s "$F_STATUS" "$STATUS")$(build p "$F_PRIORITY" "$PRIORITY")$(build f "$F_FLAG" "$FLAG")$(build e "$F_EPIC" "$EPIC")$(build t "$F_STORY" "$STORY")$(build a "$F_AREA" "$AREA")}"
echo "2/2 gh api graphql (campos: status=$STATUS priority=$PRIORITY flag=$FLAG epic=${EPIC:--} story=${STORY:--} area=${AREA:--})"
if [[ "$DRY_RUN" == "1" ]]; then echo "$MUT"; else gh api graphql -f query="$MUT" >/dev/null; fi

echo "pronto: draft $ITEM_ID — https://github.com/orgs/vcnafacul/projects/2"
