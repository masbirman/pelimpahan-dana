<template>
  <div class="min-h-screen bg-white">
    <!-- Print Button -->
    <div class="print:hidden fixed top-4 right-4 flex gap-2 z-50">
      <button @click="printReport" class="btn-primary">
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
        </svg>
        Cetak / Save PDF
      </button>
      <router-link to="/laporan" class="btn-secondary">Kembali</router-link>
    </div>

    <!-- Report Content -->
    <div id="report-content" class="max-w-4xl mx-auto p-8">
      <!-- Kop Surat -->
      <div v-if="reportHeader.header.instansi" class="mb-6">
        <div class="flex items-center gap-4 pb-3">
          <div class="w-16 h-16 flex-shrink-0">
            <img v-if="reportLogoUrl" :src="reportLogoUrl" class="w-full h-full object-contain" />
          </div>
          <div class="text-center flex-1">
            <p class="text-xs font-medium text-gray-600 uppercase">{{ reportHeader.header.instansi }}</p>
            <p class="text-xl font-bold text-gray-900">{{ reportHeader.header.dinas }}</p>
            <p class="text-xs text-gray-500">{{ reportHeader.header.alamat }}</p>
          </div>
        </div>
        <hr class="border-t-2 border-gray-900" />
        <hr class="border-t border-gray-900 mt-1" />
      </div>

      <!-- Judul -->
      <div class="text-center mb-6 pt-4">
        <h1 class="text-xl font-bold text-gray-900 uppercase">Laporan Setor ke Kas BUD</h1>
        <p class="text-gray-600 mt-1">Tahun Anggaran {{ selectedYear }}</p>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="text-center py-12">
        <p class="text-gray-500">Memuat data...</p>
      </div>

      <!-- Table -->
      <div v-else-if="setorList.length > 0" class="border border-gray-300 rounded overflow-hidden">
        <table class="w-full text-xs">
          <thead class="bg-gray-100">
            <tr>
              <th class="px-2 py-2 text-left font-semibold text-gray-700 border-b">No</th>
              <th class="px-2 py-2 text-left font-semibold text-gray-700 border-b">Tanggal</th>
              <th class="px-2 py-2 text-right font-semibold text-gray-700 border-b">Jumlah</th>
              <th class="px-2 py-2 text-left font-semibold text-gray-700 border-b">Uraian</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <tr v-for="(item, index) in setorList" :key="item.id">
              <td class="px-2 py-1 text-gray-700">{{ index + 1 }}</td>
              <td class="px-2 py-1 text-gray-700 whitespace-nowrap">{{ formatDate(item.tanggal) }}</td>
              <td class="px-2 py-1 text-red-700 font-medium text-right whitespace-nowrap">{{ formatCurrencyShort(item.jumlah) }}</td>
              <td class="px-2 py-1 text-gray-700">{{ item.keterangan }}</td>
            </tr>
          </tbody>
          <tfoot class="bg-gray-50">
            <tr class="font-bold text-xs">
              <td colspan="2" class="px-2 py-2 text-right text-gray-900">TOTAL</td>
              <td class="px-2 py-2 text-right text-red-700 whitespace-nowrap">{{ formatCurrencyShort(grandTotal) }}</td>
              <td></td>
            </tr>
          </tfoot>
        </table>
      </div>

      <div v-else class="text-center py-12 text-gray-500">
        Belum ada data setor ke Kas BUD
      </div>

      <!-- Summary & Signature -->
      <div v-if="setorList.length > 0">
        <div class="bg-red-50 border border-red-300 rounded p-4 mt-4 text-center">
          <p class="text-sm text-red-600 font-medium">Total Setor ke Kas BUD</p>
          <p class="text-2xl font-bold text-red-700">{{ formatCurrency(grandTotal) }}</p>
          <p class="text-xs text-red-600 mt-1">Terbilang: {{ terbilang(grandTotal) }} Rupiah</p>
        </div>

        <div v-if="reportHeader.signatory_left?.nama" class="mt-12 pt-8">
          <div class="grid grid-cols-2 gap-8 text-center text-sm">
            <div>
              <p class="text-gray-700">{{ reportHeader.signatory_left.jabatan }}</p>
              <div class="h-20"></div>
              <p class="font-bold text-gray-900 underline">{{ reportHeader.signatory_left.nama }}</p>
              <p class="text-gray-600 text-xs">NIP. {{ reportHeader.signatory_left.nip }}</p>
            </div>
            <div>
              <p class="text-gray-700">{{ reportHeader.signatory_right.jabatan }}</p>
              <div class="h-20"></div>
              <p class="font-bold text-gray-900 underline">{{ reportHeader.signatory_right.nama }}</p>
              <p class="text-gray-600 text-xs">NIP. {{ reportHeader.signatory_right.nip }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'

const setorList = ref([])
const selectedYear = ref(new Date().getFullYear())
const loading = ref(false)
const reportHeader = ref({
  header: { logo_url: '', instansi: '', dinas: '', alamat: '' },
  signatory_left: { jabatan: '', nama: '', nip: '' },
  signatory_right: { jabatan: '', nama: '', nip: '' }
})

const apiBaseUrl = import.meta.env.VITE_API_URL?.replace('/api', '') || 'http://localhost:8000'
const reportLogoUrl = computed(() => {
  const url = reportHeader.value.header.logo_url
  if (!url) return ''
  if (url.startsWith('http')) return url
  return apiBaseUrl + url
})

const grandTotal = computed(() => setorList.value.reduce((sum, item) => sum + (item.jumlah || 0), 0))

onMounted(async () => {
  await loadReportHeader()
  await loadData()
})

async function loadReportHeader() {
  try {
    const response = await api.get('/settings/report-header')
    if (response.data.success && response.data.data) {
      reportHeader.value = response.data.data
    }
  } catch (error) {
    console.error('Failed to load report header:', error)
  }
}

async function loadData() {
  loading.value = true
  try {
    const response = await api.get('/setor-kas-bud', { params: { per_page: 1000 } })
    if (response.data.success) {
      setorList.value = response.data.data || []
    }
  } catch (error) {
    console.error('Failed to load data:', error)
  } finally {
    loading.value = false
  }
}

function formatCurrency(value) {
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(value || 0)
}

function formatCurrencyShort(value) {
  return 'Rp ' + new Intl.NumberFormat('id-ID', { minimumFractionDigits: 0 }).format(value || 0)
}

function formatDate(date) {
  if (!date) return '-'
  return new Date(date).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' })
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
  return terbilang(Math.floor(angka / 1000000000)) + ' Miliar ' + terbilang(angka % 1000000000)
}

function printReport() {
  window.print()
}
</script>

<style>
@media print {
  body * { visibility: hidden; }
  #report-content, #report-content * { visibility: visible; }
  #report-content { position: absolute; left: 0; top: 0; width: 100%; padding: 15px; }
  .print\:hidden { display: none !important; }
  @page { size: A4; margin: 10mm; }
}
</style>
