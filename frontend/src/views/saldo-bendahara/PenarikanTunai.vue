<template>
  <div class="space-y-6 animate-fadeIn">
    <!-- Header -->
    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
      <div>
        <h1 class="text-2xl font-bold text-secondary-900">Penarikan Tunai</h1>
        <p class="text-secondary-500 text-sm md:text-base">Transfer saldo dari Bank ke Tunai</p>
      </div>
      <button @click="openForm" class="btn-primary w-full md:w-auto justify-center">
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
        </svg>
        Tarik Tunai
      </button>
    </div>

    <!-- Saldo Info -->
    <div class="card bg-gradient-to-r from-blue-50 to-emerald-50">
      <div class="card-body">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div class="p-2 md:p-0 bg-white/50 md:bg-transparent rounded-lg">
            <p class="text-sm text-secondary-600 font-medium">Saldo Bank Tersedia</p>
            <p class="text-xl md:text-2xl font-bold text-blue-700 truncate" :title="formatCurrency(saldoBank)">{{ formatCurrency(saldoBank) }}</p>
          </div>
          <div class="p-2 md:p-0 bg-white/50 md:bg-transparent rounded-lg">
            <p class="text-sm text-secondary-600 font-medium">Saldo Tunai</p>
            <p class="text-xl md:text-2xl font-bold text-emerald-700 truncate" :title="formatCurrency(saldoTunai)">{{ formatCurrency(saldoTunai) }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Search & Filter -->
    <div class="card">
      <div class="card-body">
        <div class="flex gap-4">
          <div class="flex-1">
            <input
              v-model="searchQuery"
              type="text"
              class="input text-sm"
              placeholder="Cari berdasarkan keterangan..."
            />
          </div>
        </div>
      </div>
    </div>

    <!-- Mobile Card View -->
    <div class="md:hidden space-y-3">
      <div v-if="loading" class="text-center py-8 text-secondary-500 text-sm">Memuat data...</div>
      <div v-else-if="!penarikanList.length" class="text-center py-8 text-secondary-500 text-sm">Belum ada data penarikan tunai</div>
      <div v-else v-for="item in penarikanList" :key="item.id" class="card p-4 shadow-sm border border-secondary-100">
        <div class="flex justify-between items-start mb-3">
          <div>
            <span class="text-xs text-secondary-500 font-medium uppercase tracking-wide">Tanggal</span>
            <p class="text-sm font-semibold text-secondary-900">{{ formatDate(item.tanggal) }}</p>
          </div>
          <div class="text-right">
             <span class="text-xs text-secondary-500 font-medium uppercase tracking-wide">Jumlah</span>
             <p class="text-base font-bold text-orange-600">{{ formatCurrency(item.jumlah) }}</p>
          </div>
        </div>
        
        <div class="mb-3">
           <p class="text-xs text-secondary-500 mb-1">Keterangan</p>
           <p class="text-sm text-secondary-800 bg-secondary-50 p-2 rounded-md">{{ item.keterangan }}</p>
        </div>

        <div class="flex justify-between items-center pt-3 border-t border-secondary-100">
           <div class="flex items-center gap-2 text-xs text-secondary-500">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>
              {{ item.creator?.name || '-' }}
           </div>
           <div class="flex gap-2">
             <button @click="editItem(item)" class="p-1.5 text-primary-600 hover:bg-primary-50 rounded-md bg-primary-50/50">
               <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" /></svg>
             </button>
             <button @click="confirmDelete(item)" class="p-1.5 text-red-600 hover:bg-red-50 rounded-md bg-red-50/50">
               <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
             </button>
           </div>
        </div>
      </div>
    </div>

    <!-- Desktop Table View -->
    <div class="card hidden md:block">
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-secondary-200">
          <thead class="bg-secondary-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-secondary-700 uppercase tracking-wider">Tanggal</th>
              <th class="px-6 py-3 text-right text-xs font-semibold text-secondary-700 uppercase tracking-wider">Jumlah</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-secondary-700 uppercase tracking-wider">Keterangan</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-secondary-700 uppercase tracking-wider">Dibuat Oleh</th>
              <th class="px-6 py-3 text-center text-xs font-semibold text-secondary-700 uppercase tracking-wider">Aksi</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-secondary-200">
            <tr v-for="item in penarikanList" :key="item.id" class="hover:bg-secondary-50 transition-colors">
              <td class="px-6 py-4 whitespace-nowrap text-sm text-secondary-700">
                {{ formatDate(item.tanggal) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-bold text-orange-700 text-right">
                {{ formatCurrency(item.jumlah) }}
              </td>
              <td class="px-6 py-4 text-sm text-secondary-700 max-w-xs truncate" :title="item.keterangan">
                {{ item.keterangan }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-secondary-700">
                {{ item.creator?.name || '-' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-center">
                <div class="flex items-center justify-center gap-2">
                  <button
                    @click="editItem(item)"
                    class="p-2 text-primary-600 hover:bg-primary-50 rounded-lg transition-colors"
                    title="Edit"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                    </svg>
                  </button>
                  <button
                    @click="confirmDelete(item)"
                    class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                    title="Hapus"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                </div>
              </td>
            </tr>
            <tr v-if="!penarikanList.length && !loading">
              <td colspan="5" class="px-6 py-12 text-center text-secondary-500">
                Belum ada data penarikan tunai
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div v-if="meta.total > 0" class="card-footer">
        <div class="flex flex-col md:flex-row items-center justify-between gap-4">
          <p class="text-sm text-secondary-700">
            Menampilkan {{ ((meta.page - 1) * meta.per_page) + 1 }} - {{ Math.min(meta.page * meta.per_page, meta.total) }} dari {{ meta.total }} data
          </p>
          <div class="flex gap-2 w-full md:w-auto">
            <button
              @click="changePage(meta.page - 1)"
              :disabled="meta.page === 1"
              class="btn-secondary text-sm flex-1 md:flex-none justify-center"
              :class="{ 'opacity-50 cursor-not-allowed': meta.page === 1 }"
            >
              Sebelumnya
            </button>
            <button
              @click="changePage(meta.page + 1)"
              :disabled="meta.page === meta.last_page"
              class="btn-secondary text-sm flex-1 md:flex-none justify-center"
              :class="{ 'opacity-50 cursor-not-allowed': meta.page === meta.last_page }"
            >
              Selanjutnya
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Form Modal -->
    <div v-if="showForm" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-xl shadow-xl max-w-md w-full max-h-[90vh] overflow-y-auto">
        <div class="card-header sticky top-0 bg-white z-10 border-b border-secondary-200">
          <h3 class="font-semibold text-secondary-900">{{ editMode ? 'Edit Penarikan' : 'Penarikan Tunai' }}</h3>
        </div>
        <form @submit.prevent="handleSubmit" class="p-4 space-y-4">
          <div class="bg-blue-50 rounded-lg p-4">
            <p class="text-sm text-blue-700 font-medium">Saldo Bank Tersedia</p>
            <p class="text-xl md:text-2xl font-bold text-blue-900 truncate" :title="formatCurrency(saldoBank)">{{ formatCurrency(saldoBank) }}</p>
          </div>

          <div>
            <label class="label">Tanggal <span class="text-red-500">*</span></label>
            <input v-model="form.tanggal" type="date" class="input" required />
          </div>

          <div>
            <label class="label">Jumlah Penarikan (Rp) <span class="text-red-500">*</span></label>
            <input
              v-model.number="form.jumlah"
              type="number"
              class="input"
              min="1"
              step="1"
              required
              placeholder="0"
              @input="calculatePreview"
            />
            <p v-if="form.jumlah" class="mt-1 text-sm text-secondary-500 font-medium">
              {{ formatCurrency(form.jumlah) }}
            </p>
            <p v-if="form.jumlah > saldoBank" class="mt-1 text-sm text-red-600">
              ⚠️ Saldo bank tidak mencukupi!
            </p>
          </div>

          <div>
            <label class="label">Keterangan <span class="text-red-500">*</span></label>
            <textarea
              v-model="form.keterangan"
              class="input"
              rows="3"
              required
              minlength="3"
              placeholder="Contoh: Penarikan untuk operasional"
            ></textarea>
          </div>

          <!-- Preview -->
          <div v-if="form.jumlah > 0" class="bg-secondary-50 rounded-lg p-4 space-y-2">
            <p class="text-sm font-medium text-secondary-700">Preview Setelah Penarikan:</p>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <p class="text-xs text-secondary-600">Saldo Bank</p>
                <p class="text-lg font-bold truncate" :class="previewSaldoBank >= 0 ? 'text-blue-700' : 'text-red-700'">
                  {{ formatCurrency(previewSaldoBank) }}
                </p>
              </div>
              <div>
                <p class="text-xs text-secondary-600">Saldo Tunai</p>
                <p class="text-lg font-bold text-emerald-700 truncate">
                  {{ formatCurrency(previewSaldoTunai) }}
                </p>
              </div>
            </div>
          </div>

          <div class="flex justify-end gap-3 pt-4 border-t border-secondary-200 mt-4">
            <button type="button" @click="closeForm" class="btn-secondary">Batal</button>
            <button
              type="submit"
              class="btn-primary"
              :disabled="loading || form.jumlah > saldoBank"
            >
              <svg v-if="loading" class="animate-spin -ml-1 mr-2 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              {{ loading ? 'Menyimpan...' : 'Tarik Tunai' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="deleteConfirm" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-xl shadow-xl max-w-md w-full mx-4 p-6">
        <h3 class="text-lg font-semibold text-secondary-900 mb-4">Konfirmasi Hapus</h3>
        <p class="text-secondary-700 mb-6">Apakah Anda yakin ingin menghapus penarikan tunai ini?</p>
        <div class="flex justify-end gap-3">
          <button @click="deleteConfirm = null" class="btn-secondary">Batal</button>
          <button @click="handleDelete" class="btn-danger" :disabled="loading">
            {{ loading ? 'Menghapus...' : 'Hapus' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { useDebounceFn } from '@vueuse/core'
import api from '@/services/api'
import { useNotificationStore } from '@/stores/notification'

const notificationStore = useNotificationStore()

const loading = ref(false)
const showForm = ref(false)
const editMode = ref(false)
const deleteConfirm = ref(null)
const searchQuery = ref('')
const penarikanList = ref([])
const saldoBank = ref(0)
const saldoTunai = ref(0)
const meta = ref({
  total: 0,
  page: 1,
  per_page: 10,
  last_page: 1
})

const form = reactive({
  id: null,
  tanggal: new Date().toISOString().split('T')[0],
  jumlah: 0,
  keterangan: ''
})

const previewSaldoBank = computed(() => saldoBank.value - (form.jumlah || 0))
const previewSaldoTunai = computed(() => saldoTunai.value + (form.jumlah || 0))

onMounted(() => {
  loadSaldo()
  loadData()
})

const debouncedSearch = useDebounceFn(() => {
  meta.value.page = 1
  loadData()
}, 500)

watch(searchQuery, () => {
  debouncedSearch()
})

async function loadSaldo() {
  try {
    const response = await api.get('/saldo-bendahara/latest')
    if (response.data.success) {
      saldoBank.value = response.data.data.saldo_bank || 0
      saldoTunai.value = response.data.data.saldo_tunai || 0
    }
  } catch (error) {
    console.error('Failed to load saldo:', error)
  }
}

async function loadData() {
  try {
    const response = await api.get('/penarikan-tunai', {
      params: {
        page: meta.value.page,
        per_page: meta.value.per_page,
        search: searchQuery.value
      }
    })
    if (response.data.success) {
      penarikanList.value = response.data.data
      meta.value = response.data.meta
    }
  } catch (error) {
    notificationStore.error('Gagal memuat data')
  }
}

function changePage(page) {
  meta.value.page = page
  loadData()
}

function openForm() {
  loadSaldo() // Refresh saldo before opening form
  showForm.value = true
}

function editItem(item) {
  loadSaldo() // Refresh saldo
  editMode.value = true
  form.id = item.id
  form.tanggal = item.tanggal.split('T')[0]
  form.jumlah = item.jumlah
  form.keterangan = item.keterangan
  showForm.value = true
}

function closeForm() {
  showForm.value = false
  editMode.value = false
  form.id = null
  form.tanggal = new Date().toISOString().split('T')[0]
  form.jumlah = 0
  form.keterangan = ''
}

function calculatePreview() {
  // Preview is automatically calculated via computed properties
}

async function handleSubmit() {
  if (form.jumlah > saldoBank.value) {
    notificationStore.error('Saldo bank tidak mencukupi')
    return
  }

  loading.value = true
  try {
    const payload = {
      tanggal: form.tanggal,
      jumlah: parseFloat(form.jumlah),
      keterangan: form.keterangan
    }

    if (editMode.value) {
      await api.put(`/penarikan-tunai/${form.id}`, payload)
      notificationStore.success('Penarikan tunai berhasil diupdate')
    } else {
      await api.post('/penarikan-tunai', payload)
      notificationStore.success('Penarikan tunai berhasil ditambahkan')
    }

    closeForm()
    loadSaldo()
    loadData()
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal menyimpan data')
  } finally {
    loading.value = false
  }
}

function confirmDelete(item) {
  deleteConfirm.value = item
}

async function handleDelete() {
  loading.value = true
  try {
    await api.delete(`/penarikan-tunai/${deleteConfirm.value.id}`)
    notificationStore.success('Penarikan tunai berhasil dihapus')
    deleteConfirm.value = null
    loadSaldo()
    loadData()
  } catch (error) {
    console.error('Delete error:', error.response)
    const message = error.response?.data?.message || error.message || 'Gagal menghapus data'
    notificationStore.error(message)
  } finally {
    loading.value = false
  }
}

function formatCurrency(value) {
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(value || 0)
}

function formatDate(date) {
  if (!date) return '-'
  return new Date(date).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })
}
</script>
