# Pelimpahan Dana UP/GU

Sistem manajemen pelimpahan dana UP/GU dengan fitur multi-role, input pelimpahan dengan multiple recipients, dan laporan.

## Tech Stack

- **Backend**: Goravel (Go)
- **Frontend**: Vue 3 + Vite + Tailwind CSS
- **Database**: PostgreSQL 16
- **Container**: Docker

## Quick Start

### Prerequisites
- Docker Desktop

### Running the Application

1. Clone repository dan masuk ke folder project

2. Start semua services:
   ```bash
   docker-compose up -d
   ```

3. Akses aplikasi:
   - **Frontend**: http://localhost:5173
   - **Backend API**: http://localhost:8000
   - **Adminer (DB)**: http://localhost:8080

4. Run database migrations:
   ```bash
   # Masuk ke container backend
   docker exec -it pelimpahan_backend sh
   
   # Jalankan migration
   psql -h postgres -U pelimpahan -d pelimpahan_db -f database/migrations/001_create_tables.sql
   psql -h postgres -U pelimpahan -d pelimpahan_db -f database/seeders/seed.sql
   ```

## Demo Accounts

| Role | Email | Password |
|------|-------|----------|
| Super Admin | admin@pelimpahan.local | password |
| Bendahara | bendahara@pelimpahan.local | password |
| Operator | operator@pelimpahan.local | password |

## Features

- ✅ Multi-role authentication (Super Admin, Bendahara, Operator)
- ✅ User avatar & status keaktifan
- ✅ CRUD Unit Kerja
- ✅ CRUD Jenis Pelimpahan
- ✅ Input Pelimpahan dengan multiple recipients
- ✅ Auto numbering pelimpahan per jenis
- ✅ Timezone Asia/Makassar
- ✅ Laporan per pelimpahan
- ✅ Export Excel (coming soon)
- ✅ Import Excel (coming soon)

## API Endpoints

### Authentication
- `POST /api/login` - Login
- `POST /api/logout` - Logout
- `GET /api/me` - Get current user

### Units
- `GET /api/units` - List units
- `POST /api/units` - Create unit
- `GET /api/units/:id` - Get unit
- `PUT /api/units/:id` - Update unit
- `DELETE /api/units/:id` - Delete unit

### Jenis Pelimpahan
- `GET /api/jenis-pelimpahan` - List jenis
- `POST /api/jenis-pelimpahan` - Create jenis
- `GET /api/jenis-pelimpahan/:id` - Get jenis
- `PUT /api/jenis-pelimpahan/:id` - Update jenis
- `DELETE /api/jenis-pelimpahan/:id` - Delete jenis

### Pelimpahan
- `GET /api/pelimpahan` - List pelimpahan
- `POST /api/pelimpahan` - Create pelimpahan
- `GET /api/pelimpahan/:id` - Get pelimpahan
- `PUT /api/pelimpahan/:id` - Update pelimpahan
- `DELETE /api/pelimpahan/:id` - Delete pelimpahan
- `GET /api/pelimpahan/:id/report` - Get report

### Users (Super Admin only)
- `GET /api/users` - List users
- `POST /api/users` - Create user
- `GET /api/users/:id` - Get user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user
