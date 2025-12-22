package main

import (
	"log"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"

	"pelimpahan-backend/app/http/controllers"
	"pelimpahan-backend/app/http/middleware"
	"pelimpahan-backend/app/models"
)

var DB *gorm.DB

func main() {
	// Set timezone
	loc, _ := time.LoadLocation("Asia/Makassar")
	time.Local = loc

	// Database connection
	dsn := getDSN()
	var err error
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Auto migrate
	DB.AutoMigrate(
		&models.User{},
		&models.Unit{},
		&models.JenisPelimpahan{},
		&models.Pelimpahan{},
		&models.PelimpahanDetail{},
		&models.PelimpahanRevision{},
		&models.PengembalianDana{},
		&models.Setting{},
		&models.SaldoBendahara{},
		&models.TopUpSaldo{},
		&models.PenarikanTunai{},
	)

	// Seed database
	seedDatabase(DB)

	// Set DB in controllers
	controllers.SetDB(DB)

	// Create Gin router
	r := gin.Default()

	// CORS middleware
	r.Use(middleware.CORS())

	// Serve static files (uploads)
	r.Static("/uploads", "/app/uploads")

	// API routes
	api := r.Group("/api")
	{
		// Public routes
		api.POST("/login", controllers.Login)
		api.GET("/branding", controllers.GetBranding) // Public branding endpoint for login page

		// Protected routes
		protected := api.Group("")
		protected.Use(middleware.Auth())
		{
			protected.POST("/logout", controllers.Logout)
			protected.GET("/me", controllers.Me)
			protected.PUT("/profile", controllers.UpdateProfile)
			protected.POST("/profile/avatar", controllers.UploadAvatar)
			protected.GET("/dashboard/stats", controllers.DashboardStats)
			
			// Settings
			protected.GET("/settings/countdown", controllers.GetCountdown)
			protected.PUT("/settings/countdown", controllers.SaveCountdown)
			protected.GET("/settings/branding", controllers.GetBranding)
			protected.PUT("/settings/branding", controllers.SaveBranding)
			protected.POST("/settings/logo", controllers.UploadLogo)
			protected.GET("/settings/report-header", controllers.GetReportHeader)
			protected.PUT("/settings/report-header", controllers.SaveReportHeader)
			protected.POST("/settings/report-logo", controllers.UploadReportLogo)

			// Units - specific routes BEFORE wildcard :id
			protected.GET("/units", controllers.GetUnits)
			protected.POST("/units", controllers.CreateUnit)
			protected.GET("/units/template", controllers.DownloadUnitTemplate)
			protected.GET("/units/export", controllers.ExportUnits)
			protected.POST("/units/import", controllers.ImportUnits)
			protected.POST("/units/bulk-delete", controllers.BulkDeleteUnits)
			protected.POST("/units/clone-from-previous-year", controllers.CloneUnitsFromPreviousYear)
			protected.GET("/units/:id", controllers.GetUnit)
			protected.PUT("/units/:id", controllers.UpdateUnit)
			protected.DELETE("/units/:id", controllers.DeleteUnit)

			// Jenis Pelimpahan
			protected.GET("/jenis-pelimpahan", controllers.GetJenisPelimpahan)
			protected.POST("/jenis-pelimpahan", controllers.CreateJenisPelimpahan)
			protected.GET("/jenis-pelimpahan/:id", controllers.GetJenisPelimpahanByID)
			protected.PUT("/jenis-pelimpahan/:id", controllers.UpdateJenisPelimpahan)
			protected.DELETE("/jenis-pelimpahan/:id", controllers.DeleteJenisPelimpahan)

			// Pelimpahan
			protected.GET("/pelimpahan", controllers.GetPelimpahan)
			protected.POST("/pelimpahan", controllers.CreatePelimpahan)
			protected.GET("/pelimpahan/:id", controllers.GetPelimpahanByID)
			protected.GET("/pelimpahan/:id/revisions", controllers.GetPelimpahanRevisions)
			protected.PUT("/pelimpahan/:id", controllers.UpdatePelimpahan)
			protected.DELETE("/pelimpahan/:id", controllers.DeletePelimpahan)

			// Saldo Bendahara (bendahara & super_admin)
			saldoBendahara := protected.Group("")
			saldoBendahara.Use(middleware.Role("bendahara", "super_admin"))
			{
				saldoBendahara.GET("/saldo-bendahara", controllers.GetSaldoBendahara)
				saldoBendahara.GET("/saldo-bendahara/latest", controllers.GetLatestSaldo)
				saldoBendahara.GET("/saldo-bendahara/by-month", controllers.GetSaldoByMonth)
				saldoBendahara.GET("/saldo-bendahara/:id", controllers.GetSaldoBendaharaByID)
				saldoBendahara.POST("/saldo-bendahara", controllers.CreateSaldoBendahara)
				saldoBendahara.PUT("/saldo-bendahara/:id", controllers.UpdateSaldoBendahara)
			}

			// Delete saldo (super_admin only)
			protected.DELETE("/saldo-bendahara/:id", middleware.Role("super_admin"), controllers.DeleteSaldoBendahara)

			// Top Up Saldo (bendahara & super_admin)
			topUpSaldo := protected.Group("")
			topUpSaldo.Use(middleware.Role("bendahara", "super_admin"))
			{
				topUpSaldo.GET("/top-up-saldo", controllers.GetTopUpSaldo)
				topUpSaldo.GET("/top-up-saldo/:id", controllers.GetTopUpSaldoByID)
				topUpSaldo.POST("/top-up-saldo", controllers.CreateTopUpSaldo)
				topUpSaldo.PUT("/top-up-saldo/:id", controllers.UpdateTopUpSaldo)
			}

			// Delete top up (super_admin only)
			protected.DELETE("/top-up-saldo/:id", middleware.Role("super_admin"), controllers.DeleteTopUpSaldo)

			// Penarikan Tunai (bendahara & super_admin)
			penarikanTunai := protected.Group("")
			penarikanTunai.Use(middleware.Role("bendahara", "super_admin"))
			{
				penarikanTunai.GET("/penarikan-tunai", controllers.GetPenarikanTunai)
				penarikanTunai.GET("/penarikan-tunai/:id", controllers.GetPenarikanTunaiByID)
				penarikanTunai.POST("/penarikan-tunai", controllers.CreatePenarikanTunai)
				penarikanTunai.PUT("/penarikan-tunai/:id", controllers.UpdatePenarikanTunai)
			}

			// Delete penarikan tunai (super_admin only)
			protected.DELETE("/penarikan-tunai/:id", middleware.Role("super_admin"), controllers.DeletePenarikanTunai)

			// Pengembalian Dana (bendahara & super_admin)
			pengembalian := protected.Group("")
			pengembalian.Use(middleware.Role("bendahara", "super_admin"))
			{
				pengembalian.GET("/pengembalian-dana", controllers.GetPengembalianDana)
				pengembalian.GET("/pengembalian-dana/by-pelimpahan/:id", controllers.GetPengembalianByPelimpahan)
				pengembalian.POST("/pengembalian-dana", controllers.CreatePengembalianDana)
			}

			// Delete pengembalian dana (super_admin only)
			protected.DELETE("/pengembalian-dana/:id", middleware.Role("super_admin"), controllers.DeletePengembalianDana)

			// Users (admin only)
			admin := protected.Group("")
			admin.Use(middleware.Role("super_admin"))
			{
				admin.GET("/users", controllers.GetUsers)
				admin.POST("/users", controllers.CreateUser)
				admin.GET("/users/:id", controllers.GetUserByID)
				admin.PUT("/users/:id", controllers.UpdateUser)
				admin.DELETE("/users/:id", controllers.DeleteUser)
			}
		}
	}

	// Start server
	port := os.Getenv("APP_PORT")
	if port == "" {
		port = "8000"
	}
	log.Printf("Server starting on port %s", port)
	r.Run(":" + port)
}

func getDSN() string {
	host := os.Getenv("DB_HOST")
	if host == "" {
		host = "localhost"
	}
	port := os.Getenv("DB_PORT")
	if port == "" {
		port = "5432"
	}
	user := os.Getenv("DB_USERNAME")
	if user == "" {
		user = "pelimpahan"
	}
	password := os.Getenv("DB_PASSWORD")
	if password == "" {
		password = "pelimpahan_secret"
	}
	dbname := os.Getenv("DB_DATABASE")
	if dbname == "" {
		dbname = "pelimpahan_db"
	}
	return "host=" + host + " user=" + user + " password=" + password + " dbname=" + dbname + " port=" + port + " sslmode=disable TimeZone=Asia/Makassar"
}

func seedDatabase(db *gorm.DB) {
	// Check if users exist
	var count int64
	db.Model(&models.User{}).Count(&count)
	if count > 0 {
		log.Println("Database already seeded, skipping...")
		return
	}

	log.Println("Seeding database...")

	// Generate password hash
	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("password"), bcrypt.DefaultCost)

	// Seed users
	users := []models.User{
		{Name: "Super Administrator", Username: "admin", Email: "admin@pelimpahan.local", Password: string(hashedPassword), Role: "super_admin", IsActive: true},
		{Name: "Bendahara Utama", Username: "bendahara", Email: "bendahara@pelimpahan.local", Password: string(hashedPassword), Role: "bendahara", IsActive: true},
		{Name: "Operator Input", Username: "operator", Email: "operator@pelimpahan.local", Password: string(hashedPassword), Role: "operator", IsActive: true},
	}
	for _, u := range users {
		db.Create(&u)
	}

	// Seed jenis pelimpahan
	jenisList := []models.JenisPelimpahan{
		{KodeJenis: "UP", NamaJenis: "Uang Persediaan"},
		{KodeJenis: "GU", NamaJenis: "Ganti Uang"},
		{KodeJenis: "TU", NamaJenis: "Tambahan Uang"},
		{KodeJenis: "LS", NamaJenis: "Langsung"},
	}
	for _, j := range jenisList {
		db.Create(&j)
	}

	// Seed units
	units := []models.Unit{
		{KodeUnit: "001", NamaUnit: "Dinas Pendidikan", NamaPimpinan: "Kepala Dinas", NamaBendahara: "Bendahara Dinas", NomorRekening: "1234567890"},
		{KodeUnit: "002", NamaUnit: "Bidang SD", NamaPimpinan: "Kabid SD", NamaBendahara: "Bendahara Bidang SD", NomorRekening: "1234567891"},
		{KodeUnit: "003", NamaUnit: "Bidang SMP", NamaPimpinan: "Kabid SMP", NamaBendahara: "Bendahara Bidang SMP", NomorRekening: "1234567892"},
	}
	for _, unit := range units {
		db.Create(&unit)
	}

	log.Println("Database seeded successfully!")
}
