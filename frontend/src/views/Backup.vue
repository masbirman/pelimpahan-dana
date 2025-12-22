<template>
  <div class="max-w-4xl mx-auto space-y-6 animate-fadeIn">
    <div>
      <h1 class="text-2xl font-bold text-secondary-900">Backup Database</h1>
      <p class="text-secondary-500">Kelola backup database aplikasi</p>
    </div>

    <!-- Tabs -->
    <div class="border-b border-secondary-200">
      <nav class="-mb-px flex space-x-4">
        <button
          @click="activeTab = 'local'"
          :class="[
            'py-2 px-4 text-sm font-medium border-b-2 transition-colors',
            activeTab === 'local'
              ? 'border-primary-500 text-primary-600'
              : 'border-transparent text-secondary-500 hover:text-secondary-700'
          ]"
        >
          <svg class="w-5 h-5 inline mr-2 -mt-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4" />
          </svg>
          Backup Lokal
        </button>
        <button
          @click="activeTab = 'google'"
          :class="[
            'py-2 px-4 text-sm font-medium border-b-2 transition-colors',
            activeTab === 'google'
              ? 'border-primary-500 text-primary-600'
              : 'border-transparent text-secondary-500 hover:text-secondary-700'
          ]"
        >
          <svg class="w-5 h-5 inline mr-2 -mt-1" viewBox="0 0 24 24">
            <path fill="currentColor" d="M7.71 3.5a1.5 1.5 0 0 1 2.008-.658l9.03 4.9c.638.346 1.02 1.003 1.02 1.758v5c0 .755-.382 1.412-1.02 1.758l-9.03 4.9a1.5 1.5 0 0 1-2.008-.658l-.71-1.23V5.73l.71-1.23z"/>
          </svg>
          Google Drive
        </button>
      </nav>
    </div>

    <!-- Local Backup Tab -->
    <div v-if="activeTab === 'local'" class="space-y-6">
      <!-- Create Backup Card -->
      <div class="card">
        <div class="card-header flex items-center justify-between">
          <h3 class="font-semibold text-secondary-900">Buat Backup Baru</h3>
        </div>
        <div class="card-body">
          <p class="text-sm text-secondary-500 mb-4">
            Klik tombol di bawah untuk membuat backup database. File backup akan tersimpan di server dan bisa didownload.
          </p>
          <button
            @click="createBackup"
            :disabled="creatingBackup"
            class="btn-primary"
          >
            <svg v-if="creatingBackup" class="animate-spin -ml-1 mr-2 h-4 w-4 text-white inline" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            {{ creatingBackup ? 'Membuat Backup...' : 'Backup Sekarang' }}
          </button>
        </div>
      </div>

      <!-- Backup History -->
      <div class="card">
        <div class="card-header flex items-center justify-between">
          <h3 class="font-semibold text-secondary-900">Riwayat Backup Lokal</h3>
          <button @click="loadLocalBackups" class="text-primary-600 hover:text-primary-700 text-sm">
            <svg class="w-4 h-4 inline mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
            Refresh
          </button>
        </div>
        <div class="card-body">
          <div v-if="loadingLocal" class="text-center py-8">
            <svg class="animate-spin h-8 w-8 text-primary-500 mx-auto" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
            </svg>
            <p class="text-secondary-500 mt-2">Memuat data...</p>
          </div>
          <div v-else-if="localBackups.length === 0" class="text-center py-8 text-secondary-500">
            <svg class="w-12 h-12 mx-auto text-secondary-300 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4" />
            </svg>
            Belum ada backup. Klik "Backup Sekarang" untuk membuat backup pertama.
          </div>
          <table v-else class="w-full">
            <thead>
              <tr class="border-b border-secondary-200">
                <th class="text-left py-2 text-sm font-medium text-secondary-600">Nama File</th>
                <th class="text-left py-2 text-sm font-medium text-secondary-600">Ukuran</th>
                <th class="text-left py-2 text-sm font-medium text-secondary-600">Tanggal</th>
                <th class="text-right py-2 text-sm font-medium text-secondary-600">Aksi</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="backup in localBackups" :key="backup.filename" class="border-b border-secondary-100">
                <td class="py-3 text-sm text-secondary-900">{{ backup.filename }}</td>
                <td class="py-3 text-sm text-secondary-600">{{ backup.size_human }}</td>
                <td class="py-3 text-sm text-secondary-600">{{ formatDate(backup.created_at) }}</td>
                <td class="py-3 text-right">
                  <button
                    @click="downloadBackup(backup.filename)"
                    class="text-primary-600 hover:text-primary-700 text-sm mr-3"
                  >
                    <svg class="w-4 h-4 inline mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                    </svg>
                    Download
                  </button>
                  <button
                    @click="uploadToGoogleDrive(backup.filename)"
                    :disabled="!googleConnected"
                    class="text-green-600 hover:text-green-700 text-sm mr-3 disabled:opacity-50 disabled:cursor-not-allowed"
                    :title="googleConnected ? 'Upload ke Google Drive' : 'Hubungkan Google Drive dulu'"
                  >
                    <svg class="w-4 h-4 inline mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                    </svg>
                    Upload
                  </button>
                  <button
                    @click="confirmDelete(backup.filename, 'local')"
                    class="text-red-600 hover:text-red-700 text-sm"
                  >
                    <svg class="w-4 h-4 inline mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                    Hapus
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Google Drive Tab -->
    <div v-if="activeTab === 'google'" class="space-y-6">
      <!-- Connection Status -->
      <div class="card">
        <div class="card-header">
          <h3 class="font-semibold text-secondary-900">Koneksi Google Drive</h3>
        </div>
        <div class="card-body">
          <div v-if="loadingGoogleStatus" class="flex items-center gap-2 text-secondary-500">
            <svg class="animate-spin h-5 w-5" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
            </svg>
            Memeriksa koneksi...
          </div>
          <div v-else-if="!googleConfigured" class="text-yellow-600 bg-yellow-50 p-4 rounded-lg">
            <svg class="w-5 h-5 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
            Google OAuth belum dikonfigurasi di server. Tambahkan GOOGLE_CLIENT_ID dan GOOGLE_CLIENT_SECRET di environment variables.
          </div>
          <div v-else-if="googleConnected" class="flex items-center justify-between">
            <div class="flex items-center gap-2 text-green-600">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              Terhubung ke Google Drive
            </div>
            <button @click="disconnectGoogle" class="btn-secondary text-sm">
              Putuskan Koneksi
            </button>
          </div>
          <div v-else class="flex items-center justify-between">
            <div class="text-secondary-600">
              <svg class="w-5 h-5 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1" />
              </svg>
              Belum terhubung ke Google Drive
            </div>
            <button @click="connectGoogle" class="btn-primary">
              Hubungkan Google Drive
            </button>
          </div>
        </div>
      </div>

      <!-- Google Drive Backups -->
      <div v-if="googleConnected" class="card">
        <div class="card-header flex items-center justify-between">
          <h3 class="font-semibold text-secondary-900">Backup di Google Drive</h3>
          <button @click="loadGoogleBackups" class="text-primary-600 hover:text-primary-700 text-sm">
            <svg class="w-4 h-4 inline mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
            Refresh
          </button>
        </div>
        <div class="card-body">
          <div v-if="loadingGoogle" class="text-center py-8">
            <svg class="animate-spin h-8 w-8 text-primary-500 mx-auto" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
            </svg>
            <p class="text-secondary-500 mt-2">Memuat data...</p>
          </div>
          <div v-else-if="googleBackups.length === 0" class="text-center py-8 text-secondary-500">
            <svg class="w-12 h-12 mx-auto text-secondary-300 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
            </svg>
            Belum ada backup di Google Drive. Upload backup dari tab "Backup Lokal".
          </div>
          <table v-else class="w-full">
            <thead>
              <tr class="border-b border-secondary-200">
                <th class="text-left py-2 text-sm font-medium text-secondary-600">Nama File</th>
                <th class="text-left py-2 text-sm font-medium text-secondary-600">Ukuran</th>
                <th class="text-left py-2 text-sm font-medium text-secondary-600">Tanggal</th>
                <th class="text-right py-2 text-sm font-medium text-secondary-600">Aksi</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="backup in googleBackups" :key="backup.drive_id" class="border-b border-secondary-100">
                <td class="py-3 text-sm text-secondary-900">{{ backup.filename }}</td>
                <td class="py-3 text-sm text-secondary-600">{{ backup.size_human }}</td>
                <td class="py-3 text-sm text-secondary-600">{{ formatDate(backup.created_at) }}</td>
                <td class="py-3 text-right">
                  <button
                    @click="downloadFromGoogle(backup.drive_id, backup.filename)"
                    class="text-primary-600 hover:text-primary-700 text-sm mr-3"
                  >
                    <svg class="w-4 h-4 inline mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                    </svg>
                    Download
                  </button>
                  <button
                    @click="confirmDelete(backup.drive_id, 'google', backup.filename)"
                    class="text-red-600 hover:text-red-700 text-sm"
                  >
                    <svg class="w-4 h-4 inline mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                    Hapus
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="showDeleteModal" class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div class="bg-white rounded-xl p-6 max-w-md w-full mx-4 animate-fadeIn">
        <h3 class="text-lg font-semibold text-secondary-900 mb-2">Konfirmasi Hapus</h3>
        <p class="text-secondary-600 mb-4">
          Apakah Anda yakin ingin menghapus backup <strong>{{ deleteTarget?.name }}</strong>?
          Tindakan ini tidak dapat dibatalkan.
        </p>
        <div class="flex justify-end gap-3">
          <button @click="showDeleteModal = false" class="btn-secondary">Batal</button>
          <button @click="executeDelete" :disabled="deleting" class="btn-primary bg-red-600 hover:bg-red-700">
            {{ deleting ? 'Menghapus...' : 'Hapus' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Toast Notification -->
    <div
      v-if="toast.show"
      :class="[
        'fixed bottom-4 right-4 px-6 py-3 rounded-lg shadow-lg text-white z-50 animate-fadeIn',
        toast.type === 'success' ? 'bg-green-600' : 'bg-red-600'
      ]"
    >
      {{ toast.message }}
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'

const activeTab = ref('local')

// Local backups
const localBackups = ref([])
const loadingLocal = ref(false)
const creatingBackup = ref(false)

// Google Drive
const googleConfigured = ref(false)
const googleConnected = ref(false)
const googleBackups = ref([])
const loadingGoogle = ref(false)
const loadingGoogleStatus = ref(false)

// Delete modal
const showDeleteModal = ref(false)
const deleteTarget = ref(null)
const deleting = ref(false)

// Toast
const toast = ref({ show: false, message: '', type: 'success' })

const apiBaseUrl = import.meta.env.VITE_API_URL || 'http://localhost:8000/api'

onMounted(async () => {
  // Check for Google connected callback
  const urlParams = new URLSearchParams(window.location.search)
  if (urlParams.get('google_connected') === 'true') {
    showToast('Google Drive berhasil terhubung!', 'success')
    window.history.replaceState({}, '', '/backup')
  }

  await Promise.all([
    loadLocalBackups(),
    checkGoogleStatus()
  ])
})

async function loadLocalBackups() {
  loadingLocal.value = true
  try {
    const response = await api.get('/backup/history')
    localBackups.value = response.data.backups || []
  } catch (error) {
    console.error('Failed to load backups:', error)
    showToast('Gagal memuat daftar backup', 'error')
  } finally {
    loadingLocal.value = false
  }
}

async function createBackup() {
  creatingBackup.value = true
  try {
    const response = await api.post('/backup/create')
    showToast('Backup berhasil dibuat!', 'success')
    await loadLocalBackups()
  } catch (error) {
    console.error('Failed to create backup:', error)
    showToast(error.response?.data?.error || 'Gagal membuat backup', 'error')
  } finally {
    creatingBackup.value = false
  }
}

async function downloadBackup(filename) {
  try {
    const response = await api.get(`/backup/download/${filename}`, {
      responseType: 'blob'
    })
    const url = window.URL.createObjectURL(new Blob([response.data]))
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', filename)
    document.body.appendChild(link)
    link.click()
    link.remove()
    window.URL.revokeObjectURL(url)
  } catch (error) {
    console.error('Failed to download backup:', error)
    showToast('Gagal mengunduh backup', 'error')
  }
}

// Google Drive functions
async function checkGoogleStatus() {
  loadingGoogleStatus.value = true
  try {
    const response = await api.get('/backup/google/status')
    googleConfigured.value = response.data.configured
    googleConnected.value = response.data.connected
    if (googleConnected.value) {
      await loadGoogleBackups()
    }
  } catch (error) {
    console.error('Failed to check Google status:', error)
  } finally {
    loadingGoogleStatus.value = false
  }
}

async function connectGoogle() {
  try {
    const response = await api.get('/backup/google/auth-url')
    window.location.href = response.data.url
  } catch (error) {
    console.error('Failed to get auth URL:', error)
    showToast('Gagal menghubungkan ke Google Drive', 'error')
  }
}

async function disconnectGoogle() {
  try {
    await api.post('/backup/google/disconnect')
    googleConnected.value = false
    googleBackups.value = []
    showToast('Google Drive berhasil diputuskan', 'success')
  } catch (error) {
    console.error('Failed to disconnect:', error)
    showToast('Gagal memutuskan koneksi', 'error')
  }
}

async function loadGoogleBackups() {
  loadingGoogle.value = true
  try {
    const response = await api.get('/backup/google/list')
    googleBackups.value = response.data.backups || []
  } catch (error) {
    console.error('Failed to load Google backups:', error)
  } finally {
    loadingGoogle.value = false
  }
}

async function uploadToGoogleDrive(filename) {
  try {
    showToast('Mengupload ke Google Drive...', 'success')
    await api.post(`/backup/google/upload/${filename}`)
    showToast('Backup berhasil diupload ke Google Drive!', 'success')
    await loadGoogleBackups()
  } catch (error) {
    console.error('Failed to upload:', error)
    showToast(error.response?.data?.error || 'Gagal upload ke Google Drive', 'error')
  }
}

async function downloadFromGoogle(fileId, filename) {
  try {
    const response = await api.get(`/backup/google/download/${fileId}`, {
      responseType: 'blob'
    })
    const url = window.URL.createObjectURL(new Blob([response.data]))
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', filename)
    document.body.appendChild(link)
    link.click()
    link.remove()
    window.URL.revokeObjectURL(url)
  } catch (error) {
    console.error('Failed to download from Google:', error)
    showToast('Gagal mengunduh dari Google Drive', 'error')
  }
}

function confirmDelete(id, source, name = null) {
  deleteTarget.value = {
    id,
    source,
    name: name || id
  }
  showDeleteModal.value = true
}

async function executeDelete() {
  if (!deleteTarget.value) return

  deleting.value = true
  try {
    if (deleteTarget.value.source === 'local') {
      await api.delete(`/backup/${deleteTarget.value.id}`)
      await loadLocalBackups()
    } else {
      await api.delete(`/backup/google/${deleteTarget.value.id}`)
      await loadGoogleBackups()
    }
    showToast('Backup berhasil dihapus', 'success')
  } catch (error) {
    console.error('Failed to delete:', error)
    showToast('Gagal menghapus backup', 'error')
  } finally {
    deleting.value = false
    showDeleteModal.value = false
    deleteTarget.value = null
  }
}

function formatDate(dateStr) {
  if (!dateStr) return '-'
  const date = new Date(dateStr)
  return date.toLocaleString('id-ID', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

function showToast(message, type = 'success') {
  toast.value = { show: true, message, type }
  setTimeout(() => {
    toast.value.show = false
  }, 3000)
}
</script>
