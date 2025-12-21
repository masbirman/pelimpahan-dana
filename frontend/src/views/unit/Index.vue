<template>
  <div class="space-y-6 animate-fadeIn">
    <!-- Header -->
    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
      <div>
        <h1 class="text-2xl font-bold text-secondary-900">Unit Kerja</h1>
        <p class="text-secondary-500 text-sm md:text-base">Kelola data unit kerja</p>
      </div>
      <div class="grid grid-cols-2 md:flex gap-2">
        <button @click="downloadTemplate" class="btn-secondary text-xs md:text-sm justify-center">
          <svg class="w-4 h-4 md:w-5 md:h-5 mr-1 md:mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
          </svg>
          Template
        </button>
        <button @click="openImportModal" class="btn-secondary text-xs md:text-sm justify-center">
          <svg class="w-4 h-4 md:w-5 md:h-5 mr-1 md:mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12" />
          </svg>
          Import
        </button>
        <button @click="exportData" class="btn-secondary text-xs md:text-sm justify-center">
          <svg class="w-4 h-4 md:w-5 md:h-5 mr-1 md:mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
          Export
        </button>
        <router-link to="/units/create" class="btn-primary text-xs md:text-sm justify-center">
          <svg class="w-4 h-4 md:w-5 md:h-5 mr-1 md:mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
          </svg>
          Tambah
        </router-link>
      </div>
    </div>

    <!-- Search & Bulk Actions -->
    <div class="card">
      <div class="card-body p-3 md:p-4">
        <div class="flex flex-col md:flex-row items-stretch md:items-center gap-3">
          <div class="flex-1">
            <div class="relative">
              <input 
                v-model="search" 
                type="text" 
                class="input pl-9 text-sm" 
                placeholder="Cari unit kerja..." 
                @input="debouncedSearch" 
              />
              <svg class="w-4 h-4 text-secondary-400 absolute left-3 top-1/2 -translate-y-1/2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </div>
          </div>
          <!-- Bulk Action Bar -->
          <div v-if="selectedIds.length > 0" class="flex items-center justify-between gap-3 px-3 py-2 bg-primary-50 rounded-lg border border-primary-200">
            <span class="text-xs md:text-sm text-primary-700 font-medium">{{ selectedIds.length }} dipilih</span>
            <div class="flex gap-2">
              <button @click="confirmBulkDelete" class="text-red-600 hover:text-red-800 text-xs md:text-sm font-medium flex items-center gap-1 bg-white px-2 py-1 rounded shadow-sm border border-red-100">
                <svg class="w-3 h-3 md:w-4 md:h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
                Hapus
              </button>
              <button @click="selectedIds = []" class="text-secondary-500 hover:text-secondary-700 text-xs md:text-sm px-2 py-1">Batal</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Mobile Card View -->
    <div class="md:hidden space-y-3">
      <div v-if="loading" class="text-center py-8 text-secondary-500 text-sm">Memuat data...</div>
      <div v-else-if="!units.length" class="text-center py-8 space-y-4">
        <p class="text-secondary-500 text-sm">Tidak ada data unit kerja untuk tahun ini</p>
        <button @click="cloneFromPreviousYear" :disabled="cloningUnits" class="btn-primary text-sm">
          <svg v-if="cloningUnits" class="animate-spin w-4 h-4 mr-2" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
          </svg>
          {{ cloningUnits ? 'Menyalin...' : 'Salin Data dari Tahun Sebelumnya' }}
        </button>
      </div>
      <div v-else v-for="unit in units" :key="unit.id" class="card p-3 shadow-sm border border-secondary-100 relative">
        <!-- Checkbox Absolute -->
        <div class="absolute top-3 left-3">
          <input type="checkbox" :checked="selectedIds.includes(unit.id)" @change="toggleSelect(unit.id)" class="rounded border-secondary-300 text-primary-600 focus:ring-primary-500 w-4 h-4" />
        </div>
        
        <div class="pl-7">
          <div class="flex justify-between items-start mb-2">
            <div>
              <span class="badge-primary text-[10px] px-1.5 py-0.5 mb-1 inline-block">{{ unit.kode_unit }}</span>
              <h3 class="text-sm font-semibold text-secondary-900 leading-tight">{{ unit.nama_unit }}</h3>
            </div>
          </div>
          
          <div class="space-y-1.5 mb-3">
            <div class="flex items-start gap-2">
              <svg class="w-3.5 h-3.5 text-secondary-400 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>
              <div>
                <p class="text-[10px] text-secondary-500">Pimpinan</p>
                <p class="text-xs text-secondary-700 font-medium">{{ unit.nama_pimpinan || '-' }}</p>
              </div>
            </div>
            <div class="flex items-start gap-2">
              <svg class="w-3.5 h-3.5 text-secondary-400 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" /></svg>
              <div>
                <p class="text-[10px] text-secondary-500">Bendahara</p>
                <p class="text-xs text-secondary-700 font-medium">{{ unit.nama_bendahara }}</p>
              </div>
            </div>
             <div class="flex items-start gap-2">
              <svg class="w-3.5 h-3.5 text-secondary-400 mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" /></svg>
              <div>
                <p class="text-[10px] text-secondary-500">No. Rekening</p>
                <p class="text-xs text-secondary-700 font-mono">{{ unit.nomor_rekening }}</p>
              </div>
            </div>
          </div>

          <div class="flex justify-end gap-2 pt-2 border-t border-secondary-50">
             <router-link :to="`/units/${unit.id}/edit`" class="p-1.5 text-primary-600 hover:bg-primary-50 rounded-md bg-primary-50/30 text-xs flex items-center gap-1">
              <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" /></svg>
              Edit
            </router-link>
            <button @click="confirmDelete(unit)" class="p-1.5 text-red-600 hover:bg-red-50 rounded-md bg-red-50/30 text-xs flex items-center gap-1">
              <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
              Hapus
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Desktop Table View -->
    <div class="card hidden md:block">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-secondary-50">
            <tr>
              <th class="px-4 py-3 w-10">
                <input type="checkbox" :checked="isAllSelected" @change="toggleSelectAll" class="rounded border-secondary-300 text-primary-600 focus:ring-primary-500" />
              </th>
              <th class="px-4 py-3 table-header text-xs cursor-pointer hover:bg-secondary-100" @click="setSort('kode_unit')">
                <div class="flex items-center gap-1">
                  Kode
                  <span v-if="sortBy === 'kode_unit'" class="text-primary-600">{{ sortOrder === 'asc' ? '↑' : '↓' }}</span>
                </div>
              </th>
              <th class="px-4 py-3 table-header text-xs cursor-pointer hover:bg-secondary-100" @click="setSort('nama_unit')">
                <div class="flex items-center gap-1">
                  Nama Unit
                  <span v-if="sortBy === 'nama_unit'" class="text-primary-600">{{ sortOrder === 'asc' ? '↑' : '↓' }}</span>
                </div>
              </th>
              <th class="px-4 py-3 table-header text-xs">Pimpinan</th>
              <th class="px-4 py-3 table-header text-xs cursor-pointer hover:bg-secondary-100" @click="setSort('nama_bendahara')">
                <div class="flex items-center gap-1">
                  Bendahara
                  <span v-if="sortBy === 'nama_bendahara'" class="text-primary-600">{{ sortOrder === 'asc' ? '↑' : '↓' }}</span>
                </div>
              </th>
              <th class="px-4 py-3 table-header text-xs">No. Rekening</th>
              <th class="px-4 py-3 table-header text-xs text-right">Aksi</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-secondary-200">
            <tr v-for="unit in units" :key="unit.id" class="hover:bg-secondary-50 transition-colors" :class="{ 'bg-primary-50': selectedIds.includes(unit.id) }">
              <td class="px-4 py-3">
                <input type="checkbox" :checked="selectedIds.includes(unit.id)" @change="toggleSelect(unit.id)" class="rounded border-secondary-300 text-primary-600 focus:ring-primary-500" />
              </td>
              <td class="px-4 py-3 text-sm font-medium text-secondary-900">{{ unit.kode_unit }}</td>
              <td class="px-4 py-3 text-sm text-secondary-700">{{ unit.nama_unit }}</td>
              <td class="px-4 py-3 text-sm text-secondary-700">{{ unit.nama_pimpinan || '-' }}</td>
              <td class="px-4 py-3 text-sm text-secondary-700">{{ unit.nama_bendahara }}</td>
              <td class="px-4 py-3 text-sm text-secondary-700 font-mono">{{ unit.nomor_rekening }}</td>
              <td class="px-4 py-3 text-right">
                <div class="flex items-center justify-end gap-1">
                  <router-link :to="`/units/${unit.id}/edit`" class="p-1 text-primary-600 hover:bg-primary-50 rounded" title="Edit">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                    </svg>
                  </router-link>
                  <button @click="confirmDelete(unit)" class="p-1 text-red-600 hover:bg-red-50 rounded" title="Hapus">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                </div>
              </td>
            </tr>
            <tr v-if="!units.length && !loading">
              <td colspan="7" class="px-4 py-8 text-center">
                <p class="text-secondary-500 mb-4">Tidak ada data unit kerja untuk tahun ini</p>
                <button @click="cloneFromPreviousYear" :disabled="cloningUnits" class="btn-primary text-sm">
                  {{ cloningUnits ? 'Menyalin...' : 'Salin Data dari Tahun Sebelumnya' }}
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination - Desktop -->
      <div class="px-4 py-3 border-t border-secondary-200 flex items-center justify-between">
        <p class="text-xs text-secondary-500">
          {{ meta.total === 0 ? 0 : (meta.page - 1) * meta.per_page + 1 }} - {{ Math.min(meta.page * meta.per_page, meta.total) }} dari {{ meta.total }}
        </p>
        <div class="flex items-center gap-2">
          <select v-model="meta.per_page" @change="changePerPage" class="input py-1 px-2 text-xs w-16">
            <option :value="10">10</option>
            <option :value="25">25</option>
            <option :value="50">50</option>
            <option :value="100">100</option>
          </select>
          <div class="flex gap-1">
            <button @click="changePage(1)" :disabled="meta.page === 1" class="px-2 py-1 text-xs rounded border hover:bg-secondary-50 disabled:opacity-50">«</button>
            <button @click="changePage(meta.page - 1)" :disabled="meta.page === 1" class="px-2 py-1 text-xs rounded border hover:bg-secondary-50 disabled:opacity-50">‹</button>
            <span class="px-2 py-1 text-xs bg-primary-600 text-white rounded">{{ meta.page }}</span>
            <button @click="changePage(meta.page + 1)" :disabled="meta.page >= meta.last_page" class="px-2 py-1 text-xs rounded border hover:bg-secondary-50 disabled:opacity-50">›</button>
            <button @click="changePage(meta.last_page)" :disabled="meta.page >= meta.last_page" class="px-2 py-1 text-xs rounded border hover:bg-secondary-50 disabled:opacity-50">»</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Delete Modal -->
    <div v-if="showDeleteModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-black/50" @click="showDeleteModal = false"></div>
      <div class="relative bg-white rounded-xl shadow-xl max-w-md w-full p-6 animate-fadeIn">
        <h3 class="text-lg font-semibold text-secondary-900 mb-2">Hapus Unit</h3>
        <p class="text-secondary-600 mb-6">
          Apakah Anda yakin ingin menghapus unit <strong>{{ selectedUnit?.nama_unit }}</strong>?
        </p>
        <div class="flex justify-end gap-3">
          <button @click="showDeleteModal = false" class="btn-secondary">Batal</button>
          <button @click="deleteUnit" class="btn-danger">Hapus</button>
        </div>
      </div>
    </div>

    <!-- Bulk Delete Modal -->
    <div v-if="showBulkDeleteModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-black/50" @click="showBulkDeleteModal = false"></div>
      <div class="relative bg-white rounded-xl shadow-xl max-w-md w-full p-6 animate-fadeIn">
        <h3 class="text-lg font-semibold text-secondary-900 mb-2">Hapus {{ selectedIds.length }} Unit</h3>
        <p class="text-secondary-600 mb-6">
          Apakah Anda yakin ingin menghapus <strong>{{ selectedIds.length }}</strong> unit yang dipilih? Tindakan ini tidak dapat dibatalkan.
        </p>
        <div class="flex justify-end gap-3">
          <button @click="showBulkDeleteModal = false" class="btn-secondary">Batal</button>
          <button @click="bulkDelete" class="btn-danger">Hapus Semua</button>
        </div>
      </div>
    </div>

    <!-- Import Modal -->
    <div v-if="showImportModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-black/50" @click="showImportModal = false"></div>
      <div class="relative bg-white rounded-xl shadow-xl max-w-lg w-full p-6 animate-fadeIn">
        <h3 class="text-lg font-semibold text-secondary-900 mb-4">Import Unit Kerja</h3>
        <div class="space-y-4">
          <div class="p-4 bg-blue-50 rounded-lg">
            <p class="text-sm text-blue-700"><strong>Petunjuk:</strong> Download template terlebih dahulu, isi data sesuai format, lalu upload file Excel.</p>
          </div>
          <div class="border-2 border-dashed border-secondary-300 rounded-lg p-6 text-center">
            <input ref="fileInput" type="file" accept=".xlsx,.xls" class="hidden" @change="handleFileSelect" />
            <div v-if="!importFile">
              <svg class="w-12 h-12 mx-auto text-secondary-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
              </svg>
              <button @click="$refs.fileInput.click()" class="btn-secondary">Pilih File Excel</button>
              <p class="text-sm text-secondary-500 mt-2">Format: .xlsx atau .xls</p>
            </div>
            <div v-else class="flex items-center justify-between">
              <div class="flex items-center gap-3">
                <svg class="w-10 h-10 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                <span class="text-sm font-medium">{{ importFile.name }}</span>
              </div>
              <button @click="importFile = null" class="text-red-500 hover:text-red-700">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
          </div>
          <div v-if="importResult" class="p-4 rounded-lg" :class="importResult.success ? 'bg-emerald-50' : 'bg-red-50'">
            <p class="text-sm" :class="importResult.success ? 'text-emerald-700' : 'text-red-700'">
              {{ importResult.message }}
              <span v-if="importResult.data">({{ importResult.data.imported }} berhasil, {{ importResult.data.skipped }} dilewati)</span>
            </p>
          </div>
        </div>
        <div class="flex justify-end gap-3 mt-6">
          <button @click="showImportModal = false" class="btn-secondary">Tutup</button>
          <button @click="importData" :disabled="!importFile || importing" class="btn-primary">{{ importing ? 'Mengimport...' : 'Import' }}</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'
import { useNotificationStore } from '@/stores/notification'
import { useDebounceFn } from '@vueuse/core'

const notificationStore = useNotificationStore()

const units = ref([])
const loading = ref(false)
const search = ref('')
const meta = ref({ page: 1, per_page: 10, total: 0, last_page: 1 })
const showDeleteModal = ref(false)
const showBulkDeleteModal = ref(false)
const selectedUnit = ref(null)
const selectedIds = ref([])

// Sorting
const sortBy = ref('created_at')
const sortOrder = ref('desc')

// Import related
const showImportModal = ref(false)
const importFile = ref(null)
const importing = ref(false)
const importResult = ref(null)
const cloningUnits = ref(false)

const isAllSelected = computed(() => units.value.length > 0 && selectedIds.value.length === units.value.length)

onMounted(() => { loadUnits() })

async function loadUnits() {
  loading.value = true
  try {
    const response = await api.get('/units', { 
      params: { 
        page: meta.value.page, 
        per_page: meta.value.per_page, 
        search: search.value,
        sort_by: sortBy.value,
        sort_order: sortOrder.value
      } 
    })
    if (response.data.success) {
      units.value = response.data.data || []
      meta.value = response.data.meta || { page: 1, per_page: 10, total: 0, last_page: 1 }
      selectedIds.value = []
    }
  } catch (error) {
    notificationStore.error('Gagal memuat data unit')
  } finally {
    loading.value = false
  }
}

function setSort(field) {
  if (sortBy.value === field) {
    sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortBy.value = field
    sortOrder.value = 'asc'
  }
  loadUnits()
}

const debouncedSearch = useDebounceFn(() => { meta.value.page = 1; loadUnits() }, 300)

function changePage(page) { meta.value.page = page; loadUnits() }
function changePerPage() { meta.value.page = 1; loadUnits() }

function toggleSelect(id) {
  const index = selectedIds.value.indexOf(id)
  if (index === -1) selectedIds.value.push(id)
  else selectedIds.value.splice(index, 1)
}

function toggleSelectAll() {
  if (isAllSelected.value) selectedIds.value = []
  else selectedIds.value = units.value.map(u => u.id)
}

function confirmDelete(unit) { selectedUnit.value = unit; showDeleteModal.value = true }
function confirmBulkDelete() { showBulkDeleteModal.value = true }

async function deleteUnit() {
  try {
    await api.delete(`/units/${selectedUnit.value.id}`)
    notificationStore.success('Unit berhasil dihapus')
    showDeleteModal.value = false
    loadUnits()
  } catch (error) {
    notificationStore.error('Gagal menghapus unit')
  }
}

async function bulkDelete() {
  try {
    await api.post('/units/bulk-delete', { ids: selectedIds.value })
    notificationStore.success(`${selectedIds.value.length} unit berhasil dihapus`)
    showBulkDeleteModal.value = false
    selectedIds.value = []
    loadUnits()
  } catch (error) {
    notificationStore.error('Gagal menghapus unit')
  }
}

// Excel functions
async function downloadTemplate() {
  try {
    const response = await api.get('/units/template', { responseType: 'blob' })
    const url = window.URL.createObjectURL(new Blob([response.data]))
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', 'template_unit_kerja.xlsx')
    document.body.appendChild(link)
    link.click()
    link.remove()
    window.URL.revokeObjectURL(url)
    notificationStore.success('Template berhasil didownload')
  } catch (error) {
    notificationStore.error('Gagal mendownload template')
  }
}

async function exportData() {
  try {
    const response = await api.get('/units/export', { responseType: 'blob' })
    const url = window.URL.createObjectURL(new Blob([response.data]))
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', 'data_unit_kerja.xlsx')
    document.body.appendChild(link)
    link.click()
    link.remove()
    window.URL.revokeObjectURL(url)
    notificationStore.success('Data berhasil diexport')
  } catch (error) {
    notificationStore.error('Gagal mengexport data')
  }
}

function openImportModal() { importFile.value = null; importResult.value = null; showImportModal.value = true }
function handleFileSelect(event) { if (event.target.files[0]) importFile.value = event.target.files[0] }

async function importData() {
  if (!importFile.value) return
  importing.value = true
  importResult.value = null
  try {
    const formData = new FormData()
    formData.append('file', importFile.value)
    const response = await api.post('/units/import', formData, { headers: { 'Content-Type': 'multipart/form-data' } })
    importResult.value = response.data
    if (response.data.success) {
      notificationStore.success(`Import berhasil: ${response.data.data.imported} data`)
      loadUnits()
    }
  } catch (error) {
    importResult.value = { success: false, message: error.response?.data?.message || 'Gagal mengimport data' }
    notificationStore.error('Gagal mengimport data')
  } finally {
    importing.value = false
  }
}

async function cloneFromPreviousYear() {
  cloningUnits.value = true
  try {
    const response = await api.post('/units/clone-from-previous-year')
    if (response.data.success) {
      notificationStore.success(response.data.message)
      loadUnits()
    } else {
      notificationStore.error(response.data.message)
    }
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal menyalin data unit')
  } finally {
    cloningUnits.value = false
  }
}
</script>
