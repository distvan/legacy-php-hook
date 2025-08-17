#!/bin/bash
#pre-commit hook: Run PHP Code Sniffer only on changed files
HOWTO_RUN_PHPCS="./vendor/bin/phpcs --standard=src/MyCodeStandard/ruleset-newcode-legacy.xml"

#fail immediately if a command exist with a non-zero status
set -e

# Function: get changed lines in a file from staged changes
get_changed_lines() {
  local file="$1"
  git diff --cached -U0 -- "$file" \
    | grep -E '^@@' \
    | sed -E 's/^@@ .* \+([0-9]+)(,([0-9]+))? @@.*/\1 \3/' \
    | while read start count; do
        [ -z "$count" ] && count=1
        seq "$start" $((start + count - 1))
      done
}

# Function: Filter PHPCS output to only issues on changed lines
filter_phpcs_output() {
  local file="$1"
  local phpcs_output="$2"
  local changed_lines
  changed_lines=$(get_changed_lines "$file")
  # If there are no changed lines (file staged but no code changes), skip
  [ -z "$changed_lines" ] && return

  declare -A changed_map
  for line in $changed_lines; do
    changed_map["$line"]=1
  done

  # Keep only lines where the issue is in changed lines
  while IFS= read -r phpcs_line; do
    lineno=$(echo "$phpcs_line" | awk -F: '{print $2}')
    if [ -n "${changed_map[$lineno]}" ]; then
      echo "$phpcs_line"
    fi
  done <<< "$phpcs_output"
}

echo "Running PHPCS on changed lines only..."

# Track if we have any blocking issues
errors_found=false

# Loop over staged (Added, Copied, Modified) PHP files
for file in $(git diff --cached --name-only --diff-filter=ACM | grep -E '\.php$'); do
  # Run PHPCS on the file
  phpcs_output=$($HOWTO_RUN_PHPCS --report=emacs "$file" || true)
  # Filter output
  filtered=$(filter_phpcs_output "$file" "$phpcs_output")
  if [ -n "$filtered" ]; then
    echo "PHPCS issues in changed lines for $file:"
    echo "$filtered"
    errors_found=true
  fi
done

# If any errors found, show it but don't block the commit
if [ "$errors_found" = true ]; then
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "Commit has PHPCS violations in changed lines."
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  exit 0
fi

echo "PHPCS passed for changed lines."
exit 0