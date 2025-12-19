<template>
  <div class="max-w-2xl mx-auto space-y-6 animate-fadeIn">
    <div>
      <h1 class="text-2xl font-bold text-secondary-900">Edit Profil</h1>
      <p class="text-secondary-500">Kelola informasi profil Anda</p>
    </div>

    <div class="card">
      <div class="card-body space-y-6">
        <!-- Avatar Section -->
        <div class="flex items-center gap-6">
          <div class="relative">
            <div v-if="avatarUrl" class="w-24 h-24 rounded-full overflow-hidden bg-secondary-200">
              <img :src="avatarUrl" alt="Avatar" class="w-full h-full object-cover" />
            </div>
            <div v-else class="w-24 h-24 rounded-full bg-gradient-to-br from-primary-500 to-primary-600 flex items-center justify-center text-white text-3xl font-bold">
              {{ user.name?.charAt(0)?.toUpperCase() }}
            </div>
            <button
              @click="$refs.avatarInput.click()"
              class="absolute bottom-0 right-0 p-2 bg-primary-600 text-white rounded-full shadow-lg hover:bg-primary-700 transition-colors"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
            </button>
            <input ref="avatarInput" type="file" accept="image/*" class="hidden" @change="uploadAvatar" />
          </div>
          <div>
            <h3 class="font-semibold text-secondary-900">{{ user.name }}</h3>
            <p class="text-sm text-secondary-500">{{ user.email }}</p>
            <span class="badge-info mt-1 inline-block">{{ roleLabel }}</span>
          </div>
        </div>

        <hr class="border-secondary-200" />

        <!-- Profile Form -->
        <form @submit.prevent="updateProfile" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-secondary-700 mb-1">Nama Lengkap</label>
            <input v-model="form.name" type="text" class="input" placeholder="Nama lengkap" />
          </div>

          <div>
            <label class="block text-sm font-medium text-secondary-700 mb-1">Email</label>
            <input :value="user.email" type="email" class="input bg-secondary-50" disabled />
            <p class="text-xs text-secondary-500 mt-1">Email tidak dapat diubah</p>
          </div>

          <hr class="border-secondary-200" />

          <h4 class="font-medium text-secondary-900">Ubah Password</h4>

          <div>
            <label class="block text-sm font-medium text-secondary-700 mb-1">Password Lama</label>
            <input v-model="form.password" type="password" class="input" placeholder="Masukkan password lama" />
          </div>

          <div>
            <label class="block text-sm font-medium text-secondary-700 mb-1">Password Baru</label>
            <input v-model="form.new_password" type="password" class="input" placeholder="Masukkan password baru" />
          </div>

          <div>
            <label class="block text-sm font-medium text-secondary-700 mb-1">Konfirmasi Password Baru</label>
            <input v-model="form.confirm_password" type="password" class="input" placeholder="Konfirmasi password baru" />
          </div>

          <div class="flex justify-end gap-3 pt-4">
            <router-link to="/" class="btn-secondary">Batal</router-link>
            <button type="submit" :disabled="saving" class="btn-primary">
              {{ saving ? 'Menyimpan...' : 'Simpan Perubahan' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'
import { useAuthStore } from '@/stores/auth'
import { useNotificationStore } from '@/stores/notification'

const authStore = useAuthStore()
const notificationStore = useNotificationStore()

const user = ref({})
const saving = ref(false)
const form = ref({
  name: '',
  password: '',
  new_password: '',
  confirm_password: ''
})

const roleLabel = computed(() => {
  const roles = { super_admin: 'Super Admin', bendahara: 'Bendahara', operator: 'Operator' }
  return roles[user.value.role] || user.value.role
})

// API Base URL for images
const apiBaseUrl = import.meta.env.VITE_API_URL?.replace('/api', '') || 'http://localhost:8000'

// Helper to resolve image URLs (handles relative and absolute)
function resolveImageUrl(url) {
  if (!url) return ''
  if (url.startsWith('http')) return url
  return apiBaseUrl + url
}

// Computed avatar URL
const avatarUrl = computed(() => resolveImageUrl(user.value.avatar))

onMounted(async () => {
  try {
    const response = await api.get('/me')
    if (response.data.success) {
      user.value = response.data.data
      form.value.name = user.value.name
    }
  } catch (error) {
    notificationStore.error('Gagal memuat profil')
  }
})

async function updateProfile() {
  if (form.value.new_password && form.value.new_password !== form.value.confirm_password) {
    notificationStore.error('Konfirmasi password tidak cocok')
    return
  }

  saving.value = true
  try {
    const payload = { name: form.value.name }
    if (form.value.new_password) {
      payload.password = form.value.password
      payload.new_password = form.value.new_password
    }

    const response = await api.put('/profile', payload)
    if (response.data.success) {
      notificationStore.success('Profil berhasil diupdate')
      user.value = { ...user.value, ...response.data.data }
      authStore.user = { ...authStore.user, name: response.data.data.name }
      form.value.password = ''
      form.value.new_password = ''
      form.value.confirm_password = ''
    }
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal mengupdate profil')
  } finally {
    saving.value = false
  }
}

async function uploadAvatar(event) {
  const file = event.target.files[0]
  if (!file) return

  if (file.size > 2 * 1024 * 1024) {
    notificationStore.error('Ukuran file maksimal 2MB')
    return
  }

  try {
    const formData = new FormData()
    formData.append('avatar', file)
    const response = await api.post('/profile/avatar', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    if (response.data.success) {
      user.value.avatar = response.data.data.avatar
      authStore.user.avatar = response.data.data.avatar
      notificationStore.success('Avatar berhasil diupload')
    }
  } catch (error) {
    notificationStore.error('Gagal mengupload avatar')
  }
}
</script>
