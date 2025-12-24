<template>
  <div class="space-y-6 animate-fadeIn">
    <!-- Header -->
    <div class="flex justify-between items-center">
      <div>
        <h1 class="text-2xl font-bold text-secondary-900">Setoran Pengembalian</h1>
        <p class="text-secondary-500">Daftar pengembalian dana dari Unit ke Bendahara</p>
      </div>
      <router-link v-if="!isYearLocked" to="/setoran-pengembalian/create" class="btn-primary">
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
        </svg>
        Input Setoran Pengembalian
      </router-link>
    </div>

    <!-- Table -->
    <div class="card">
      <div class="card-body p-0">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-secondary-200">
            <thead class="bg-secondary-50">
              <tr>
                <th class="px-4 py-3 text-left text-xs font-medium text-secondary-500 uppercase">No. Setoran</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-secondary-500 uppercase">Tanggal</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-secondary-500 uppercase">Unit</th>
                <th class="px-4 py-3 text-right text-xs font-medium text-secondary-500 uppercase">Total</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-secondary-500 uppercase">Keterangan</th>
                <th class="px-4 py-3 text-center text-xs font-medium text-secondary-500 uppercase">Aksi</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-secondary-200">
              <tr v-if="loading">
                <td colspan="6" class="px-4 py-8 text-center text-secondary-500">Memuat data...</td>
              </tr>
              <tr v-else-if="!setoranList.length">
                <td colspan="6" class="px-4 py-8 text-center text-secondary-500">Belum ada data setoran pengembalian</td>
              </tr>
              <tr v-else v-for="item in setoranList" :key="item.id" class="hover:bg-secondary-50">
                <td class="px-4 py-3 text-sm font-medium text-primary-600">{{ item.nomor_setoran }}</td>
                <td class="px-4 py-3 text-sm text-secondary-900">{{ formatDate(item.tanggal) }}</td>
                <td class="px-4 py-3">
                  <div class="flex flex-wrap gap-1">
                    <span v-for="d in item.details" :key="d.id" class="px-2 py-0.5 text-xs bg-emerald-100 text-emerald-700 rounded">
                      {{ d.unit?.nama_unit || 'N/A' }}
                    </span>
                  </div>
                </td>
                <td class="px-4 py-3 text-sm font-semibold text-right text-emerald-700">{{ formatRupiah(getTotal(item.details)) }}</td>
                <td class="px-4 py-3 text-sm text-secondary-600 max-w-xs truncate">{{ item.keterangan || '-' }}</td>
                <td class="px-4 py-3 text-center">
                  <button v-if="authStore.user?.role === 'super_admin'" @click="confirmDelete(item)" class="btn-icon btn-icon-danger" title="Hapus">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="deleteConfirm" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <h3 class="text-lg font-semibold text-secondary-900 mb-2">Konfirmasi Hapus</h3>
        <p class="text-secondary-600 mb-6">Apakah Anda yakin ingin menghapus setoran {{ deleteConfirm.nomor_setoran }}?</p>
        <div class="flex justify-end gap-3">
          <button @click="deleteConfirm = null" class="btn-secondary">Batal</button>
          <button @click="handleDelete" class="btn-danger" :disabled="submitting">{{ submitting ? 'Menghapus...' : 'Hapus' }}</button>
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

const setoranList = ref([])
const loading = ref(false)
const submitting = ref(false)
const deleteConfirm = ref(null)
const isYearLocked = ref(false)

onMounted(() => {
  fetchLockStatus()
  fetchSetoran()
})

async function fetchLockStatus() {
  if (authStore.user?.role === 'super_admin') {
    isYearLocked.value = false
    return
  }
  try {
    const response = await api.get('/settings/lock-status')
    if (response.data.success && response.data.data?.locked) {
      isYearLocked.value = true
    }
  } catch (error) {
    console.log('Lock check failed')
  }
}

async function fetchSetoran() {
  loading.value = true
  try {
    const response = await api.get('/setoran-pengembalian', { params: { per_page: 100 } })
    if (response.data.success) {
      setoranList.value = response.data.data || []
    }
  } catch (error) {
    console.error('Error fetching setoran:', error)
  } finally {
    loading.value = false
  }
}

function getTotal(details) {
  return (details || []).reduce((sum, d) => sum + (d.jumlah || 0), 0)
}

function confirmDelete(item) {
  deleteConfirm.value = item
}

async function handleDelete() {
  submitting.value = true
  try {
    await api.delete(`/setoran-pengembalian/${deleteConfirm.value.id}`)
    notificationStore.success('Setoran pengembalian berhasil dihapus')
    deleteConfirm.value = null
    fetchSetoran()
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal menghapus')
  } finally {
    submitting.value = false
  }
}

function formatRupiah(amount) {
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(amount)
}

function formatDate(date) {
  return new Date(date).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })
}
</script>
