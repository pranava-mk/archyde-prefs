# OverTheWire password manager (Bandit)
_OTW_CSV="$HOME/overthewirepasswords.csv"
_OTW_HOST="bandit.labs.overthewire.org"
_OTW_PORT="2220"

_otw_init() {
  local now; now=$(date -Iseconds)

  if [[ ! -f "$_OTW_CSV" ]]; then
    echo "level,password,date" > "$_OTW_CSV"
    return
  fi

  local header; header=$(head -1 "$_OTW_CSV")

  # Migrate 2-column → 3-column, stamping today's date on existing rows
  if [[ "$header" == "level,password" ]]; then
    local tmp; tmp=$(mktemp)
    echo "level,password,date" > "$tmp"
    awk -F',' -v d="$now" 'NR>1 && $1!="" {print $1","$2","d}' "$_OTW_CSV" >> "$tmp"
    mv "$tmp" "$_OTW_CSV"
    return
  fi

  # Backfill any rows that still have an empty date field
  if awk -F',' 'NR>1 && $1!="" && $3==""' "$_OTW_CSV" | grep -q .; then
    local tmp; tmp=$(mktemp)
    awk -F',' -v d="$now" \
      'NR==1{print;next} $1!="" && $3==""{print $1","$2","d;next} {print}' \
      "$_OTW_CSV" > "$tmp"
    mv "$tmp" "$_OTW_CSV"
  fi
}

alias otwcat='_otw_init && column -t -s "," "$_OTW_CSV" | bat --style=grid'

otw() {
  _otw_init

  case "$1" in
    -s|save)
      local level password existing confirm date tmp

      printf "Level: "; read -r level
      [[ "$level" =~ ^[0-9]+$ ]] || { echo "Error: level must be a number" >&2; return 1; }

      existing=$(awk -F',' -v l="$level" 'NR>1 && $1==l {print $2}' "$_OTW_CSV")
      if [[ -n "$existing" ]]; then
        echo "Level $level already saved (${existing:0:8}...)"
        printf "Overwrite? [y/N] "; read -r confirm
        [[ "$confirm" == [yY] ]] || { echo "Cancelled."; return 0; }
      fi

      printf "Password: "; read -r password
      [[ -n "$password" ]] || { echo "Error: password cannot be empty" >&2; return 1; }

      date=$(date -Iseconds)
      tmp=$(mktemp)

      if [[ -n "$existing" ]]; then
        awk -F',' -v l="$level" -v p="$password" -v d="$date" \
          'NR==1{print;next} $1==l{print l","p","d;next} {print}' \
          "$_OTW_CSV" > "$tmp"
        echo "Updated level $level  ($date)"
      else
        cp "$_OTW_CSV" "$tmp"
        echo "$level,$password,$date" >> "$tmp"
        echo "Saved level $level  ($date)"
      fi
      mv "$tmp" "$_OTW_CSV"
      ;;

    -c|connect)
      local level="${2:-}"
      if [[ -z "$level" ]]; then
        printf "Level: "; read -r level
      fi
      [[ "$level" =~ ^[0-9]+$ ]] || { echo "Error: level must be a number" >&2; return 1; }

      local password
      password=$(awk -F',' -v l="$level" 'NR>1 && $1==l {print $2}' "$_OTW_CSV")
      if [[ -z "$password" ]]; then
        echo "No password saved for level $level. Run: otw save"
        return 1
      fi

      local user="bandit${level}"
      echo "$password" | wl-copy 2>/dev/null
      echo "  Password copied to clipboard."
      echo "→ ssh ${user}@${_OTW_HOST} -p ${_OTW_PORT}"
      ssh "${user}@${_OTW_HOST}" -p "${_OTW_PORT}"
      ;;

    -p|--progress|progress)
      local total
      total=$(awk -F',' 'NR>1 && $1!="" {c++} END{print c+0}' "$_OTW_CSV")
      [[ $total -eq 0 ]] && { echo "No passwords saved yet. Use 'otw save'."; return 0; }

      echo
      printf "  %-6s  %-17s  %s\n" "Level" "Date" "Since prev"
      printf "  %-6s  %-17s  %s\n" "------" "-----------------" "----------"

      local prev_ts=0
      while IFS=',' read -r level pass date; do
        [[ "$level" == "level" || -z "$level" ]] && continue
        local ts=0 delta="—" display_date="(no date)"
        if [[ -n "$date" ]]; then
          ts=$(date -d "$date" +%s 2>/dev/null || echo 0)
          display_date=$(date -d "$date" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "$date")
        fi
        if [[ $prev_ts -gt 0 && $ts -gt 0 ]]; then
          local diff=$((ts - prev_ts))
          local d=$((diff/86400)) h=$(( (diff%86400)/3600 )) m=$(( (diff%3600)/60 ))
          if   [[ $d -gt 0 ]]; then delta="${d}d ${h}h"
          elif [[ $h -gt 0 ]]; then delta="${h}h ${m}m"
          else delta="${m}m"; fi
        elif [[ $prev_ts -eq 0 ]]; then delta="(start)"; fi

        printf "  %-6s  %-17s  %s\n" "$level" "$display_date" "$delta"
        [[ $ts -gt 0 ]] && prev_ts=$ts
      done < <(awk -F',' 'NR>1 && $1!="" {print}' "$_OTW_CSV" | sort -t',' -k1,1n)

      echo
      printf "  Levels completed: %s\n" "$total"

      local first last
      first=$(awk -F',' 'NR>1 && $3!="" {print $3}' "$_OTW_CSV" | sort    | head -1)
      last=$( awk -F',' 'NR>1 && $3!="" {print $3}' "$_OTW_CSV" | sort -r | head -1)
      if [[ -n "$first" && -n "$last" && "$first" != "$last" ]]; then
        local fts lts span tdays
        fts=$(date -d "$first" +%s)
        lts=$(date -d "$last" +%s)
        span=$((lts - fts))
        tdays=$((span / 86400))
        printf "  Started:  %s\n" "$(date -d "$first" '+%Y-%m-%d')"
        printf "  Latest:   %s\n" "$(date -d "$last"  '+%Y-%m-%d')"
        printf "  Duration: %s days\n" "$tdays"
        if [[ $total -gt 1 ]]; then
          local avgh=$((span / (total - 1) / 3600))
          printf "  Avg/level: ~%sh\n" "$avgh"
        fi
      fi
      echo
      ;;

    -l|latest)
      awk -F',' 'NR>1 && $1+0>max+0 {max=$1; pass=$2} END{if(max) print max, pass; else exit 1}' "$_OTW_CSV"
      ;;

    -h|--help|help)
      cat <<'EOF'
otw — OverTheWire Bandit password manager

  otw <level>          Retrieve password for a level
  otw save             Save/update a password (interactive)
  otw connect <level>  SSH into bandit<level>, password auto-copied to clipboard
  otw latest           Show highest completed level + password
  otw progress         Show timeline with dates and time deltas
  otw help             Show this help

  otwcat               Pretty-print the full password file
EOF
      ;;

    "")
      echo "Usage: otw <level|save|connect|latest|progress|help>"
      return 1
      ;;

    *)
      local result
      result=$(awk -F',' -v l="$1" 'NR>1 && $1==l {print $2}' "$_OTW_CSV")
      if [[ -z "$result" ]]; then
        echo "No password found for level $1"; return 1
      fi
      echo "$result"
      ;;
  esac
}
