#!/usr/bin/env bash
# Create GitHub repo and push (requires: gh auth login).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
export PATH="${HOME}/bin:${PATH}"

VISIBILITY="${VISIBILITY:-public}"
REPO_NAME="${REPO_NAME:-1d-arc}"

if ! gh auth status >/dev/null 2>&1; then
  echo "Not logged in. Run: gh auth login --hostname github.com --git-protocol ssh --web"
  exit 1
fi

OWNER="$(gh api user -q .login)"
echo "Creating ${OWNER}/${REPO_NAME} (${VISIBILITY})..."

if gh repo view "${OWNER}/${REPO_NAME}" >/dev/null 2>&1; then
  echo "Repo already exists."
else
  gh repo create "${REPO_NAME}" --"${VISIBILITY}" --source=. --remote=origin --description "1D-ARC relational decomposition evaluation (Popper / IJCAI 2025)"
fi

git remote remove origin 2>/dev/null || true
git remote add origin "git@github.com:${OWNER}/${REPO_NAME}.git"
git push -u origin main
echo "Pushed: https://github.com/${OWNER}/${REPO_NAME}"
