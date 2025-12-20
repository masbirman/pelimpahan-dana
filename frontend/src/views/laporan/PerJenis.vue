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

    <!-- Filter Form -->
    <div class="print:hidden max-w-4xl mx-auto p-8 pb-0">
      <div class="card mb-6">
        <div class="card-header">
          <h3 class="font-semibold text-secondary-900">Filter Jenis Pelimpahan</h3>
        </div>
        <div class="card-body">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="label">Jenis Pelimpahan <span class="text-red-500">*</span></label>
              <select v-model="selectedJenis" class="input" @change="loadData" required>
                <option value="">Pilih Jenis</option>
                <option v-for="jenis in jenisList" :key="jenis.id" :value="jenis.id">
                  {{ jenis.kode_jenis }} - {{ jenis.nama_jenis }}
                </option>
              </select>
            </div>
            <div>
              <label class="label">Bulan</label>
              <select v-model="selectedMonth" class="input" @change="loadData">
                <option value="">Semua Bulan</option>
                <option v-for="(name, index) in monthNames.slice(1)" :key="index" :value="index + 1">{{ name }}</option>
              </select>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Report Content -->
    <div id="report-content" class="max-w-4xl mx-auto p-8">
      <div v-if="!selectedJenis" class="text-center py-12 text-secondary-500">
        Pilih jenis pelimpahan untuk melihat laporan
      </div>

      <div v-else>
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
          <h1 class="text-xl font-bold text-gray-900 uppercase">Laporan Pelimpahan Dana</h1>
          <p class="text-gray-600 mt-1">{{ selectedJenisData?.nama_jenis }}</p>
          <p class="text-sm text-gray-500">{{ filterDescription }}</p>
        </div>

        <!-- Loading -->
        <div v-if="loading" class="text-center py-12">
          <p class="text-gray-500">Memuat data...</p>
        </div>

        <!-- Table -->
        <div v-else-if="pelimpahanList.length > 0" class="border border-gray-300 rounded overflow-hidden">
          <table class="w-full text-xs">
            <thead class="bg-gray-100">
              <tr>
                <th class="px-2 py-2 text-left font-semibold text-gray-700 border-b">No</th>
                <th class="px-2 py-2 text-left font-semibold text-gray-700 border-b">Tanggal</th>
                <th class="px-2 py-2 text-left font-semibold text-gray-700 border-b">Uraian</th>
                <th class="px-2 py-2 text-center font-semibold text-gray-700 border-b">Penerima</th>
                <th class="px-2 py-2 text-right font-semibold text-gray-700 border-b">Bank</th>
                <th class="px-2 py-2 text-right font-semibold text-gray-700 border-b">Tunai</th>
                <th class="px-2 py-2 text-right font-semibold text-gray-700 border-b">Total</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
              <tr v-for="(item, index) in pelimpahanList" :key="item.id">
                <td class="px-2 py-1 text-gray-700">{{ index + 1 }}</td>
                <td class="px-2 py-1 text-gray-700 whitespace-nowrap">{{ formatDate(item.tanggal_pelimpahan) }}</td>
                <td class="px-2 py-1 text-gray-700">{{ item.uraian_pelimpahan || '-' }}</td>
                <td class="px-2 py-1 text-gray-700 text-center">{{ item.details?.length || 0 }}</td>
                <td class="px-2 py-1 text-blue-700 font-medium text-right whitespace-nowrap">{{ formatCurrencyShort(item.saldo_bank) }}</td>
                <td class="px-2 py-1 text-emerald-700 font-medium text-right whitespace-nowrap">{{ formatCurrencyShort(item.saldo_tunai) }}</td>
                <td class="px-2 py-1 text-gray-900 font-semibold text-right whitespace-nowrap">{{ formatCurrencyShort(item.total_jumlah) }}</td>
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

        <div v-else class="text-center py-12 text-gray-500">
          Tidak ada data pelimpahan untuk jenis ini
        </div>

        <!-- Summary & Signature -->
        <div v-if="pelimpahanList.length > 0">
          <div class="bg-indigo-50 border border-indigo-300 rounded p-4 mt-4 text-center">
            <p class="text-sm text-indigo-600 font-medium">Total Pelimpahan {{ selectedJenisData?.kode_jenis }}</p>
            <p class="text-2xl font-bold text-indigo-700">{{ formatCurrency(grandTotal) }}</p>
            <p class="text-xs text-indigo-600 mt-1">Terbilang: {{ terbilang(grandTotal) }} Rupiah</p>
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
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'

const jenisList = ref([])
const pelimpahanList = ref([])
const selectedJenis = ref('')
const selectedMonth = ref('')
const loading = ref(false)
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

const selectedJenisData = computed(() => jenisList.value.find(j => j.id === selectedJenis.value))

const filterDescription = computed(() => {
  const parts = []
  if (selectedMonth.value) parts.push(`Bulan ${monthNames[selectedMonth.value]}`)
  return parts.length > 0 ? parts.join(' - ') : 'Semua Data'
})

const totalBank = computed(() => pelimpahanList.value.reduce((sum, item) => sum + (item.saldo_bank || 0), 0))
const totalTunai = computed(() => pelimpahanList.value.reduce((sum, item) => sum + (item.saldo_tunai || 0), 0))
const grandTotal = computed(() => pelimpahanList.value.reduce((sum, item) => sum + (item.total_jumlah || 0), 0))

onMounted(async () => {
  await loadJenis()
  await loadReportHeader()
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
  if (!selectedJenis.value) {
    pelimpahanList.value = []
    return
  }

  loading.value = true
  try {
    const response = await api.get('/pelimpahan', {
      params: {
        per_page: 1000,
        jenis_pelimpahan_id: selectedJenis.value,
        month: selectedMonth.value
      }
    })
    if (response.data.success) {
      pelimpahanList.value = response.data.data || []
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
