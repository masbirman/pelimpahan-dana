<template>
  <div class="space-y-6 animate-fadeIn">
    <!-- Header -->
    <div class="flex items-center gap-4">
      <router-link to="/setoran-pengembalian" class="p-2 rounded-lg hover:bg-secondary-100 transition-colors">
        <svg class="w-5 h-5 text-secondary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
        </svg>
      </router-link>
      <div>
        <h1 class="text-2xl font-bold text-secondary-900">Input Setoran Pengembalian</h1>
        <p class="text-secondary-500">Catat pengembalian dana dari Unit ke Bendahara</p>
      </div>
    </div>

    <!-- Form -->
    <form @submit.prevent="handleSubmit" class="space-y-6">
      <!-- Info Setoran -->
      <div class="card">
        <div class="card-header">
          <h3 class="font-semibold text-secondary-900">Info Setoran Pengembalian</h3>
        </div>
        <div class="card-body space-y-6">
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
              <label class="label">Nomor Setoran</label>
              <input type="text" class="input bg-secondary-50" :value="nomorSetoran" disabled />
            </div>
            <div>
              <label class="label">Waktu Input</label>
              <input type="text" class="input bg-secondary-50" :value="waktuInput" disabled />
            </div>
            <div>
              <label class="label">Tanggal Setoran <span class="text-red-500">*</span></label>
              <input v-model="form.tanggal" type="date" class="input" required />
            </div>
          </div>

          <div>
            <label class="label">Keterangan</label>
            <input v-model="form.keterangan" type="text" class="input" placeholder="Keterangan setoran pengembalian..." />
          </div>
        </div>
      </div>

      <!-- Daftar Unit yang Mengembalikan -->
      <div class="card">
        <div class="card-header flex items-center justify-between">
          <h3 class="font-semibold text-secondary-900">Daftar Unit Pengirim</h3>
          <button type="button" @click="addUnit" class="btn-secondary text-sm">
            <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
            Tambah Unit
          </button>
        </div>
        <div class="card-body space-y-4">
          <div v-if="form.details.length === 0" class="text-center py-8 text-secondary-500">
            <svg class="w-12 h-12 mx-auto mb-4 text-secondary-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
            </svg>
            <p>Belum ada unit. Klik "Tambah Unit" untuk menambahkan.</p>
          </div>

          <!-- Unit Row -->
          <div
            v-for="(detail, index) in form.details"
            :key="index"
            class="p-4 bg-emerald-50 rounded-xl space-y-4"
          >
            <div class="flex items-center justify-between">
              <span class="text-sm font-medium text-emerald-700">Unit #{{ index + 1 }}</span>
              <button
                type="button"
                @click="removeUnit(index)"
                class="p-1.5 text-red-500 hover:bg-red-100 rounded-lg transition-colors"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
              <div>
                <label class="label text-xs">Unit Kerja <span class="text-red-500">*</span></label>
                <select v-model="detail.unit_id" class="input text-sm" required @change="onUnitChange(index)">
                  <option value="">Pilih Unit</option>
                  <option v-for="unit in unitsList" :key="unit.id" :value="unit.id">
                    {{ unit.kode_unit }} - {{ unit.nama_unit }}
                  </option>
                </select>
              </div>
              <div>
                <label class="label text-xs">Nama Penyetor <span class="text-red-500">*</span></label>
                <input v-model="detail.nama_penerima" type="text" class="input text-sm" required />
              </div>
              <div>
                <label class="label text-xs">No. Rekening</label>
                <input v-model="detail.no_rekening" type="text" class="input text-sm" />
              </div>
              <div>
                <label class="label text-xs">Jumlah (Rp) <span class="text-red-500">*</span></label>
                <input
                  v-model.number="detail.jumlah"
                  type="number"
                  class="input text-sm"
                  min="1"
                  required
                />
              </div>
            </div>

            <!-- Sumber Dana -->
            <div>
              <label class="label text-xs">Disetor via <span class="text-red-500">*</span></label>
              <div class="flex gap-4 mt-1">
                <label class="flex items-center cursor-pointer group">
                  <input
                    type="radio"
                    v-model="detail.sumber_dana"
                    value="bank"
                    class="w-4 h-4 text-primary-600 focus:ring-primary-500 focus:ring-2"
                  />
                  <span class="ml-2 text-sm text-secondary-700 group-hover:text-primary-600 transition-colors">💳 Bank</span>
                </label>
                <label class="flex items-center cursor-pointer group">
                  <input
                    type="radio"
                    v-model="detail.sumber_dana"
                    value="tunai"
                    class="w-4 h-4 text-primary-600 focus:ring-primary-500 focus:ring-2"
                  />
                  <span class="ml-2 text-sm text-secondary-700 group-hover:text-primary-600 transition-colors">💵 Tunai</span>
                </label>
              </div>
            </div>
          </div>

          <!-- Total -->
          <div v-if="form.details.length > 0" class="flex justify-end pt-4 border-t border-secondary-200">
            <div class="text-right">
              <p class="text-sm text-secondary-500">Total Setoran Pengembalian</p>
              <p class="text-2xl font-bold text-emerald-600">{{ formatCurrency(totalJumlah) }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Actions -->
      <div class="flex justify-end gap-3">
        <router-link to="/setoran-pengembalian" class="btn-secondary">Batal</router-link>
        <button type="submit" class="btn-primary" :disabled="loading || form.details.length === 0">
          <svg v-if="loading" class="animate-spin -ml-1 mr-2 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          {{ loading ? 'Menyimpan...' : 'Simpan Setoran' }}
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/services/api'
import { useNotificationStore } from '@/stores/notification'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const notificationStore = useNotificationStore()
const authStore = useAuthStore()

const loading = ref(false)
const unitsList = ref([])
const nomorSetoran = ref('(Auto)')

const form = reactive({
  tanggal: new Date().toISOString().split('T')[0],
  keterangan: '',
  details: []
})

const waktuInput = computed(() => {
  return new Date().toLocaleString('id-ID', {
    timeZone: 'Asia/Makassar',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  }) + ' WITA'
})

const totalJumlah = computed(() => {
  return form.details.reduce((sum, d) => sum + (d.jumlah || 0), 0)
})

onMounted(async () => {
  // Check if year is locked (skip for super_admin)
  if (authStore.user?.role !== 'super_admin') {
    try {
      const lockResponse = await api.get('/settings/lock-status')
      if (lockResponse.data.success && lockResponse.data.data?.locked) {
        notificationStore.error('Tahun anggaran sudah dikunci. Hubungi administrator.')
        router.push('/setoran-pengembalian')
        return
      }
    } catch (error) {
      console.log('Lock check failed')
    }
  }

  await loadUnits()
})

async function loadUnits() {
  try {
    const response = await api.get('/units', { params: { per_page: 100 } })
    if (response.data.success) {
      unitsList.value = response.data.data
    }
  } catch (error) {
    console.error('Failed to load units:', error)
  }
}

function addUnit() {
  form.details.push({
    unit_id: '',
    nama_penerima: '',
    no_rekening: '',
    jumlah: 0,
    sumber_dana: 'bank'
  })
}

function removeUnit(index) {
  form.details.splice(index, 1)
}

function onUnitChange(index) {
  const detail = form.details[index]
  const unit = unitsList.value.find(u => u.id === detail.unit_id)
  if (unit) {
    detail.nama_penerima = unit.nama_bendahara
    detail.no_rekening = unit.nomor_rekening
  }
}

async function handleSubmit() {
  if (form.details.length === 0) {
    notificationStore.error('Minimal satu unit harus diisi')
    return
  }

  loading.value = true
  try {
    const payload = {
      tanggal: form.tanggal,
      keterangan: form.keterangan,
      details: form.details.map(d => ({
        unit_id: parseInt(d.unit_id),
        nama_penerima: d.nama_penerima,
        no_rekening: d.no_rekening,
        jumlah: parseFloat(d.jumlah),
        sumber_dana: d.sumber_dana
      }))
    }

    await api.post('/setoran-pengembalian', payload)
    notificationStore.success('Setoran pengembalian berhasil dicatat')
    router.push('/setoran-pengembalian')
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal menyimpan')
  } finally {
    loading.value = false
  }
}

function formatCurrency(value) {
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(value || 0)
}
</script>
