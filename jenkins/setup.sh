#!/usr/bin/env bash
set -e

# === Настройки (при необходимости поменяйте) ===
JENKINS_URL="${JENKINS_URL:-http://127.0.0.1:8080}"
ADMIN_USER="${ADMIN_USER:-admin}"
ADMIN_PASS="${ADMIN_PASS:-admin}"

# Список рекомендованных плагинов (из master/platform-plugins.json)
PLUGINS=(
  antisamy-markup-formatter
  build-timeout
  cloudbees-folder
  configuration-as-code
  credentials-binding
  email-ext
  git
  git-client
  github
  github-api
  github-branch-source
  gradle
  ldap
  mailer
  matrix-auth
  pam-auth
  pipeline-github-lib
  pipeline-stage-view
  ssh-slaves
  timestamper
  workflow-aggregator
  ws-cleanup
)

# === Работа ===
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "[*] Скачиваю jenkins-cli.jar ..."
curl -fsSL "$JENKINS_URL/jnlpJars/jenkins-cli.jar" -o "$TMP_DIR/jenkins-cli.jar"

echo "[*] Проверяю авторизацию ..."
java -jar "$TMP_DIR/jenkins-cli.jar" -s "$JENKINS_URL" -auth "$ADMIN_USER:$ADMIN_PASS" who-am-i >/dev/null

echo "[*] Устанавливаю рекомендуемые плагины ..."
java -jar "$TMP_DIR/jenkins-cli.jar" -s "$JENKINS_URL" -auth "$ADMIN_USER:$ADMIN_PASS" \
  install-plugin "${PLUGINS[@]}"

echo "[*] Делаю safe-restart ..."
java -jar "$TMP_DIR/jenkins-cli.jar" -s "$JENKINS_URL" -auth "$ADMIN_USER:$ADMIN_PASS" safe-restart

echo "[✓] Готово."