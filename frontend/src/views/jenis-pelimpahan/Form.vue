<template>
  <div class="space-y-6 animate-fadeIn">
    <!-- Header -->
    <div class="flex items-center gap-4">
      <router-link to="/jenis-pelimpahan" class="p-2 rounded-lg hover:bg-secondary-100 transition-colors">
        <svg class="w-5 h-5 text-secondary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
        </svg>
      </router-link>
      <div>
        <h1 class="text-2xl font-bold text-secondary-900">{{ isEdit ? 'Edit Jenis' : 'Tambah Jenis' }}</h1>
        <p class="text-secondary-500">{{ isEdit ? 'Ubah data jenis pelimpahan' : 'Buat jenis pelimpahan baru' }}</p>
      </div>
    </div>

    <!-- Form -->
    <div class="card max-w-lg">
      <form @submit.prevent="handleSubmit" class="card-body space-y-6">
        <div>
          <label class="label">Kode Jenis <span class="text-red-500">*</span></label>
          <input v-model="form.kode_jenis" type="text" class="input" placeholder="UP" required />
        </div>

        <div>
          <label class="label">Nama Jenis <span class="text-red-500">*</span></label>
          <input v-model="form.nama_jenis" type="text" class="input" placeholder="Uang Persediaan" required />
        </div>

        <div class="flex justify-end gap-3 pt-4 border-t border-secondary-200">
          <router-link to="/jenis-pelimpahan" class="btn-secondary">Batal</router-link>
          <button type="submit" class="btn-primary" :disabled="loading">
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
  kode_jenis: '',
  nama_jenis: ''
})

onMounted(async () => {
  if (isEdit.value) {
    try {
      const response = await api.get(`/jenis-pelimpahan/${route.params.id}`)
      if (response.data.success) {
        Object.assign(form, response.data.data)
      }
    } catch (error) {
      notificationStore.error('Gagal memuat data')
      router.push('/jenis-pelimpahan')
    }
  }
})

async function handleSubmit() {
  loading.value = true
  try {
    if (isEdit.value) {
      await api.put(`/jenis-pelimpahan/${route.params.id}`, form)
      notificationStore.success('Jenis pelimpahan berhasil diupdate')
    } else {
      await api.post('/jenis-pelimpahan', form)
      notificationStore.success('Jenis pelimpahan berhasil dibuat')
    }
    router.push('/jenis-pelimpahan')
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal menyimpan')
  } finally {
    loading.value = false
  }
}
</script>
