# Sistem Pelimpahan Dana

Aplikasi manajemen pelimpahan dana dengan fitur lengkap untuk tracking saldo bendahara, top-up, penarikan tunai, dan pelimpahan ke unit kerja.

## 🚀 Features

### Core Features
- ✅ **Manajemen User** - Super Admin, Bendahara, Operator
- ✅ **Unit Kerja** - CRUD unit penerima dana
- ✅ **Jenis Pelimpahan** - Kategorisasi jenis pelimpahan
- ✅ **Input Pelimpahan** - Form pelimpahan dengan multiple penerima
- ✅ **Sumber Dana** - Per-recipient source selection (Bank/Tunai)
- ✅ **Export Excel** - Export data pelimpahan ke Excel

### Saldo Management
- ✅ **Saldo Bendahara** - Track initial balance (Bank & Tunai)
- ✅ **Top Up Bank** - Record external fund receipts
- ✅ **Penarikan Tunai** - Internal transfer Bank → Tunai
- ✅ **Real-time Balance** - Automatic calculation with audit trail

### Reporting
- ✅ **List Pelimpahan** - View with running balance
- ✅ **Detail Report** - Print-ready pelimpahan report
- ✅ **Balance Tracking** - Real-time saldo calculation

## 🛠️ Tech Stack

### Backend
- **Framework:** Go (Gin)
- **Database:** PostgreSQL 16
- **ORM:** GORM
- **Auth:** JWT

### Frontend
- **Framework:** Vue 3 (Composition API)
- **Build Tool:** Vite
- **State Management:** Pinia
- **Styling:** Tailwind CSS
- **HTTP Client:** Axios

### DevOps
- **Containerization:** Docker & Docker Compose
- **Database Admin:** Adminer

## 📦 Installation

### Prerequisites
- Docker & Docker Compose
- Git

### Quick Start

1. **Clone repository:**
```bash
git clone https://github.com/masbirman/pelimpahan-dana.git
cd pelimpahan-dana
```

2. **Start services:**
```bash
docker-compose up -d
```

3. **Access applications:**
- Frontend: http://localhost:5173
- Backend API: http://localhost:8000
- Adminer: http://localhost:8080

### Default Credentials
- **Email:** admin@pelimpahan.com
- **Password:** admin123

## 📁 Project Structure

```
pelimpahan-dana/
├── backend/              # Go (Gin) API
│   ├── app/
│   │   ├── http/
│   │   │   └── controllers/
│   │   └── models/
│   ├── middleware/
│   └── main.go
├── frontend/            # Vue 3 + Vite
│   ├── src/
│   │   ├── components/
│   │   ├── views/
│   │   ├── stores/
│   │   └── services/
│   └── package.json
├── database/            # Database backups
├── uploads/             # File uploads
└── docker-compose.yml
```

## 🗄️ Database Schema

### Main Tables
- `users` - User accounts with roles
- `units` - Unit kerja (work units)
- `jenis_pelimpahan` - Transfer types
- `pelimpahan` - Main transfer records
- `pelimpahan_details` - Transfer recipients
- `saldo_bendahara` - Initial balance records
- `top_up_saldo` - Bank top-up transactions
- `penarikan_tunai` - Cash withdrawal transactions

## 💰 Balance Calculation Logic

```
Saldo Bank = Saldo Awal Bank
           + SUM(top_up_saldo.jumlah)
           - SUM(penarikan_tunai.jumlah)
           - SUM(pelimpahan_detail.jumlah WHERE sumber_dana='bank')

Saldo Tunai = Saldo Awal Tunai
            + SUM(penarikan_tunai.jumlah)
            - SUM(pelimpahan_detail.jumlah WHERE sumber_dana='tunai')
```

## 🔐 User Roles

### Super Admin
- Full system access
- User management
- Delete operations
- System settings

### Bendahara
- Saldo management
- Top-up & withdrawal
- View all pelimpahan
- Cannot delete

### Operator
- Input pelimpahan
- View own pelimpahan
- Export reports

## 📊 API Endpoints

### Authentication
- `POST /api/login` - User login
- `POST /api/logout` - User logout
- `GET /api/me` - Get current user

### Pelimpahan
- `GET /api/pelimpahan` - List all
- `POST /api/pelimpahan` - Create new
- `GET /api/pelimpahan/:id` - Get detail
- `PUT /api/pelimpahan/:id` - Update
- `DELETE /api/pelimpahan/:id` - Delete

### Saldo Management
- `GET /api/saldo-bendahara/latest` - Get real-time balance
- `POST /api/top-up-saldo` - Create top-up
- `POST /api/penarikan-tunai` - Create withdrawal

## 🔧 Configuration

### Backend (.env)
```env
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=pelimpahan_db
DB_USERNAME=pelimpahan
DB_PASSWORD=pelimpahan_secret
JWT_SECRET=your-jwt-secret-key
```

### Frontend (.env)
```env
VITE_API_URL=http://localhost:8000/api
```

## 🚢 Deployment

### Production Build

**Backend:**
```bash
cd backend
go build -o pelimpahan-api
```

**Frontend:**
```bash
cd frontend
npm run build
```

## 📝 Database Backup & Restore

### Backup
```bash
docker exec pelimpahan_db pg_dump -U pelimpahan pelimpahan_db > backup.sql
```

### Restore
```bash
docker exec -i pelimpahan_db psql -U pelimpahan pelimpahan_db < backup.sql
```

## 🐛 Troubleshooting

### Frontend shows login after refresh
- Check browser console for errors
- Verify JWT token in localStorage
- Check `/api/me` endpoint response

### Database connection failed
- Ensure PostgreSQL container is running
- Check database credentials in docker-compose.yml
- Verify network connectivity

## 📄 License

This project is proprietary software.

## 👥 Contributors

- **Developer:** Antigravity AI Assistant
- **Project Owner:** Anto

## 📞 Support

For issues and questions, please create an issue on GitHub.

---

**Version:** 1.0.0  
**Last Updated:** December 18, 2025
