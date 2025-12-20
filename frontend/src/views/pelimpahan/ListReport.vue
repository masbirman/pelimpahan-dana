<template>
  <div class="min-h-screen bg-white">
    <!-- Print Button (hidden on print) -->
    <div class="print:hidden fixed top-4 right-4 flex gap-2 z-50">
      <button @click="printReport" class="btn-primary">
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
        </svg>
        Cetak / Save PDF
      </button>
      <router-link to="/pelimpahan" class="btn-secondary">
        Kembali
      </router-link>
    </div>

    <!-- Report Content -->
    <div id="report-content" class="max-w-4xl mx-auto p-8">
      <!-- Kop Surat -->
      <div v-if="reportHeader.header.instansi" class="print-header mb-6">
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

      <!-- Judul Laporan -->
      <div class="text-center mb-6 pt-4">
        <h1 class="text-xl font-bold text-gray-900 uppercase">Laporan Pelimpahan Dana</h1>
        <p class="text-gray-600 mt-1">{{ filterDescription }}</p>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="text-center py-12">
        <p class="text-gray-500">Memuat data...</p>
      </div>

      <!-- Table -->
      <div v-else class="border border-gray-300 rounded overflow-hidden">
        <table class="w-full text-xs">
          <thead class="bg-gray-100">
            <tr>
              <th class="px-2 py-2 text-left font-semibold text-gray-700 border-b">No</th>
              <th class="px-2 py-2 text-left font-semibold text-gray-700 border-b">Jenis</th>
              <th class="px-2 py-2 text-left font-semibold text-gray-700 border-b">Tanggal</th>
              <th class="px-2 py-2 text-left font-semibold text-gray-700 border-b">Uraian</th>
              <th class="px-2 py-2 text-right font-semibold text-gray-700 border-b">Bank</th>
              <th class="px-2 py-2 text-right font-semibold text-gray-700 border-b">Tunai</th>
              <th class="px-2 py-2 text-right font-semibold text-gray-700 border-b">Total</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <tr v-for="(item, index) in pelimpahanList" :key="item.id">
              <td class="px-2 py-1 text-gray-700">{{ index + 1 }}</td>
              <td class="px-2 py-1 text-gray-700">{{ item.jenis_pelimpahan?.kode_jenis }}</td>
              <td class="px-2 py-1 text-gray-700 whitespace-nowrap">{{ formatDate(item.tanggal_pelimpahan) }}</td>
              <td class="px-2 py-1 text-gray-700">{{ truncateText(item.uraian_pelimpahan, 35) }}</td>
              <td class="px-2 py-1 text-blue-700 font-medium text-right whitespace-nowrap">{{ formatCurrencyShort(item.saldo_bank) }}</td>
              <td class="px-2 py-1 text-emerald-700 font-medium text-right whitespace-nowrap">{{ formatCurrencyShort(item.saldo_tunai) }}</td>
              <td class="px-2 py-1 text-gray-900 font-semibold text-right whitespace-nowrap">{{ formatCurrencyShort(item.total_jumlah) }}</td>
            </tr>
            <tr v-if="!pelimpahanList.length">
              <td colspan="7" class="px-2 py-6 text-center text-gray-500">Tidak ada data</td>
            </tr>
          </tbody>
          <tfoot class="bg-gray-50">
            <tr class="font-bold text-xs">
              <td colspan="4" class="px-2 py-2 text-right text-gray-900">TOTAL</td>
              <td class="px-2 py-2 text-right text-blue-700 whitespace-nowrap">{{ formatCurrencyShort(totalBank) }}</td>
              <td class="px-2 py-2 text-right text-emerald-700 whitespace-nowrap">{{ formatCurrencyShort(totalTunai) }}</td>
              <td class="px-2 py-2 text-right text-gray-900 whitespace-nowrap">{{ formatCurrencyShort(grandTotal) }}</td>
            </tr>
          </tfoot>
        </table>
      </div>

      <!-- Ringkasan Total Bank & Tunai -->
      <div class="grid grid-cols-2 gap-3 mt-4">
        <div class="bg-blue-50 border border-blue-200 rounded p-3 text-center">
          <p class="text-xs text-blue-600 font-medium">Total Pelimpahan Bank</p>
          <p class="text-lg font-bold text-blue-700">{{ formatCurrency(totalBank) }}</p>
        </div>
        <div class="bg-emerald-50 border border-emerald-200 rounded p-3 text-center">
          <p class="text-xs text-emerald-600 font-medium">Total Pelimpahan Tunai</p>
          <p class="text-lg font-bold text-emerald-700">{{ formatCurrency(totalTunai) }}</p>
        </div>
      </div>

      <!-- Total Pelimpahan (Gabungan) -->
      <div class="bg-indigo-50 border border-indigo-300 rounded p-4 mt-3 text-center">
        <p class="text-sm text-indigo-600 font-medium">Total Pelimpahan</p>
        <p class="text-2xl font-bold text-indigo-700">{{ formatCurrency(grandTotal) }}</p>
        <p class="text-xs text-indigo-600 mt-1">Terbilang: {{ terbilang(grandTotal) }} Rupiah</p>
      </div>

      <!-- Sisa Saldo -->
      <div class="bg-blue-50 border border-blue-200 rounded p-3 mt-2 text-sm">
        <span class="font-medium">Sisa Saldo:</span> <span class="font-bold text-blue-700">{{ formatCurrency(sisaSaldo) }}</span>
      </div>

      <!-- Tanda Tangan -->
      <div v-if="reportHeader.signatory_left.nama || reportHeader.signatory_right.nama" class="mt-12 pt-8">
        <div class="grid grid-cols-2 gap-8 text-center text-sm">
          <div>
            <p class="text-gray-700">{{ reportHeader.signatory_left.jabatan }}</p>
            <div class="h-20"></div>
            <p class="font-bold text-gray-900 underline">{{ reportHeader.signatory_left.nama }}</p>
            <p class="text-gray-600 text-xs">{{ reportHeader.signatory_left.nip }}</p>
          </div>
          <div>
            <p class="text-gray-700">{{ reportHeader.signatory_right.jabatan }}</p>
            <div class="h-20"></div>
            <p class="font-bold text-gray-900 underline">{{ reportHeader.signatory_right.nama }}</p>
            <p class="text-gray-600 text-xs">{{ reportHeader.signatory_right.nip }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import api from '@/services/api'

const route = useRoute()
const pelimpahanList = ref([])
const loading = ref(true)
const reportHeader = ref({
  header: { logo_url: '', instansi: '', dinas: '', alamat: '' },
  signatory_left: { jabatan: '', nama: '', nip: '' },
  signatory_right: { jabatan: '', nama: '', nip: '' }
})

const monthNames = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember']

const apiBaseUrl = import.meta.env.VITE_API_URL?.replace('/api', '') || 'http://localhost:8000'
const reportLogoUrl = computed(() => {
  const url = reportHeader.value.header.logo_url
  if (!url) return ''
  if (url.startsWith('http')) return url
  return apiBaseUrl + url
})

const totalBank = computed(() => pelimpahanList.value.reduce((sum, item) => sum + (item.saldo_bank || 0), 0))
const totalTunai = computed(() => pelimpahanList.value.reduce((sum, item) => sum + (item.saldo_tunai || 0), 0))
const grandTotal = computed(() => pelimpahanList.value.reduce((sum, item) => sum + (item.total_jumlah || 0), 0))

// Sisa saldo from the last item in the filtered list
const sisaSaldo = computed(() => {
  if (pelimpahanList.value.length === 0) return 0
  // Get the item with the highest nomor_pelimpahan (last transaction)
  const lastItem = pelimpahanList.value.reduce((max, item) => 
    (item.nomor_pelimpahan > max.nomor_pelimpahan) ? item : max, pelimpahanList.value[0])
  return lastItem?.sisa_saldo || 0
})

const filterDescription = computed(() => {
  const parts = []
  if (route.query.month) {
    parts.push(`Bulan ${monthNames[parseInt(route.query.month)]}`)
  }
  if (route.query.sumber_dana) {
    parts.push(`Sumber: ${route.query.sumber_dana === 'bank' ? 'Bank' : 'Tunai'}`)
  }
  if (route.query.jenis_pelimpahan_id) {
    parts.push(`Jenis ID: ${route.query.jenis_pelimpahan_id}`)
  }
  return parts.length > 0 ? parts.join(' | ') : 'Semua Data'
})

onMounted(async () => {
  try {
    // Load pelimpahan data with filters
    const response = await api.get('/pelimpahan', {
      params: {
        per_page: 1000, // Get all for print
        month: route.query.month || '',
        sumber_dana: route.query.sumber_dana || '',
        jenis_pelimpahan_id: route.query.jenis_pelimpahan_id || ''
      }
    })
    if (response.data.success) {
      pelimpahanList.value = response.data.data || []
    }

    // Load report header settings
    const headerResponse = await api.get('/settings/report-header')
    if (headerResponse.data.success && headerResponse.data.data) {
      const data = headerResponse.data.data
      reportHeader.value = {
        header: {
          logo_url: data.header?.logo_url || '',
          instansi: data.header?.instansi || '',
          dinas: data.header?.dinas || '',
          alamat: data.header?.alamat || ''
        },
        signatory_left: {
          jabatan: data.signatory_left?.jabatan || '',
          nama: data.signatory_left?.nama || '',
          nip: data.signatory_left?.nip || ''
        },
        signatory_right: {
          jabatan: data.signatory_right?.jabatan || '',
          nama: data.signatory_right?.nama || '',
          nip: data.signatory_right?.nip || ''
        }
      }
    }
  } catch (error) {
    console.error('Failed to load data:', error)
  } finally {
    loading.value = false
  }
})

function formatCurrency(value) {
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(value || 0)
}

function formatCurrencyShort(value) {
  return 'Rp ' + new Intl.NumberFormat('id-ID', { minimumFractionDigits: 0 }).format(value || 0)
}

function truncateText(text, maxLength) {
  if (!text) return '-'
  return text.length > maxLength ? text.substring(0, maxLength) + '...' : text
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
    padding: 15px;
  }
  .print\\:hidden {
    display: none !important;
  }
  @page {
    size: A4 landscape;
    margin: 10mm;
  }
}
</style>
