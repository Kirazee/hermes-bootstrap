#!/usr/bin/env bash
# Bootstrap Hermes di VPS baru: install (kalau belum ada) + import otak + start gateway.
#
# Pakai:
#   curl -fsSL https://raw.githubusercontent.com/Kirazee/hermes-bootstrap/main/bootstrap-hermes.sh | bash -s -- ~/hermes-backup-2026-11-01.zip
# atau lokal:
#   bash bootstrap-hermes.sh ~/hermes-backup-2026-11-01.zip
set -uo pipefail

ZIP="${1:-}"
say()  { printf '\n\033[1m== %s\033[0m\n' "$*"; }
ok()   { printf '   ✅ %s\n' "$*"; }
warn() { printf '   ⚠️  %s\n' "$*"; }
die()  { printf '   ❌ %s\n' "$*" >&2; exit 1; }

[ -n "$ZIP" ] || die "kasih path file backup: bash bootstrap-hermes.sh ~/hermes-backup-YYYY-MM-DD.zip"
[ -f "$ZIP" ] || die "file tidak ada: $ZIP"
python3 -c "import zipfile,sys; z=zipfile.ZipFile(sys.argv[1]); bad=z.testzip(); print('   ✅ arsip zip valid, '+str(len(z.namelist()))+' entri'); sys.exit(1 if bad else 0)" "$ZIP" \
  || die "zip korup: $ZIP"

export PATH="$HOME/.local/bin:$PATH"

say "1/4 Paket dasar"
if ! command -v git >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
  sudo -n apt-get update -qq && sudo -n apt-get install -y -qq git curl tar unzip >/dev/null 2>&1 \
    && ok "git/curl/unzip terpasang" || warn "gagal install paket dasar, lanjut coba"
else
  ok "git/curl sudah ada"
fi

say "2/4 Install Hermes"
if command -v hermes >/dev/null 2>&1; then
  ok "Hermes sudah terpasang: $(hermes --version 2>/dev/null | head -1)"
else
  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --non-interactive 2>&1 | tail -3
  export PATH="$HOME/.local/bin:$PATH"
  command -v hermes >/dev/null 2>&1 && ok "Hermes terpasang" || die "install Hermes gagal, cek ~/.hermes/logs/install.log"
fi

say "3/4 Import otak Hermes (memory, skill, cron, token)"
hermes import --force "$ZIP" 2>&1 | tail -5
ok "import selesai"

say "4/4 Nyalakan gateway"
export PATH="$HOME/.local/bin:$PATH"
systemctl --user daemon-reload 2>/dev/null
systemctl --user enable --now hermes-gateway 2>/dev/null \
  && ok "gateway aktif" || warn "unit gateway belum ada, coba: hermes gateway start"
loginctl enable-linger "$USER" 2>/dev/null && ok "linger aktif (auto-start setelah reboot)"

printf '\n\033[1mSELESAI\033[0m — cek Telegram, bot sudah nyambung lagi.\n'
printf 'Lanjut: kirim pesan "restore vps" ke bot, lalu ikuti instruksinya.\n'
printf 'Verifikasi manual: hermes doctor | hermes gateway status\n'
