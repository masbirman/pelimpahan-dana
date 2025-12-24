package controllers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/xuri/excelize/v2"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"

	"pelimpahan-backend/app/models"
)

var DB *gorm.DB

func SetDB(db *gorm.DB) {
	DB = db
}

// Auth Controllers
func Login(c *gin.Context) {
	var req struct {
		Username string `json:"username" binding:"required"`
		Password string `json:"password" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request data"})
		return
	}

	var user models.User
	if err := DB.Where("username = ?", req.Username).First(&user).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "Username atau password salah"})
		return
	}

	if !user.IsActive {
		c.JSON(http.StatusForbidden, gin.H{"success": false, "message": "Akun Anda telah dinonaktifkan"})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"success": false, "message": "Username atau password salah"})
		return
	}

	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		secret = "your-jwt-secret-key-change-in-production"
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": user.ID,
		"role":    user.Role,
		"exp":     time.Now().Add(24 * time.Hour).Unix(),
	})

	tokenString, err := token.SignedString([]byte(secret))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Login berhasil",
		"data": gin.H{
			"token": tokenString,
			"user": gin.H{
				"id":        user.ID,
				"name":      user.Name,
				"username":  user.Username,
				"email":     user.Email,
				"role":      user.Role,
				"avatar":    user.Avatar,
				"is_active": user.IsActive,
			},
		},
	})
}

func Logout(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Logout berhasil"})
}

func Me(c *gin.Context) {
	userID := c.GetUint("user_id")
	var user models.User
	if err := DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "User not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"id":        user.ID,
			"name":      user.Name,
			"email":     user.Email,
			"role":      user.Role,
			"avatar":    user.Avatar,
			"is_active": user.IsActive,
		},
	})
}

// Update user profile
func UpdateProfile(c *gin.Context) {
	userID := c.GetUint("user_id")
	var user models.User
	if err := DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "User not found"})
		return
	}

	var req struct {
		Name        string `json:"name"`
		Password    string `json:"password"`
		NewPassword string `json:"new_password"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request"})
		return
	}

	if req.Name != "" {
		user.Name = req.Name
	}

	if req.NewPassword != "" {
		if req.Password == "" {
			c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Password lama diperlukan"})
			return
		}
		if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Password lama salah"})
			return
		}
		hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
		user.Password = string(hashedPassword)
	}

	DB.Save(&user)
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Profil berhasil diupdate",
		"data": gin.H{
			"id":     user.ID,
			"name":   user.Name,
			"email":  user.Email,
			"role":   user.Role,
			"avatar": user.Avatar,
		},
	})
}

// Upload avatar
func UploadAvatar(c *gin.Context) {
	userID := c.GetUint("user_id")
	var user models.User
	if err := DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "User not found"})
		return
	}

	file, err := c.FormFile("avatar")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "File tidak ditemukan"})
		return
	}

	// Validate file size
	if file.Size > 2*1024*1024 {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Ukuran file maksimal 2MB"})
		return
	}

	// Create uploads directory if not exists
	uploadDir := "/app/uploads"
	if err := os.MkdirAll(uploadDir, 0755); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Gagal membuat direktori"})
		return
	}

	// Generate unique filename
	ext := ".jpg"
	if strings.Contains(file.Filename, ".") {
		parts := strings.Split(file.Filename, ".")
		ext = "." + parts[len(parts)-1]
	}
	filename := "avatar_" + time.Now().Format("20060102150405") + "_" + strings.ReplaceAll(user.Email, "@", "_") + ext
	savePath := uploadDir + "/" + filename

	if err := c.SaveUploadedFile(file, savePath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Gagal menyimpan file: " + err.Error()})
		return
	}

	// Build base URL from request headers (behind reverse proxy)
	scheme := "https" // Default to HTTPS in production
	if proto := c.GetHeader("X-Forwarded-Proto"); proto != "" {
		scheme = proto
	}
	// Check X-Forwarded-Host first (set by nginx/traefik), then Host
	host := c.GetHeader("X-Forwarded-Host")
	if host == "" {
		host = c.GetHeader("Host")
	}
	if host == "" || host == "backend:8000" || strings.HasPrefix(host, "localhost") {
		host = "pelimpahan.keudisdiksulteng.web.id"
	}
	baseURL := scheme + "://" + host

	user.Avatar = baseURL + "/uploads/" + filename
	DB.Save(&user)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Avatar berhasil diupload",
		"data":    gin.H{"avatar": user.Avatar},
	})
}

// Dashboard Controller
func DashboardStats(c *gin.Context) {
	var totalPelimpahan, totalUnit, totalJenis, totalUser int64

	// Get tahun anggaran from header (default to 2025 if not provided)
	tahunAnggaran := c.GetHeader("X-Tahun-Anggaran")
	if tahunAnggaran == "" {
		tahunAnggaran = "2025"
	}
	
	// Debug log
	log.Printf("DashboardStats: tahun_anggaran header = %s", tahunAnggaran)

	DB.Model(&models.Pelimpahan{}).Where("tahun_anggaran = ?", tahunAnggaran).Count(&totalPelimpahan)
	DB.Model(&models.Unit{}).Count(&totalUnit)
	DB.Model(&models.JenisPelimpahan{}).Count(&totalJenis)
	DB.Model(&models.User{}).Count(&totalUser)

	var recentPelimpahan []models.Pelimpahan
	DB.Preload("JenisPelimpahan").Preload("Details").
		Where("tahun_anggaran = ?", tahunAnggaran).
		Order("created_at desc").Limit(5).Find(&recentPelimpahan)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"total_pelimpahan":  totalPelimpahan,
			"total_unit":        totalUnit,
			"total_jenis":       totalJenis,
			"total_user":        totalUser,
			"recent_pelimpahan": recentPelimpahan,
		},
	})
}

// Get Countdown Settings
func GetCountdown(c *gin.Context) {
	var setting models.Setting
	if err := DB.Where("key = ?", "countdown").First(&setting).Error; err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"data":    nil,
		})
		return
	}

	// Parse JSON value
	var data map[string]interface{}
	if err := json.Unmarshal([]byte(setting.Value), &data); err != nil {
		c.JSON(http.StatusOK, gin.H{"success": true, "data": nil})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    data,
	})
}

// Save Countdown Settings
func SaveCountdown(c *gin.Context) {
	var req struct {
		Active      bool   `json:"active"`
		Title       string `json:"title"`
		Description string `json:"description"`
		TargetDate  string `json:"target_date"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request"})
		return
	}

	// Convert to JSON
	data := map[string]interface{}{
		"active":      req.Active,
		"title":       req.Title,
		"description": req.Description,
		"target_date": req.TargetDate,
	}
	jsonData, _ := json.Marshal(data)

	var setting models.Setting
	result := DB.Where("key = ?", "countdown").First(&setting)
	if result.Error != nil {
		// Create new
		setting = models.Setting{
			Key:   "countdown",
			Value: string(jsonData),
		}
		DB.Create(&setting)
	} else {
		// Update existing
		setting.Value = string(jsonData)
		DB.Save(&setting)
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Countdown settings saved",
		"data":    data,
	})
}

// Get Branding Settings
func GetBranding(c *gin.Context) {
	var setting models.Setting
	if err := DB.Where("key = ?", "branding").First(&setting).Error; err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"data":    nil,
		})
		return
	}

	var data map[string]interface{}
	if err := json.Unmarshal([]byte(setting.Value), &data); err != nil {
		c.JSON(http.StatusOK, gin.H{"success": true, "data": nil})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    data,
	})
}

// Save Branding Settings
func SaveBranding(c *gin.Context) {
	var req struct {
		AppName     string `json:"app_name"`
		AppSubtitle string `json:"app_subtitle"`
		LogoUrl     string `json:"logo_url"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request"})
		return
	}

	data := map[string]interface{}{
		"app_name":     req.AppName,
		"app_subtitle": req.AppSubtitle,
		"logo_url":     req.LogoUrl,
	}
	jsonData, _ := json.Marshal(data)

	var setting models.Setting
	result := DB.Where("key = ?", "branding").First(&setting)
	if result.Error != nil {
		setting = models.Setting{
			Key:   "branding",
			Value: string(jsonData),
		}
		DB.Create(&setting)
	} else {
		setting.Value = string(jsonData)
		DB.Save(&setting)
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Branding settings saved",
		"data":    data,
	})
}

// Upload Logo
func UploadLogo(c *gin.Context) {
	file, err := c.FormFile("logo")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "File tidak ditemukan"})
		return
	}

	if file.Size > 2*1024*1024 {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Ukuran file maksimal 2MB"})
		return
	}

	uploadDir := "/app/uploads"
	if err := os.MkdirAll(uploadDir, 0755); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Gagal membuat direktori"})
		return
	}

	ext := ".png"
	if strings.Contains(file.Filename, ".") {
		parts := strings.Split(file.Filename, ".")
		ext = "." + parts[len(parts)-1]
	}
	filename := "logo_" + time.Now().Format("20060102150405") + ext
	savePath := uploadDir + "/" + filename

	if err := c.SaveUploadedFile(file, savePath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Gagal menyimpan file"})
		return
	}

	// Build base URL from request headers (behind reverse proxy)
	scheme := "https" // Default to HTTPS in production
	if proto := c.GetHeader("X-Forwarded-Proto"); proto != "" {
		scheme = proto
	}
	// Check X-Forwarded-Host first (set by nginx/traefik), then Host
	host := c.GetHeader("X-Forwarded-Host")
	if host == "" {
		host = c.GetHeader("Host")
	}
	if host == "" || host == "backend:8000" || strings.HasPrefix(host, "localhost") {
		host = "pelimpahan.keudisdiksulteng.web.id"
	}
	baseURL := scheme + "://" + host

	logoUrl := baseURL + "/uploads/" + filename

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Logo berhasil diupload",
		"data":    gin.H{"logo_url": logoUrl},
	})
}

// Get Report Header Settings (kop surat & tanda tangan)
func GetReportHeader(c *gin.Context) {
	var setting models.Setting
	if err := DB.Where("key = ?", "report_header").First(&setting).Error; err != nil {
		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"data":    nil,
		})
		return
	}

	var data map[string]interface{}
	if err := json.Unmarshal([]byte(setting.Value), &data); err != nil {
		c.JSON(http.StatusOK, gin.H{"success": true, "data": nil})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    data,
	})
}

// Save Report Header Settings
func SaveReportHeader(c *gin.Context) {
	var req struct {
		Header struct {
			LogoUrl  string `json:"logo_url"`
			Instansi string `json:"instansi"`
			Dinas    string `json:"dinas"`
			Alamat   string `json:"alamat"`
		} `json:"header"`
		SignatoryLeft struct {
			Jabatan string `json:"jabatan"`
			Nama    string `json:"nama"`
			Nip     string `json:"nip"`
		} `json:"signatory_left"`
		SignatoryRight struct {
			Jabatan string `json:"jabatan"`
			Nama    string `json:"nama"`
			Nip     string `json:"nip"`
		} `json:"signatory_right"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request"})
		return
	}

	data := map[string]interface{}{
		"header": map[string]interface{}{
			"logo_url": req.Header.LogoUrl,
			"instansi": req.Header.Instansi,
			"dinas":    req.Header.Dinas,
			"alamat":   req.Header.Alamat,
		},
		"signatory_left": map[string]interface{}{
			"jabatan": req.SignatoryLeft.Jabatan,
			"nama":    req.SignatoryLeft.Nama,
			"nip":     req.SignatoryLeft.Nip,
		},
		"signatory_right": map[string]interface{}{
			"jabatan": req.SignatoryRight.Jabatan,
			"nama":    req.SignatoryRight.Nama,
			"nip":     req.SignatoryRight.Nip,
		},
	}
	jsonData, _ := json.Marshal(data)

	var setting models.Setting
	result := DB.Where("key = ?", "report_header").First(&setting)
	if result.Error != nil {
		setting = models.Setting{
			Key:   "report_header",
			Value: string(jsonData),
		}
		DB.Create(&setting)
	} else {
		setting.Value = string(jsonData)
		DB.Save(&setting)
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Report header settings saved",
		"data":    data,
	})
}

// Upload Report Logo (logo instansi untuk kop surat)
func UploadReportLogo(c *gin.Context) {
	file, err := c.FormFile("logo")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "File tidak ditemukan"})
		return
	}

	if file.Size > 2*1024*1024 {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Ukuran file maksimal 2MB"})
		return
	}

	uploadDir := "/app/uploads"
	if err := os.MkdirAll(uploadDir, 0755); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Gagal membuat direktori"})
		return
	}

	ext := ".png"
	if strings.Contains(file.Filename, ".") {
		parts := strings.Split(file.Filename, ".")
		ext = "." + parts[len(parts)-1]
	}
	filename := "report_logo_" + time.Now().Format("20060102150405") + ext
	savePath := uploadDir + "/" + filename

	if err := c.SaveUploadedFile(file, savePath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Gagal menyimpan file"})
		return
	}

	// Return relative path - frontend will construct full URL based on API base URL
	logoUrl := "/uploads/" + filename

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Logo kop surat berhasil diupload",
		"data":    gin.H{"logo_url": logoUrl},
	})
}

// Unit Controllers
func GetUnits(c *gin.Context) {
	// Get tahun anggaran from header
	tahunAnggaran := c.GetHeader("X-Tahun-Anggaran")
	if tahunAnggaran == "" {
		tahunAnggaran = "2025"
	}

	var units []models.Unit
	query := DB.Model(&models.Unit{}).Where("tahun_anggaran = ?", tahunAnggaran)

	if search := c.Query("search"); search != "" {
		query = query.Where("nama_unit ILIKE ? OR kode_unit ILIKE ?", "%"+search+"%", "%"+search+"%")
	}

	var total int64
	query.Count(&total)

	page := 1
	perPage := 10
	if p := c.Query("page"); p != "" {
		page = atoi(p)
	}
	if pp := c.Query("per_page"); pp != "" {
		perPage = atoi(pp)
	}

	// Sorting
	sortBy := c.DefaultQuery("sort_by", "created_at")
	sortOrder := c.DefaultQuery("sort_order", "desc")
	allowedSortFields := map[string]bool{"kode_unit": true, "nama_unit": true, "nama_bendahara": true, "created_at": true}
	if !allowedSortFields[sortBy] {
		sortBy = "created_at"
	}
	if sortOrder != "asc" && sortOrder != "desc" {
		sortOrder = "desc"
	}

	offset := (page - 1) * perPage
	query.Offset(offset).Limit(perPage).Order(sortBy + " " + sortOrder).Find(&units)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    units,
		"meta": gin.H{
			"total":     total,
			"page":      page,
			"per_page":  perPage,
			"last_page": (int(total) + perPage - 1) / perPage,
		},
	})
}

func CreateUnit(c *gin.Context) {
	// Get tahun anggaran from header
	tahunAnggaran := c.GetHeader("X-Tahun-Anggaran")
	if tahunAnggaran == "" {
		tahunAnggaran = "2025"
	}
	tahunAnggaranInt := atoi(tahunAnggaran)

	var unit models.Unit
	if err := c.ShouldBindJSON(&unit); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request data"})
		return
	}

	unit.TahunAnggaran = tahunAnggaranInt

	if err := DB.Create(&unit).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Failed to create unit"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"success": true, "message": "Unit berhasil dibuat", "data": unit})
}

func GetUnit(c *gin.Context) {
	var unit models.Unit
	if err := DB.First(&unit, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Unit not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": unit})
}

func UpdateUnit(c *gin.Context) {
	var unit models.Unit
	if err := DB.First(&unit, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Unit not found"})
		return
	}

	if err := c.ShouldBindJSON(&unit); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request data"})
		return
	}

	DB.Save(&unit)
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Unit berhasil diupdate", "data": unit})
}

// Clone units from previous year to current year
func CloneUnitsFromPreviousYear(c *gin.Context) {
	// Get tahun anggaran from header
	tahunAnggaran := c.GetHeader("X-Tahun-Anggaran")
	if tahunAnggaran == "" {
		tahunAnggaran = "2025"
	}
	tahunAnggaranInt := atoi(tahunAnggaran)
	previousYear := tahunAnggaranInt - 1

	// Check if current year already has units
	var existingCount int64
	DB.Model(&models.Unit{}).Where("tahun_anggaran = ?", tahunAnggaranInt).Count(&existingCount)
	
	if existingCount > 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false, 
			"message": fmt.Sprintf("Tahun %d sudah memiliki %d unit. Hapus dulu jika ingin clone ulang.", tahunAnggaranInt, existingCount),
		})
		return
	}

	// Get units from previous year
	var previousUnits []models.Unit
	DB.Where("tahun_anggaran = ?", previousYear).Find(&previousUnits)

	if len(previousUnits) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false, 
			"message": fmt.Sprintf("Tidak ada data unit di tahun %d untuk di-copy", previousYear),
		})
		return
	}

	// Clone each unit
	var clonedCount int
	for _, u := range previousUnits {
		newUnit := models.Unit{
			TahunAnggaran: tahunAnggaranInt,
			KodeUnit:      u.KodeUnit,
			NamaUnit:      u.NamaUnit,
			NamaPimpinan:  u.NamaPimpinan,
			NIPPimpinan:   u.NIPPimpinan,
			NamaBendahara: u.NamaBendahara,
			NIPBendahara:  u.NIPBendahara,
			NomorRekening: u.NomorRekening,
		}
		if err := DB.Create(&newUnit).Error; err == nil {
			clonedCount++
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": fmt.Sprintf("%d unit berhasil di-copy dari tahun %d ke %d", clonedCount, previousYear, tahunAnggaranInt),
	})
}

func DeleteUnit(c *gin.Context) {
	if err := DB.Delete(&models.Unit{}, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Failed to delete unit"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Unit berhasil dihapus"})
}

// Bulk delete units
func BulkDeleteUnits(c *gin.Context) {
	var req struct {
		IDs []uint `json:"ids" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request"})
		return
	}
	if len(req.IDs) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "No items selected"})
		return
	}
	DB.Delete(&models.Unit{}, req.IDs)
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Unit berhasil dihapus", "deleted": len(req.IDs)})
}

// Download Excel template for Unit Kerja
func DownloadUnitTemplate(c *gin.Context) {
	f := excelize.NewFile()
	defer f.Close()

	sheet := "Template Unit Kerja"
	f.SetSheetName("Sheet1", sheet)

	// Set headers
	headers := []string{"Kode Unit", "Nama Unit", "Nama Pimpinan", "Nama Bendahara", "Nomor Rekening"}
	for i, h := range headers {
		cell, _ := excelize.CoordinatesToCellName(i+1, 1)
		f.SetCellValue(sheet, cell, h)
	}

	// Style header row
	headerStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Bold: true, Color: "FFFFFF"},
		Fill:      excelize.Fill{Type: "pattern", Color: []string{"4F81BD"}, Pattern: 1},
		Alignment: &excelize.Alignment{Horizontal: "center"},
	})
	f.SetCellStyle(sheet, "A1", "E1", headerStyle)

	// Set column widths
	f.SetColWidth(sheet, "A", "A", 15)
	f.SetColWidth(sheet, "B", "B", 30)
	f.SetColWidth(sheet, "C", "C", 25)
	f.SetColWidth(sheet, "D", "D", 25)
	f.SetColWidth(sheet, "E", "E", 20)

	// Add example row
	f.SetCellValue(sheet, "A2", "001")
	f.SetCellValue(sheet, "B2", "Dinas Pendidikan")
	f.SetCellValue(sheet, "C2", "Kepala Dinas")
	f.SetCellValue(sheet, "D2", "Bendahara Dinas")
	f.SetCellValue(sheet, "E2", "1234567890")

	// Set response headers
	c.Header("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
	c.Header("Content-Disposition", "attachment; filename=template_unit_kerja.xlsx")

	f.Write(c.Writer)
}

// Import Units from Excel
func ImportUnits(c *gin.Context) {
	file, err := c.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "File tidak ditemukan"})
		return
	}

	src, err := file.Open()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Gagal membuka file"})
		return
	}
	defer src.Close()

	f, err := excelize.OpenReader(src)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "File Excel tidak valid"})
		return
	}
	defer f.Close()

	// Get first sheet
	sheets := f.GetSheetList()
	if len(sheets) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "File Excel kosong"})
		return
	}

	rows, err := f.GetRows(sheets[0])
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Gagal membaca data"})
		return
	}

	if len(rows) < 2 {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Tidak ada data untuk diimport"})
		return
	}

	var imported, skipped int
	var errors []string

	// Skip header row (index 0)
	for i, row := range rows[1:] {
		if len(row) < 5 {
			skipped++
			errors = append(errors, "Baris "+(string(rune('0'+i+2)))+": Data tidak lengkap")
			continue
		}

		kodeUnit := strings.TrimSpace(row[0])
		namaUnit := strings.TrimSpace(row[1])
		namaPimpinan := strings.TrimSpace(row[2])
		namaBendahara := strings.TrimSpace(row[3])
		nomorRekening := strings.TrimSpace(row[4])

		if kodeUnit == "" || namaUnit == "" || namaBendahara == "" || nomorRekening == "" {
			skipped++
			continue
		}

		// Check if unit already exists
		var existing models.Unit
		if DB.Where("kode_unit = ?", kodeUnit).First(&existing).Error == nil {
			// Update existing
			existing.NamaUnit = namaUnit
			existing.NamaPimpinan = namaPimpinan
			existing.NamaBendahara = namaBendahara
			existing.NomorRekening = nomorRekening
			DB.Save(&existing)
		} else {
			// Create new
			unit := models.Unit{
				KodeUnit:      kodeUnit,
				NamaUnit:      namaUnit,
				NamaPimpinan:  namaPimpinan,
				NamaBendahara: namaBendahara,
				NomorRekening: nomorRekening,
			}
			DB.Create(&unit)
		}
		imported++
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Import selesai",
		"data": gin.H{
			"imported": imported,
			"skipped":  skipped,
			"errors":   errors,
		},
	})
}

// Export Units to Excel
func ExportUnits(c *gin.Context) {
	var units []models.Unit
	DB.Order("kode_unit asc").Find(&units)

	f := excelize.NewFile()
	defer f.Close()

	sheet := "Data Unit Kerja"
	f.SetSheetName("Sheet1", sheet)

	// Headers
	headers := []string{"No", "Kode Unit", "Nama Unit", "Nama Pimpinan", "Nama Bendahara", "Nomor Rekening"}
	for i, h := range headers {
		cell, _ := excelize.CoordinatesToCellName(i+1, 1)
		f.SetCellValue(sheet, cell, h)
	}

	// Style header
	headerStyle, _ := f.NewStyle(&excelize.Style{
		Font:      &excelize.Font{Bold: true, Color: "FFFFFF"},
		Fill:      excelize.Fill{Type: "pattern", Color: []string{"4F81BD"}, Pattern: 1},
		Alignment: &excelize.Alignment{Horizontal: "center"},
	})
	f.SetCellStyle(sheet, "A1", "F1", headerStyle)

	// Data rows
	for i, u := range units {
		row := i + 2
		f.SetCellValue(sheet, cellName(1, row), i+1)
		f.SetCellValue(sheet, cellName(2, row), u.KodeUnit)
		f.SetCellValue(sheet, cellName(3, row), u.NamaUnit)
		f.SetCellValue(sheet, cellName(4, row), u.NamaPimpinan)
		f.SetCellValue(sheet, cellName(5, row), u.NamaBendahara)
		f.SetCellValue(sheet, cellName(6, row), u.NomorRekening)
	}

	// Column widths
	f.SetColWidth(sheet, "A", "A", 5)
	f.SetColWidth(sheet, "B", "B", 15)
	f.SetColWidth(sheet, "C", "C", 30)
	f.SetColWidth(sheet, "D", "D", 25)
	f.SetColWidth(sheet, "E", "E", 25)
	f.SetColWidth(sheet, "F", "F", 20)

	c.Header("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
	c.Header("Content-Disposition", "attachment; filename=data_unit_kerja.xlsx")
	f.Write(c.Writer)
}

func cellName(col, row int) string {
	name, _ := excelize.CoordinatesToCellName(col, row)
	return name
}

// Jenis Pelimpahan Controllers
func GetJenisPelimpahan(c *gin.Context) {
	var jenisList []models.JenisPelimpahan
	DB.Order("created_at desc").Find(&jenisList)
	c.JSON(http.StatusOK, gin.H{"success": true, "data": jenisList})
}

func CreateJenisPelimpahan(c *gin.Context) {
	var jenis models.JenisPelimpahan
	if err := c.ShouldBindJSON(&jenis); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request data"})
		return
	}
	DB.Create(&jenis)
	c.JSON(http.StatusCreated, gin.H{"success": true, "message": "Jenis pelimpahan berhasil dibuat", "data": jenis})
}

func GetJenisPelimpahanByID(c *gin.Context) {
	var jenis models.JenisPelimpahan
	if err := DB.First(&jenis, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": jenis})
}

func UpdateJenisPelimpahan(c *gin.Context) {
	var jenis models.JenisPelimpahan
	if err := DB.First(&jenis, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Not found"})
		return
	}
	c.ShouldBindJSON(&jenis)
	DB.Save(&jenis)
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Jenis pelimpahan berhasil diupdate", "data": jenis})
}

func DeleteJenisPelimpahan(c *gin.Context) {
	DB.Delete(&models.JenisPelimpahan{}, c.Param("id"))
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Jenis pelimpahan berhasil dihapus"})
}

// Pelimpahan Controllers
func GetPelimpahan(c *gin.Context) {
	var pelimpahanList []models.Pelimpahan
	query := DB.Model(&models.Pelimpahan{}).
		Preload("JenisPelimpahan").
		Preload("Creator").
		Preload("Details.Unit")

	if jenisID := c.Query("jenis_pelimpahan_id"); jenisID != "" {
		query = query.Where("jenis_pelimpahan_id = ?", jenisID)
	}

	// Month filter (1-12)
	if month := c.Query("month"); month != "" {
		query = query.Where("EXTRACT(MONTH FROM tanggal_pelimpahan) = ?", month)
	}

	// Sumber dana filter (bank/tunai)
	if sumberDana := c.Query("sumber_dana"); sumberDana != "" && sumberDana != "all" {
		query = query.Where("sumber_dana = ?", sumberDana)
	}

	// Year-based filtering
	tahunAnggaran := c.GetHeader("X-Tahun-Anggaran")
	if tahunAnggaran == "" {
		tahunAnggaran = "2025"
	}
	query = query.Where("tahun_anggaran = ?", tahunAnggaran)

	// Role-based filtering
	userRole := c.GetString("user_role")
	if userRole == "operator" {
		userID := c.GetUint("user_id")
		query = query.Where("created_by = ?", userID)
	}

	var total int64
	query.Count(&total)

	page := 1
	perPage := 10
	if p := c.Query("page"); p != "" {
		page = atoi(p)
	}
	if pp := c.Query("per_page"); pp != "" {
		perPage = atoi(pp)
	}

	offset := (page - 1) * perPage
	query.Offset(offset).Limit(perPage).Order("created_at desc").Find(&pelimpahanList)

	// Get latest saldo bendahara (base saldo)
	var latestSaldo models.SaldoBendahara
	var baseSaldoBank float64 = 0
	var baseSaldoTunai float64 = 0
	if err := DB.Order("tanggal desc").First(&latestSaldo).Error; err == nil {
		baseSaldoBank = latestSaldo.SaldoBank
		baseSaldoTunai = latestSaldo.SaldoTunai
	}

	// Get ALL pelimpahan ordered by tanggal_pelimpahan ASC, then nomor_pelimpahan ASC
	var allPelimpahan []models.Pelimpahan
	DB.Model(&models.Pelimpahan{}).Preload("Details").Order("tanggal_pelimpahan asc, nomor_pelimpahan asc").Find(&allPelimpahan)

	// Build map of cumulative sisa saldo for each pelimpahan (chronologically)
	sisaSaldoMap := make(map[uint]float64)
	saldoAwalMap := make(map[uint]float64)

	for _, p := range allPelimpahan {
		// Calculate top up sum up to this pelimpahan date
		var topUpUntilDate float64
		DB.Model(&models.TopUpSaldo{}).Where("tanggal <= ?", p.TanggalPelimpahan).Select("COALESCE(SUM(jumlah), 0)").Scan(&topUpUntilDate)

		// Calculate penarikan tunai sum up to this pelimpahan date (moves from bank to tunai, net 0 on total)
		// Note: Penarikan doesn't affect total saldo, only the bank/tunai split

		// Calculate total pelimpahan from all earlier pelimpahan (by date/nomor order)
		var pelimpahanBefore float64 = 0
		for _, prev := range allPelimpahan {
			if prev.TanggalPelimpahan.Before(p.TanggalPelimpahan) ||
				(prev.TanggalPelimpahan.Equal(p.TanggalPelimpahan) && prev.NomorPelimpahan < p.NomorPelimpahan) {
				for _, detail := range prev.Details {
					pelimpahanBefore += detail.Jumlah
				}
			}
		}

		// Current pelimpahan amount
		var currentPelimpahan float64 = 0
		for _, detail := range p.Details {
			currentPelimpahan += detail.Jumlah
		}

		// Saldo awal = base saldo + top up until this date
		saldoAwal := baseSaldoBank + baseSaldoTunai + topUpUntilDate
		saldoAwalMap[p.ID] = saldoAwal

		// Sisa saldo = saldo awal - pelimpahan before - current pelimpahan
		sisaSaldo := saldoAwal - pelimpahanBefore - currentPelimpahan
		sisaSaldoMap[p.ID] = sisaSaldo
	}

	// Build response
	type PelimpahanWithSaldo struct {
		models.Pelimpahan
		SaldoBank  float64 `json:"saldo_bank"`
		SaldoTunai float64 `json:"saldo_tunai"`
		SaldoAwal  float64 `json:"saldo_awal"`
		SisaSaldo  float64 `json:"sisa_saldo"`
	}

	var pelimpahanWithSaldo []PelimpahanWithSaldo
	for _, p := range pelimpahanList {
		// Calculate jumlah per sumber for this transaction
		var jumlahBank float64 = 0
		var jumlahTunai float64 = 0
		for _, detail := range p.Details {
			if detail.SumberDana == "tunai" {
				jumlahTunai += detail.Jumlah
			} else {
				jumlahBank += detail.Jumlah
			}
		}

		pelimpahanWithSaldo = append(pelimpahanWithSaldo, PelimpahanWithSaldo{
			Pelimpahan: p,
			SaldoBank:  jumlahBank,
			SaldoTunai: jumlahTunai,
			SaldoAwal:  saldoAwalMap[p.ID],
			SisaSaldo:  sisaSaldoMap[p.ID],
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    pelimpahanWithSaldo,
		"meta": gin.H{
			"total":     total,
			"page":      page,
			"per_page":  perPage,
			"last_page": (int(total) + perPage - 1) / perPage,
		},
	})
}

func CreatePelimpahan(c *gin.Context) {
	var req struct {
		TanggalPelimpahan string `json:"tanggal_pelimpahan"`
		UraianPelimpahan  string `json:"uraian_pelimpahan"`
		JenisPelimpahanID uint   `json:"jenis_pelimpahan_id"`
		Details           []struct {
			UnitID        uint    `json:"unit_id"`
			NamaPenerima  string  `json:"nama_penerima"`
			NomorRekening string  `json:"nomor_rekening"`
			Jumlah        float64 `json:"jumlah"`
			SumberDana    string  `json:"sumber_dana"`
		} `json:"details"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request data"})
		return
	}

	if len(req.Details) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Minimal satu penerima harus diisi"})
		return
	}

	tanggal, _ := time.Parse("2006-01-02", req.TanggalPelimpahan)

	// Get next nomor
	var lastPelimpahan models.Pelimpahan
	var nomorPelimpahan int = 1
	if err := DB.Where("jenis_pelimpahan_id = ?", req.JenisPelimpahanID).
		Order("nomor_pelimpahan desc").First(&lastPelimpahan).Error; err == nil {
		nomorPelimpahan = lastPelimpahan.NomorPelimpahan + 1
	}

	var totalJumlah float64
	for _, d := range req.Details {
		totalJumlah += d.Jumlah
	}

	loc, _ := time.LoadLocation("Asia/Makassar")
	pelimpahan := models.Pelimpahan{
		NomorPelimpahan:   nomorPelimpahan,
		WaktuPelimpahan:   time.Now().In(loc),
		TanggalPelimpahan: tanggal,
		UraianPelimpahan:  req.UraianPelimpahan,
		JenisPelimpahanID: req.JenisPelimpahanID,
		CreatedBy:         c.GetUint("user_id"),
		TotalJumlah:       totalJumlah,
	}

	DB.Create(&pelimpahan)

	for _, d := range req.Details {
		// Validate sumber_dana per detail
		sumberDana := d.SumberDana
		if sumberDana != "bank" && sumberDana != "tunai" {
			sumberDana = "bank" // default to bank
		}
		
		detail := models.PelimpahanDetail{
			PelimpahanID:  pelimpahan.ID,
			UnitID:        d.UnitID,
			NamaPenerima:  d.NamaPenerima,
			NomorRekening: d.NomorRekening,
			Jumlah:        d.Jumlah,
			SumberDana:    sumberDana,
		}
		DB.Create(&detail)
	}

	DB.Preload("JenisPelimpahan").Preload("Creator").Preload("Details.Unit").First(&pelimpahan, pelimpahan.ID)

	c.JSON(http.StatusCreated, gin.H{"success": true, "message": "Pelimpahan berhasil dibuat", "data": pelimpahan})
}

func GetPelimpahanByID(c *gin.Context) {
	var pelimpahan models.Pelimpahan
	if err := DB.Preload("JenisPelimpahan").Preload("Creator").Preload("Details.Unit").
		First(&pelimpahan, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": pelimpahan})
}

func UpdatePelimpahan(c *gin.Context) {
	var pelimpahan models.Pelimpahan
	if err := DB.Preload("Details").First(&pelimpahan, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Not found"})
		return
	}

	var req struct {
		TanggalPelimpahan string `json:"tanggal_pelimpahan"`
		UraianPelimpahan  string `json:"uraian_pelimpahan"`
		JenisPelimpahanID uint   `json:"jenis_pelimpahan_id"`
		Reason            string `json:"reason"` // Alasan koreksi
		Details           []struct {
			UnitID        uint    `json:"unit_id"`
			NamaPenerima  string  `json:"nama_penerima"`
			NomorRekening string  `json:"nomor_rekening"`
			Jumlah        float64 `json:"jumlah"`
			SumberDana    string  `json:"sumber_dana"`
		} `json:"details"`
	}
	c.ShouldBindJSON(&req)

	tanggal, _ := time.Parse("2006-01-02", req.TanggalPelimpahan)

	var totalJumlah float64
	for _, d := range req.Details {
		totalJumlah += d.Jumlah
	}

	// Serialize old data for revision history
	dataBefore := map[string]interface{}{
		"tanggal_pelimpahan":  pelimpahan.TanggalPelimpahan,
		"uraian_pelimpahan":   pelimpahan.UraianPelimpahan,
		"jenis_pelimpahan_id": pelimpahan.JenisPelimpahanID,
		"total_jumlah":        pelimpahan.TotalJumlah,
		"details":             pelimpahan.Details,
	}
	dataBeforeJSON, _ := json.Marshal(dataBefore)

	// Get next revision number
	var lastRevision models.PelimpahanRevision
	var revisionNumber int = 1
	if err := DB.Where("pelimpahan_id = ?", pelimpahan.ID).Order("revision_number desc").First(&lastRevision).Error; err == nil {
		revisionNumber = lastRevision.RevisionNumber + 1
	}

	// Update pelimpahan
	pelimpahan.TanggalPelimpahan = tanggal
	pelimpahan.UraianPelimpahan = req.UraianPelimpahan
	pelimpahan.JenisPelimpahanID = req.JenisPelimpahanID
	pelimpahan.TotalJumlah = totalJumlah
	DB.Save(&pelimpahan)

	// Delete old details
	DB.Where("pelimpahan_id = ?", pelimpahan.ID).Delete(&models.PelimpahanDetail{})

	// Create new details
	var newDetails []models.PelimpahanDetail
	for _, d := range req.Details {
		sumberDana := d.SumberDana
		if sumberDana != "bank" && sumberDana != "tunai" {
			sumberDana = "bank"
		}
		detail := models.PelimpahanDetail{
			PelimpahanID:  pelimpahan.ID,
			UnitID:        d.UnitID,
			NamaPenerima:  d.NamaPenerima,
			NomorRekening: d.NomorRekening,
			Jumlah:        d.Jumlah,
			SumberDana:    sumberDana,
		}
		DB.Create(&detail)
		newDetails = append(newDetails, detail)
	}

	// Serialize new data for revision history
	dataAfter := map[string]interface{}{
		"tanggal_pelimpahan":  tanggal,
		"uraian_pelimpahan":   req.UraianPelimpahan,
		"jenis_pelimpahan_id": req.JenisPelimpahanID,
		"total_jumlah":        totalJumlah,
		"details":             newDetails,
	}
	dataAfterJSON, _ := json.Marshal(dataAfter)

	// Get user ID from context
	userID, _ := c.Get("user_id")
	revisedBy := uint(1)
	if uid, ok := userID.(uint); ok {
		revisedBy = uid
	}

	// Save revision history
	revision := models.PelimpahanRevision{
		PelimpahanID:   pelimpahan.ID,
		RevisionNumber: revisionNumber,
		DataBefore:     string(dataBeforeJSON),
		DataAfter:      string(dataAfterJSON),
		Reason:         req.Reason,
		RevisedBy:      revisedBy,
		RevisedAt:      time.Now(),
	}
	DB.Create(&revision)

	DB.Preload("JenisPelimpahan").Preload("Creator").Preload("Details.Unit").First(&pelimpahan, pelimpahan.ID)

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Pelimpahan berhasil diupdate", "data": pelimpahan})
}


func DeletePelimpahan(c *gin.Context) {
	DB.Where("pelimpahan_id = ?", c.Param("id")).Delete(&models.PelimpahanDetail{})
	DB.Delete(&models.Pelimpahan{}, c.Param("id"))
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Pelimpahan berhasil dihapus"})
}

// GetPelimpahanRevisions returns revision history for a pelimpahan
func GetPelimpahanRevisions(c *gin.Context) {
	pelimpahanID := c.Param("id")
	
	var revisions []models.PelimpahanRevision
	if err := DB.Where("pelimpahan_id = ?", pelimpahanID).
		Preload("Revisor").
		Order("revision_number desc").
		Find(&revisions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Failed to fetch revisions"})
		return
	}
	
	c.JSON(http.StatusOK, gin.H{"success": true, "data": revisions})
}

// User Controllers
func GetUsers(c *gin.Context) {
	var users []models.User
	DB.Order("created_at desc").Find(&users)
	c.JSON(http.StatusOK, gin.H{"success": true, "data": users})
}

func CreateUser(c *gin.Context) {
	var req struct {
		Name     string `json:"name" binding:"required"`
		Email    string `json:"email" binding:"required"`
		Password string `json:"password" binding:"required"`
		Role     string `json:"role" binding:"required"`
		IsActive bool   `json:"is_active"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request data"})
		return
	}

	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)

	user := models.User{
		Name:     req.Name,
		Email:    req.Email,
		Password: string(hashedPassword),
		Role:     req.Role,
		IsActive: req.IsActive,
	}

	if err := DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Failed to create user"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"success": true, "message": "User berhasil dibuat"})
}

func GetUserByID(c *gin.Context) {
	var user models.User
	if err := DB.First(&user, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Not found"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "data": gin.H{
		"id": user.ID, "name": user.Name, "email": user.Email, "role": user.Role, "is_active": user.IsActive,
	}})
}

func UpdateUser(c *gin.Context) {
	var user models.User
	if err := DB.First(&user, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Not found"})
		return
	}

	var req struct {
		Name     string `json:"name"`
		Email    string `json:"email"`
		Password string `json:"password"`
		Role     string `json:"role"`
		IsActive bool   `json:"is_active"`
	}
	c.ShouldBindJSON(&req)

	user.Name = req.Name
	user.Email = req.Email
	user.Role = req.Role
	user.IsActive = req.IsActive

	if req.Password != "" {
		hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
		user.Password = string(hashedPassword)
	}

	DB.Save(&user)
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "User berhasil diupdate"})
}

func DeleteUser(c *gin.Context) {
	currentUserID := c.GetUint("user_id")
	if c.Param("id") == string(rune(currentUserID)) {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Tidak dapat menghapus akun sendiri"})
		return
	}
	DB.Delete(&models.User{}, c.Param("id"))
	c.JSON(http.StatusOK, gin.H{"success": true, "message": "User berhasil dihapus"})
}

// Saldo Bendahara Controllers
func GetSaldoBendahara(c *gin.Context) {
	var saldos []models.SaldoBendahara
	query := DB.Model(&models.SaldoBendahara{}).Preload("Creator")

	// Year filtering
	tahunAnggaran := c.GetHeader("X-Tahun-Anggaran")
	if tahunAnggaran == "" {
		tahunAnggaran = "2025"
	}
	query = query.Where("tahun_anggaran = ?", tahunAnggaran)

	// Search
	if search := c.Query("search"); search != "" {
		query = query.Where("keterangan ILIKE ?", "%"+search+"%")
	}

	// Sorting
	sortBy := c.DefaultQuery("sort_by", "tanggal")
	sortOrder := c.DefaultQuery("sort_order", "desc")
	query = query.Order(sortBy + " " + sortOrder)

	// Pagination
	page := atoi(c.DefaultQuery("page", "1"))
	perPage := atoi(c.DefaultQuery("per_page", "10"))
	offset := (page - 1) * perPage

	var total int64
	query.Count(&total)

	query.Limit(perPage).Offset(offset).Find(&saldos)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    saldos,
		"meta": gin.H{
			"total":    total,
			"page":     page,
			"per_page": perPage,
		},
	})
}

func GetLatestSaldo(c *gin.Context) {
	// Get tahun anggaran from header
	tahunAnggaran := c.GetHeader("X-Tahun-Anggaran")
	if tahunAnggaran == "" {
		tahunAnggaran = "2025"
	}

	// Get latest saldo bendahara for this year
	var latestSaldo models.SaldoBendahara
	var saldoBank float64 = 0
	var saldoTunai float64 = 0

	if err := DB.Where("tahun_anggaran = ?", tahunAnggaran).Order("tanggal desc").First(&latestSaldo).Error; err == nil {
		saldoBank = latestSaldo.SaldoBank
		saldoTunai = latestSaldo.SaldoTunai
	}

	// Add top up to saldo bank (filtered by year)
	var totalTopUp float64
	DB.Model(&models.TopUpSaldo{}).Where("tahun_anggaran = ?", tahunAnggaran).Select("COALESCE(SUM(jumlah), 0)").Scan(&totalTopUp)
	saldoBank += totalTopUp

	// Subtract penarikan tunai from bank, add to tunai (filtered by year)
	var totalPenarikan float64
	DB.Model(&models.PenarikanTunai{}).Where("tahun_anggaran = ?", tahunAnggaran).Select("COALESCE(SUM(jumlah), 0)").Scan(&totalPenarikan)
	saldoBank -= totalPenarikan
	saldoTunai += totalPenarikan

	// Subtract pelimpahan from respective sources (filtered by year via join)
	var totalPelimpahanBank float64
	DB.Model(&models.PelimpahanDetail{}).
		Joins("JOIN pelimpahans ON pelimpahans.id = pelimpahan_details.pelimpahan_id").
		Where("pelimpahans.tahun_anggaran = ?", tahunAnggaran).
		Where("pelimpahan_details.sumber_dana = ?", "bank").
		Select("COALESCE(SUM(pelimpahan_details.jumlah), 0)").Scan(&totalPelimpahanBank)
	saldoBank -= totalPelimpahanBank

	var totalPelimpahanTunai float64
	DB.Model(&models.PelimpahanDetail{}).
		Joins("JOIN pelimpahans ON pelimpahans.id = pelimpahan_details.pelimpahan_id").
		Where("pelimpahans.tahun_anggaran = ?", tahunAnggaran).
		Where("pelimpahan_details.sumber_dana = ?", "tunai").
		Select("COALESCE(SUM(pelimpahan_details.jumlah), 0)").Scan(&totalPelimpahanTunai)
	saldoTunai -= totalPelimpahanTunai

	// Add pengembalian dana (returns go back to saldo)
	var totalPengembalianBank float64
	DB.Model(&models.PengembalianDana{}).
		Where("tahun_anggaran = ?", tahunAnggaran).
		Where("sumber_dana = ?", "bank").
		Select("COALESCE(SUM(jumlah), 0)").Scan(&totalPengembalianBank)
	saldoBank += totalPengembalianBank

	var totalPengembalianTunai float64
	DB.Model(&models.PengembalianDana{}).
		Where("tahun_anggaran = ?", tahunAnggaran).
		Where("sumber_dana = ?", "tunai").
		Select("COALESCE(SUM(jumlah), 0)").Scan(&totalPengembalianTunai)
	saldoTunai += totalPengembalianTunai

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"saldo_bank":  saldoBank,
			"saldo_tunai": saldoTunai,
			"total_saldo": saldoBank + saldoTunai,
			"tanggal":     latestSaldo.Tanggal,
		},
	})
}

// GetSaldoByMonth calculates saldo at the end of a specific month
func GetSaldoByMonth(c *gin.Context) {
	month := c.Query("month")
	year := c.Query("year")
	if month == "" || year == "" {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Month and year are required"})
		return
	}

	// Calculate the last day of the selected month
	monthInt := 0
	yearInt := 0
	fmt.Sscanf(month, "%d", &monthInt)
	fmt.Sscanf(year, "%d", &yearInt)

	// End of month date
	var endOfMonth time.Time
	if monthInt == 12 {
		endOfMonth = time.Date(yearInt+1, 1, 1, 0, 0, 0, 0, time.Local).AddDate(0, 0, -1)
	} else {
		endOfMonth = time.Date(yearInt, time.Month(monthInt+1), 1, 0, 0, 0, 0, time.Local).AddDate(0, 0, -1)
	}

	// Get latest saldo bendahara (base saldo)
	var latestSaldo models.SaldoBendahara
	var baseSaldoBank float64 = 0
	var baseSaldoTunai float64 = 0
	var saldoAwalDate time.Time

	if err := DB.Where("tahun_anggaran = ?", year).Order("tanggal desc").First(&latestSaldo).Error; err == nil {
		baseSaldoBank = latestSaldo.SaldoBank
		baseSaldoTunai = latestSaldo.SaldoTunai
		saldoAwalDate = latestSaldo.Tanggal
	}

	// Calculate total top up until end of month
	var totalTopUp float64
	DB.Model(&models.TopUpSaldo{}).
		Where("tahun_anggaran = ?", year).
		Where("tanggal <= ?", endOfMonth).
		Select("COALESCE(SUM(jumlah), 0)").Scan(&totalTopUp)

	// Calculate total penarikan tunai until end of month
	var totalPenarikan float64
	DB.Model(&models.PenarikanTunai{}).
		Where("tahun_anggaran = ?", year).
		Where("tanggal <= ?", endOfMonth).
		Select("COALESCE(SUM(jumlah), 0)").Scan(&totalPenarikan)

	// Calculate total pelimpahan bank until end of month
	var totalPelimpahanBank float64
	DB.Model(&models.PelimpahanDetail{}).
		Joins("JOIN pelimpahans ON pelimpahans.id = pelimpahan_details.pelimpahan_id").
		Where("pelimpahans.tahun_anggaran = ?", year).
		Where("pelimpahans.tanggal_pelimpahan <= ?", endOfMonth).
		Where("pelimpahan_details.sumber_dana = ?", "bank").
		Select("COALESCE(SUM(pelimpahan_details.jumlah), 0)").Scan(&totalPelimpahanBank)

	// Calculate total pelimpahan tunai until end of month
	var totalPelimpahanTunai float64
	DB.Model(&models.PelimpahanDetail{}).
		Joins("JOIN pelimpahans ON pelimpahans.id = pelimpahan_details.pelimpahan_id").
		Where("pelimpahans.tahun_anggaran = ?", year).
		Where("pelimpahans.tanggal_pelimpahan <= ?", endOfMonth).
		Where("pelimpahan_details.sumber_dana = ?", "tunai").
		Select("COALESCE(SUM(pelimpahan_details.jumlah), 0)").Scan(&totalPelimpahanTunai)

	// Calculate final saldo
	saldoBank := baseSaldoBank + totalTopUp - totalPenarikan - totalPelimpahanBank
	saldoTunai := baseSaldoTunai + totalPenarikan - totalPelimpahanTunai

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"saldo_awal":             baseSaldoBank + baseSaldoTunai,
			"saldo_awal_date":        saldoAwalDate,
			"total_topup":            totalTopUp,
			"total_penarikan":        totalPenarikan,
			"total_pelimpahan_bank":  totalPelimpahanBank,
			"total_pelimpahan_tunai": totalPelimpahanTunai,
			"saldo_bank":             saldoBank,
			"saldo_tunai":            saldoTunai,
			"total_saldo":            saldoBank + saldoTunai,
		},
	})
}

// GetSisaSaldoPerJenis calculates remaining saldo per jenis pelimpahan (UP/GU and TU)
// Logic:
// UP/GU pool = Saldo Bendahara + TopUp(UPGU) - Penarikan - Pelimpahan UP/GU + Pengembalian UP/GU
// TU pool = TopUp(TU) - Pelimpahan TU + Pengembalian TU (separate tracking)
func GetSisaSaldoPerJenis(c *gin.Context) {
	// Get tahun anggaran from header
	tahunAnggaran := c.GetHeader("X-Tahun-Anggaran")
	if tahunAnggaran == "" {
		tahunAnggaran = "2025"
	}

	// ============================================
	// CALCULATE SISA SALDO UP/GU
	// ============================================

	// Get base saldo bendahara (bank + tunai) - this is for UP/GU
	var latestSaldo models.SaldoBendahara
	var baseSaldoUPGU float64 = 0
	if err := DB.Where("tahun_anggaran = ?", tahunAnggaran).Order("tanggal desc").First(&latestSaldo).Error; err == nil {
		baseSaldoUPGU = latestSaldo.SaldoBank + latestSaldo.SaldoTunai
	}

	// Add TopUp for UPGU only
	var totalTopUpUPGU float64
	DB.Model(&models.TopUpSaldo{}).
		Where("tahun_anggaran = ?", tahunAnggaran).
		Where("jenis_saldo = ? OR jenis_saldo IS NULL OR jenis_saldo = ''", "UPGU").
		Select("COALESCE(SUM(jumlah), 0)").Scan(&totalTopUpUPGU)
	baseSaldoUPGU += totalTopUpUPGU

	// Subtract penarikan tunai (only for UPGU pool)
	var totalPenarikan float64
	DB.Model(&models.PenarikanTunai{}).
		Where("tahun_anggaran = ?", tahunAnggaran).
		Select("COALESCE(SUM(jumlah), 0)").Scan(&totalPenarikan)
	baseSaldoUPGU -= totalPenarikan

	// Get jenis pelimpahan IDs
	var jenisUP, jenisGU, jenisTU models.JenisPelimpahan
	DB.Where("kode_jenis = ?", "UP").First(&jenisUP)
	DB.Where("kode_jenis = ?", "GU").First(&jenisGU)
	DB.Where("kode_jenis = ?", "TU").First(&jenisTU)

	// Calculate pelimpahan for UP/GU
	var totalPelimpahanUPGU float64
	DB.Model(&models.PelimpahanDetail{}).
		Joins("JOIN pelimpahans ON pelimpahans.id = pelimpahan_details.pelimpahan_id").
		Where("pelimpahans.tahun_anggaran = ?", tahunAnggaran).
		Where("pelimpahans.jenis_pelimpahan_id IN ?", []uint{jenisUP.ID, jenisGU.ID}).
		Select("COALESCE(SUM(pelimpahan_details.jumlah), 0)").Scan(&totalPelimpahanUPGU)

	// Calculate pengembalian for UP/GU
	var totalPengembalianUPGU float64
	DB.Model(&models.PengembalianDana{}).
		Joins("JOIN pelimpahan_details ON pelimpahan_details.id = pengembalian_danas.pelimpahan_detail_id").
		Joins("JOIN pelimpahans ON pelimpahans.id = pelimpahan_details.pelimpahan_id").
		Where("pengembalian_danas.tahun_anggaran = ?", tahunAnggaran).
		Where("pelimpahans.jenis_pelimpahan_id IN ?", []uint{jenisUP.ID, jenisGU.ID}).
		Select("COALESCE(SUM(pengembalian_danas.jumlah), 0)").Scan(&totalPengembalianUPGU)

	// Sisa UP/GU
	sisaUPGU := baseSaldoUPGU - totalPelimpahanUPGU + totalPengembalianUPGU

	// ============================================
	// CALCULATE SISA SALDO TU (Separate Pool)
	// ============================================

	// TU has its own top up pool (no base saldo)
	var totalTopUpTU float64
	DB.Model(&models.TopUpSaldo{}).
		Where("tahun_anggaran = ?", tahunAnggaran).
		Where("jenis_saldo = ?", "TU").
		Select("COALESCE(SUM(jumlah), 0)").Scan(&totalTopUpTU)

	// Calculate pelimpahan for TU
	var totalPelimpahanTU float64
	DB.Model(&models.PelimpahanDetail{}).
		Joins("JOIN pelimpahans ON pelimpahans.id = pelimpahan_details.pelimpahan_id").
		Where("pelimpahans.tahun_anggaran = ?", tahunAnggaran).
		Where("pelimpahans.jenis_pelimpahan_id = ?", jenisTU.ID).
		Select("COALESCE(SUM(pelimpahan_details.jumlah), 0)").Scan(&totalPelimpahanTU)

	// Calculate pengembalian for TU
	var totalPengembalianTU float64
	DB.Model(&models.PengembalianDana{}).
		Joins("JOIN pelimpahan_details ON pelimpahan_details.id = pengembalian_danas.pelimpahan_detail_id").
		Joins("JOIN pelimpahans ON pelimpahans.id = pelimpahan_details.pelimpahan_id").
		Where("pengembalian_danas.tahun_anggaran = ?", tahunAnggaran).
		Where("pelimpahans.jenis_pelimpahan_id = ?", jenisTU.ID).
		Select("COALESCE(SUM(pengembalian_danas.jumlah), 0)").Scan(&totalPengembalianTU)

	// Sisa TU = TopUp TU - Pelimpahan TU + Pengembalian TU
	sisaTU := totalTopUpTU - totalPelimpahanTU + totalPengembalianTU

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data": gin.H{
			"sisa_upgu":         sisaUPGU,
			"sisa_tu":           sisaTU,
			"topup_upgu":        totalTopUpUPGU,
			"topup_tu":          totalTopUpTU,
			"pelimpahan_upgu":   totalPelimpahanUPGU,
			"pelimpahan_tu":     totalPelimpahanTU,
			"pengembalian_upgu": totalPengembalianUPGU,
			"pengembalian_tu":   totalPengembalianTU,
		},
	})
}

func GetSaldoBendaharaByID(c *gin.Context) {
	var saldo models.SaldoBendahara
	if err := DB.Preload("Creator").First(&saldo, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Saldo tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    saldo,
	})
}

func CreateSaldoBendahara(c *gin.Context) {
	var input struct {
		Tanggal    string  `json:"tanggal" binding:"required"`
		SaldoBank  float64 `json:"saldo_bank" binding:"gte=0"`
		SaldoTunai float64 `json:"saldo_tunai" binding:"gte=0"`
		Keterangan string  `json:"keterangan"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": err.Error()})
		return
	}

	// Parse tanggal
	tanggal, err := time.Parse("2006-01-02", input.Tanggal)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Format tanggal tidak valid"})
		return
	}

	// Get user ID from context
	userID, _ := c.Get("user_id")

	saldo := models.SaldoBendahara{
		Tanggal:    tanggal,
		SaldoBank:  input.SaldoBank,
		SaldoTunai: input.SaldoTunai,
		Keterangan: input.Keterangan,
		CreatedBy:  userID.(uint),
	}

	if err := DB.Create(&saldo).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Gagal menyimpan saldo"})
		return
	}

	// Load creator
	DB.Preload("Creator").First(&saldo, saldo.ID)

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": "Saldo berhasil ditambahkan",
		"data":    saldo,
	})
}

func UpdateSaldoBendahara(c *gin.Context) {
	var saldo models.SaldoBendahara
	if err := DB.First(&saldo, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Saldo tidak ditemukan"})
		return
	}

	var input struct {
		Tanggal    string  `json:"tanggal" binding:"required"`
		SaldoBank  float64 `json:"saldo_bank" binding:"gte=0"`
		SaldoTunai float64 `json:"saldo_tunai" binding:"gte=0"`
		Keterangan string  `json:"keterangan"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": err.Error()})
		return
	}

	// Parse tanggal
	tanggal, err := time.Parse("2006-01-02", input.Tanggal)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Format tanggal tidak valid"})
		return
	}

	saldo.Tanggal = tanggal
	saldo.SaldoBank = input.SaldoBank
	saldo.SaldoTunai = input.SaldoTunai
	saldo.Keterangan = input.Keterangan

	if err := DB.Save(&saldo).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Gagal mengupdate saldo"})
		return
	}

	// Load creator
	DB.Preload("Creator").First(&saldo, saldo.ID)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Saldo berhasil diupdate",
		"data":    saldo,
	})
}

func DeleteSaldoBendahara(c *gin.Context) {
	if err := DB.Delete(&models.SaldoBendahara{}, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Gagal menghapus saldo"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Saldo berhasil dihapus",
	})
}

// Helper function
func atoi(s string) int {
	var n int
	for _, c := range s {
		n = n*10 + int(c-'0')
	}
	return n
}
// TOP UP SALDO CONTROLLERS

func GetTopUpSaldo(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	perPage, _ := strconv.Atoi(c.DefaultQuery("per_page", "10"))
	search := c.Query("search")
	sortBy := c.DefaultQuery("sort_by", "tanggal")
	sortOrder := c.DefaultQuery("sort_order", "desc")

	// Get tahun anggaran from header
	tahunAnggaran := c.GetHeader("X-Tahun-Anggaran")
	if tahunAnggaran == "" {
		tahunAnggaran = "2025"
	}

	var topUpList []models.TopUpSaldo
	var total int64

	query := DB.Model(&models.TopUpSaldo{}).Preload("Creator").
		Where("tahun_anggaran = ?", tahunAnggaran)

	if search != "" {
		query = query.Where("keterangan LIKE ?", "%"+search+"%")
	}

	query.Count(&total)

	offset := (page - 1) * perPage
	query.Order(sortBy + " " + sortOrder).Limit(perPage).Offset(offset).Find(&topUpList)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    topUpList,
		"meta": gin.H{
			"total":     total,
			"page":      page,
			"per_page":  perPage,
			"last_page": (int(total) + perPage - 1) / perPage,
		},
	})
}

func GetTopUpSaldoByID(c *gin.Context) {
	var topUp models.TopUpSaldo
	if err := DB.Preload("Creator").First(&topUp, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Data tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    topUp,
	})
}

func CreateTopUpSaldo(c *gin.Context) {
	var req struct {
		Tanggal    string  `json:"tanggal" binding:"required"`
		Jumlah     float64 `json:"jumlah" binding:"required,gt=0"`
		Keterangan string  `json:"keterangan" binding:"required,min=3"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Data tidak valid"})
		return
	}

	tanggal, _ := time.Parse("2006-01-02", req.Tanggal)

	topUp := models.TopUpSaldo{
		Tanggal:    tanggal,
		Jumlah:     req.Jumlah,
		Keterangan: req.Keterangan,
		CreatedBy:  c.GetUint("user_id"),
	}

	if err := DB.Create(&topUp).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Gagal menyimpan data"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Top up berhasil ditambahkan",
		"data":    topUp,
	})
}

func UpdateTopUpSaldo(c *gin.Context) {
	var topUp models.TopUpSaldo
	if err := DB.First(&topUp, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Data tidak ditemukan"})
		return
	}

	var req struct {
		Tanggal    string  `json:"tanggal" binding:"required"`
		Jumlah     float64 `json:"jumlah" binding:"required,gt=0"`
		Keterangan string  `json:"keterangan" binding:"required,min=3"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Data tidak valid"})
		return
	}

	tanggal, _ := time.Parse("2006-01-02", req.Tanggal)

	topUp.Tanggal = tanggal
	topUp.Jumlah = req.Jumlah
	topUp.Keterangan = req.Keterangan

	if err := DB.Save(&topUp).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Gagal mengupdate data"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Top up berhasil diupdate",
		"data":    topUp,
	})
}

func DeleteTopUpSaldo(c *gin.Context) {
	if err := DB.Delete(&models.TopUpSaldo{}, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Gagal menghapus data"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Top up berhasil dihapus",
	})
}

// PENARIKAN TUNAI CONTROLLERS

func GetPenarikanTunai(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	perPage, _ := strconv.Atoi(c.DefaultQuery("per_page", "10"))
	search := c.Query("search")
	sortBy := c.DefaultQuery("sort_by", "tanggal")
	sortOrder := c.DefaultQuery("sort_order", "desc")

	// Get tahun anggaran from header
	tahunAnggaran := c.GetHeader("X-Tahun-Anggaran")
	if tahunAnggaran == "" {
		tahunAnggaran = "2025"
	}

	var penarikanList []models.PenarikanTunai
	var total int64

	query := DB.Model(&models.PenarikanTunai{}).Preload("Creator").
		Where("tahun_anggaran = ?", tahunAnggaran)

	if search != "" {
		query = query.Where("keterangan LIKE ?", "%"+search+"%")
	}

	query.Count(&total)

	offset := (page - 1) * perPage
	query.Order(sortBy + " " + sortOrder).Limit(perPage).Offset(offset).Find(&penarikanList)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    penarikanList,
		"meta": gin.H{
			"total":     total,
			"page":      page,
			"per_page":  perPage,
			"last_page": (int(total) + perPage - 1) / perPage,
		},
	})
}

func GetPenarikanTunaiByID(c *gin.Context) {
	var penarikan models.PenarikanTunai
	if err := DB.Preload("Creator").First(&penarikan, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Data tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    penarikan,
	})
}

func CreatePenarikanTunai(c *gin.Context) {
	var req struct {
		Tanggal    string  `json:"tanggal" binding:"required"`
		Jumlah     float64 `json:"jumlah" binding:"required,gt=0"`
		Keterangan string  `json:"keterangan" binding:"required,min=3"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Data tidak valid"})
		return
	}

	// Calculate current saldo bank
	var latestSaldo models.SaldoBendahara
	var saldoBank float64 = 0
	if err := DB.Order("tanggal desc").First(&latestSaldo).Error; err == nil {
		saldoBank = latestSaldo.SaldoBank
	}

	// Add top ups
	var totalTopUp float64
	DB.Model(&models.TopUpSaldo{}).Select("COALESCE(SUM(jumlah), 0)").Scan(&totalTopUp)
	saldoBank += totalTopUp

	// Subtract penarikan tunai
	var totalPenarikan float64
	DB.Model(&models.PenarikanTunai{}).Select("COALESCE(SUM(jumlah), 0)").Scan(&totalPenarikan)
	saldoBank -= totalPenarikan

	// Subtract pelimpahan bank
	var totalPelimpahanBank float64
	DB.Model(&models.PelimpahanDetail{}).Where("sumber_dana = ?", "bank").Select("COALESCE(SUM(jumlah), 0)").Scan(&totalPelimpahanBank)
	saldoBank -= totalPelimpahanBank

	// Validate: saldo bank must be sufficient
	if saldoBank < req.Jumlah {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Saldo bank tidak mencukupi untuk penarikan tunai",
			"data": gin.H{
				"saldo_bank_tersedia": saldoBank,
				"jumlah_penarikan":    req.Jumlah,
			},
		})
		return
	}

	tanggal, _ := time.Parse("2006-01-02", req.Tanggal)

	penarikan := models.PenarikanTunai{
		Tanggal:    tanggal,
		Jumlah:     req.Jumlah,
		Keterangan: req.Keterangan,
		CreatedBy:  c.GetUint("user_id"),
	}

	if err := DB.Create(&penarikan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Gagal menyimpan data"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Penarikan tunai berhasil ditambahkan",
		"data":    penarikan,
	})
}

func UpdatePenarikanTunai(c *gin.Context) {
	var penarikan models.PenarikanTunai
	if err := DB.First(&penarikan, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Data tidak ditemukan"})
		return
	}

	var req struct {
		Tanggal    string  `json:"tanggal" binding:"required"`
		Jumlah     float64 `json:"jumlah" binding:"required,gt=0"`
		Keterangan string  `json:"keterangan" binding:"required,min=3"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Data tidak valid"})
		return
	}

	// Calculate current saldo bank (excluding this penarikan)
	var latestSaldo models.SaldoBendahara
	var saldoBank float64 = 0
	if err := DB.Order("tanggal desc").First(&latestSaldo).Error; err == nil {
		saldoBank = latestSaldo.SaldoBank
	}

	var totalTopUp float64
	DB.Model(&models.TopUpSaldo{}).Select("COALESCE(SUM(jumlah), 0)").Scan(&totalTopUp)
	saldoBank += totalTopUp

	var totalPenarikan float64
	DB.Model(&models.PenarikanTunai{}).Where("id != ?", penarikan.ID).Select("COALESCE(SUM(jumlah), 0)").Scan(&totalPenarikan)
	saldoBank -= totalPenarikan

	var totalPelimpahanBank float64
	DB.Model(&models.PelimpahanDetail{}).Where("sumber_dana = ?", "bank").Select("COALESCE(SUM(jumlah), 0)").Scan(&totalPelimpahanBank)
	saldoBank -= totalPelimpahanBank

	// Validate
	if saldoBank < req.Jumlah {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Saldo bank tidak mencukupi untuk penarikan tunai",
			"data": gin.H{
				"saldo_bank_tersedia": saldoBank,
				"jumlah_penarikan":    req.Jumlah,
			},
		})
		return
	}

	tanggal, _ := time.Parse("2006-01-02", req.Tanggal)

	penarikan.Tanggal = tanggal
	penarikan.Jumlah = req.Jumlah
	penarikan.Keterangan = req.Keterangan

	if err := DB.Save(&penarikan).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Gagal mengupdate data"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Penarikan tunai berhasil diupdate",
		"data":    penarikan,
	})
}

func DeletePenarikanTunai(c *gin.Context) {
	if err := DB.Delete(&models.PenarikanTunai{}, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Gagal menghapus data"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "Penarikan tunai berhasil dihapus",
	})
}

// Pengembalian Dana Controllers
func GetPengembalianDana(c *gin.Context) {
	var pengembalianList []models.PengembalianDana
	query := DB.Model(&models.PengembalianDana{}).
		Preload("PelimpahanDetail.Unit").
		Preload("Creator")

	// Filter by tahun anggaran
	tahunAnggaran := time.Now().Year()
	if tahun := c.Query("tahun_anggaran"); tahun != "" {
		fmt.Sscanf(tahun, "%d", &tahunAnggaran)
	}
	query = query.Where("tahun_anggaran = ?", tahunAnggaran)

	query.Order("tanggal desc").Find(&pengembalianList)

	c.JSON(http.StatusOK, gin.H{"success": true, "data": pengembalianList})
}

func GetPengembalianByPelimpahan(c *gin.Context) {
	pelimpahanID := c.Param("id")
	
	var pengembalianList []models.PengembalianDana
	DB.Model(&models.PengembalianDana{}).
		Joins("JOIN pelimpahan_details ON pelimpahan_details.id = pengembalian_danas.pelimpahan_detail_id").
		Where("pelimpahan_details.pelimpahan_id = ?", pelimpahanID).
		Preload("PelimpahanDetail.Unit").
		Preload("Creator").
		Order("pengembalian_danas.tanggal desc").
		Find(&pengembalianList)

	c.JSON(http.StatusOK, gin.H{"success": true, "data": pengembalianList})
}

func CreatePengembalianDana(c *gin.Context) {
	var req struct {
		PelimpahanDetailID uint    `json:"pelimpahan_detail_id" binding:"required"`
		Tanggal            string  `json:"tanggal" binding:"required"`
		Jumlah             float64 `json:"jumlah" binding:"required"`
		SumberDana         string  `json:"sumber_dana"`
		Keterangan         string  `json:"keterangan"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Invalid request"})
		return
	}

	// Validate pelimpahan detail exists
	var detail models.PelimpahanDetail
	if err := DB.Preload("Unit").First(&detail, req.PelimpahanDetailID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"success": false, "message": "Detail pelimpahan tidak ditemukan"})
		return
	}

	// Validate jumlah tidak melebihi jumlah pelimpahan
	var totalPengembalian float64
	DB.Model(&models.PengembalianDana{}).
		Where("pelimpahan_detail_id = ?", req.PelimpahanDetailID).
		Select("COALESCE(SUM(jumlah), 0)").
		Scan(&totalPengembalian)

	if totalPengembalian + req.Jumlah > detail.Jumlah {
		c.JSON(http.StatusBadRequest, gin.H{
			"success": false, 
			"message": fmt.Sprintf("Jumlah pengembalian melebihi sisa yang dapat dikembalikan. Maksimal: Rp %s", 
				formatCurrency(detail.Jumlah - totalPengembalian)),
		})
		return
	}

	tanggal, err := time.Parse("2006-01-02", req.Tanggal)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"success": false, "message": "Format tanggal tidak valid"})
		return
	}

	sumberDana := req.SumberDana
	if sumberDana != "bank" && sumberDana != "tunai" {
		sumberDana = "bank"
	}

	userID, _ := c.Get("user_id")
	createdBy := uint(1)
	if uid, ok := userID.(uint); ok {
		createdBy = uid
	}

	pengembalian := models.PengembalianDana{
		TahunAnggaran:      tanggal.Year(),
		PelimpahanDetailID: req.PelimpahanDetailID,
		Tanggal:            tanggal,
		Jumlah:             req.Jumlah,
		SumberDana:         sumberDana,
		Keterangan:         req.Keterangan,
		CreatedBy:          createdBy,
	}

	if err := DB.Create(&pengembalian).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Gagal menyimpan data"})
		return
	}

	DB.Preload("PelimpahanDetail.Unit").Preload("Creator").First(&pengembalian, pengembalian.ID)

	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"message": fmt.Sprintf("Pengembalian dana dari %s berhasil dicatat", detail.Unit.NamaUnit),
		"data":    pengembalian,
	})
}

func DeletePengembalianDana(c *gin.Context) {
	if err := DB.Delete(&models.PengembalianDana{}, c.Param("id")).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"success": false, "message": "Gagal menghapus data"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true, "message": "Pengembalian dana berhasil dihapus"})
}

func formatCurrency(value float64) string {
	return fmt.Sprintf("%.0f", value)
}
