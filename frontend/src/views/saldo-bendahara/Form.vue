<template>
  <div class="max-w-3xl mx-auto space-y-6 animate-fadeIn">
    <!-- Header -->
    <div>
      <h1 class="text-2xl font-bold text-secondary-900">{{ isEdit ? 'Edit' : 'Tambah' }} Saldo Bendahara</h1>
      <p class="text-secondary-500">{{ isEdit ? 'Ubah' : 'Tambahkan' }} data saldo awal bendahara</p>
    </div>

    <!-- Form -->
    <div class="card">
      <div class="card-body">
        <form @submit.prevent="handleSubmit" class="space-y-6">
          <!-- Tanggal -->
          <div>
            <label class="label">Tanggal <span class="text-red-500">*</span></label>
            <input
              v-model="form.tanggal"
              type="date"
              class="input"
              required
            />
          </div>

          <!-- Saldo Bank -->
          <div>
            <label class="label">Saldo Bank</label>
            <div class="relative">
              <span class="absolute left-3 top-1/2 -translate-y-1/2 text-secondary-500">Rp</span>
              <input
                v-model="form.saldo_bank"
                type="number"
                step="0.01"
                min="0"
                class="input pl-12"
                placeholder="0"
              />
            </div>
            <p class="text-sm text-secondary-500 mt-1">{{ formatRupiah(form.saldo_bank || 0) }}</p>
          </div>

          <!-- Saldo Tunai -->
          <div>
            <label class="label">Saldo Tunai</label>
            <div class="relative">
              <span class="absolute left-3 top-1/2 -translate-y-1/2 text-secondary-500">Rp</span>
              <input
                v-model="form.saldo_tunai"
                type="number"
                step="0.01"
                min="0"
                class="input pl-12"
                placeholder="0"
              />
            </div>
            <p class="text-sm text-secondary-500 mt-1">{{ formatRupiah(form.saldo_tunai || 0) }}</p>
          </div>

          <!-- Total Saldo (Read-only) -->
          <div class="p-4 bg-primary-50 rounded-lg">
            <label class="label mb-2">Total Saldo</label>
            <p class="text-3xl font-bold text-primary-700">{{ formatRupiah(totalSaldo) }}</p>
          </div>

          <!-- Keterangan -->
          <div>
            <label class="label">Keterangan (Opsional)</label>
            <textarea
              v-model="form.keterangan"
              class="input"
              rows="3"
              placeholder="Catatan tambahan..."
            ></textarea>
          </div>

          <!-- Actions -->
          <div class="flex justify-end gap-3 pt-4 border-t border-secondary-200">
            <router-link to="/saldo-bendahara" class="btn-secondary">
              Batal
            </router-link>
            <button type="submit" :disabled="loading" class="btn-primary">
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
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '@/services/api'
import { useNotificationStore } from '@/stores/notification'

const route = useRoute()
const router = useRouter()
const notificationStore = useNotificationStore()

const isEdit = computed(() => !!route.params.id)
const loading = ref(false)

const form = ref({
  tanggal: '',
  saldo_bank: 0,
  saldo_tunai: 0,
  keterangan: ''
})

const totalSaldo = computed(() => {
  return (parseFloat(form.value.saldo_bank) || 0) + (parseFloat(form.value.saldo_tunai) || 0)
})

onMounted(() => {
  if (isEdit.value) {
    fetchSaldo()
  } else {
    // Set default tanggal to today
    const today = new Date().toISOString().split('T')[0]
    form.value.tanggal = today
  }
})

async function fetchSaldo() {
  loading.value = true
  try {
    const response = await api.get(`/saldo-bendahara/${route.params.id}`)
    const data = response.data.data
    form.value = {
      tanggal: data.tanggal.split('T')[0],
      saldo_bank: data.saldo_bank,
      saldo_tunai: data.saldo_tunai,
      keterangan: data.keterangan || ''
    }
  } catch (error) {
    notificationStore.error('Gagal memuat data saldo')
    router.push('/saldo-bendahara')
  } finally {
    loading.value = false
  }
}

async function handleSubmit() {
  loading.value = true
  try {
    const payload = {
      tanggal: form.value.tanggal,
      saldo_bank: parseFloat(form.value.saldo_bank),
      saldo_tunai: parseFloat(form.value.saldo_tunai),
      keterangan: form.value.keterangan
    }

    if (isEdit.value) {
      await api.put(`/saldo-bendahara/${route.params.id}`, payload)
      notificationStore.success('Saldo berhasil diupdate')
    } else {
      await api.post('/saldo-bendahara', payload)
      notificationStore.success('Saldo berhasil ditambahkan')
    }

    router.push('/saldo-bendahara')
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal menyimpan saldo')
  } finally {
    loading.value = false
  }
}

function formatRupiah(amount) {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    minimumFractionDigits: 0
  }).format(amount)
}
</script>
