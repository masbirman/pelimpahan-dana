<template>
  <div class="space-y-6 animate-fadeIn">
    <!-- Header -->
    <div class="flex justify-between items-center">
      <div>
        <h1 class="text-2xl font-bold text-secondary-900">Setor ke Kas BUD</h1>
        <p class="text-secondary-500">Pengembalian sisa saldo ke Kas BUD</p>
      </div>
    </div>

    <!-- Saldo Terkini -->
    <div class="card">
      <div class="card-header">
        <h3 class="font-semibold text-secondary-900">Sisa Saldo Bendahara</h3>
      </div>
      <div class="card-body">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div class="p-4 bg-blue-50 rounded-lg">
            <p class="text-sm text-secondary-600 mb-1">Saldo Bank</p>
            <p class="text-2xl font-bold text-blue-700">{{ formatRupiah(latestSaldo?.saldo_bank || 0) }}</p>
          </div>
          <div class="p-4 bg-emerald-50 rounded-lg">
            <p class="text-sm text-secondary-600 mb-1">Saldo Tunai</p>
            <p class="text-2xl font-bold text-emerald-700">{{ formatRupiah(latestSaldo?.saldo_tunai || 0) }}</p>
          </div>
          <div class="p-4 bg-amber-50 rounded-lg">
            <p class="text-sm text-secondary-600 mb-1">Total Sisa Saldo</p>
            <p class="text-2xl font-bold text-amber-700">{{ formatRupiah(latestSaldo?.total_saldo || 0) }}</p>
          </div>
        </div>

        <!-- Setor Button -->
        <div class="mt-6">
          <button @click="openSetorModal" class="btn-primary">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
            💰 Setor ke Kas BUD
          </button>
        </div>
      </div>
    </div>

    <!-- Riwayat Setor -->
    <div class="card">
      <div class="card-header">
        <h3 class="font-semibold text-secondary-900">Riwayat Setor ke Kas BUD</h3>
      </div>
      <div class="card-body p-0">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-secondary-200">
            <thead class="bg-secondary-50">
              <tr>
                <th class="px-4 py-3 text-left text-xs font-medium text-secondary-500 uppercase">Tanggal</th>
                <th class="px-4 py-3 text-right text-xs font-medium text-secondary-500 uppercase">Jumlah</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-secondary-500 uppercase">Uraian</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-secondary-500 uppercase">Dibuat Oleh</th>
                <th class="px-4 py-3 text-center text-xs font-medium text-secondary-500 uppercase">Aksi</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-secondary-200">
              <tr v-if="loading">
                <td colspan="5" class="px-4 py-8 text-center text-secondary-500">Memuat data...</td>
              </tr>
              <tr v-else-if="!setorList.length">
                <td colspan="5" class="px-4 py-8 text-center text-secondary-500">Belum ada data setor ke Kas BUD</td>
              </tr>
              <tr v-else v-for="item in setorList" :key="item.id" class="hover:bg-secondary-50">
                <td class="px-4 py-3 text-sm text-secondary-900">{{ formatDate(item.tanggal) }}</td>
                <td class="px-4 py-3 text-sm font-semibold text-right text-red-700">{{ formatRupiah(item.jumlah) }}</td>
                <td class="px-4 py-3 text-sm text-secondary-600 max-w-xs truncate">{{ item.keterangan }}</td>
                <td class="px-4 py-3 text-sm text-secondary-600">{{ item.creator?.name || '-' }}</td>
                <td class="px-4 py-3 text-center">
                  <button v-if="authStore.user?.role === 'super_admin'" @click="confirmDelete(item)" class="btn-icon btn-icon-danger" title="Hapus">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                </td>
              </tr>
            </tbody>
            <tfoot v-if="setorList.length" class="bg-secondary-100">
              <tr class="font-bold">
                <td class="px-4 py-3 text-sm">Total Setor</td>
                <td class="px-4 py-3 text-sm text-right text-red-700">{{ formatRupiah(totalSetor) }}</td>
                <td colspan="3"></td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>

    <!-- Setor Modal -->
    <div v-if="showSetorModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-xl shadow-xl max-w-md w-full">
        <div class="card-header">
          <h3 class="font-semibold text-secondary-900">Setor ke Kas BUD</h3>
        </div>
        <form @submit.prevent="handleSetorSubmit" class="card-body space-y-4">
          <div class="bg-amber-50 rounded-lg p-4">
            <p class="text-sm text-amber-700 font-medium">Sisa Saldo Yang Akan Disetor</p>
            <p class="text-xl font-bold text-amber-900">{{ formatRupiah(latestSaldo?.total_saldo || 0) }}</p>
          </div>
          <div>
            <label class="label">Tanggal <span class="text-red-500">*</span></label>
            <input v-model="setorForm.tanggal" type="date" class="input" required />
          </div>
          <div>
            <label class="label">Jumlah Setor (Rp) <span class="text-red-500">*</span></label>
            <input v-model.number="setorForm.jumlah" type="number" class="input" min="1" required placeholder="0" />
            <p v-if="setorForm.jumlah" class="mt-1 text-sm text-secondary-500">{{ formatRupiah(setorForm.jumlah) }}</p>
            <p v-if="setorForm.jumlah > (latestSaldo?.total_saldo || 0)" class="mt-1 text-sm text-red-600">⚠️ Jumlah melebihi sisa saldo!</p>
          </div>
          <div>
            <label class="label">Uraian <span class="text-red-500">*</span></label>
            <textarea v-model="setorForm.keterangan" class="input" rows="3" required minlength="3" placeholder="Contoh: Setor sisa UP/GU dan TU TA 2025"></textarea>
          </div>
          <div class="flex justify-end gap-3 pt-4">
            <button type="button" @click="closeSetorModal" class="btn-secondary">Batal</button>
            <button type="submit" class="btn-primary" :disabled="submitting || setorForm.jumlah > (latestSaldo?.total_saldo || 0)">{{ submitting ? 'Menyimpan...' : 'Setor' }}</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div v-if="deleteConfirm" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <h3 class="text-lg font-semibold text-secondary-900 mb-2">Konfirmasi Hapus</h3>
        <p class="text-secondary-600 mb-6">Apakah Anda yakin ingin menghapus setor ini?</p>
        <div class="flex justify-end gap-3">
          <button @click="deleteConfirm = null" class="btn-secondary">Batal</button>
          <button @click="handleDelete" class="btn-danger" :disabled="submitting">{{ submitting ? 'Menghapus...' : 'Hapus' }}</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import api from '@/services/api'
import { useAuthStore } from '@/stores/auth'
import { useNotificationStore } from '@/stores/notification'

const authStore = useAuthStore()
const notificationStore = useNotificationStore()

const latestSaldo = ref(null)
const setorList = ref([])
const loading = ref(false)
const submitting = ref(false)
const showSetorModal = ref(false)
const deleteConfirm = ref(null)

const setorForm = reactive({
  tanggal: new Date().toISOString().split('T')[0],
  jumlah: 0,
  keterangan: ''
})

const totalSetor = computed(() => setorList.value.reduce((sum, item) => sum + item.jumlah, 0))

onMounted(() => {
  fetchLatestSaldo()
  fetchSetorList()
})

async function fetchLatestSaldo() {
  try {
    const response = await api.get('/saldo-bendahara/latest')
    if (response.data.success) {
      latestSaldo.value = response.data.data
    }
  } catch (error) {
    console.error('Error fetching saldo:', error)
  }
}

async function fetchSetorList() {
  loading.value = true
  try {
    const response = await api.get('/setor-kas-bud', { params: { per_page: 100 } })
    if (response.data.success) {
      setorList.value = response.data.data || []
    }
  } catch (error) {
    console.error('Error fetching setor list:', error)
  } finally {
    loading.value = false
  }
}

function openSetorModal() {
  setorForm.tanggal = new Date().toISOString().split('T')[0]
  setorForm.jumlah = latestSaldo.value?.total_saldo || 0
  setorForm.keterangan = ''
  showSetorModal.value = true
}

function closeSetorModal() {
  showSetorModal.value = false
}

async function handleSetorSubmit() {
  submitting.value = true
  try {
    await api.post('/setor-kas-bud', {
      tanggal: setorForm.tanggal,
      jumlah: parseFloat(setorForm.jumlah),
      keterangan: setorForm.keterangan
    })
    notificationStore.success('Setor ke Kas BUD berhasil dicatat')
    closeSetorModal()
    fetchLatestSaldo()
    fetchSetorList()
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal menyimpan data')
  } finally {
    submitting.value = false
  }
}

function confirmDelete(item) {
  deleteConfirm.value = item
}

async function handleDelete() {
  submitting.value = true
  try {
    await api.delete(`/setor-kas-bud/${deleteConfirm.value.id}`)
    notificationStore.success('Setor berhasil dihapus')
    deleteConfirm.value = null
    fetchLatestSaldo()
    fetchSetorList()
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal menghapus data')
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
