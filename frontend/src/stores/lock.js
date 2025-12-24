import { defineStore } from 'pinia'
import { ref } from 'vue'
import api from '@/services/api'

export const useLockStore = defineStore('lock', () => {
  const isLocked = ref(false)
  const lockInfo = ref({
    locked: false,
    tahun: '2025',
    locked_at: null,
    locked_reason: ''
  })
  const loading = ref(false)

  async function fetchLockStatus() {
    loading.value = true
    try {
      const response = await api.get('/settings/lock-status')
      if (response.data.success && response.data.data) {
        lockInfo.value = response.data.data
        isLocked.value = response.data.data.locked || false
      }
    } catch (error) {
      console.error('Error fetching lock status:', error)
    } finally {
      loading.value = false
    }
  }

  return {
    isLocked,
    lockInfo,
    loading,
    fetchLockStatus
  }
})
