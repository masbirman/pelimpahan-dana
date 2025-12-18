<template>
  <div class="space-y-6 animate-fadeIn">
    <!-- Header -->
    <div class="flex items-center gap-4">
      <router-link to="/units" class="p-2 rounded-lg hover:bg-secondary-100 transition-colors">
        <svg class="w-5 h-5 text-secondary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
        </svg>
      </router-link>
      <div>
        <h1 class="text-2xl font-bold text-secondary-900">{{ isEdit ? 'Edit Unit' : 'Tambah Unit' }}</h1>
        <p class="text-secondary-500">{{ isEdit ? 'Ubah data unit kerja' : 'Buat unit kerja baru' }}</p>
      </div>
    </div>

    <!-- Form -->
    <div class="card max-w-2xl">
      <form @submit.prevent="handleSubmit" class="card-body space-y-6">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label class="label">Kode Unit <span class="text-red-500">*</span></label>
            <input v-model="form.kode_unit" type="text" class="input" placeholder="001" required />
          </div>
          <div>
            <label class="label">Nama Unit <span class="text-red-500">*</span></label>
            <input v-model="form.nama_unit" type="text" class="input" placeholder="Dinas Pendidikan" required />
          </div>
        </div>

        <div>
          <label class="label">Nama Pimpinan</label>
          <input v-model="form.nama_pimpinan" type="text" class="input" placeholder="Kepala Dinas" />
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label class="label">Nama Bendahara <span class="text-red-500">*</span></label>
            <input v-model="form.nama_bendahara" type="text" class="input" placeholder="Bendahara Dinas" required />
          </div>
          <div>
            <label class="label">Nomor Rekening <span class="text-red-500">*</span></label>
            <input v-model="form.nomor_rekening" type="text" class="input" placeholder="1234567890" required />
          </div>
        </div>

        <div class="flex justify-end gap-3 pt-4 border-t border-secondary-200">
          <router-link to="/units" class="btn-secondary">Batal</router-link>
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
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import api from '@/services/api'
import { useNotificationStore } from '@/stores/notification'

const router = useRouter()
const route = useRoute()
const notificationStore = useNotificationStore()

const loading = ref(false)
const isEdit = computed(() => !!route.params.id)

const form = reactive({
  kode_unit: '',
  nama_unit: '',
  nama_pimpinan: '',
  nama_bendahara: '',
  nomor_rekening: ''
})

onMounted(async () => {
  if (isEdit.value) {
    try {
      const response = await api.get(`/units/${route.params.id}`)
      if (response.data.success) {
        Object.assign(form, response.data.data)
      }
    } catch (error) {
      notificationStore.error('Gagal memuat data unit')
      router.push('/units')
    }
  }
})

async function handleSubmit() {
  loading.value = true
  try {
    if (isEdit.value) {
      await api.put(`/units/${route.params.id}`, form)
      notificationStore.success('Unit berhasil diupdate')
    } else {
      await api.post('/units', form)
      notificationStore.success('Unit berhasil dibuat')
    }
    router.push('/units')
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal menyimpan unit')
  } finally {
    loading.value = false
  }
}
</script>
