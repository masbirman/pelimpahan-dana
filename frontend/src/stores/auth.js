import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '@/services/api'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const token = ref(localStorage.getItem('token') || null)
  const selectedYear = ref(localStorage.getItem('selectedYear') || '2025')
  const loading = ref(false)

  const isAuthenticated = computed(() => !!token.value && !!user.value)

  const isSuperAdmin = computed(() => user.value?.role === 'super_admin')
  const isBendahara = computed(() => user.value?.role === 'bendahara')
  const isOperator = computed(() => user.value?.role === 'operator')

  async function login(username, password, tahunAnggaran = '2025', turnstileToken = '') {
    loading.value = true
    try {
      const payload = { 
        username, 
        password,
        tahun_anggaran: tahunAnggaran
      }
      
      // Add turnstile token if provided (for production)
      if (turnstileToken) {
        payload.turnstile_token = turnstileToken
      }
      
      const response = await api.post('/login', payload)
      if (response.data.success) {
        token.value = response.data.data.token
        user.value = response.data.data.user
        selectedYear.value = tahunAnggaran
        
        localStorage.setItem('token', token.value)
        localStorage.setItem('selectedYear', tahunAnggaran)
        api.defaults.headers.common['Authorization'] = `Bearer ${token.value}`
        
        return { success: true }
      }
      return { success: false, message: response.data.message }
    } catch (error) {
      return { 
        success: false, 
        message: error.response?.data?.message || 'Login failed' 
      }
    } finally {
      loading.value = false
    }
  }

  async function logout() {
    try {
      await api.post('/logout')
    } catch (error) {
      console.error('Logout error:', error)
    } finally {
      token.value = null
      user.value = null
      selectedYear.value = '2025'
      localStorage.removeItem('token')
      localStorage.removeItem('selectedYear')
      delete api.defaults.headers.common['Authorization']
    }
  }

  async function checkAuth() {
    if (!token.value) return

    api.defaults.headers.common['Authorization'] = `Bearer ${token.value}`
    
    try {
      const response = await api.get('/me')
      if (response.data.success) {
        user.value = response.data.data
      } else {
        // Only logout if it's an authentication issue
        if (response.status === 401) {
          logout()
        }
      }
    } catch (error) {
      // Only logout on 401 Unauthorized, not on network errors or 500
      if (error.response?.status === 401) {
        logout()
      } else {
        console.error('CheckAuth error (not logging out):', error.message)
      }
    }
  }

  function hasRole(role) {
    return user.value?.role === role
  }

  function hasAnyRole(roles) {
    return roles.includes(user.value?.role)
  }

  function setYear(year) {
    selectedYear.value = year
    localStorage.setItem('selectedYear', year)
  }

  return {
    user,
    token,
    selectedYear,
    loading,
    isAuthenticated,
    isSuperAdmin,
    isBendahara,
    isOperator,
    login,
    logout,
    checkAuth,
    hasRole,
    hasAnyRole,
    setYear
  }
})
