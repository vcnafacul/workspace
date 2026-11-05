#!/usr/bin/env bash
# Clona, atualiza e mostra o estado dos repos listados em repos.txt.
# Precisa rodar no bash 3.2 (macOS): sem arrays associativos, mapfile ou ${var,,}.
set -u

RAIZ="$(cd "$(dirname "$0")" && pwd)"
MANIFESTO="$RAIZ/repos.txt"
ORG="vcnafacul"
FALHOU=0

# Preenchidas por cada_repo para o callback.
nome=""
branch=""
opcional=0
dir=""

uso() {
  cat <<'EOF'
Uso: ./ws [comando]

  clonar [--com <nome>]... [--todos]   clona o que falta e cria os .env locais (padrão)
  atualizar                            fetch em todos; fast-forward só nos limpos na branch padrão
  status [--curto]                     estado dos repos, sem fetch
EOF
}

erro_fatal() {
  printf '✖ %s\n' "$1" >&2
  exit 1
}

tem() {
  command -v "$1" >/dev/null 2>&1
}

# Chama "$1" uma vez por linha do manifesto. Lê pelo fd 3 para que git e gh não
# consumam o manifesto pelo stdin.
cada_repo() {
  [ -f "$MANIFESTO" ] || erro_fatal "repos.txt não encontrado em $RAIZ"
  local callback="$1" linha campo
  while IFS= read -r linha <&3 || [ -n "$linha" ]; do
    linha="${linha%%#*}"
    # shellcheck disable=SC2086 # a separação em campos é intencional
    set -- $linha
    [ "$#" -gt 0 ] || continue
    nome="$1"
    shift
    branch=""
    opcional=0
    for campo in "$@"; do
      if [ "$campo" = "opcional" ]; then
        opcional=1
      else
        branch="$campo"
      fi
    done
    dir="$RAIZ/$nome"
    "$callback"
  done 3<"$MANIFESTO"
}

origem_confere() {
  local url
  url="$(git -C "$dir" config --get remote.origin.url 2>/dev/null)" || return 1
  url="${url%/}"
  url="${url%.git}"
  case "$url" in
    "https://github.com/$ORG/$nome" | "git@github.com:$ORG/$nome" | "ssh://git@github.com/$ORG/$nome")
      return 0
      ;;
  esac
  return 1
}

# ausente | ok | outro. O teste de .git impede que o git suba até o repo do workspace.
estado_pasta() {
  if [ ! -e "$dir" ]; then
    echo ausente
  elif [ -e "$dir/.git" ] && origem_confere; then
    echo ok
  else
    echo outro
  fi
}

branch_padrao() {
  if [ -n "$branch" ]; then
    printf '%s\n' "$branch"
    return
  fi
  local ref
  ref="$(git -C "$dir" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)" || ref=""
  printf '%s\n' "${ref#origin/}"
}

branch_atual() {
  git -C "$dir" symbolic-ref --quiet --short HEAD 2>/dev/null || git -C "$dir" rev-parse --short HEAD 2>/dev/null
}

esta_sujo() {
  [ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]
}

copiar_se_faltar() {
  local origem="$1" destino="$2"
  if [ -e "$dir/$origem" ] && [ ! -e "$dir/$destino" ]; then
    cp "$dir/$origem" "$dir/$destino" && printf '+ %s/%s criado a partir do %s\n' "$nome" "$destino" "$origem"
  fi
}

copiar_envs() {
  copiar_se_faltar .env.example .env
  if [ "$nome" = "vcnafacul-stack" ]; then
    copiar_se_faltar .env.compose.example .env.compose
  fi
}

clonar_repo() {
  if tem gh && gh repo clone "$ORG/$nome" "$dir"; then
    :
  elif [ ! -e "$dir" ] && git clone "https://github.com/$ORG/$nome.git" "$dir"; then
    :
  else
    printf '✖ %s: falha ao clonar\n' "$nome" >&2
    FALHOU=1
    return 1
  fi
  if [ -n "$branch" ] && ! git -C "$dir" checkout "$branch"; then
    printf '⚠ %s: branch %s não encontrada\n' "$nome" "$branch" >&2
  fi
  printf '✔ %s clonado\n' "$nome"
}

COM=""
TODOS=0

foi_pedido() {
  [ "$opcional" = 0 ] && return 0
  [ "$TODOS" = 1 ] && return 0
  case " $COM " in
    *" $nome "*) return 0 ;;
  esac
  return 1
}

clonar_um() {
  case "$(estado_pasta)" in
    ok)
      foi_pedido && printf '✔ %s\n' "$nome"
      copiar_envs
      ;;
    outro)
      if foi_pedido; then
        printf '⚠ %s: pasta existe e não é %s/%s — ignorada\n' "$nome" "$ORG" "$nome"
      fi
      ;;
    ausente)
      if foi_pedido && clonar_repo; then
        copiar_envs
      fi
      ;;
  esac
}

NOMES=""
coletar_nome() {
  NOMES="$NOMES $nome "
}

cmd_clonar() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --com)
        [ "$#" -ge 2 ] || erro_fatal "--com precisa de um nome"
        COM="$COM $2"
        shift 2
        ;;
      --todos)
        TODOS=1
        shift
        ;;
      *)
        uso >&2
        erro_fatal "opção desconhecida: $1"
        ;;
    esac
  done

  cada_repo coletar_nome
  local pedido
  for pedido in $COM; do
    case "$NOMES" in
      *" $pedido "*) ;;
      *) erro_fatal "$pedido não está no repos.txt" ;;
    esac
  done

  tem gh || printf '⚠ gh não encontrado: clonando por HTTPS. Agentes precisam do gh para abrir PRs.\n'
  tem docker || printf '⚠ docker não encontrado: a stack precisa dele.\n'

  cada_repo clonar_um

  printf '\nValores de homologação não ficam no repo: peça ao time (em privado).\n'
  printf 'Instale o plugin: claude plugin install superpowers@claude-plugins-official --scope project\n'
  return "$FALHOU"
}

atualizar_um() {
  [ "$(estado_pasta)" = "ok" ] || return 0

  if ! git -C "$dir" fetch --prune --quiet; then
    printf '⚠ %s: fetch falhou\n' "$nome"
    return 0
  fi

  local padrao atual contagem frente atras
  padrao="$(branch_padrao)"
  if [ -z "$padrao" ]; then
    git -C "$dir" remote set-head origin --auto >/dev/null 2>&1
    padrao="$(branch_padrao)"
  fi
  if [ -z "$padrao" ]; then
    printf '⚠ %s: branch padrão desconhecida\n' "$nome"
    return 0
  fi

  atual="$(branch_atual)"
  if esta_sujo; then
    printf '⚠ %s: com mudanças\n' "$nome"
  elif [ "$atual" != "$padrao" ]; then
    printf '⚠ %s: em %s\n' "$nome" "$atual"
  elif ! contagem="$(git -C "$dir" rev-list --left-right --count "HEAD...origin/$padrao" 2>/dev/null)"; then
    printf '⚠ %s: origin/%s não encontrada\n' "$nome" "$padrao"
  else
    # shellcheck disable=SC2086 # a separação em campos é intencional
    set -- $contagem
    frente="$1"
    atras="$2"
    if [ "$frente" -gt 0 ] && [ "$atras" -gt 0 ]; then
      printf '⚠ %s: divergiu de origin/%s\n' "$nome" "$padrao"
    elif [ "$atras" -eq 0 ]; then
      printf '✔ %s: em dia\n' "$nome"
    elif git -C "$dir" pull --ff-only --quiet; then
      printf '✔ %s: atualizado (%s commits)\n' "$nome" "$atras"
    else
      printf '⚠ %s: pull falhou\n' "$nome"
    fi
  fi
}

CURTO=0

status_um() {
  local estado padrao atual limpeza contagem frente=0 atras=0 relacao problemas=""
  estado="$(estado_pasta)"

  if [ "$estado" != "ok" ]; then
    [ "$opcional" = 1 ] && return 0
    local motivo="não clonado"
    [ "$estado" = "outro" ] && motivo="pasta não é $ORG/$nome"
    if [ "$CURTO" = 1 ]; then
      printf '⚠ %s: %s\n' "$nome" "$motivo"
    else
      printf '%-20s %s\n' "$nome" "($motivo)"
    fi
    return 0
  fi

  padrao="$(branch_padrao)"
  atual="$(branch_atual)"
  limpeza="limpo"
  esta_sujo && limpeza="sujo"

  if contagem="$(git -C "$dir" rev-list --left-right --count "HEAD...@{upstream}" 2>/dev/null)"; then
    # shellcheck disable=SC2086 # a separação em campos é intencional
    set -- $contagem
    frente="$1"
    atras="$2"
    relacao="+$frente/-$atras"
  else
    relacao="sem upstream"
  fi

  if [ "$CURTO" = 0 ]; then
    printf '%-20s %-34s %-6s %s\n' "$nome" "$atual" "$limpeza" "$relacao"
    return 0
  fi

  [ "$limpeza" = "sujo" ] && problemas="sujo"
  if [ -n "$padrao" ] && [ "$atual" != "$padrao" ]; then
    problemas="${problemas:+$problemas, }em $atual"
  fi
  if [ "$atras" -gt 0 ]; then
    problemas="${problemas:+$problemas, }$atras atrás"
  fi
  [ -z "$problemas" ] || printf '⚠ %s: %s\n' "$nome" "$problemas"
}

cmd_status() {
  case "${1:-}" in
    "") ;;
    --curto) CURTO=1 ;;
    *)
      uso >&2
      erro_fatal "opção desconhecida: $1"
      ;;
  esac
  if [ "$CURTO" = 0 ]; then
    printf '%-20s %-34s %-6s %s\n' "repo" "branch" "estado" "+frente/-atrás"
  fi
  cada_repo status_um
}

tem git || erro_fatal "git não encontrado"

comando="${1:-clonar}"
[ "$#" -eq 0 ] || shift

case "$comando" in
  clonar) cmd_clonar "$@" ;;
  atualizar) cada_repo atualizar_um ;;
  status) cmd_status "$@" ;;
  ajuda | -h | --help) uso ;;
  *)
    uso >&2
    erro_fatal "comando desconhecido: $comando"
    ;;
esac
