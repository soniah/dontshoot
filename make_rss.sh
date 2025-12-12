#!/usr/bin/env bash
set -euo pipefail

# Config
USERNAME="soniah"
REPONAME="dontshoot"
OBFUSCATED_DIR="8f12ab"
BASE_URL="https://${USERNAME}.github.io/${REPONAME}/podcast/${OBFUSCATED_DIR}"

# Go to repo root (directory where this script lives)
cd "$(dirname "$0")"

EP_DIR="podcast/${OBFUSCATED_DIR}"

if [ ! -d "$EP_DIR" ]; then
  echo "Episode directory '$EP_DIR' not found" >&2
  exit 1
fi

cd "$EP_DIR"

RSS_FILE="rss.xml"

# Generate rss.xml
{
  echo '<?xml version="1.0" encoding="UTF-8"?>'
  echo '<rss version="2.0">'
  echo '  <channel>'
  echo '    <title>Don'"'"'t Shoot The Dog</title>'
  echo "    <link>${BASE_URL}/</link>"
  echo '    <description>Private feed</description>'
  echo '    <language>en-us</language>'

  # Simple pubDate template – same date for all episodes is fine
  PUBDATE="Tue, 01 Jan 2030 00:00:00 GMT"

  for f in dont_*.m4a; do
    [ -e "$f" ] || continue
    size=$(stat -f%z "$f")
    guid=$(shasum -a256 "$f" | awk '{print $1}')
    title="${f%.m4a}"
    url="${BASE_URL}/${f}"

    echo '    <item>'
    echo "      <title>${title}</title>"
    echo "      <enclosure url=\"${url}\" type=\"audio/mp4\" length=\"${size}\" />"
    echo "      <guid>${guid}</guid>"
    echo "      <pubDate>${PUBDATE}</pubDate>"
    echo '    </item>'
  done

  echo '  </channel>'
  echo '</rss>'
} > "${RSS_FILE}"

echo "Wrote ${EP_DIR}/${RSS_FILE}"

# Go back to repo root for git commands
cd - >/dev/null

# Ensure we are in a git repo; init if needed
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init
fi

git add "${EP_DIR}/rss.xml" "${EP_DIR}"/dont_*.m4a
git commit -m "Add Don't Shoot The Dog podcast feed and episodes" || {
  echo "Nothing to commit (perhaps already committed)."
}

