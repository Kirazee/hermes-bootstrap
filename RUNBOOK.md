# RUNBOOK — Kalau VPS Mati Permanen

Ditulis 2026-11-01. Simpan juga di DM Telegram (@sasaherbot).

## Yang lo punya (semua di DM Telegram bot @sasaherbot)

| File | Isi | Kapan dikirim |
|---|---|---|
| `db-YYYY-MM-DD.sql.gz` | database MySQL toko (produk, order, deposit) | tiap hari 03:45 |
| `swanlakekode-db-YYYY-MM-DD.json.gz` | data aplikasi toko-kode (akun, token) | tiap hari 03:45 |
| `vps-config-YYYY-MM-DD.tar.gz` | kode app, nginx, pm2, crontab, .env, systemd, META | harian/manual |
| `hermes-backup-YYYY-MM-DD.zip` | seluruh otak Hermes: memory, skill, cron, sesi | manual/mingguan |

Kode juga ada di GitHub private: `Kirazee/swanlake-toko`, `Kirazee/swanlake-kode`.

## Langkah

### 1. VPS baru
Beli Ubuntu 22.04/24.04, minimal 2 vCPU / 4 GB RAM / 60 GB. Catat IP-nya.

### 2. Pasang Hermes (satu perintah)
```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --non-interactive
```

### 3. Hidupkan otak Hermes
Download `hermes-backup-*.zip` dari DM Telegram ke VPS baru, lalu:
```bash
hermes import hermes-backup-2026-11-01.zip
```
Setelah ini Hermes punya memory, skill, cron, dan token bot yang sama.

### 4. Pindahkan bahan pemulihan
Download 3 file dari DM Telegram (`db-*.sql.gz`, `swanlakekode-db-*.json.gz`,
`vps-config-*.tar.gz`) ke `/home/ubuntu/backup/`, lalu jalankan:
```bash
bash restore-vps.sh vps-config-2026-11-01.tar.gz db-2026-11-01.sql.gz swanlakekode-db-2026-11-01.json.gz
```
Script ada di dalam bundel (`scripts/restore-vps.sh`) dan di repo Hermes ini.

Cek dulu tanpa mengubah sistem:
```bash
bash restore-vps.sh vps-config-2026-11-01.tar.gz db-2026-11-01.sql.gz --check
```

### 5. DNS
Arahkan `proprem.my.id` dan `swanlakekode.my.id` ke IP baru (A record).

### 6. SSL
```bash
sudo certbot --nginx -d proprem.my.id -d swanlakekode.my.id
```

### 7. WhatsApp
```bash
cd /opt/waha && sudo docker compose up -d
```
Lalu scan QR dari HP (WhatsApp → Perangkat tertaut).

### 8. Verifikasi
```bash
pm2 list
systemctl status nginx mysql
curl -I https://proprem.my.id
```

## Urutan prioritas kalau waktu mepet
1. Database — tanpa ini bisnis hilang
2. Kode aplikasi
3. Config (.env, nginx, cron)
4. Sesi WhatsApp — paling akhir, cuma butuh scan QR
