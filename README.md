# hermes-bootstrap

Bootstrap VPS baru setelah VPS lama mati: install Hermes, import otak (memory/skill/cron/token), nyalakan gateway. Tanpa secret.

```bash
cd ~
curl -fsSL -o bootstrap-hermes.sh https://raw.githubusercontent.com/Kirazee/hermes-bootstrap/refs/heads/main/bootstrap-hermes.sh
curl -fsSL -o hermes-backup-latest.zip https://raw.githubusercontent.com/Kirazee/hermes-bootstrap/refs/heads/main/bootstrap-hermes.sh  # GANTI dengan zip dari Telegram
bash bootstrap-hermes.sh ~/hermes-backup-YYYY-MM-DD.zip
```

Backup zip diambil dari DM Telegram bot (@sasaherbot).
