#!/usr/bin/env bash
# Claude Code statusline script
# Reads session JSON from stdin, outputs a vertical formatted status line
# Requires: jq

set -euo pipefail

if ! command -v jq &>/dev/null; then
  printf "\033[1;33m⚠ jq missing — brew install jq\033[0m"
  exit 0
fi

input=$(cat)

# Parse all fields in a single jq call
eval "$(echo "$input" | jq -r '
  "model=" + (.model.display_name // "" | @sh),
  "cwd=" + (.workspace.current_dir // "" | @sh),
  "cost_usd=" + (.cost.total_cost_usd // 0 | tostring | @sh),
  "duration_ms=" + (.cost.total_duration_ms // 0 | tostring | @sh),
  "api_duration_ms=" + (.cost.total_api_duration_ms // 0 | tostring | @sh),
  "lines_added=" + (.cost.total_lines_added // 0 | tostring | @sh),
  "lines_removed=" + (.cost.total_lines_removed // 0 | tostring | @sh),
  "used_pct=" + (.context_window.used_percentage // 0 | tostring | @sh),
  "total_output=" + (.context_window.total_output_tokens // 0 | tostring | @sh),
  "exceeds_200k=" + (.exceeds_200k_tokens // false | tostring | @sh),
  "version=" + (.version // "" | @sh),
  "session_id=" + (.session_id // "" | @sh)
' 2>/dev/null)"

if [[ -z "$model" && -z "$cwd" ]]; then
  echo "⚠ Statusline: data unavailable"
  exit 0
fi

# -- Colors (256-color with fallbacks) --
if [ -n "${NO_COLOR:-}" ] || [ "${TERM:-}" = "dumb" ]; then
  R="" BOLD="" DIM=""
  C_PATH="" C_GIT="" C_MODEL="" C_ADD="" C_DEL="" C_LABEL=""
else
  R="\033[0m"
  BOLD="\033[1m"
  DIM="\033[2m"
  C_PATH="\033[1;36m"
  C_GIT="\033[1;35m"
  C_MODEL="\033[1;38;5;213m"
  C_ADD="\033[1;38;5;46m"
  C_DEL="\033[1;38;5;208m"
  C_LABEL="\033[38;5;245m"
fi

# -- Directory --
dir="${cwd/#$HOME/~}"

# -- Git branch --
git_branch=""
git_dirty=""
if [ -n "$cwd" ] && command -v git &>/dev/null && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null | head -1)" ]; then
    git_dirty=" \033[1;38;5;214m●${R}"
  fi
fi

if [ -n "$git_branch" ]; then
  path_part=$(printf "${C_PATH}%s${R}  ${C_GIT} %s${R}%b" "$dir" "$git_branch" "${git_dirty:-}")
else
  path_part=$(printf "${C_PATH} %s${R}" "$dir")
fi

# -- Model --
model_part=$(printf "${C_MODEL}🤖 %s${R}" "$model")

# -- Cost with dynamic color --
read -r cost_fmt cost_cents <<< "$(echo "$cost_usd" | LANG=C awk '{printf "%.4f %d", $1, $1*10000}')"
if [ "$cost_cents" -lt 10000 ]; then
  C_COST="\033[1;38;5;46m"
elif [ "$cost_cents" -lt 50000 ]; then
  C_COST="\033[1;38;5;226m"
else
  C_COST="\033[1;38;5;196m"
fi
cost_part=$(printf "${C_COST}\$%s${R}" "$cost_fmt")

# -- Lines --
lines_part=$(printf "${C_ADD}+%s${R} ${C_DEL}-%s${R}" "${lines_added:-0}" "${lines_removed:-0}")

# -- API ratio + duration --
api_part=""
if [ "$duration_ms" -gt 0 ] 2>/dev/null && [ "$api_duration_ms" -gt 0 ] 2>/dev/null; then
  api_pct=$(( api_duration_ms * 100 / duration_ms ))
  if [ "$api_pct" -le 40 ]; then
    C_API="\033[38;5;78m"; api_icon="🌿"
  elif [ "$api_pct" -le 70 ]; then
    C_API="\033[38;5;220m"; api_icon="⚡"
  else
    C_API="\033[38;5;208m"; api_icon="🔥"
  fi
  total_sec=$(( duration_ms / 1000 ))
  if [ "$total_sec" -ge 3600 ]; then
    duration_fmt=$(printf "%dh%02dm" $(( total_sec / 3600 )) $(( (total_sec % 3600) / 60 )))
  elif [ "$total_sec" -ge 60 ]; then
    duration_fmt=$(printf "%dm%02ds" $(( total_sec / 60 )) $(( total_sec % 60 )))
  else
    duration_fmt=$(printf "%ds" "$total_sec")
  fi
  if [ "$total_sec" -ge 7200 ]; then
    C_DUR="\033[1;38;5;196m"
  elif [ "$total_sec" -ge 3600 ]; then
    C_DUR="\033[1;38;5;208m"
  elif [ "$total_sec" -ge 1800 ]; then
    C_DUR="\033[1;38;5;220m"
  else
    C_DUR="\033[38;5;78m"
  fi
  api_part=$(printf "${C_API}%s %s%%${R} │ ${C_DUR}⏱ %s${R}" "$api_icon" "$api_pct" "$duration_fmt")
fi

# -- Tokens output --
output_part=""
if [ "$total_output" -gt 0 ] 2>/dev/null; then
  C_OUTPUT="\033[1;38;5;117m"
  if [ "$total_output" -ge 1000 ]; then
    out_k="$(( total_output / 1000 )).$(( (total_output % 1000) / 100 ))"
    output_part=$(printf "${C_OUTPUT}✎ %sk${R}" "$out_k")
  else
    output_part=$(printf "${C_OUTPUT}✎ %s${R}" "$total_output")
  fi
fi

# -- Context bar --
pct="${used_pct%%.*}"
pct="${pct:-0}"
if [ "$pct" -le 33 ] 2>/dev/null; then
  C_CTX="\033[38;5;78m"
elif [ "$pct" -le 60 ] 2>/dev/null; then
  C_CTX="\033[38;5;220m"
elif [ "$pct" -le 80 ] 2>/dev/null; then
  C_CTX="\033[38;5;208m"
else
  C_CTX="\033[1;31m"
fi

filled=$(( pct / 10 ))
empty=$(( 10 - filled ))
bar_filled="" bar_empty=""
for ((i=0; i<filled; i++)); do bar_filled+="█"; done
for ((i=0; i<empty; i++)); do bar_empty+="░"; done

if [ "$pct" -gt 75 ] 2>/dev/null; then
  ctx_part=$(printf "\033[1;41;97m %s%s %s%% \033[0m" "$bar_filled" "$bar_empty" "$pct")
else
  ctx_part=$(printf "${BOLD}${C_CTX}%s\033[0m\033[38;5;240m%s\033[0m ${BOLD}${C_CTX}%s%%${R}" "$bar_filled" "$bar_empty" "$pct")
fi

# -- Exceeds 200k warning --
warn=""
if [ "$exceeds_200k" = "true" ]; then
  warn=$(printf " \033[1;5;41;97m ⚠ >200k \033[0m")
fi

# -- Permission mode (from hook temp file) --
mode=""
if [[ -n "$session_id" ]] && [[ -f "/tmp/claude-mode-${session_id}" ]]; then
  mode=$(cat "/tmp/claude-mode-${session_id}" 2>/dev/null || true)
fi

mode_part=""
case "$mode" in
  plan)              mode_part=$'\033[1;35m📋 PLAN\033[0m' ;;
  acceptEdits)       mode_part=$'\033[1;33m✏️  AUTO-EDIT\033[0m' ;;
  dontAsk)           mode_part=$'\033[1;31m🚀 YOLO\033[0m' ;;
  bypassPermissions) mode_part=$'\033[1;31m⚠️  BYPASS\033[0m' ;;
  *)                 mode_part="" ;;
esac

# -- Output (vertical layout with aligned labels) --
printf "%b\n" "$(printf "${C_LABEL}📂 Directory  ${R}")$path_part"
printf "%b\n" "$(printf "${C_LABEL}🤖 Model      ${R}")$model_part"
printf "%b\n" "$(printf "${C_LABEL}💰 Cost       ${R}")$cost_part"
printf "%b\n" "$(printf "${C_LABEL}📝 Lines      ${R}")$lines_part"
if [ -n "$api_part" ]; then
  printf "%b\n" "$(printf "${C_LABEL}⚡ API        ${R}")$api_part"
fi
if [ -n "$output_part" ]; then
  printf "%b\n" "$(printf "${C_LABEL}✎ Tokens     ${R}")$output_part"
fi
printf "%b\n" "$(printf "${C_LABEL}📊 Context    ${R}")${ctx_part}${warn}"
if [ -n "$mode_part" ]; then
  printf "%b\n" "$(printf "${C_LABEL}🔒 Mode       ${R}")$mode_part"
fi
printf "%b"   "$(printf "${C_LABEL}📡 Claude     ${R}")$(printf "\033[38;5;245mv%s${R}" "$version")"
