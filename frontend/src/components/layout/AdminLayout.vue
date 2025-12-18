<template>
  <div class="flex h-screen bg-secondary-100">
    <!-- Sidebar -->
    <Sidebar :collapsed="sidebarCollapsed" />
    
    <!-- Main Content -->
    <div class="flex-1 flex flex-col overflow-hidden">
      <!-- Navbar -->
      <Navbar @toggle-sidebar="sidebarCollapsed = !sidebarCollapsed" />
      
      <!-- Page Content -->
      <main class="flex-1 overflow-y-auto p-6">
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </main>
    </div>

    <!-- Notifications -->
    <div class="fixed top-4 right-4 z-50 space-y-2">
      <TransitionGroup name="notification">
        <div
          v-for="notification in notificationStore.notifications"
          :key="notification.id"
          :class="[
            'p-4 rounded-lg shadow-lg max-w-sm animate-fadeIn',
            {
              'bg-emerald-500 text-white': notification.type === 'success',
              'bg-red-500 text-white': notification.type === 'error',
              'bg-amber-500 text-white': notification.type === 'warning',
              'bg-primary-500 text-white': notification.type === 'info'
            }
          ]"
        >
          <div class="flex items-center justify-between gap-4">
            <p class="text-sm font-medium">{{ notification.message }}</p>
            <button 
              @click="notificationStore.remove(notification.id)"
              class="hover:opacity-75"
            >
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </button>
          </div>
        </div>
      </TransitionGroup>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import Sidebar from './Sidebar.vue'
import Navbar from './Navbar.vue'
import { useNotificationStore } from '@/stores/notification'

const sidebarCollapsed = ref(false)
const notificationStore = useNotificationStore()
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.notification-enter-active {
  transition: all 0.3s ease-out;
}

.notification-leave-active {
  transition: all 0.2s ease-in;
}

.notification-enter-from {
  opacity: 0;
  transform: translateX(100%);
}

.notification-leave-to {
  opacity: 0;
  transform: translateX(100%);
}
</style>
