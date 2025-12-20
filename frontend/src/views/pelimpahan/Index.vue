<template>
  <div class="space-y-6 animate-fadeIn">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-secondary-900">List Pelimpahan</h1>
        <p class="text-secondary-500">Daftar semua pelimpahan dana</p>
      </div>
      <div class="flex gap-3">
        <button @click="exportExcel" class="btn-secondary">
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
          Export Excel
        </button>
        <router-link to="/pelimpahan/create" class="btn-primary">
          <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
          </svg>
          Input Pelimpahan
        </router-link>
      </div>
    </div>

    <!-- Filters -->
    <div class="card">
      <div class="card-body flex flex-wrap gap-4">
        <div class="flex-1 min-w-[200px]">
          <input
            v-model="filters.search"
            type="text"
            class="input"
            placeholder="Cari uraian..."
            @input="debouncedSearch"
          />
        </div>
        <div class="w-40">
          <select v-model="filters.month" class="input" @change="loadData">
            <option value="">Semua Bulan</option>
            <option value="1">Januari</option>
            <option value="2">Februari</option>
            <option value="3">Maret</option>
            <option value="4">April</option>
            <option value="5">Mei</option>
            <option value="6">Juni</option>
            <option value="7">Juli</option>
            <option value="8">Agustus</option>
            <option value="9">September</option>
            <option value="10">Oktober</option>
            <option value="11">November</option>
            <option value="12">Desember</option>
          </select>
        </div>
        <div class="w-40">
          <select v-model="filters.sumber_dana" class="input" @change="loadData">
            <option value="">Semua Sumber</option>
            <option value="bank">Bank</option>
            <option value="tunai">Tunai</option>
          </select>
        </div>
        <div class="w-48">
          <select v-model="filters.jenis_pelimpahan_id" class="input" @change="loadData">
            <option value="">Semua Jenis</option>
            <option v-for="jenis in jenisList" :key="jenis.id" :value="jenis.id">
              {{ jenis.kode_jenis }} - {{ jenis.nama_jenis }}
            </option>
          </select>
        </div>
      </div>
    </div>

    <!-- Table -->
    <div class="card">
      <div class="overflow-x-auto">
        <table class="w-full">
          <thead class="bg-secondary-50">
            <tr>
              <th class="px-6 py-4 table-header">No</th>
              <th class="px-6 py-4 table-header">Jenis</th>
              <th class="px-6 py-4 table-header">Tanggal</th>
              <th class="px-6 py-4 table-header">Uraian</th>
              <th class="px-6 py-4 table-header">Penerima</th>
              <th class="px-6 py-4 table-header text-right">Total</th>
              <th class="px-6 py-4 table-header text-right">Pelimpahan Bank</th>
              <th class="px-6 py-4 table-header text-right">Pelimpahan Tunai</th>
              <th class="px-6 py-4 table-header text-right">Saldo Awal</th>
              <th class="px-6 py-4 table-header text-right">Sisa Saldo</th>
              <th class="px-6 py-4 table-header text-right">Aksi</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-secondary-200">
            <tr v-for="item in pelimpahanList" :key="item.id" class="hover:bg-secondary-50 transition-colors">
              <td class="px-6 py-4 text-sm font-medium text-secondary-900">
                {{ item.nomor_pelimpahan }}
              </td>
              <td class="px-6 py-4">
                <span class="badge-info">{{ item.jenis_pelimpahan?.kode_jenis }}</span>
              </td>
              <td class="px-6 py-4 text-sm text-secondary-700">
                {{ formatDate(item.tanggal_pelimpahan) }}
              </td>
              <td class="px-6 py-4 text-sm text-secondary-700 max-w-xs truncate">
                {{ item.uraian_pelimpahan || '-' }}
              </td>
              <td class="px-6 py-4 text-sm text-secondary-700">
                {{ item.details?.length || 0 }} penerima
              </td>
              <td class="px-6 py-4 text-sm font-semibold text-primary-600 text-right">
                {{ formatCurrency(item.total_jumlah) }}
              </td>
              <td class="px-6 py-4 text-sm font-semibold text-blue-600 text-right">
                {{ formatCurrency(item.saldo_bank) }}
              </td>
              <td class="px-6 py-4 text-sm font-semibold text-emerald-600 text-right">
                {{ formatCurrency(item.saldo_tunai) }}
              </td>
              <td class="px-6 py-4 text-sm font-semibold text-indigo-700 text-right">
                {{ formatCurrency(item.saldo_awal) }}
              </td>
              <td class="px-6 py-4 text-sm font-bold text-right" :class="item.sisa_saldo >= 0 ? 'text-emerald-700' : 'text-red-700'">
                {{ formatCurrency(item.sisa_saldo) }}
              </td>
              <td class="px-6 py-4 text-right">
                <div class="flex items-center justify-end gap-2">
                  <router-link
                    :to="`/pelimpahan/${item.id}`"
                    class="p-2 text-emerald-600 hover:bg-emerald-50 rounded-lg transition-colors"
                    title="Lihat Detail"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                    </svg>
                  </router-link>
                  <router-link
                    :to="`/pelimpahan/${item.id}/edit`"
                    class="p-2 text-primary-600 hover:bg-primary-50 rounded-lg transition-colors"
                    title="Edit"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                    </svg>
                  </router-link>
                  <button
                    @click="confirmDelete(item)"
                    class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                    title="Hapus"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                </div>
              </td>
            </tr>
            <tr v-if="!pelimpahanList.length && !loading">
              <td colspan="11" class="px-6 py-12 text-center text-secondary-500">
                Tidak ada data pelimpahan
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div v-if="meta.last_page > 1" class="px-6 py-4 border-t border-secondary-200 flex items-center justify-between">
        <p class="text-sm text-secondary-500">
          Menampilkan {{ (meta.page - 1) * meta.per_page + 1 }} - {{ Math.min(meta.page * meta.per_page, meta.total) }} dari {{ meta.total }} data
        </p>
        <div class="flex gap-2">
          <button @click="changePage(meta.page - 1)" :disabled="meta.page === 1" class="btn-secondary text-sm">
            Sebelumnya
          </button>
          <button @click="changePage(meta.page + 1)" :disabled="meta.page === meta.last_page" class="btn-secondary text-sm">
            Selanjutnya
          </button>
        </div>
      </div>
    </div>

    <!-- Delete Modal -->
    <div v-if="showDeleteModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-black/50" @click="showDeleteModal = false"></div>
      <div class="relative bg-white rounded-xl shadow-xl max-w-md w-full p-6 animate-fadeIn">
        <h3 class="text-lg font-semibold text-secondary-900 mb-2">Hapus Pelimpahan</h3>
        <p class="text-secondary-600 mb-6">
          Apakah Anda yakin ingin menghapus pelimpahan ke-<strong>{{ selectedItem?.nomor_pelimpahan }}</strong>?
        </p>
        <div class="flex justify-end gap-3">
          <button @click="showDeleteModal = false" class="btn-secondary">Batal</button>
          <button @click="deleteItem" class="btn-danger">Hapus</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import api from '@/services/api'
import { useNotificationStore } from '@/stores/notification'
import { useDebounceFn } from '@vueuse/core'

const notificationStore = useNotificationStore()

const pelimpahanList = ref([])
const jenisList = ref([])
const loading = ref(false)
const meta = ref({ page: 1, per_page: 10, total: 0, last_page: 1 })
const filters = reactive({ search: '', jenis_pelimpahan_id: '', month: '', sumber_dana: '' })
const showDeleteModal = ref(false)
const selectedItem = ref(null)

onMounted(async () => {
  await loadJenis()
  await loadData()
})

async function loadJenis() {
  try {
    const response = await api.get('/jenis-pelimpahan', { params: { per_page: 100 } })
    if (response.data.success) {
      jenisList.value = response.data.data
    }
  } catch (error) {
    console.error('Failed to load jenis:', error)
  }
}

async function loadData() {
  loading.value = true
  try {
    const response = await api.get('/pelimpahan', {
      params: {
        page: meta.value.page,
        per_page: meta.value.per_page,
        search: filters.search,
        jenis_pelimpahan_id: filters.jenis_pelimpahan_id,
        month: filters.month,
        sumber_dana: filters.sumber_dana
      }
    })
    if (response.data.success) {
      pelimpahanList.value = response.data.data
      meta.value = response.data.meta
    }
  } catch (error) {
    notificationStore.error('Gagal memuat data')
  } finally {
    loading.value = false
  }
}

const debouncedSearch = useDebounceFn(() => {
  meta.value.page = 1
  loadData()
}, 300)

function changePage(page) {
  meta.value.page = page
  loadData()
}

function confirmDelete(item) {
  selectedItem.value = item
  showDeleteModal.value = true
}

async function deleteItem() {
  try {
    await api.delete(`/pelimpahan/${selectedItem.value.id}`)
    notificationStore.success('Pelimpahan berhasil dihapus')
    showDeleteModal.value = false
    loadData()
  } catch (error) {
    notificationStore.error('Gagal menghapus pelimpahan')
  }
}

function exportExcel() {
  notificationStore.info('Fitur export sedang dalam pengembangan')
}

function formatCurrency(value) {
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(value || 0)
}

function formatDate(date) {
  if (!date) return '-'
  return new Date(date).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' })
}
</script>
