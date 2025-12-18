<template>
  <div class="space-y-6 animate-fadeIn">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-secondary-900">Top Up Saldo Bank</h1>
        <p class="text-secondary-500">Kelola penerimaan dana dari luar</p>
      </div>
      <button @click="showForm = true" class="btn-primary">
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
        </svg>
        Tambah Top Up
      </button>
    </div>

    <!-- Search & Filter -->
    <div class="card">
      <div class="card-body">
        <div class="flex gap-4">
          <div class="flex-1">
            <input
              v-model="searchQuery"
              type="text"
              class="input"
              placeholder="Cari berdasarkan keterangan..."
            />
          </div>
        </div>
      </div>
    </div>

    <!-- Table -->
    <div class="card">
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
            <tr v-for="item in topUpList" :key="item.id" class="hover:bg-secondary-50 transition-colors">
              <td class="px-6 py-4 whitespace-nowrap text-sm text-secondary-700">
                {{ formatDate(item.tanggal) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-bold text-emerald-700 text-right">
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
            <tr v-if="!topUpList.length && !loading">
              <td colspan="5" class="px-6 py-12 text-center text-secondary-500">
                Belum ada data top up
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div v-if="meta.total > 0" class="card-footer">
        <div class="flex items-center justify-between">
          <p class="text-sm text-secondary-700">
            Menampilkan {{ ((meta.page - 1) * meta.per_page) + 1 }} - {{ Math.min(meta.page * meta.per_page, meta.total) }} dari {{ meta.total }} data
          </p>
          <div class="flex gap-2">
            <button
              @click="changePage(meta.page - 1)"
              :disabled="meta.page === 1"
              class="btn-secondary text-sm"
              :class="{ 'opacity-50 cursor-not-allowed': meta.page === 1 }"
            >
              Sebelumnya
            </button>
            <button
              @click="changePage(meta.page + 1)"
              :disabled="meta.page === meta.last_page"
              class="btn-secondary text-sm"
              :class="{ 'opacity-50 cursor-not-allowed': meta.page === meta.last_page }"
            >
              Selanjutnya
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Form Modal -->
    <div v-if="showForm" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-xl shadow-xl max-w-md w-full mx-4">
        <div class="card-header">
          <h3 class="font-semibold text-secondary-900">{{ editMode ? 'Edit Top Up' : 'Tambah Top Up' }}</h3>
        </div>
        <form @submit.prevent="handleSubmit" class="card-body space-y-4">
          <div>
            <label class="label">Tanggal <span class="text-red-500">*</span></label>
            <input v-model="form.tanggal" type="date" class="input" required />
          </div>
          <div>
            <label class="label">Jumlah (Rp) <span class="text-red-500">*</span></label>
            <input
              v-model.number="form.jumlah"
              type="number"
              class="input"
              min="1"
              step="1"
              required
              placeholder="0"
            />
            <p v-if="form.jumlah" class="mt-1 text-sm text-secondary-500">
              {{ formatCurrency(form.jumlah) }}
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
              placeholder="Contoh: Penerimaan APBD Triwulan 1"
            ></textarea>
          </div>
          <div class="flex justify-end gap-3 pt-4">
            <button type="button" @click="closeForm" class="btn-secondary">Batal</button>
            <button type="submit" class="btn-primary" :disabled="loading">
              <svg v-if="loading" class="animate-spin -ml-1 mr-2 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              {{ loading ? 'Menyimpan...' : 'Simpan' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="deleteConfirm" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-xl shadow-xl max-w-md w-full mx-4 p-6">
        <h3 class="text-lg font-semibold text-secondary-900 mb-4">Konfirmasi Hapus</h3>
        <p class="text-secondary-700 mb-6">Apakah Anda yakin ingin menghapus top up ini?</p>
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
import { ref, reactive, onMounted, watch } from 'vue'
import { useDebounceFn } from '@vueuse/core'
import api from '@/services/api'
import { useNotificationStore } from '@/stores/notification'

const notificationStore = useNotificationStore()

const loading = ref(false)
const showForm = ref(false)
const editMode = ref(false)
const deleteConfirm = ref(null)
const searchQuery = ref('')
const topUpList = ref([])
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

onMounted(() => {
  loadData()
})

const debouncedSearch = useDebounceFn(() => {
  meta.value.page = 1
  loadData()
}, 500)

watch(searchQuery, () => {
  debouncedSearch()
})

async function loadData() {
  try {
    const response = await api.get('/top-up-saldo', {
      params: {
        page: meta.value.page,
        per_page: meta.value.per_page,
        search: searchQuery.value
      }
    })
    if (response.data.success) {
      topUpList.value = response.data.data
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

function editItem(item) {
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

async function handleSubmit() {
  loading.value = true
  try {
    const payload = {
      tanggal: form.tanggal,
      jumlah: parseFloat(form.jumlah),
      keterangan: form.keterangan
    }

    if (editMode.value) {
      await api.put(`/top-up-saldo/${form.id}`, payload)
      notificationStore.success('Top up berhasil diupdate')
    } else {
      await api.post('/top-up-saldo', payload)
      notificationStore.success('Top up berhasil ditambahkan')
    }

    closeForm()
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
    await api.delete(`/top-up-saldo/${deleteConfirm.value.id}`)
    notificationStore.success('Top up berhasil dihapus')
    deleteConfirm.value = null
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
