package controllers

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	"google.golang.org/api/drive/v3"
	"google.golang.org/api/option"
)

// Backup directory
const backupDir = "./backups"

// Google OAuth config
var googleOAuthConfig *oauth2.Config
var googleDriveTokens = make(map[uint]*oauth2.Token) // userId -> token

func init() {
	// Ensure backup directory exists
	os.MkdirAll(backupDir, 0755)
}

// InitGoogleOAuth initializes Google OAuth configuration
func InitGoogleOAuth() {
	clientID := os.Getenv("GOOGLE_CLIENT_ID")
	clientSecret := os.Getenv("GOOGLE_CLIENT_SECRET")
	redirectURL := os.Getenv("GOOGLE_REDIRECT_URL")

	if clientID == "" || clientSecret == "" {
		fmt.Println("Warning: Google OAuth credentials not configured")
		return
	}

	if redirectURL == "" {
		redirectURL = "http://localhost:8000/api/backup/google/callback"
	}

	googleOAuthConfig = &oauth2.Config{
		ClientID:     clientID,
		ClientSecret: clientSecret,
		RedirectURL:  redirectURL,
		Scopes: []string{
			"https://www.googleapis.com/auth/drive.file",
		},
		Endpoint: google.Endpoint,
	}
}

// BackupInfo represents a backup file info
type BackupInfo struct {
	Filename  string    `json:"filename"`
	Size      int64     `json:"size"`
	SizeHuman string    `json:"size_human"`
	CreatedAt time.Time `json:"created_at"`
	Source    string    `json:"source"` // "local" or "google_drive"
	DriveID   string    `json:"drive_id,omitempty"`
}

// CreateBackup creates a new database backup
func CreateBackup(c *gin.Context) {
	// Get database connection details from environment
	dbHost := os.Getenv("DB_HOST")
	dbPort := os.Getenv("DB_PORT")
	dbUser := os.Getenv("DB_USERNAME")
	dbPass := os.Getenv("DB_PASSWORD")
	dbName := os.Getenv("DB_DATABASE")

	if dbHost == "" {
		dbHost = "localhost"
	}
	if dbPort == "" {
		dbPort = "5432"
	}

	// Generate filename with timestamp
	timestamp := time.Now().Format("20060102_150405")
	filename := fmt.Sprintf("backup_%s_%s.sql", dbName, timestamp)
	filepath := filepath.Join(backupDir, filename)

	// Set PGPASSWORD environment variable
	os.Setenv("PGPASSWORD", dbPass)

	// Run pg_dump
	cmd := exec.Command("pg_dump",
		"-h", dbHost,
		"-p", dbPort,
		"-U", dbUser,
		"-d", dbName,
		"-f", filepath,
	)

	output, err := cmd.CombinedOutput()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":   "Failed to create backup",
			"details": string(output),
		})
		return
	}

	// Get file info
	fileInfo, err := os.Stat(filepath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get backup info"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Backup created successfully",
		"backup": BackupInfo{
			Filename:  filename,
			Size:      fileInfo.Size(),
			SizeHuman: formatBytes(fileInfo.Size()),
			CreatedAt: fileInfo.ModTime(),
			Source:    "local",
		},
	})
}

// GetBackupHistory returns list of all backups
func GetBackupHistory(c *gin.Context) {
	var backups []BackupInfo

	// Read local backup directory
	files, err := os.ReadDir(backupDir)
	if err != nil {
		// Directory might not exist yet
		c.JSON(http.StatusOK, gin.H{"backups": backups})
		return
	}

	for _, file := range files {
		if file.IsDir() || !strings.HasSuffix(file.Name(), ".sql") {
			continue
		}

		info, err := file.Info()
		if err != nil {
			continue
		}

		backups = append(backups, BackupInfo{
			Filename:  file.Name(),
			Size:      info.Size(),
			SizeHuman: formatBytes(info.Size()),
			CreatedAt: info.ModTime(),
			Source:    "local",
		})
	}

	// Sort by date descending (newest first)
	sort.Slice(backups, func(i, j int) bool {
		return backups[i].CreatedAt.After(backups[j].CreatedAt)
	})

	c.JSON(http.StatusOK, gin.H{"backups": backups})
}

// DownloadBackup downloads a backup file
func DownloadBackup(c *gin.Context) {
	filename := c.Param("filename")

	// Sanitize filename to prevent directory traversal
	filename = filepath.Base(filename)
	filePath := filepath.Join(backupDir, filename)

	// Check if file exists
	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		c.JSON(http.StatusNotFound, gin.H{"error": "Backup file not found"})
		return
	}

	c.Header("Content-Description", "File Transfer")
	c.Header("Content-Disposition", fmt.Sprintf("attachment; filename=%s", filename))
	c.Header("Content-Type", "application/sql")
	c.File(filePath)
}

// DeleteBackup deletes a backup file
func DeleteBackup(c *gin.Context) {
	filename := c.Param("filename")

	// Sanitize filename
	filename = filepath.Base(filename)
	filePath := filepath.Join(backupDir, filename)

	// Check if file exists
	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		c.JSON(http.StatusNotFound, gin.H{"error": "Backup file not found"})
		return
	}

	// Delete the file
	if err := os.Remove(filePath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete backup"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Backup deleted successfully"})
}

// === Google Drive Integration ===

// GoogleDriveStatus returns Google Drive connection status
func GoogleDriveStatus(c *gin.Context) {
	if googleOAuthConfig == nil {
		c.JSON(http.StatusOK, gin.H{
			"configured": false,
			"connected":  false,
			"message":    "Google OAuth not configured",
		})
		return
	}

	// Get user ID from context
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	uid := userID.(uint)
	token, hasToken := googleDriveTokens[uid]

	c.JSON(http.StatusOK, gin.H{
		"configured": true,
		"connected":  hasToken && token.Valid(),
		"message":    "",
	})
}

// GoogleDriveAuthURL returns OAuth authorization URL
func GoogleDriveAuthURL(c *gin.Context) {
	if googleOAuthConfig == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Google OAuth not configured"})
		return
	}

	// Get user ID for state
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	state := fmt.Sprintf("%d", userID.(uint))
	url := googleOAuthConfig.AuthCodeURL(state, oauth2.AccessTypeOffline, oauth2.ApprovalForce)

	c.JSON(http.StatusOK, gin.H{"url": url})
}

// GoogleDriveCallback handles OAuth callback
func GoogleDriveCallback(c *gin.Context) {
	if googleOAuthConfig == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Google OAuth not configured"})
		return
	}

	code := c.Query("code")
	state := c.Query("state")

	if code == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Authorization code not provided"})
		return
	}

	// Exchange code for token
	token, err := googleOAuthConfig.Exchange(context.Background(), code)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to exchange token: " + err.Error()})
		return
	}

	// Parse user ID from state
	var userID uint
	fmt.Sscanf(state, "%d", &userID)

	// Store token for this user
	googleDriveTokens[userID] = token

	// Redirect to frontend with success message
	frontendURL := os.Getenv("FRONTEND_URL")
	if frontendURL == "" {
		frontendURL = "http://localhost:5173"
	}
	c.Redirect(http.StatusTemporaryRedirect, frontendURL+"/backup?google_connected=true")
}

// GoogleDriveDisconnect disconnects Google Drive
func GoogleDriveDisconnect(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	uid := userID.(uint)
	delete(googleDriveTokens, uid)

	c.JSON(http.StatusOK, gin.H{"message": "Google Drive disconnected"})
}

// UploadToGoogleDrive uploads a backup to Google Drive
func UploadToGoogleDrive(c *gin.Context) {
	if googleOAuthConfig == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Google OAuth not configured"})
		return
	}

	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	uid := userID.(uint)
	token, hasToken := googleDriveTokens[uid]
	if !hasToken || !token.Valid() {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Google Drive not connected"})
		return
	}

	filename := c.Param("filename")
	filename = filepath.Base(filename)
	filePath := filepath.Join(backupDir, filename)

	// Check if file exists
	file, err := os.Open(filePath)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Backup file not found"})
		return
	}
	defer file.Close()

	// Create Drive service
	ctx := context.Background()
	client := googleOAuthConfig.Client(ctx, token)
	srv, err := drive.NewService(ctx, option.WithHTTPClient(client))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create Drive service"})
		return
	}

	// Get or create backup folder
	folderID, err := getOrCreateBackupFolder(srv)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create backup folder: " + err.Error()})
		return
	}

	// Upload file
	driveFile := &drive.File{
		Name:    filename,
		Parents: []string{folderID},
	}

	uploadedFile, err := srv.Files.Create(driveFile).Media(file).Do()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to upload: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":  "Backup uploaded to Google Drive",
		"drive_id": uploadedFile.Id,
		"filename": filename,
	})
}

// ListGoogleDriveBackups lists backups from Google Drive
func ListGoogleDriveBackups(c *gin.Context) {
	if googleOAuthConfig == nil {
		c.JSON(http.StatusOK, gin.H{"backups": []BackupInfo{}, "connected": false})
		return
	}

	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	uid := userID.(uint)
	token, hasToken := googleDriveTokens[uid]
	if !hasToken || !token.Valid() {
		c.JSON(http.StatusOK, gin.H{"backups": []BackupInfo{}, "connected": false})
		return
	}

	ctx := context.Background()
	client := googleOAuthConfig.Client(ctx, token)
	srv, err := drive.NewService(ctx, option.WithHTTPClient(client))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create Drive service"})
		return
	}

	// Find backup folder
	folderID, err := findBackupFolder(srv)
	if err != nil || folderID == "" {
		c.JSON(http.StatusOK, gin.H{"backups": []BackupInfo{}, "connected": true})
		return
	}

	// List files in folder
	query := fmt.Sprintf("'%s' in parents and trashed = false", folderID)
	result, err := srv.Files.List().Q(query).Fields("files(id, name, size, createdTime)").Do()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to list files"})
		return
	}

	var backups []BackupInfo
	for _, f := range result.Files {
		createdTime, _ := time.Parse(time.RFC3339, f.CreatedTime)
		backups = append(backups, BackupInfo{
			Filename:  f.Name,
			Size:      f.Size,
			SizeHuman: formatBytes(f.Size),
			CreatedAt: createdTime,
			Source:    "google_drive",
			DriveID:   f.Id,
		})
	}

	c.JSON(http.StatusOK, gin.H{"backups": backups, "connected": true})
}

// DownloadFromGoogleDrive downloads a backup from Google Drive
func DownloadFromGoogleDrive(c *gin.Context) {
	if googleOAuthConfig == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Google OAuth not configured"})
		return
	}

	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	uid := userID.(uint)
	token, hasToken := googleDriveTokens[uid]
	if !hasToken || !token.Valid() {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Google Drive not connected"})
		return
	}

	fileID := c.Param("fileId")

	ctx := context.Background()
	client := googleOAuthConfig.Client(ctx, token)
	srv, err := drive.NewService(ctx, option.WithHTTPClient(client))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create Drive service"})
		return
	}

	// Get file metadata
	file, err := srv.Files.Get(fileID).Fields("name").Do()
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "File not found"})
		return
	}

	// Download file content
	resp, err := srv.Files.Get(fileID).Download()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to download file"})
		return
	}
	defer resp.Body.Close()

	c.Header("Content-Description", "File Transfer")
	c.Header("Content-Disposition", fmt.Sprintf("attachment; filename=%s", file.Name))
	c.Header("Content-Type", "application/sql")

	io.Copy(c.Writer, resp.Body)
}

// DeleteFromGoogleDrive deletes a backup from Google Drive
func DeleteFromGoogleDrive(c *gin.Context) {
	if googleOAuthConfig == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Google OAuth not configured"})
		return
	}

	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	uid := userID.(uint)
	token, hasToken := googleDriveTokens[uid]
	if !hasToken || !token.Valid() {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Google Drive not connected"})
		return
	}

	fileID := c.Param("fileId")

	ctx := context.Background()
	client := googleOAuthConfig.Client(ctx, token)
	srv, err := drive.NewService(ctx, option.WithHTTPClient(client))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create Drive service"})
		return
	}

	err = srv.Files.Delete(fileID).Do()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete file"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Backup deleted from Google Drive"})
}

// Helper functions

func getOrCreateBackupFolder(srv *drive.Service) (string, error) {
	// Check if folder exists
	folderID, err := findBackupFolder(srv)
	if err == nil && folderID != "" {
		return folderID, nil
	}

	// Create new folder
	folder := &drive.File{
		Name:     "Pelimpahan Dana Backups",
		MimeType: "application/vnd.google-apps.folder",
	}

	createdFolder, err := srv.Files.Create(folder).Do()
	if err != nil {
		return "", err
	}

	return createdFolder.Id, nil
}

func findBackupFolder(srv *drive.Service) (string, error) {
	query := "name = 'Pelimpahan Dana Backups' and mimeType = 'application/vnd.google-apps.folder' and trashed = false"
	result, err := srv.Files.List().Q(query).Fields("files(id)").Do()
	if err != nil {
		return "", err
	}

	if len(result.Files) > 0 {
		return result.Files[0].Id, nil
	}

	return "", nil
}

func formatBytes(bytes int64) string {
	const unit = 1024
	if bytes < unit {
		return fmt.Sprintf("%d B", bytes)
	}
	div, exp := int64(unit), 0
	for n := bytes / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%.1f %cB", float64(bytes)/float64(div), "KMGTPE"[exp])
}

// SaveGoogleTokenToFile saves token to file for persistence
func SaveGoogleTokenToFile(userID uint, token *oauth2.Token) error {
	tokenDir := "./tokens"
	os.MkdirAll(tokenDir, 0700)

	filename := filepath.Join(tokenDir, fmt.Sprintf("google_token_%d.json", userID))
	data, err := json.Marshal(token)
	if err != nil {
		return err
	}

	return os.WriteFile(filename, data, 0600)
}

// LoadGoogleTokenFromFile loads token from file
func LoadGoogleTokenFromFile(userID uint) (*oauth2.Token, error) {
	filename := filepath.Join("./tokens", fmt.Sprintf("google_token_%d.json", userID))
	data, err := os.ReadFile(filename)
	if err != nil {
		return nil, err
	}

	var token oauth2.Token
	if err := json.Unmarshal(data, &token); err != nil {
		return nil, err
	}

	return &token, nil
}
