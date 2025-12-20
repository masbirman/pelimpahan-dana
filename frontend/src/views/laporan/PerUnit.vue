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

    <!-- Filter Form (hidden on print) -->
    <div class="print:hidden max-w-4xl mx-auto p-8 pb-0">
      <div class="card mb-6">
        <div class="card-header">
          <h3 class="font-semibold text-secondary-900">Filter Laporan</h3>
        </div>
        <div class="card-body">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="label">Unit Kerja</label>
              <select v-model="selectedUnit" class="input" @change="loadData">
                <option value="">Semua Unit</option>
                <option v-for="unit in unitsList" :key="unit.id" :value="unit.id">
                  {{ unit.kode_unit }} - {{ unit.nama_unit }}
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
      <div v-if="!hasData && !loading" class="text-center py-12 text-secondary-500">
        Klik filter untuk melihat laporan
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
          <p class="text-gray-600 mt-1">{{ selectedUnit ? selectedUnitData?.nama_unit : 'Semua Unit Kerja' }}</p>
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
                <th class="px-2 py-2 text-left font-semibold text-gray-700 border-b">Jenis</th>
                <th class="px-2 py-2 text-left font-semibold text-gray-700 border-b">Uraian</th>
                <th class="px-2 py-2 text-right font-semibold text-gray-700 border-b">Bank</th>
                <th class="px-2 py-2 text-right font-semibold text-gray-700 border-b">Tunai</th>
                <th class="px-2 py-2 text-right font-semibold text-gray-700 border-b">Total</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
              <tr v-for="(item, index) in pelimpahanList" :key="item.id">
                <td class="px-2 py-1 text-gray-700">{{ index + 1 }}</td>
                <td class="px-2 py-1 text-gray-700 whitespace-nowrap">{{ formatDate(item.tanggal) }}</td>
                <td class="px-2 py-1 text-gray-700">{{ item.jenis }}</td>
                <td class="px-2 py-1 text-gray-700">{{ item.uraian }}</td>
                <td class="px-2 py-1 text-blue-700 font-medium text-right whitespace-nowrap">{{ formatCurrencyShort(item.bank) }}</td>
                <td class="px-2 py-1 text-emerald-700 font-medium text-right whitespace-nowrap">{{ formatCurrencyShort(item.tunai) }}</td>
                <td class="px-2 py-1 text-gray-900 font-semibold text-right whitespace-nowrap">{{ formatCurrencyShort(item.total) }}</td>
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
          Tidak ada data pelimpahan untuk unit ini
        </div>

        <!-- Summary -->
        <div v-if="pelimpahanList.length > 0">
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

          <div class="bg-indigo-50 border border-indigo-300 rounded p-4 mt-3 text-center">
            <p class="text-sm text-indigo-600 font-medium">Total Pelimpahan</p>
            <p class="text-2xl font-bold text-indigo-700">{{ formatCurrency(grandTotal) }}</p>
            <p class="text-xs text-indigo-600 mt-1">Terbilang: {{ terbilang(grandTotal) }} Rupiah</p>
          </div>

          <!-- Tanda Tangan BPP & KPA (untuk unit spesifik) -->
          <div v-if="selectedUnit" class="mt-12 pt-8">
            <div class="grid grid-cols-2 gap-8 text-center text-sm">
              <div>
                <p class="text-gray-700">Bendahara Pengeluaran Pembantu</p>
                <div class="h-20"></div>
                <p class="font-bold text-gray-900 underline">{{ selectedUnitData?.nama_bendahara || '-' }}</p>
                <p class="text-gray-600 text-xs">NIP. {{ selectedUnitData?.nip_bendahara || '-' }}</p>
              </div>
              <div>
                <p class="text-gray-700">Kuasa Pengguna Anggaran</p>
                <div class="h-20"></div>
                <p class="font-bold text-gray-900 underline">{{ selectedUnitData?.nama_pimpinan || '-' }}</p>
                <p class="text-gray-600 text-xs">NIP. {{ selectedUnitData?.nip_pimpinan || '-' }}</p>
              </div>
            </div>
          </div>

          <!-- Tanda Tangan dari Settings (untuk Semua Unit) -->
          <div v-else-if="reportHeader.signatory_left?.nama" class="mt-12 pt-8">
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

const unitsList = ref([])
const pelimpahanList = ref([])
const selectedUnit = ref('')
const selectedMonth = ref('')
const loading = ref(false)
const reportHeader = ref({
  header: { logo_url: '', instansi: '', dinas: '', alamat: '' },
  signatory_left: { jabatan: '', nama: '', nip: '' },
  signatory_right: { jabatan: '', nama: '', nip: '' }
})

const hasData = computed(() => pelimpahanList.value.length > 0 || loading.value)

const monthNames = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember']

const apiBaseUrl = import.meta.env.VITE_API_URL?.replace('/api', '') || 'http://localhost:8000'
const reportLogoUrl = computed(() => {
  const url = reportHeader.value.header.logo_url
  if (!url) return ''
  if (url.startsWith('http')) return url
  return apiBaseUrl + url
})

const selectedUnitData = computed(() => unitsList.value.find(u => u.id === selectedUnit.value))

const filterDescription = computed(() => {
  const parts = []
  if (selectedMonth.value) parts.push(`Bulan ${monthNames[selectedMonth.value]}`)
  return parts.length > 0 ? parts.join(' - ') : 'Semua Data'
})

const totalBank = computed(() => pelimpahanList.value.reduce((sum, item) => sum + (item.bank || 0), 0))
const totalTunai = computed(() => pelimpahanList.value.reduce((sum, item) => sum + (item.tunai || 0), 0))
const grandTotal = computed(() => pelimpahanList.value.reduce((sum, item) => sum + (item.total || 0), 0))

onMounted(async () => {
  await loadUnits()
  await loadReportHeader()
})

async function loadUnits() {
  try {
    const response = await api.get('/units', { params: { per_page: 100 } })
    if (response.data.success) {
      unitsList.value = response.data.data
    }
  } catch (error) {
    console.error('Failed to load units:', error)
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
  loading.value = true
  try {
    const params = {
      per_page: 1000,
      month: selectedMonth.value
    }
    
    const response = await api.get('/pelimpahan', { params })
    if (response.data.success) {
      const data = response.data.data || []
      
      if (selectedUnit.value) {
        // Filter by specific unit
        pelimpahanList.value = data.map(p => {
          const unitDetail = p.details?.find(d => d.unit_id === selectedUnit.value)
          return {
            id: p.id,
            tanggal: p.tanggal_pelimpahan,
            jenis: p.jenis_pelimpahan?.kode_jenis,
            uraian: p.uraian_pelimpahan,
            bank: unitDetail?.sumber_dana === 'bank' ? unitDetail.jumlah : 0,
            tunai: unitDetail?.sumber_dana === 'tunai' ? unitDetail.jumlah : 0,
            total: unitDetail?.jumlah || 0
          }
        }).filter(p => p.total > 0)
      } else {
        // All units - use saldo_bank and saldo_tunai from pelimpahan
        pelimpahanList.value = data.map(p => ({
          id: p.id,
          tanggal: p.tanggal_pelimpahan,
          jenis: p.jenis_pelimpahan?.kode_jenis,
          uraian: p.uraian_pelimpahan,
          bank: p.saldo_bank || 0,
          tunai: p.saldo_tunai || 0,
          total: p.total_jumlah || 0
        }))
      }
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
  if (angka < 1000000000000) return terbilang(Math.floor(angka / 1000000000)) + ' Miliar ' + terbilang(angka % 1000000000)
  return terbilang(Math.floor(angka / 1000000000000)) + ' Triliun ' + terbilang(angka % 1000000000000)
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
