<template>
  <div class="min-h-screen bg-gradient-to-br from-primary-50 via-white to-blue-50 flex items-center justify-center p-4">
    <div class="w-full max-w-6xl grid grid-cols-1 lg:grid-cols-2 gap-8 items-center">
      <!-- Left Side: Illustration -->
      <div class="hidden lg:flex items-center justify-center">
        <img 
          src="http://localhost:8000/uploads/login.webp" 
          alt="Login Illustration" 
          class="w-full max-w-lg object-contain"
        />
      </div>

      <!-- Right Side: Login Form -->
      <div class="w-full max-w-md mx-auto">
        <!-- Logo & Title -->
        <div class="text-center mb-8">
          <div class="inline-flex items-center justify-center w-24 h-24 mb-4">
            <img 
              src="http://localhost:8000/uploads/logo_20251218171038.png" 
              alt="Logo" 
              class="w-full h-full object-contain"
            />
          </div>
          <h1 class="text-3xl font-bold text-secondary-900 mb-2">{{ branding.app_name }}</h1>
          <p class="text-secondary-600">{{ branding.app_subtitle }}</p>
          <p class="text-sm text-secondary-500 mt-2">Silakan login untuk melanjutkan</p>
        </div>

        <!-- Login Form Card -->
        <div class="bg-white rounded-2xl shadow-xl border border-secondary-100 p-8">
          <form @submit.prevent="handleLogin" class="space-y-6">
            <!-- Error message -->
            <div v-if="error" class="p-4 bg-red-50 border border-red-200 rounded-lg">
              <p class="text-sm text-red-600">{{ error }}</p>
            </div>

            <!-- Email -->
            <div>
              <label for="email" class="label">Email</label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <svg class="w-5 h-5 text-secondary-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                  </svg>
                </div>
                <input
                  id="email"
                  v-model="form.email"
                  type="email"
                  class="input pl-10"
                  placeholder="email@example.com"
                  required
                  autocomplete="email"
                />
              </div>
            </div>

            <!-- Password -->
            <div>
              <label for="password" class="label">Password</label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <svg class="w-5 h-5 text-secondary-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                  </svg>
                </div>
                <input
                  id="password"
                  v-model="form.password"
                  :type="showPassword ? 'text' : 'password'"
                  class="input pl-10 pr-10"
                  placeholder="••••••••"
                  required
                  autocomplete="current-password"
                />
                <button
                  type="button"
                  @click="showPassword = !showPassword"
                  class="absolute inset-y-0 right-0 pr-3 flex items-center"
                >
                  <svg v-if="!showPassword" class="w-5 h-5 text-secondary-400 hover:text-secondary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                  </svg>
                  <svg v-else class="w-5 h-5 text-secondary-400 hover:text-secondary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />
                  </svg>
                </button>
              </div>
            </div>

            <!-- Submit -->
            <button
              type="submit"
              :disabled="authStore.loading"
              class="w-full btn-primary py-3 text-base"
            >
              <svg v-if="authStore.loading" class="animate-spin -ml-1 mr-2 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              {{ authStore.loading ? 'Memproses...' : 'Login' }}
            </button>
          </form>
        </div>

        <!-- Footer -->
        <p class="text-center text-sm text-secondary-500 mt-6">
          © 2025 {{ branding.app_name }}. All rights reserved.
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import api from '@/services/api'

const router = useRouter()
const authStore = useAuthStore()

const form = reactive({
  email: '',
  password: ''
})

const showPassword = ref(false)
const error = ref('')

const branding = ref({
  app_name: 'Pelimpahan',
  app_subtitle: 'Dana UP/GU',
  logo_url: ''
})

onMounted(async () => {
  try {
    const response = await api.get('/branding')
    if (response.data.success && response.data.data) {
      branding.value = {
        app_name: response.data.data.app_name || 'Pelimpahan',
        app_subtitle: response.data.data.app_subtitle || 'Dana UP/GU',
        logo_url: response.data.data.logo_url || ''
      }
    }
  } catch (error) {
    console.log('Using default branding')
  }
})

async function handleLogin() {
  error.value = ''
  const result = await authStore.login(form.email, form.password)
  
  if (result.success) {
    router.push('/')
  } else {
    error.value = result.message
  }
}
</script>
