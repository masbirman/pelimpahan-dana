<template>
  <div class="space-y-6 animate-fadeIn">
    <!-- Header -->
    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
      <div>
        <h1 class="text-2xl font-bold text-secondary-900">Jenis Pelimpahan</h1>
        <p class="text-secondary-500 text-sm md:text-base">Kelola data jenis pelimpahan</p>
      </div>
      <router-link to="/jenis-pelimpahan/create" class="btn-primary w-full md:w-auto justify-center text-sm">
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
        </svg>
        Tambah Jenis
      </router-link>
    </div>

    <!-- Mobile Card View -->
    <div class="md:hidden space-y-3">
      <div v-if="loading" class="text-center py-8 text-secondary-500 text-sm">Memuat data...</div>
      <div v-else-if="!jenisList.length" class="text-center py-8 text-secondary-500 text-sm">Tidak ada data jenis pelimpahan</div>
      <div v-else v-for="jenis in jenisList" :key="jenis.id" class="card p-4 shadow-sm border border-secondary-100 flex items-center justify-between">
        <div class="flex items-center gap-3">
          <span class="badge-info text-xs px-2 py-1">{{ jenis.kode_jenis }}</span>
          <span class="text-sm font-medium text-secondary-900">{{ jenis.nama_jenis }}</span>
        </div>
        <div class="flex items-center gap-2">
           <router-link :to="`/jenis-pelimpahan/${jenis.id}/edit`" class="p-1.5 text-primary-600 hover:bg-primary-50 rounded-md bg-primary-50/30">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" /></svg>
          </router-link>
          <button @click="confirmDelete(jenis)" class="p-1.5 text-red-600 hover:bg-red-50 rounded-md bg-red-50/30">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
          </button>
        </div>
      </div>
    </div>

    <!-- Desktop Table View -->
    <div class="card hidden md:block">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-secondary-50">
            <tr>
              <th class="px-6 py-4 table-header">Kode</th>
              <th class="px-6 py-4 table-header">Nama Jenis</th>
              <th class="px-6 py-4 table-header text-right">Aksi</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-secondary-200">
            <tr v-for="jenis in jenisList" :key="jenis.id" class="hover:bg-secondary-50 transition-colors">
              <td class="px-6 py-4">
                <span class="badge-info">{{ jenis.kode_jenis }}</span>
              </td>
              <td class="px-6 py-4 text-sm text-secondary-700">{{ jenis.nama_jenis }}</td>
              <td class="px-6 py-4 text-right">
                <div class="flex items-center justify-end gap-2">
                  <router-link
                    :to="`/jenis-pelimpahan/${jenis.id}/edit`"
                    class="p-2 text-primary-600 hover:bg-primary-50 rounded-lg transition-colors"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                    </svg>
                  </router-link>
                  <button
                    @click="confirmDelete(jenis)"
                    class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                </div>
              </td>
            </tr>
            <tr v-if="!jenisList.length && !loading">
              <td colspan="3" class="px-6 py-12 text-center text-secondary-500">
                Tidak ada data jenis pelimpahan
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
        <h3 class="text-lg font-semibold text-secondary-900 mb-2">Hapus Jenis Pelimpahan</h3>
        <p class="text-secondary-600 mb-6">
          Apakah Anda yakin ingin menghapus jenis <strong>{{ selectedJenis?.nama_jenis }}</strong>?
        </p>
        <div class="flex justify-end gap-3">
          <button @click="showDeleteModal = false" class="btn-secondary">Batal</button>
          <button @click="deleteJenis" class="btn-danger">Hapus</button>
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

const jenisList = ref([])
const loading = ref(false)
const showDeleteModal = ref(false)
const selectedJenis = ref(null)

onMounted(() => {
  loadJenis()
})

async function loadJenis() {
  loading.value = true
  try {
    const response = await api.get('/jenis-pelimpahan', { params: { per_page: 100 } })
    if (response.data.success) {
      jenisList.value = response.data.data
    }
  } catch (error) {
    notificationStore.error('Gagal memuat data jenis pelimpahan')
  } finally {
    loading.value = false
  }
}

function confirmDelete(jenis) {
  selectedJenis.value = jenis
  showDeleteModal.value = true
}

async function deleteJenis() {
  try {
    await api.delete(`/jenis-pelimpahan/${selectedJenis.value.id}`)
    notificationStore.success('Jenis pelimpahan berhasil dihapus')
    showDeleteModal.value = false
    loadJenis()
  } catch (error) {
    notificationStore.error('Gagal menghapus jenis pelimpahan')
  }
}
</script>
