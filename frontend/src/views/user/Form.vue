<template>
  <div class="space-y-6 animate-fadeIn">
    <!-- Header -->
    <div class="flex items-center gap-4">
      <router-link to="/users" class="p-2 rounded-lg hover:bg-secondary-100 transition-colors">
        <svg class="w-5 h-5 text-secondary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
        </svg>
      </router-link>
      <div>
        <h1 class="text-2xl font-bold text-secondary-900">{{ isEdit ? 'Edit User' : 'Tambah User' }}</h1>
        <p class="text-secondary-500">{{ isEdit ? 'Ubah data pengguna' : 'Buat pengguna baru' }}</p>
      </div>
    </div>

    <!-- Form -->
    <div class="card max-w-xl">
      <form @submit.prevent="handleSubmit" class="card-body space-y-6">
        <div>
          <label class="label">Nama <span class="text-red-500">*</span></label>
          <input v-model="form.name" type="text" class="input" placeholder="Nama lengkap" required />
        </div>

        <div>
          <label class="label">Username <span class="text-red-500">*</span></label>
          <input v-model="form.username" type="text" class="input" placeholder="username" required />
        </div>

        <div>
          <label class="label">Password {{ isEdit ? '' : '*' }}</label>
          <input
            v-model="form.password"
            type="password"
            class="input"
            :placeholder="isEdit ? 'Kosongkan jika tidak ingin mengubah' : 'Minimal 6 karakter'"
            :required="!isEdit"
            minlength="6"
          />
        </div>

        <div>
          <label class="label">Role <span class="text-red-500">*</span></label>
          <select v-model="form.role" class="input" required>
            <option value="">Pilih Role</option>
            <option value="super_admin">Super Admin</option>
            <option value="bendahara">Bendahara</option>
            <option value="operator">Operator</option>
          </select>
        </div>

        <div class="flex items-center gap-3">
          <input
            v-model="form.is_active"
            type="checkbox"
            id="is_active"
            class="w-4 h-4 text-primary-600 rounded border-secondary-300 focus:ring-primary-500"
          />
          <label for="is_active" class="text-sm text-secondary-700">Aktifkan user ini</label>
        </div>

        <div class="flex justify-end gap-3 pt-4 border-t border-secondary-200">
          <router-link to="/users" class="btn-secondary">Batal</router-link>
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
  name: '',
  username: '',
  password: '',
  role: '',
  is_active: true
})

onMounted(async () => {
  if (isEdit.value) {
    try {
      const response = await api.get(`/users/${route.params.id}`)
      if (response.data.success) {
        const data = response.data.data
        form.name = data.name
        form.username = data.username
        form.role = data.role
        form.is_active = data.is_active
      }
    } catch (error) {
      notificationStore.error('Gagal memuat data')
      router.push('/users')
    }
  }
})

async function handleSubmit() {
  loading.value = true
  try {
    const payload = { ...form }
    if (isEdit.value && !payload.password) {
      delete payload.password
    }

    if (isEdit.value) {
      await api.put(`/users/${route.params.id}`, payload)
      notificationStore.success('User berhasil diupdate')
    } else {
      await api.post('/users', payload)
      notificationStore.success('User berhasil dibuat')
    }
    router.push('/users')
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal menyimpan')
  } finally {
    loading.value = false
  }
}
</script>
