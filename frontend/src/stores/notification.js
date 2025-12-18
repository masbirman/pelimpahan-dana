import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useNotificationStore = defineStore('notification', () => {
  const notifications = ref([])

  function show(message, type = 'info', duration = 5000) {
    const id = Date.now()
    notifications.value.push({ id, message, type })
    
    if (duration > 0) {
      setTimeout(() => {
        remove(id)
      }, duration)
    }
  }

  function success(message, duration = 5000) {
    show(message, 'success', duration)
  }

  function error(message, duration = 5000) {
    show(message, 'error', duration)
  }

  function warning(message, duration = 5000) {
    show(message, 'warning', duration)
  }

  function info(message, duration = 5000) {
    show(message, 'info', duration)
  }

  function remove(id) {
    const index = notifications.value.findIndex(n => n.id === id)
    if (index !== -1) {
      notifications.value.splice(index, 1)
    }
  }

  return {
    notifications,
    show,
    success,
    error,
    warning,
    info,
    remove
  }
})
