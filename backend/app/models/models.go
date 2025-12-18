package models

import (
	"time"
)

type User struct {
	ID        uint      `gorm:"primarykey" json:"id"`
	Name      string    `gorm:"type:varchar(255);not null" json:"name"`
	Email     string    `gorm:"type:varchar(255);unique;not null" json:"email"`
	Password  string    `gorm:"type:varchar(255);not null" json:"-"`
	Role      string    `gorm:"type:varchar(50);not null;default:'operator'" json:"role"`
	Avatar    string    `gorm:"type:varchar(255)" json:"avatar"`
	IsActive  bool      `gorm:"default:true" json:"is_active"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type Unit struct {
	ID            uint      `gorm:"primarykey" json:"id"`
	KodeUnit      string    `gorm:"type:varchar(50);unique;not null" json:"kode_unit"`
	NamaUnit      string    `gorm:"type:varchar(255);not null" json:"nama_unit"`
	NamaPimpinan  string    `gorm:"type:varchar(255)" json:"nama_pimpinan"`
	NamaBendahara string    `gorm:"type:varchar(255);not null" json:"nama_bendahara"`
	NomorRekening string    `gorm:"type:varchar(50);not null" json:"nomor_rekening"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type JenisPelimpahan struct {
	ID        uint      `gorm:"primarykey" json:"id"`
	KodeJenis string    `gorm:"type:varchar(50);unique;not null" json:"kode_jenis"`
	NamaJenis string    `gorm:"type:varchar(255);not null" json:"nama_jenis"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type Pelimpahan struct {
	ID                uint               `gorm:"primarykey" json:"id"`
	NomorPelimpahan   int                `gorm:"not null" json:"nomor_pelimpahan"`
	WaktuPelimpahan   time.Time          `gorm:"not null" json:"waktu_pelimpahan"`
	TanggalPelimpahan time.Time          `gorm:"type:date;not null" json:"tanggal_pelimpahan"`
	UraianPelimpahan  string             `gorm:"type:text" json:"uraian_pelimpahan"`
	JenisPelimpahanID uint               `gorm:"not null" json:"jenis_pelimpahan_id"`
	JenisPelimpahan   JenisPelimpahan    `gorm:"foreignKey:JenisPelimpahanID" json:"jenis_pelimpahan"`
	CreatedBy         uint               `gorm:"not null" json:"created_by"`
	Creator           User               `gorm:"foreignKey:CreatedBy" json:"creator"`
	TotalJumlah       float64            `gorm:"type:decimal(15,2);default:0" json:"total_jumlah"`
	Details           []PelimpahanDetail `gorm:"foreignKey:PelimpahanID" json:"details"`
	CreatedAt         time.Time          `json:"created_at"`
	UpdatedAt         time.Time          `json:"updated_at"`
}

type PelimpahanDetail struct {
	ID            uint      `gorm:"primarykey" json:"id"`
	PelimpahanID  uint      `gorm:"not null" json:"pelimpahan_id"`
	UnitID        uint      `gorm:"not null" json:"unit_id"`
	Unit          Unit      `gorm:"foreignKey:UnitID" json:"unit"`
	NamaPenerima  string    `gorm:"type:varchar(255);not null" json:"nama_penerima"`
	NomorRekening string    `gorm:"type:varchar(50);not null" json:"nomor_rekening"`
	Jumlah        float64   `gorm:"type:decimal(15,2);not null" json:"jumlah"`
	SumberDana    string    `gorm:"type:varchar(10);not null;default:bank" json:"sumber_dana"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type Setting struct {
	ID        uint      `gorm:"primarykey" json:"id"`
	Key       string    `gorm:"type:varchar(100);unique;not null" json:"key"`
	Value     string    `gorm:"type:text" json:"value"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type SaldoBendahara struct {
	ID         uint      `gorm:"primarykey" json:"id"`
	Tanggal    time.Time `gorm:"type:date;not null" json:"tanggal"`
	SaldoBank  float64   `gorm:"type:decimal(15,2);not null;default:0" json:"saldo_bank"`
	SaldoTunai float64   `gorm:"type:decimal(15,2);not null;default:0" json:"saldo_tunai"`
	Keterangan string    `gorm:"type:text" json:"keterangan"`
	CreatedBy  uint      `json:"created_by"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`

	// Relations
	Creator User `gorm:"foreignKey:CreatedBy" json:"creator,omitempty"`
}

type TopUpSaldo struct {
	ID         uint      `gorm:"primarykey" json:"id"`
	Tanggal    time.Time `gorm:"type:date;not null" json:"tanggal"`
	Jumlah     float64   `gorm:"type:decimal(15,2);not null" json:"jumlah"`
	Keterangan string    `gorm:"type:text;not null" json:"keterangan"`
	CreatedBy  uint      `gorm:"not null" json:"created_by"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`

	// Relations
	Creator User `gorm:"foreignKey:CreatedBy" json:"creator,omitempty"`
}

type PenarikanTunai struct {
	ID         uint      `gorm:"primarykey" json:"id"`
	Tanggal    time.Time `gorm:"type:date;not null" json:"tanggal"`
	Jumlah     float64   `gorm:"type:decimal(15,2);not null" json:"jumlah"`
	Keterangan string    `gorm:"type:text;not null" json:"keterangan"`
	CreatedBy  uint      `gorm:"not null" json:"created_by"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`

	// Relations
	Creator User `gorm:"foreignKey:CreatedBy" json:"creator,omitempty"`
}
