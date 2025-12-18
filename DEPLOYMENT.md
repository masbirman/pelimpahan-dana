# Panduan Deployment ke Dokploy

## Domain Configuration
- **Frontend**: `pelimpahan.keudisdiksulteng.web.id`
- **Backend API**: `api-pelimpahan.keudisdiksulteng.web.id`

## Database (Sudah Tersedia di Dokploy)
- **Host**: `pelimpahan-dana-database-hlpgww`
- **Port**: `5432`
- **Database**: `pelimpahan_dana_db`
- **User**: `pelimpahan_user`
- **Password**: `Fr3aks@16121899`

---

## Opsi Deployment

### Opsi 1: Deploy dengan Docker Compose (Recommended)

1. **Push ke Git Repository**
   ```bash
   git add .
   git commit -m "Add production deployment files"
   git push origin main
   ```

2. **Di Dokploy:**
   - Buat service baru → pilih "Compose"
   - Connect ke repository Git
   - Set compose file path: `docker-compose.prod.yml`
   - Set environment variables:
     ```
     DB_PASSWORD=Fr3aks@16121899
     JWT_SECRET=<generate-strong-secret>
     ```
   - Deploy

3. **Generate JWT Secret:**
   ```bash
   openssl rand -base64 32
   ```

---

### Opsi 2: Deploy Services Terpisah

#### A. Deploy Backend

1. Di Dokploy, buat service baru → pilih "Application"
2. Connect ke repository Git
3. Set build configuration:
   - **Dockerfile Path**: `backend/Dockerfile.prod`
   - **Build Context**: `backend`
4. Set Environment Variables:
   ```
   APP_ENV=production
   APP_DEBUG=false
   APP_PORT=8000
   APP_TIMEZONE=Asia/Makassar
   DB_CONNECTION=postgres
   DB_HOST=pelimpahan-dana-database-hlpgww
   DB_PORT=5432
   DB_DATABASE=pelimpahan_dana_db
   DB_USERNAME=pelimpahan_user
   DB_PASSWORD=Fr3aks@16121899
   JWT_SECRET=<your-strong-secret>
   CORS_ALLOWED_ORIGINS=https://pelimpahan.keudisdiksulteng.web.id
   ```
5. Set Domain: `api-pelimpahan.keudisdiksulteng.web.id`
6. Enable HTTPS
7. Deploy

#### B. Deploy Frontend

1. Di Dokploy, buat service baru → pilih "Application"
2. Connect ke repository Git
3. Set build configuration:
   - **Dockerfile Path**: `frontend/Dockerfile.prod`
   - **Build Context**: `frontend`
   - **Build Args**: 
     ```
     VITE_API_URL=https://api-pelimpahan.keudisdiksulteng.web.id/api
     ```
4. Set Domain: `pelimpahan.keudisdiksulteng.web.id`
5. Enable HTTPS
6. Deploy

---

## Post-Deployment Checklist

- [ ] Verify frontend accessible at https://pelimpahan.keudisdiksulteng.web.id
- [ ] Verify backend API at https://api-pelimpahan.keudisdiksulteng.web.id/api/branding
- [ ] Test login dengan credentials:
  - Email: `admin@pelimpahan.local` / Password: `password` (Super Admin)
  - Email: `bendahara@pelimpahan.local` / Password: `passworduntu` (Bendahara)
  - Email: `operator@pelimpahan.local` / Password: `password` (Operator)
- [ ] Test CRUD operations
- [ ] Check database connection

---

## Troubleshooting

### CORS Error
Pastikan environment variable `CORS_ALLOWED_ORIGINS` di backend sudah benar:
```
CORS_ALLOWED_ORIGINS=https://pelimpahan.keudisdiksulteng.web.id
```

### Database Connection Failed
Pastikan backend bisa reach database. Service harus dalam network yang sama dengan database di Dokploy.

### 502 Bad Gateway
Check container logs di Dokploy untuk error details.

---

## 🗄️ Import Database dari Local

Setelah deploy selesai, import data dari database lokal:

### File yang Disiapkan:
- `backup_production.sql` - Database backup dengan URL production

### Langkah Import:

1. **SSH ke server Dokploy** atau gunakan Dokploy Terminal

2. **Kosongkan database existing (jika perlu):**
   ```bash
   docker exec -it pelimpahan-dana-database-hlpgww psql -U pelimpahan_user -d pelimpahan_dana_db
   ```
   ```sql
   DROP SCHEMA public CASCADE;
   CREATE SCHEMA public;
   GRANT ALL ON SCHEMA public TO pelimpahan_user;
   \q
   ```

3. **Import backup:**
   ```bash
   # Upload file backup_production.sql ke server terlebih dahulu
   docker exec -i pelimpahan-dana-database-hlpgww psql -U pelimpahan_user -d pelimpahan_dana_db < backup_production.sql
   ```

4. **Verifikasi:**
   ```bash
   docker exec -it pelimpahan-dana-database-hlpgww psql -U pelimpahan_user -d pelimpahan_dana_db -c "SELECT * FROM users;"
   ```

📖 Lihat `IMPORT_DATABASE.md` untuk panduan lengkap.

---

## 📁 Persistent Storage (Uploads)

### Volume Configuration (sudah ada di docker-compose.prod.yml):
```yaml
volumes:
  - pelimpahan_uploads:/app/uploads
```

### Upload File ke Production:

1. **Via Docker CP:**
   ```bash
   # Copy file dari local ke container
   docker cp ./uploads/. pelimpahan-backend:/app/uploads/
   ```

2. **Via Aplikasi:**
   - Login sebagai admin
   - Upload ulang logo di Settings → Branding
   - Upload ulang avatar di Profile

### File yang perlu diupload:
- `logo_20251218225558.png` - Logo aplikasi
- `avatar_20251218225545_admin_pelimpahan.local.png` - Avatar admin
- `ilustrasi-dashboard.webp` - Ilustrasi dashboard

---

## File Structure
```
pelimpahan-dana/
├── backend/
│   ├── Dockerfile.prod     # Production Dockerfile
│   ├── .dockerignore       # Docker ignore
│   └── .env.production     # Production env template
├── frontend/
│   ├── Dockerfile.prod     # Production Dockerfile
│   ├── nginx.conf          # Nginx configuration
│   ├── .dockerignore       # Docker ignore
│   └── .env.production     # Production env template
├── backup_production.sql   # Database backup for production
├── IMPORT_DATABASE.md      # Detailed import guide
└── docker-compose.prod.yml # Dokploy compose file
```
