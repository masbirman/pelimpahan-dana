<template>
  <div class="space-y-6 animate-fadeIn">
    <!-- Header -->
    <div class="flex justify-between items-center">
      <div>
        <h1 class="text-2xl font-bold text-secondary-900">Saldo Bendahara</h1>
        <p class="text-secondary-500">Kelola saldo awal bendahara (Bank & Tunai)</p>
      </div>
      <router-link to="/saldo-bendahara/create" class="btn-primary">
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
        </svg>
        Tambah Saldo Baru
      </router-link>
    </div>

    <!-- Latest Saldo Card -->
    <div v-if="latestSaldo" class="card">
      <div class="card-header">
        <h3 class="font-semibold text-secondary-900">Saldo Terkini</h3>
        <p class="text-xs text-secondary-500">{{ formatDate(latestSaldo.tanggal) }}</p>
      </div>
      <div class="card-body">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div class="p-4 bg-blue-50 rounded-lg">
            <p class="text-sm text-secondary-600 mb-1">Saldo Bank</p>
            <p class="text-2xl font-bold text-blue-700">{{ formatRupiah(latestSaldo.saldo_bank) }}</p>
          </div>
          <div class="p-4 bg-emerald-50 rounded-lg">
            <p class="text-sm text-secondary-600 mb-1">Saldo Tunai</p>
            <p class="text-2xl font-bold text-emerald-700">{{ formatRupiah(latestSaldo.saldo_tunai) }}</p>
          </div>
          <div class="p-4 bg-primary-50 rounded-lg">
            <p class="text-sm text-secondary-600 mb-1">Total Saldo</p>
            <p class="text-2xl font-bold text-primary-700">{{ formatRupiah(latestSaldo.saldo_bank + latestSaldo.saldo_tunai) }}</p>
          </div>
        </div>
        
        <!-- Action Buttons -->
        <div class="flex gap-3 mt-6">
          <router-link to="/saldo-bendahara/top-up" class="btn-primary flex-1">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
            💰 Top Up Bank
          </router-link>
          <router-link to="/saldo-bendahara/penarikan-tunai" class="btn-secondary flex-1">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" />
            </svg>
            💵 Penarikan Tunai
          </router-link>
        </div>
      </div>
    </div>

    <!-- Filters -->
    <div class="card">
      <div class="card-body">
        <div class="flex gap-4">
          <div class="flex-1">
            <input
              v-model="search"
              type="text"
              class="input"
              placeholder="Cari berdasarkan keterangan..."
              @input="fetchSaldos"
            />
          </div>
        </div>
      </div>
    </div>

    <!-- Table -->
    <div class="card">
      <div class="card-body p-0">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-secondary-200">
            <thead class="bg-secondary-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-secondary-500 uppercase tracking-wider whitespace-nowrap">
                  Tanggal
                </th>
                <th class="px-6 py-3 text-right text-xs font-medium text-secondary-500 uppercase tracking-wider whitespace-nowrap">
                  Saldo Bank
                </th>
                <th class="px-6 py-3 text-right text-xs font-medium text-secondary-500 uppercase tracking-wider whitespace-nowrap">
                  Saldo Tunai
                </th>
                <th class="px-6 py-3 text-right text-xs font-medium text-secondary-500 uppercase tracking-wider whitespace-nowrap">
                  Total Saldo
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-secondary-500 uppercase tracking-wider">
                  Keterangan
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-secondary-500 uppercase tracking-wider whitespace-nowrap">
                  Dibuat Oleh
                </th>
                <th class="px-6 py-3 text-center text-xs font-medium text-secondary-500 uppercase tracking-wider whitespace-nowrap">
                  Aksi
                </th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-secondary-200">
              <tr v-if="loading">
                <td colspan="7" class="px-6 py-8 text-center">
                  <div class="flex justify-center">
                    <svg class="animate-spin h-8 w-8 text-primary-600" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                  </div>
                </td>
              </tr>
              <tr v-else-if="saldos.length === 0">
                <td colspan="7" class="px-6 py-8 text-center text-secondary-500">
                  Belum ada data saldo
                </td>
              </tr>
              <tr v-else v-for="saldo in saldos" :key="saldo.id" class="hover:bg-secondary-50 transition-colors">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-secondary-900">
                  {{ formatDate(saldo.tanggal) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-right text-blue-700">
                  {{ formatRupiah(saldo.saldo_bank) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-right text-emerald-700">
                  {{ formatRupiah(saldo.saldo_tunai) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-bold text-right text-primary-700">
                  {{ formatRupiah(saldo.saldo_bank + saldo.saldo_tunai) }}
                </td>
                <td class="px-6 py-4 text-sm text-secondary-600 max-w-xs truncate" :title="saldo.keterangan">
                  {{ saldo.keterangan || '-' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-secondary-600">
                  {{ saldo.creator?.name || '-' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-center">
                  <div class="flex justify-center gap-2">
                    <router-link :to="`/saldo-bendahara/${saldo.id}/edit`" class="btn-icon btn-icon-warning" title="Edit">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                      </svg>
                    </router-link>
                    <button v-if="authStore.user?.role === 'super_admin'" @click="confirmDelete(saldo)" class="btn-icon btn-icon-danger" title="Hapus">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                      </svg>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Pagination -->
    <div v-if="meta.total > 0" class="flex justify-between items-center">
      <p class="text-sm text-secondary-600">
        Menampilkan {{ ((meta.page - 1) * meta.per_page) + 1 }} - {{ Math.min(meta.page * meta.per_page, meta.total) }} dari {{ meta.total }} data
      </p>
      <div class="flex gap-2">
        <button @click="changePage(meta.page - 1)" :disabled="meta.page === 1" class="btn-secondary">
          Sebelumnya
        </button>
        <button @click="changePage(meta.page + 1)" :disabled="meta.page * meta.per_page >= meta.total" class="btn-secondary">
          Selanjutnya
        </button>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="showDeleteModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <h3 class="text-lg font-semibold text-secondary-900 mb-2">Konfirmasi Hapus</h3>
        <p class="text-secondary-600 mb-6">Apakah Anda yakin ingin menghapus data saldo tanggal {{ formatDate(selectedSaldo?.tanggal) }}?</p>
        <div class="flex justify-end gap-3">
          <button @click="showDeleteModal = false" class="btn-secondary">Batal</button>
          <button @click="deleteSaldo" class="btn-danger">Hapus</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import { useAuthStore } from '@/stores/auth'
import { useNotificationStore } from '@/stores/notification'

const authStore = useAuthStore()
const notificationStore = useNotificationStore()

const saldos = ref([])
const latestSaldo = ref(null)
const loading = ref(false)
const search = ref('')
const meta = ref({
  total: 0,
  page: 1,
  per_page: 10
})

const showDeleteModal = ref(false)
const selectedSaldo = ref(null)

onMounted(() => {
  fetchLatestSaldo()
  fetchSaldos()
})

async function fetchLatestSaldo() {
  try {
    const response = await api.get('/saldo-bendahara/latest')
    if (response.data.success && response.data.data) {
      latestSaldo.value = response.data.data
    }
  } catch (error) {
    console.error('Error fetching latest saldo:', error)
  }
}

async function fetchSaldos() {
  loading.value = true
  try {
    const params = {
      page: meta.value.page,
      per_page: meta.value.per_page,
      search: search.value
    }
    const response = await api.get('/saldo-bendahara', { params })
    saldos.value = response.data.data
    meta.value = response.data.meta
  } catch (error) {
    notificationStore.error('Gagal memuat data saldo')
  } finally {
    loading.value = false
  }
}

function changePage(page) {
  meta.value.page = page
  fetchSaldos()
}

function confirmDelete(saldo) {
  selectedSaldo.value = saldo
  showDeleteModal.value = true
}

async function deleteSaldo() {
  try {
    await api.delete(`/saldo-bendahara/${selectedSaldo.value.id}`)
    notificationStore.success('Saldo berhasil dihapus')
    showDeleteModal.value = false
    fetchLatestSaldo()
    fetchSaldos()
  } catch (error) {
    notificationStore.error('Gagal menghapus saldo')
  }
}

function formatRupiah(amount) {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    minimumFractionDigits: 0
  }).format(amount)
}

function formatDate(date) {
  return new Date(date).toLocaleDateString('id-ID', {
    day: 'numeric',
    month: 'long',
    year: 'numeric'
  })
}
</script>
