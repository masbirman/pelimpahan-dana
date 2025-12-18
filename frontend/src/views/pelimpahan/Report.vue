<template>
  <div class="space-y-6 animate-fadeIn">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div class="flex items-center gap-4">
        <router-link to="/pelimpahan" class="p-2 rounded-lg hover:bg-secondary-100 transition-colors">
          <svg class="w-5 h-5 text-secondary-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
        </router-link>
        <div>
          <h1 class="text-2xl font-bold text-secondary-900">Laporan Pelimpahan</h1>
          <p class="text-secondary-500">Detail pelimpahan ke-{{ pelimpahan?.nomor_pelimpahan }}</p>
        </div>
      </div>
      <button @click="printReport" class="btn-primary">
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
        </svg>
        Cetak
      </button>
    </div>

    <!-- Report Content -->
    <div id="report-content" class="card">
      <div class="card-body space-y-6">
        <!-- Header Info -->
        <div class="text-center border-b border-secondary-200 pb-6">
          <h2 class="text-xl font-bold text-secondary-900">LAPORAN PELIMPAHAN DANA</h2>
          <p class="text-secondary-600">{{ pelimpahan?.jenis_pelimpahan?.nama_jenis }}</p>
        </div>

        <!-- Info Grid -->
        <div class="grid grid-cols-2 gap-4 text-sm">
          <div class="space-y-2">
            <div class="flex">
              <span class="w-40 text-secondary-500">Pelimpahan Ke</span>
              <span class="font-medium text-secondary-900">: {{ pelimpahan?.nomor_pelimpahan }}</span>
            </div>
            <div class="flex">
              <span class="w-40 text-secondary-500">Jenis Pelimpahan</span>
              <span class="font-medium text-secondary-900">: {{ pelimpahan?.jenis_pelimpahan?.kode_jenis }} - {{ pelimpahan?.jenis_pelimpahan?.nama_jenis }}</span>
            </div>
            <div class="flex">
              <span class="w-40 text-secondary-500">Tanggal Pelimpahan</span>
              <span class="font-medium text-secondary-900">: {{ formatDate(pelimpahan?.tanggal_pelimpahan) }}</span>
            </div>
          </div>
          <div class="space-y-2">
            <div class="flex">
              <span class="w-40 text-secondary-500">Waktu Input</span>
              <span class="font-medium text-secondary-900">: {{ formatDateTime(pelimpahan?.waktu_pelimpahan) }}</span>
            </div>
            <div class="flex">
              <span class="w-40 text-secondary-500">Dibuat Oleh</span>
              <span class="font-medium text-secondary-900">: {{ pelimpahan?.creator?.name }}</span>
            </div>
            <div class="flex">
              <span class="w-40 text-secondary-500">Uraian</span>
              <span class="font-medium text-secondary-900">: {{ pelimpahan?.uraian_pelimpahan || '-' }}</span>
            </div>
          </div>
        </div>

        <!-- Details Table -->
        <div class="border border-secondary-200 rounded-lg overflow-hidden">
          <table class="w-full">
            <thead class="bg-secondary-100">
              <tr>
                <th class="px-4 py-3 text-left text-xs font-semibold text-secondary-700 uppercase">No</th>
                <th class="px-4 py-3 text-left text-xs font-semibold text-secondary-700 uppercase">Unit Kerja</th>
                <th class="px-4 py-3 text-left text-xs font-semibold text-secondary-700 uppercase">Nama Penerima</th>
                <th class="px-4 py-3 text-left text-xs font-semibold text-secondary-700 uppercase">No. Rekening</th>
                <th class="px-4 py-3 text-right text-xs font-semibold text-secondary-700 uppercase">Jumlah</th>
                <th class="px-4 py-3 text-center text-xs font-semibold text-secondary-700 uppercase">Sumber Dana</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-secondary-200">
              <tr v-for="(detail, index) in pelimpahan?.details" :key="detail.id">
                <td class="px-4 py-3 text-sm text-secondary-700">{{ index + 1 }}</td>
                <td class="px-4 py-3 text-sm text-secondary-700">{{ detail.unit?.nama_unit }}</td>
                <td class="px-4 py-3 text-sm text-secondary-700">{{ detail.nama_penerima }}</td>
                <td class="px-4 py-3 text-sm text-secondary-700">{{ detail.nomor_rekening }}</td>
                <td class="px-4 py-3 text-sm text-secondary-900 font-medium text-right">{{ formatCurrency(detail.jumlah) }}</td>
                <td class="px-4 py-3 text-sm text-center">
                  <span v-if="detail.sumber_dana === 'bank'" class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                    💳 Bank
                  </span>
                  <span v-else class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-emerald-100 text-emerald-800">
                    💵 Tunai
                  </span>
                </td>
              </tr>
            </tbody>
            <tfoot class="bg-secondary-50">
              <tr>
                <td colspan="4" class="px-4 py-3 text-sm font-semibold text-secondary-900 text-right">TOTAL</td>
                <td class="px-4 py-3 text-lg font-bold text-primary-600 text-right">{{ formatCurrency(pelimpahan?.total_jumlah) }}</td>
                <td></td>
              </tr>
            </tfoot>
          </table>
        </div>

        <!-- Terbilang -->
        <div class="bg-primary-50 rounded-lg p-4">
          <p class="text-sm text-primary-700">
            <span class="font-medium">Terbilang:</span> {{ terbilang(pelimpahan?.total_jumlah) }} Rupiah
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '@/services/api'
import { useNotificationStore } from '@/stores/notification'

const route = useRoute()
const router = useRouter()
const notificationStore = useNotificationStore()

const pelimpahan = ref(null)

onMounted(async () => {
  try {
    const response = await api.get(`/pelimpahan/${route.params.id}`)
    if (response.data.success) {
      pelimpahan.value = response.data.data
    }
  } catch (error) {
    notificationStore.error('Gagal memuat data')
    router.push('/pelimpahan')
  }
})

function formatCurrency(value) {
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(value || 0)
}

function formatDate(date) {
  if (!date) return '-'
  return new Date(date).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })
}

function formatDateTime(date) {
  if (!date) return '-'
  return new Date(date).toLocaleString('id-ID', {
    timeZone: 'Asia/Makassar',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }) + ' WITA'
}

function terbilang(angka) {
  if (!angka) return 'Nol'
  
  const satuan = ['', 'Satu', 'Dua', 'Tiga', 'Empat', 'Lima', 'Enam', 'Tujuh', 'Delapan', 'Sembilan', 'Sepuluh', 'Sebelas']
  
  if (angka < 12) return satuan[angka]
  if (angka < 20) return satuan[angka - 10] + ' Belas'
  if (angka < 100) return satuan[Math.floor(angka / 10)] + ' Puluh ' + satuan[angka % 10]
  if (angka < 200) return 'Seratus ' + terbilang(angka - 100)
  if (angka < 1000) return satuan[Math.floor(angka / 100)] + ' Ratus ' + terbilang(angka % 100)
  if (angka < 2000) return 'Seribu ' + terbilang(angka - 1000)
  if (angka < 1000000) return terbilang(Math.floor(angka / 1000)) + ' Ribu ' + terbilang(angka % 1000)
  if (angka < 1000000000) return terbilang(Math.floor(angka / 1000000)) + ' Juta ' + terbilang(angka % 1000000)
  if (angka < 1000000000000) return terbilang(Math.floor(angka / 1000000000)) + ' Miliar ' + terbilang(angka % 1000000000)
  return terbilang(Math.floor(angka / 1000000000000)) + ' Triliun ' + terbilang(angka % 1000000000000)
}

function printReport() {
  window.print()
}
</script>

<style>
@media print {
  body * {
    visibility: hidden;
  }
  #report-content, #report-content * {
    visibility: visible;
  }
  #report-content {
    position: absolute;
    left: 0;
    top: 0;
    width: 100%;
  }
}
</style>
