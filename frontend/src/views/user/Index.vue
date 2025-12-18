<template>
  <div class="space-y-6 animate-fadeIn">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-secondary-900">Manajemen User</h1>
        <p class="text-secondary-500">Kelola pengguna sistem</p>
      </div>
      <router-link to="/users/create" class="btn-primary">
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
        </svg>
        Tambah User
      </router-link>
    </div>

    <!-- Table -->
    <div class="card">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-secondary-50">
            <tr>
              <th class="px-6 py-4 table-header">User</th>
              <th class="px-6 py-4 table-header">Email</th>
              <th class="px-6 py-4 table-header">Role</th>
              <th class="px-6 py-4 table-header">Status</th>
              <th class="px-6 py-4 table-header text-right">Aksi</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-secondary-200">
            <tr v-for="user in users" :key="user.id" class="hover:bg-secondary-50 transition-colors">
              <td class="px-6 py-4">
                <div class="flex items-center gap-3">
                  <div class="w-10 h-10 rounded-full bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center text-white font-semibold">
                    {{ user.name?.charAt(0).toUpperCase() }}
                  </div>
                  <span class="text-sm font-medium text-secondary-900">{{ user.name }}</span>
                </div>
              </td>
              <td class="px-6 py-4 text-sm text-secondary-700">{{ user.email }}</td>
              <td class="px-6 py-4">
                <span :class="getRoleBadgeClass(user.role)">{{ getRoleLabel(user.role) }}</span>
              </td>
              <td class="px-6 py-4">
                <span :class="user.is_active ? 'badge-success' : 'badge-danger'">
                  {{ user.is_active ? 'Aktif' : 'Nonaktif' }}
                </span>
              </td>
              <td class="px-6 py-4 text-right">
                <div class="flex items-center justify-end gap-2">
                  <router-link
                    :to="`/users/${user.id}/edit`"
                    class="p-2 text-primary-600 hover:bg-primary-50 rounded-lg transition-colors"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                    </svg>
                  </router-link>
                  <button
                    @click="confirmDelete(user)"
                    class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Delete Modal -->
    <div v-if="showDeleteModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-black/50" @click="showDeleteModal = false"></div>
      <div class="relative bg-white rounded-xl shadow-xl max-w-md w-full p-6 animate-fadeIn">
        <h3 class="text-lg font-semibold text-secondary-900 mb-2">Hapus User</h3>
        <p class="text-secondary-600 mb-6">
          Apakah Anda yakin ingin menghapus user <strong>{{ selectedUser?.name }}</strong>?
        </p>
        <div class="flex justify-end gap-3">
          <button @click="showDeleteModal = false" class="btn-secondary">Batal</button>
          <button @click="deleteUser" class="btn-danger">Hapus</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import { useNotificationStore } from '@/stores/notification'

const notificationStore = useNotificationStore()

const users = ref([])
const loading = ref(false)
const showDeleteModal = ref(false)
const selectedUser = ref(null)

onMounted(() => {
  loadUsers()
})

async function loadUsers() {
  loading.value = true
  try {
    const response = await api.get('/users', { params: { per_page: 100 } })
    if (response.data.success) {
      users.value = response.data.data
    }
  } catch (error) {
    notificationStore.error('Gagal memuat data user')
  } finally {
    loading.value = false
  }
}

function getRoleLabel(role) {
  const roles = { super_admin: 'Super Admin', bendahara: 'Bendahara', operator: 'Operator' }
  return roles[role] || role
}

function getRoleBadgeClass(role) {
  const classes = {
    super_admin: 'badge bg-purple-100 text-purple-700',
    bendahara: 'badge bg-emerald-100 text-emerald-700',
    operator: 'badge bg-blue-100 text-blue-700'
  }
  return classes[role] || 'badge bg-secondary-100 text-secondary-700'
}

function confirmDelete(user) {
  selectedUser.value = user
  showDeleteModal.value = true
}

async function deleteUser() {
  try {
    await api.delete(`/users/${selectedUser.value.id}`)
    notificationStore.success('User berhasil dihapus')
    showDeleteModal.value = false
    loadUsers()
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal menghapus user')
  }
}
</script>
