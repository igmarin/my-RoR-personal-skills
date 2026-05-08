#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

failures=0

section() {
  printf '\n%s\n' "$1"
}

fail() {
  printf '✗ %s\n' "$1"
  failures=$((failures + 1))
}

pass() {
  printf '✓ %s\n' "$1"
}

section "Validating eval ownership"

tracked_root_evals="$(git ls-files 'evals/**')"
if [[ -n "$tracked_root_evals" ]]; then
  fail "root evals/ is generated Tessl staging output and must not be tracked"
  printf '%s\n' "$tracked_root_evals"
else
  pass "root evals/ has no tracked files"
fi

section "Validating personal eval scenarios"

while IFS= read -r scenario_dir; do
  relative_dir="${scenario_dir#./}"

  [[ -f "$scenario_dir/task.md" ]] || fail "$relative_dir is missing task.md"
  [[ -f "$scenario_dir/criteria.json" ]] || fail "$relative_dir is missing criteria.json"

  if [[ -f "$scenario_dir/criteria.json" ]]; then
    ruby -rjson -e 'data = JSON.parse(File.read(ARGV.fetch(0))); abort "missing weighted_checklist type" unless data["type"] == "weighted_checklist"; checklist = data.fetch("checklist"); total = checklist.sum { |item| item.fetch("max_score") }; abort "criteria total must be 100, got #{total}" unless total == 100' "$scenario_dir/criteria.json" \
      && pass "$relative_dir criteria.json is valid" \
      || fail "$relative_dir criteria.json failed validation"
  fi
done < <(find personal-evals -mindepth 1 -maxdepth 1 -type d | sort)

if [[ "$failures" -gt 0 ]]; then
  printf '\nFailed: %d\n' "$failures"
  exit 1
fi

printf '\nAll eval validations passed.\n'
