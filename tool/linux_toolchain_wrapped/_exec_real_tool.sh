#!/usr/bin/env bash
set -euo pipefail

tool_name="${1:?tool name required}"
shift

self_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

find_real_tool() {
  local candidate_dir dir_real candidate
  for candidate_dir in "$@"; do
    [[ -n "$candidate_dir" && -d "$candidate_dir" ]] || continue
    dir_real="$(cd "$candidate_dir" && pwd -P)"
    [[ "$dir_real" == "$self_dir" ]] && continue
    candidate="$candidate_dir/$tool_name"
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

IFS=':' read -r -a path_parts <<< "${PATH:-}"
real_tool="$(find_real_tool "${path_parts[@]}" /usr/bin /bin /usr/local/bin /usr/lib/llvm-18/bin || true)"

if [[ -z "$real_tool" && "$tool_name" == "ld.lld" ]]; then
  tool_name="ld"
  real_tool="$(find_real_tool "${path_parts[@]}" /usr/bin /bin /usr/local/bin /usr/lib/llvm-18/bin || true)"
fi

if [[ -z "$real_tool" ]]; then
  echo "Unable to locate real tool '$tool_name' outside $self_dir." >&2
  exit 1
fi

exec "$real_tool" "$@"