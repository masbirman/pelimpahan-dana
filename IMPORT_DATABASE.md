# Panduan Import Database dan Setup Storage

## 📦 File yang Disiapkan

| File | Deskripsi | Ukuran |
|------|-----------|--------|
| `backup_production.sql` | Database backup (URL sudah diganti ke production) | ~20KB |
| `uploads/` | Folder file uploads (logo, avatar) | ~1.3MB |

---

## 🗄️ Import Database ke Dokploy

### Langkah 1: Connect ke Database di Dokploy

Di Dokploy, buka **Terminal** pada service database atau gunakan **External Connection**.

**Database Details:**
- **Host**: `pelimpahan-dana-database-hlpgww`
- **Port**: `5432`
- **Database**: `pelimpahan_dana_db`
- **User**: `pelimpahan_user`
- **Password**: `Fr3aks@16121899`

### Langkah 2: Import SQL via Dokploy Terminal

1. Buka Dokploy → Database Service → **Terminal**

2. Atau jika menggunakan SSH ke server Dokploy:
   ```bash
   # Masuk ke container database
   docker exec -it pelimpahan-dana-database-hlpgww psql -U pelimpahan_user -d pelimpahan_dana_db
   ```

3. Jika ada data lama, kosongkan dulu (HATI-HATI!):
   ```sql
   -- Drop semua tables
   DROP SCHEMA public CASCADE;
   CREATE SCHEMA public;
   GRANT ALL ON SCHEMA public TO pelimpahan_user;
   GRANT ALL ON SCHEMA public TO public;
   ```

4. Keluar dari psql: `\q`

### Langkah 3: Upload dan Import SQL File

**Opsi A: Via Dokploy File Manager (Jika tersedia)**

1. Upload file `backup_production.sql` ke server
2. Import dengan command:
   ```bash
   docker exec -i pelimpahan-dana-database-hlpgww psql -U pelimpahan_user -d pelimpahan_dana_db < /path/to/backup_production.sql
   ```

**Opsi B: Via psql dari Local (Jika port exposed)**

```bash
psql -h <dokploy-server-ip> -p 5432 -U pelimpahan_user -d pelimpahan_dana_db < backup_production.sql
```

**Opsi C: Copy-Paste via Terminal**

1. Buka `backup_production.sql` di text editor
2. Copy seluruh isinya
3. Paste di psql terminal Dokploy
4. Atau gunakan:
   ```bash
   # Di server Dokploy
   cat << 'EOF' | docker exec -i pelimpahan-dana-database-hlpgww psql -U pelimpahan_user -d pelimpahan_dana_db
   <PASTE ISI backup_production.sql DISINI>
   EOF
   ```

### Langkah 4: Verifikasi Import

```bash
docker exec -it pelimpahan-dana-database-hlpgww psql -U pelimpahan_user -d pelimpahan_dana_db
```

```sql
-- Cek tables
\dt

-- Cek data users
SELECT id, name, email, role FROM users;

-- Cek data units
SELECT id, kode_unit, nama_unit FROM units;

-- Cek settings
SELECT key, value FROM settings;
```

---

## 📁 Setup Persistent Storage untuk Uploads

### Volume sudah dikonfigurasi di docker-compose.prod.yml:

```yaml
volumes:
  - pelimpahan_uploads:/app/uploads
```

### Upload File ke Production

**Opsi A: Via SCP/SFTP ke Server Dokploy**

```bash
# Dari local, copy folder uploads ke server
scp -r uploads/* user@dokploy-server:/tmp/uploads/

# Di server, copy ke volume
docker cp /tmp/uploads/. pelimpahan-backend:/app/uploads/
```

**Opsi B: Via Dokploy Container Terminal**

1. Buka Dokploy → Backend Service → **Terminal**
2. Check uploads folder:
   ```bash
   ls -la /app/uploads/
   ```

**Opsi C: Via API Upload**

Upload ulang file melalui aplikasi:
1. Login sebagai admin
2. Buka Settings → Branding
3. Upload logo baru
4. Buka Profile → Upload avatar baru

---

## ✅ Checklist Post-Import

- [ ] Semua tables sudah ter-create
- [ ] Users dapat login:
  - `admin@pelimpahan.local` / `password` (Super Admin)
  - `bendahara@pelimpahan.local` / `password` (Bendahara)
  - `operator@pelimpahan.local` / `password` (Operator)
- [ ] Data units tampil di halaman Units
- [ ] Saldo bendahara tampil di dashboard
- [ ] Logo aplikasi tampil di sidebar
- [ ] File uploads accessible via `https://pelimpahan.keudisdiksulteng.web.id/uploads/`

---

## 🔧 Troubleshooting

### Error: "relation already exists"

Database sudah memiliki tables. Hapus dulu dengan:
```sql
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO pelimpahan_user;
```

### Error: "permission denied"

Pastikan user database memiliki akses:
```sql
GRANT ALL PRIVILEGES ON DATABASE pelimpahan_dana_db TO pelimpahan_user;
GRANT ALL ON SCHEMA public TO pelimpahan_user;
```

### File uploads tidak tampil

1. Pastikan volume mounted dengan benar
2. Check permissions: `chmod -R 755 /app/uploads`
3. Pastikan nginx proxy ke backend berjalan

### Database connection refused

Pastikan backend dan database dalam network yang sama di docker-compose.
