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
          <h3 class="font-semibold text-secondary-900">Filter Laporan Saldo</h3>
        </div>
        <div class="card-body">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="label">Pilih Bulan</label>
              <select v-model="selectedMonth" @change="loadData" class="input">
                <option value="">-- Pilih Bulan --</option>
                <option v-for="(name, index) in monthNames.slice(1)" :key="index" :value="index + 1">{{ name }}</option>
              </select>
            </div>
            <div>
              <label class="label">Tahun Anggaran</label>
              <select v-model="selectedYear" @change="loadData" class="input">
                <option v-for="year in availableYears" :key="year" :value="year">{{ year }}</option>
              </select>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Report Content -->
    <div id="report-content" class="max-w-4xl mx-auto p-8">
      <div v-if="!selectedMonth" class="text-center py-12 text-secondary-500">
        Pilih bulan untuk melihat laporan saldo
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

        <!-- Judul Laporan -->
        <div class="text-center mb-8 pt-4">
          <h1 class="text-xl font-bold text-gray-900 uppercase">Laporan Saldo Bendahara</h1>
          <p class="text-gray-600 mt-1">Bulan {{ monthNames[selectedMonth] }} {{ selectedYear }}</p>
        </div>

        <!-- Loading -->
        <div v-if="loading" class="text-center py-12">
          <p class="text-gray-500">Memuat data...</p>
        </div>

        <!-- Saldo Cards -->
        <div v-else class="space-y-6">
          <!-- Summary Cards -->
          <div class="grid grid-cols-3 gap-4">
            <div class="bg-blue-50 border border-blue-200 rounded-lg p-6 text-center">
              <p class="text-sm text-blue-600 font-medium mb-2">Saldo Bank</p>
              <p class="text-2xl font-bold text-blue-700">{{ formatCurrency(saldoData.saldo_bank) }}</p>
            </div>
            <div class="bg-emerald-50 border border-emerald-200 rounded-lg p-6 text-center">
              <p class="text-sm text-emerald-600 font-medium mb-2">Saldo Tunai</p>
              <p class="text-2xl font-bold text-emerald-700">{{ formatCurrency(saldoData.saldo_tunai) }}</p>
            </div>
            <div class="bg-amber-50 border border-amber-200 rounded-lg p-6 text-center">
              <p class="text-sm text-amber-600 font-medium mb-2">Total Saldo</p>
              <p class="text-2xl font-bold text-amber-700">{{ formatCurrency(saldoData.total_saldo) }}</p>
            </div>
          </div>

          <!-- Detail Transactions Table -->
          <div class="border border-gray-300 rounded-lg overflow-hidden">
            <table class="w-full text-sm">
              <thead class="bg-gray-100">
                <tr>
                  <th class="px-4 py-3 text-left font-semibold text-gray-700" colspan="2">Rincian Transaksi Bulan {{ monthNames[selectedMonth] }}</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200">
                <tr>
                  <td class="px-4 py-3 text-gray-700">Saldo Awal ({{ formatDate(saldoData.saldo_awal_date) }})</td>
                  <td class="px-4 py-3 text-right font-semibold text-gray-900">{{ formatCurrency(saldoData.saldo_awal) }}</td>
                </tr>
                <tr class="bg-blue-50">
                  <td class="px-4 py-3 text-blue-700">+ Total Top Up Bank</td>
                  <td class="px-4 py-3 text-right font-semibold text-blue-700">{{ formatCurrency(saldoData.total_topup) }}</td>
                </tr>
                <tr class="bg-orange-50">
                  <td class="px-4 py-3 text-orange-700">- Total Penarikan Tunai (dipindah ke Tunai)</td>
                  <td class="px-4 py-3 text-right font-semibold text-orange-700">{{ formatCurrency(saldoData.total_penarikan) }}</td>
                </tr>
                <tr class="bg-red-50">
                  <td class="px-4 py-3 text-red-700">- Total Pelimpahan Bank</td>
                  <td class="px-4 py-3 text-right font-semibold text-red-700">{{ formatCurrency(saldoData.total_pelimpahan_bank) }}</td>
                </tr>
                <tr class="bg-red-50">
                  <td class="px-4 py-3 text-red-700">- Total Pelimpahan Tunai</td>
                  <td class="px-4 py-3 text-right font-semibold text-red-700">{{ formatCurrency(saldoData.total_pelimpahan_tunai) }}</td>
                </tr>
              </tbody>
              <tfoot class="bg-gray-100">
                <tr class="font-bold">
                  <td class="px-4 py-3 text-gray-900">Saldo Akhir Bulan {{ monthNames[selectedMonth] }}</td>
                  <td class="px-4 py-3 text-right text-primary-700 text-lg">{{ formatCurrency(saldoData.total_saldo) }}</td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Terbilang -->
          <div class="bg-amber-50 border border-amber-200 rounded-lg p-4 text-center">
            <p class="text-sm text-amber-700">
              <span class="font-medium">Terbilang:</span> {{ terbilang(saldoData.total_saldo) }} Rupiah
            </p>
          </div>

          <!-- Signature -->
          <div v-if="reportHeader.signatory_left.nama || reportHeader.signatory_right.nama" class="mt-12 pt-8">
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

const selectedMonth = ref('')
const selectedYear = ref(new Date().getFullYear())
const loading = ref(false)
const saldoData = ref({
  saldo_awal: 0,
  saldo_awal_date: null,
  total_topup: 0,
  total_penarikan: 0,
  total_pelimpahan_bank: 0,
  total_pelimpahan_tunai: 0,
  saldo_bank: 0,
  saldo_tunai: 0,
  total_saldo: 0
})

const reportHeader = ref({
  header: { logo_url: '', instansi: '', dinas: '', alamat: '' },
  signatory_left: { jabatan: '', nama: '', nip: '' },
  signatory_right: { jabatan: '', nama: '', nip: '' }
})

const monthNames = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember']
const availableYears = [2024, 2025, 2026]

const apiBaseUrl = import.meta.env.VITE_API_URL?.replace('/api', '') || 'http://localhost:8000'
const reportLogoUrl = computed(() => {
  const url = reportHeader.value.header.logo_url
  if (!url) return ''
  if (url.startsWith('http')) return url
  return apiBaseUrl + url
})

onMounted(async () => {
  await loadReportHeader()
})

async function loadReportHeader() {
  try {
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
    console.error('Failed to load report header:', error)
  }
}

async function loadData() {
  if (!selectedMonth.value) return
  
  loading.value = true
  try {
    // Get saldo by month from API
    const response = await api.get('/saldo-bendahara/by-month', {
      params: {
        month: selectedMonth.value,
        year: selectedYear.value
      }
    })
    
    if (response.data.success && response.data.data) {
      saldoData.value = response.data.data
    }
  } catch (error) {
    console.error('Failed to load saldo data:', error)
  } finally {
    loading.value = false
  }
}

function formatCurrency(value) {
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(value || 0)
}

function formatDate(date) {
  if (!date) return '-'
  return new Date(date).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })
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
  .print\:hidden {
    display: none !important;
  }
  @page {
    size: A4 portrait;
    margin: 10mm;
  }
}
</style>
