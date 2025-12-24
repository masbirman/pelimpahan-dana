<template>
  <div class="space-y-6 animate-fadeIn">
    <!-- Header -->
    <div class="flex justify-between items-center">
      <div>
        <h1 class="text-2xl font-bold text-secondary-900">Saldo Bendahara</h1>
        <p class="text-secondary-500">Kelola saldo awal bendahara (Bank & Tunai)</p>
      </div>
      <router-link v-if="!isYearLocked" to="/saldo-bendahara/create" class="btn-primary">
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
        </svg>
        Tambah Saldo Baru
      </router-link>
    </div>

    <!-- Latest Saldo Card -->
    <div v-if="latestSaldo" class="card">
      <div class="card-header">
        <h3 class="font-semibold text-secondary-900">Saldo Terkini</h3>
        <p class="text-xs text-secondary-500">{{ formatDate(latestSaldo.tanggal) }}</p>
      </div>
      <div class="card-body">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div class="p-4 bg-blue-50 rounded-lg">
            <p class="text-sm text-secondary-600 mb-1">Saldo Bank</p>
            <p class="text-2xl font-bold text-blue-700">{{ formatRupiah(latestSaldo.saldo_bank) }}</p>
          </div>
          <div class="p-4 bg-emerald-50 rounded-lg">
            <p class="text-sm text-secondary-600 mb-1">Saldo Tunai</p>
            <p class="text-2xl font-bold text-emerald-700">{{ formatRupiah(latestSaldo.saldo_tunai) }}</p>
          </div>
          <div class="p-4 bg-primary-50 rounded-lg">
            <p class="text-sm text-secondary-600 mb-1">Total Saldo</p>
            <p class="text-2xl font-bold text-primary-700">{{ formatRupiah(latestSaldo.saldo_bank + latestSaldo.saldo_tunai) }}</p>
          </div>
        </div>
        
        <!-- Action Buttons - Hidden when locked -->
        <div v-if="!isYearLocked" class="flex gap-3 mt-6">
          <button @click="openTopUpModal" class="btn-primary flex-1">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
            💰 Top Up Bank
          </button>
          <button @click="openPenarikanModal" class="btn-secondary flex-1">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z" />
            </svg>
            💵 Penarikan Tunai
          </button>
          <button @click="openSetorModal" class="btn-danger flex-1">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 14l6-6m-5.5.5h.01m4.99 5h.01M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16l3.5-2 3.5 2 3.5-2 3.5 2z" />
            </svg>
            📤 Setor ke Kas BUD
          </button>
        </div>
        <!-- Locked Warning -->
        <div v-else class="mt-6 p-4 bg-red-100 border border-red-300 rounded-lg">
          <p class="text-red-700 text-sm font-medium">🔒 Tahun anggaran dikunci. Transaksi tidak dapat dilakukan.</p>
        </div>
      </div>
    </div>

    <!-- Top Up History Table -->
    <div class="card">
      <div class="card-header">
        <h3 class="font-semibold text-secondary-900">Riwayat Top Up Bank</h3>
        <p class="text-xs text-secondary-500">Penerimaan dana dari luar</p>
      </div>
      <div class="card-body p-0">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-secondary-200">
            <thead class="bg-secondary-50">
              <tr>
                <th class="px-4 py-3 text-left text-xs font-medium text-secondary-500 uppercase">Tanggal</th>
                <th class="px-4 py-3 text-right text-xs font-medium text-secondary-500 uppercase">Jumlah</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-secondary-500 uppercase">Keterangan</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-secondary-500 uppercase">Dibuat Oleh</th>
                <th class="px-4 py-3 text-center text-xs font-medium text-secondary-500 uppercase">Aksi</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-secondary-200">
              <tr v-if="loadingTopUp">
                <td colspan="5" class="px-4 py-8 text-center text-secondary-500">Memuat data...</td>
              </tr>
              <tr v-else-if="!topUpList.length">
                <td colspan="5" class="px-4 py-8 text-center text-secondary-500">Belum ada data top up</td>
              </tr>
              <tr v-else v-for="item in topUpList" :key="item.id" class="hover:bg-secondary-50">
                <td class="px-4 py-3 text-sm text-secondary-900">{{ formatDate(item.tanggal) }}</td>
                <td class="px-4 py-3 text-sm font-semibold text-right text-emerald-700">{{ formatRupiah(item.jumlah) }}</td>
                <td class="px-4 py-3 text-sm text-secondary-600 max-w-xs truncate">{{ item.keterangan }}</td>
                <td class="px-4 py-3 text-sm text-secondary-600">{{ item.creator?.name || '-' }}</td>
                <td class="px-4 py-3 text-center">
                  <div class="flex justify-center gap-2">
                    <button @click="editTopUp(item)" class="btn-icon btn-icon-warning" title="Edit">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                      </svg>
                    </button>
                    <button @click="confirmDeleteTopUp(item)" class="btn-icon btn-icon-danger" title="Hapus">
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
        <!-- Pagination -->
        <div v-if="topUpMeta.last_page > 1" class="flex items-center justify-between px-4 py-3 border-t border-secondary-200">
          <span class="text-sm text-secondary-500">Halaman {{ topUpMeta.page }} dari {{ topUpMeta.last_page }}</span>
          <div class="flex gap-1">
            <button @click="changeTopUpPage(topUpMeta.page - 1)" :disabled="topUpMeta.page <= 1" class="px-3 py-1 text-sm bg-secondary-100 rounded hover:bg-secondary-200 disabled:opacity-50">←</button>
            <button @click="changeTopUpPage(topUpMeta.page + 1)" :disabled="topUpMeta.page >= topUpMeta.last_page" class="px-3 py-1 text-sm bg-secondary-100 rounded hover:bg-secondary-200 disabled:opacity-50">→</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Penarikan Tunai History Table -->
    <div class="card">
      <div class="card-header">
        <h3 class="font-semibold text-secondary-900">Riwayat Penarikan Tunai</h3>
        <p class="text-xs text-secondary-500">Transfer saldo dari Bank ke Tunai</p>
      </div>
      <div class="card-body p-0">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-secondary-200">
            <thead class="bg-secondary-50">
              <tr>
                <th class="px-4 py-3 text-left text-xs font-medium text-secondary-500 uppercase">Tanggal</th>
                <th class="px-4 py-3 text-right text-xs font-medium text-secondary-500 uppercase">Jumlah</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-secondary-500 uppercase">Keterangan</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-secondary-500 uppercase">Dibuat Oleh</th>
                <th class="px-4 py-3 text-center text-xs font-medium text-secondary-500 uppercase">Aksi</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-secondary-200">
              <tr v-if="loadingPenarikan">
                <td colspan="5" class="px-4 py-8 text-center text-secondary-500">Memuat data...</td>
              </tr>
              <tr v-else-if="!penarikanList.length">
                <td colspan="5" class="px-4 py-8 text-center text-secondary-500">Belum ada data penarikan tunai</td>
              </tr>
              <tr v-else v-for="item in penarikanList" :key="item.id" class="hover:bg-secondary-50">
                <td class="px-4 py-3 text-sm text-secondary-900">{{ formatDate(item.tanggal) }}</td>
                <td class="px-4 py-3 text-sm font-semibold text-right text-orange-700">{{ formatRupiah(item.jumlah) }}</td>
                <td class="px-4 py-3 text-sm text-secondary-600 max-w-xs truncate">{{ item.keterangan }}</td>
                <td class="px-4 py-3 text-sm text-secondary-600">{{ item.creator?.name || '-' }}</td>
                <td class="px-4 py-3 text-center">
                  <div class="flex justify-center gap-2">
                    <button @click="editPenarikan(item)" class="btn-icon btn-icon-warning" title="Edit">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                      </svg>
                    </button>
                    <button @click="confirmDeletePenarikan(item)" class="btn-icon btn-icon-danger" title="Hapus">
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
        <!-- Pagination -->
        <div v-if="penarikanMeta.last_page > 1" class="flex items-center justify-between px-4 py-3 border-t border-secondary-200">
          <span class="text-sm text-secondary-500">Halaman {{ penarikanMeta.page }} dari {{ penarikanMeta.last_page }}</span>
          <div class="flex gap-1">
            <button @click="changePenarikanPage(penarikanMeta.page - 1)" :disabled="penarikanMeta.page <= 1" class="px-3 py-1 text-sm bg-secondary-100 rounded hover:bg-secondary-200 disabled:opacity-50">←</button>
            <button @click="changePenarikanPage(penarikanMeta.page + 1)" :disabled="penarikanMeta.page >= penarikanMeta.last_page" class="px-3 py-1 text-sm bg-secondary-100 rounded hover:bg-secondary-200 disabled:opacity-50">→</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Setor Kas BUD History Table -->
    <div class="card">
      <div class="card-header">
        <h3 class="font-semibold text-secondary-900">Riwayat Setor ke Kas BUD</h3>
        <p class="text-xs text-secondary-500">Pengembalian saldo ke Kas BUD</p>
      </div>
      <div class="card-body p-0">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-secondary-200">
            <thead class="bg-secondary-50">
              <tr>
                <th class="px-4 py-3 text-left text-xs font-medium text-secondary-500 uppercase">Tanggal</th>
                <th class="px-4 py-3 text-right text-xs font-medium text-secondary-500 uppercase">Jumlah</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-secondary-500 uppercase">Keterangan</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-secondary-500 uppercase">Dibuat Oleh</th>
                <th class="px-4 py-3 text-center text-xs font-medium text-secondary-500 uppercase">Aksi</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-secondary-200">
              <tr v-if="loadingSetor">
                <td colspan="5" class="px-4 py-8 text-center text-secondary-500">Memuat data...</td>
              </tr>
              <tr v-else-if="!setorList.length">
                <td colspan="5" class="px-4 py-8 text-center text-secondary-500">Belum ada data setor ke Kas BUD</td>
              </tr>
              <tr v-else v-for="item in setorList" :key="item.id" class="hover:bg-secondary-50">
                <td class="px-4 py-3 text-sm text-secondary-900">{{ formatDate(item.tanggal) }}</td>
                <td class="px-4 py-3 text-sm font-semibold text-right text-red-700">{{ formatRupiah(item.jumlah) }}</td>
                <td class="px-4 py-3 text-sm text-secondary-600 max-w-xs truncate">{{ item.keterangan }}</td>
                <td class="px-4 py-3 text-sm text-secondary-600">{{ item.creator?.name || '-' }}</td>
                <td class="px-4 py-3 text-center">
                  <button v-if="authStore.user?.role === 'super_admin'" @click="confirmDeleteSetor(item)" class="btn-icon btn-icon-danger" title="Hapus">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <!-- Pagination -->
        <div v-if="setorMeta.last_page > 1" class="flex items-center justify-between px-4 py-3 border-t border-secondary-200">
          <span class="text-sm text-secondary-500">Halaman {{ setorMeta.page }} dari {{ setorMeta.last_page }}</span>
          <div class="flex gap-1">
            <button @click="changeSetorPage(setorMeta.page - 1)" :disabled="setorMeta.page <= 1" class="px-3 py-1 text-sm bg-secondary-100 rounded hover:bg-secondary-200 disabled:opacity-50">←</button>
            <button @click="changeSetorPage(setorMeta.page + 1)" :disabled="setorMeta.page >= setorMeta.last_page" class="px-3 py-1 text-sm bg-secondary-100 rounded hover:bg-secondary-200 disabled:opacity-50">→</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Saldo Bendahara History (existing) -->
    <div class="card">
      <div class="card-header">
        <h3 class="font-semibold text-secondary-900">Riwayat Saldo Bendahara</h3>
        <p class="text-xs text-secondary-500">Catatan saldo awal bendahara</p>
      </div>
      <div class="card-body">
        <div class="flex gap-4">
          <div class="flex-1">
            <input
              v-model="search"
              type="text"
              class="input"
              placeholder="Cari berdasarkan keterangan..."
              @input="fetchSaldos"
            />
          </div>
        </div>
      </div>
      <div class="card-body p-0">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-secondary-200">
            <thead class="bg-secondary-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-secondary-500 uppercase tracking-wider whitespace-nowrap">Tanggal</th>
                <th class="px-6 py-3 text-right text-xs font-medium text-secondary-500 uppercase tracking-wider whitespace-nowrap">Saldo Bank</th>
                <th class="px-6 py-3 text-right text-xs font-medium text-secondary-500 uppercase tracking-wider whitespace-nowrap">Saldo Tunai</th>
                <th class="px-6 py-3 text-right text-xs font-medium text-secondary-500 uppercase tracking-wider whitespace-nowrap">Total Saldo</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-secondary-500 uppercase tracking-wider">Keterangan</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-secondary-500 uppercase tracking-wider whitespace-nowrap">Dibuat Oleh</th>
                <th class="px-6 py-3 text-center text-xs font-medium text-secondary-500 uppercase tracking-wider whitespace-nowrap">Aksi</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-secondary-200">
              <tr v-if="loading">
                <td colspan="7" class="px-6 py-8 text-center">
                  <div class="flex justify-center">
                    <svg class="animate-spin h-8 w-8 text-primary-600" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                  </div>
                </td>
              </tr>
              <tr v-else-if="saldos.length === 0">
                <td colspan="7" class="px-6 py-8 text-center text-secondary-500">Belum ada data saldo</td>
              </tr>
              <tr v-else v-for="saldo in saldos" :key="saldo.id" class="hover:bg-secondary-50 transition-colors">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-secondary-900">{{ formatDate(saldo.tanggal) }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-right text-blue-700">{{ formatRupiah(saldo.saldo_bank) }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-right text-emerald-700">{{ formatRupiah(saldo.saldo_tunai) }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-bold text-right text-primary-700">{{ formatRupiah(saldo.saldo_bank + saldo.saldo_tunai) }}</td>
                <td class="px-6 py-4 text-sm text-secondary-600 max-w-xs truncate" :title="saldo.keterangan">{{ saldo.keterangan || '-' }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-secondary-600">{{ saldo.creator?.name || '-' }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-center">
                  <div class="flex justify-center gap-2">
                    <router-link :to="`/saldo-bendahara/${saldo.id}/edit`" class="btn-icon btn-icon-warning" title="Edit">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                      </svg>
                    </router-link>
                    <button v-if="authStore.user?.role === 'super_admin'" @click="confirmDelete(saldo)" class="btn-icon btn-icon-danger" title="Hapus">
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
    </div>

    <!-- Pagination -->
    <div v-if="meta.total > 0" class="flex justify-between items-center">
      <p class="text-sm text-secondary-600">
        Menampilkan {{ ((meta.page - 1) * meta.per_page) + 1 }} - {{ Math.min(meta.page * meta.per_page, meta.total) }} dari {{ meta.total }} data
      </p>
      <div class="flex gap-2">
        <button @click="changePage(meta.page - 1)" :disabled="meta.page === 1" class="btn-secondary">Sebelumnya</button>
        <button @click="changePage(meta.page + 1)" :disabled="meta.page * meta.per_page >= meta.total" class="btn-secondary">Selanjutnya</button>
      </div>
    </div>

    <!-- Top Up Modal -->
    <div v-if="showTopUpModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-xl shadow-xl max-w-md w-full">
        <div class="card-header">
          <h3 class="font-semibold text-secondary-900">{{ topUpEditMode ? 'Edit Top Up' : 'Tambah Top Up Bank' }}</h3>
        </div>
        <form @submit.prevent="handleTopUpSubmit" class="card-body space-y-4">
          <div>
            <label class="label">Tanggal <span class="text-red-500">*</span></label>
            <input v-model="topUpForm.tanggal" type="date" class="input" required />
          </div>
          <div>
            <label class="label">Jumlah (Rp) <span class="text-red-500">*</span></label>
            <input v-model.number="topUpForm.jumlah" type="number" class="input" min="1" required placeholder="0" />
            <p v-if="topUpForm.jumlah" class="mt-1 text-sm text-secondary-500">{{ formatRupiah(topUpForm.jumlah) }}</p>
          </div>
          <div>
            <label class="label">Keterangan <span class="text-red-500">*</span></label>
            <textarea v-model="topUpForm.keterangan" class="input" rows="3" required minlength="3" placeholder="Contoh: Penerimaan APBD Triwulan 1"></textarea>
          </div>
          <div class="flex justify-end gap-3 pt-4">
            <button type="button" @click="closeTopUpModal" class="btn-secondary">Batal</button>
            <button type="submit" class="btn-primary" :disabled="submitting">{{ submitting ? 'Menyimpan...' : 'Simpan' }}</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Penarikan Tunai Modal -->
    <div v-if="showPenarikanModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-xl shadow-xl max-w-md w-full max-h-[90vh] overflow-y-auto">
        <div class="card-header sticky top-0 bg-white z-10 border-b border-secondary-200">
          <h3 class="font-semibold text-secondary-900">{{ penarikanEditMode ? 'Edit Penarikan' : 'Penarikan Tunai' }}</h3>
        </div>
        <form @submit.prevent="handlePenarikanSubmit" class="p-4 space-y-4">
          <div class="bg-blue-50 rounded-lg p-4">
            <p class="text-sm text-blue-700 font-medium">Saldo Bank Tersedia</p>
            <p class="text-xl font-bold text-blue-900">{{ formatRupiah(latestSaldo?.saldo_bank || 0) }}</p>
          </div>
          <div>
            <label class="label">Tanggal <span class="text-red-500">*</span></label>
            <input v-model="penarikanForm.tanggal" type="date" class="input" required />
          </div>
          <div>
            <label class="label">Jumlah Penarikan (Rp) <span class="text-red-500">*</span></label>
            <input v-model.number="penarikanForm.jumlah" type="number" class="input" min="1" required placeholder="0" />
            <p v-if="penarikanForm.jumlah" class="mt-1 text-sm text-secondary-500">{{ formatRupiah(penarikanForm.jumlah) }}</p>
            <p v-if="penarikanForm.jumlah > (latestSaldo?.saldo_bank || 0)" class="mt-1 text-sm text-red-600">⚠️ Saldo bank tidak mencukupi!</p>
          </div>
          <div>
            <label class="label">Keterangan <span class="text-red-500">*</span></label>
            <textarea v-model="penarikanForm.keterangan" class="input" rows="3" required minlength="3" placeholder="Contoh: Penarikan untuk operasional"></textarea>
          </div>
          <div class="flex justify-end gap-3 pt-4 border-t border-secondary-200 mt-4">
            <button type="button" @click="closePenarikanModal" class="btn-secondary">Batal</button>
            <button type="submit" class="btn-primary" :disabled="submitting || penarikanForm.jumlah > (latestSaldo?.saldo_bank || 0)">{{ submitting ? 'Menyimpan...' : 'Tarik Tunai' }}</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Confirmation Modal (Saldo) -->
    <div v-if="showDeleteModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <h3 class="text-lg font-semibold text-secondary-900 mb-2">Konfirmasi Hapus</h3>
        <p class="text-secondary-600 mb-6">Apakah Anda yakin ingin menghapus data saldo tanggal {{ formatDate(selectedSaldo?.tanggal) }}?</p>
        <div class="flex justify-end gap-3">
          <button @click="showDeleteModal = false" class="btn-secondary">Batal</button>
          <button @click="deleteSaldo" class="btn-danger">Hapus</button>
        </div>
      </div>
    </div>

    <!-- Delete Top Up Confirmation Modal -->
    <div v-if="deleteTopUpConfirm" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <h3 class="text-lg font-semibold text-secondary-900 mb-2">Konfirmasi Hapus</h3>
        <p class="text-secondary-600 mb-6">Apakah Anda yakin ingin menghapus top up ini?</p>
        <div class="flex justify-end gap-3">
          <button @click="deleteTopUpConfirm = null" class="btn-secondary">Batal</button>
          <button @click="handleDeleteTopUp" class="btn-danger" :disabled="submitting">{{ submitting ? 'Menghapus...' : 'Hapus' }}</button>
        </div>
      </div>
    </div>

    <!-- Delete Penarikan Confirmation Modal -->
    <div v-if="deletePenarikanConfirm" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <h3 class="text-lg font-semibold text-secondary-900 mb-2">Konfirmasi Hapus</h3>
        <p class="text-secondary-600 mb-6">Apakah Anda yakin ingin menghapus penarikan tunai ini?</p>
        <div class="flex justify-end gap-3">
          <button @click="deletePenarikanConfirm = null" class="btn-secondary">Batal</button>
          <button @click="handleDeletePenarikan" class="btn-danger" :disabled="submitting">{{ submitting ? 'Menghapus...' : 'Hapus' }}</button>
        </div>
      </div>
    </div>

    <!-- Setor Kas BUD Modal -->
    <div v-if="showSetorModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-xl shadow-xl max-w-md w-full max-h-[90vh] overflow-y-auto">
        <div class="card-header sticky top-0 bg-white z-10 border-b border-secondary-200">
          <h3 class="font-semibold text-secondary-900">Setor ke Kas BUD</h3>
        </div>
        <form @submit.prevent="handleSetorSubmit" class="p-4 space-y-4">
          <div class="bg-amber-50 rounded-lg p-4">
            <p class="text-sm text-amber-700 font-medium">Sisa Saldo Yang Akan Disetor</p>
            <p class="text-xl font-bold text-amber-900">{{ formatRupiah(latestSaldo?.saldo_bank + latestSaldo?.saldo_tunai || 0) }}</p>
          </div>
          <div>
            <label class="label">Tanggal <span class="text-red-500">*</span></label>
            <input v-model="setorForm.tanggal" type="date" class="input" required />
          </div>
          <div>
            <label class="label">Jumlah Setor (Rp) <span class="text-red-500">*</span></label>
            <input v-model.number="setorForm.jumlah" type="number" class="input" min="1" required placeholder="0" />
            <p v-if="setorForm.jumlah" class="mt-1 text-sm text-secondary-500">{{ formatRupiah(setorForm.jumlah) }}</p>
            <p v-if="setorForm.jumlah > (latestSaldo?.saldo_bank + latestSaldo?.saldo_tunai || 0)" class="mt-1 text-sm text-red-600">⚠️ Jumlah melebihi sisa saldo!</p>
          </div>
          <div>
            <label class="label">Uraian <span class="text-red-500">*</span></label>
            <textarea v-model="setorForm.keterangan" class="input" rows="3" required minlength="3" placeholder="Contoh: Setor sisa UP/GU dan TU TA 2025"></textarea>
          </div>
          <div class="flex justify-end gap-3 pt-4 border-t border-secondary-200 mt-4">
            <button type="button" @click="closeSetorModal" class="btn-secondary">Batal</button>
            <button type="submit" class="btn-danger" :disabled="submitting || setorForm.jumlah > (latestSaldo?.saldo_bank + latestSaldo?.saldo_tunai || 0)">{{ submitting ? 'Menyimpan...' : 'Setor ke BUD' }}</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Delete Setor Confirmation Modal -->
    <div v-if="deleteSetorConfirm" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        <h3 class="text-lg font-semibold text-secondary-900 mb-2">Konfirmasi Hapus</h3>
        <p class="text-secondary-600 mb-6">Apakah Anda yakin ingin menghapus setor ke Kas BUD ini?</p>
        <div class="flex justify-end gap-3">
          <button @click="deleteSetorConfirm = null" class="btn-secondary">Batal</button>
          <button @click="handleDeleteSetor" class="btn-danger" :disabled="submitting">{{ submitting ? 'Menghapus...' : 'Hapus' }}</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import api from '@/services/api'
import { useAuthStore } from '@/stores/auth'
import { useNotificationStore } from '@/stores/notification'

const authStore = useAuthStore()
const notificationStore = useNotificationStore()

// Lock status
const isYearLocked = ref(false)

// Saldo Bendahara state
const saldos = ref([])
const latestSaldo = ref(null)
const loading = ref(false)
const search = ref('')
const meta = ref({ total: 0, page: 1, per_page: 5 })
const showDeleteModal = ref(false)
const selectedSaldo = ref(null)

// Top Up state
const topUpList = ref([])
const loadingTopUp = ref(false)
const topUpMeta = ref({ total: 0, page: 1, per_page: 5, last_page: 1 })
const showTopUpModal = ref(false)
const topUpEditMode = ref(false)
const topUpForm = reactive({ id: null, tanggal: new Date().toISOString().split('T')[0], jumlah: 0, keterangan: '' })
const deleteTopUpConfirm = ref(null)

// Penarikan Tunai state
const penarikanList = ref([])
const loadingPenarikan = ref(false)
const penarikanMeta = ref({ total: 0, page: 1, per_page: 5, last_page: 1 })
const showPenarikanModal = ref(false)
const penarikanEditMode = ref(false)
const penarikanForm = reactive({ id: null, tanggal: new Date().toISOString().split('T')[0], jumlah: 0, keterangan: '' })
const deletePenarikanConfirm = ref(null)

// Setor Kas BUD state
const setorList = ref([])
const loadingSetor = ref(false)
const setorMeta = ref({ total: 0, page: 1, per_page: 5, last_page: 1 })
const showSetorModal = ref(false)
const setorForm = reactive({ tanggal: new Date().toISOString().split('T')[0], jumlah: 0, keterangan: '' })
const deleteSetorConfirm = ref(null)

const submitting = ref(false)

onMounted(() => {
  fetchLockStatus()
  fetchLatestSaldo()
  fetchSaldos()
  fetchTopUpList()
  fetchPenarikanList()
  fetchSetorList()
})

// Check lock status
async function fetchLockStatus() {
  if (authStore.user?.role === 'super_admin') {
    isYearLocked.value = false
    return
  }
  try {
    const response = await api.get('/settings/lock-status')
    if (response.data.success && response.data.data?.locked) {
      isYearLocked.value = true
    }
  } catch (error) {
    console.log('Lock check failed')
  }
}

// ========== Saldo Bendahara Functions ==========
async function fetchLatestSaldo() {
  try {
    const response = await api.get('/saldo-bendahara/latest')
    if (response.data.success && response.data.data) {
      latestSaldo.value = response.data.data
    }
  } catch (error) {
    console.error('Error fetching latest saldo:', error)
  }
}

async function fetchSaldos() {
  loading.value = true
  try {
    const params = { page: meta.value.page, per_page: meta.value.per_page, search: search.value }
    const response = await api.get('/saldo-bendahara', { params })
    saldos.value = response.data.data
    meta.value = response.data.meta
  } catch (error) {
    notificationStore.error('Gagal memuat data saldo')
  } finally {
    loading.value = false
  }
}

function changePage(page) {
  meta.value.page = page
  fetchSaldos()
}

function confirmDelete(saldo) {
  selectedSaldo.value = saldo
  showDeleteModal.value = true
}

async function deleteSaldo() {
  try {
    await api.delete(`/saldo-bendahara/${selectedSaldo.value.id}`)
    notificationStore.success('Saldo berhasil dihapus')
    showDeleteModal.value = false
    fetchLatestSaldo()
    fetchSaldos()
  } catch (error) {
    notificationStore.error('Gagal menghapus saldo')
  }
}

// ========== Top Up Functions ==========
async function fetchTopUpList() {
  loadingTopUp.value = true
  try {
    const response = await api.get('/top-up-saldo', { params: { page: topUpMeta.value.page, per_page: 5 } })
    if (response.data.success) {
      topUpList.value = response.data.data
      topUpMeta.value = response.data.meta || topUpMeta.value
    }
  } catch (error) {
    console.error('Error fetching top up list:', error)
  } finally {
    loadingTopUp.value = false
  }
}

function changeTopUpPage(page) {
  topUpMeta.value.page = page
  fetchTopUpList()
}

function openTopUpModal() {
  topUpEditMode.value = false
  topUpForm.id = null
  topUpForm.tanggal = new Date().toISOString().split('T')[0]
  topUpForm.jumlah = 0
  topUpForm.keterangan = ''
  showTopUpModal.value = true
}

function editTopUp(item) {
  topUpEditMode.value = true
  topUpForm.id = item.id
  topUpForm.tanggal = item.tanggal.split('T')[0]
  topUpForm.jumlah = item.jumlah
  topUpForm.keterangan = item.keterangan
  showTopUpModal.value = true
}

function closeTopUpModal() {
  showTopUpModal.value = false
}

async function handleTopUpSubmit() {
  submitting.value = true
  try {
    const payload = { tanggal: topUpForm.tanggal, jumlah: parseFloat(topUpForm.jumlah), keterangan: topUpForm.keterangan }
    if (topUpEditMode.value) {
      await api.put(`/top-up-saldo/${topUpForm.id}`, payload)
      notificationStore.success('Top up berhasil diupdate')
    } else {
      await api.post('/top-up-saldo', payload)
      notificationStore.success('Top up berhasil ditambahkan')
    }
    closeTopUpModal()
    fetchTopUpList()
    fetchLatestSaldo()
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal menyimpan data')
  } finally {
    submitting.value = false
  }
}

function confirmDeleteTopUp(item) {
  deleteTopUpConfirm.value = item
}

async function handleDeleteTopUp() {
  submitting.value = true
  try {
    await api.delete(`/top-up-saldo/${deleteTopUpConfirm.value.id}`)
    notificationStore.success('Top up berhasil dihapus')
    deleteTopUpConfirm.value = null
    fetchTopUpList()
    fetchLatestSaldo()
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal menghapus data')
  } finally {
    submitting.value = false
  }
}

// ========== Penarikan Tunai Functions ==========
async function fetchPenarikanList() {
  loadingPenarikan.value = true
  try {
    const response = await api.get('/penarikan-tunai', { params: { page: penarikanMeta.value.page, per_page: 5 } })
    if (response.data.success) {
      penarikanList.value = response.data.data
      penarikanMeta.value = response.data.meta || penarikanMeta.value
    }
  } catch (error) {
    console.error('Error fetching penarikan list:', error)
  } finally {
    loadingPenarikan.value = false
  }
}

function changePenarikanPage(page) {
  penarikanMeta.value.page = page
  fetchPenarikanList()
}

function openPenarikanModal() {
  fetchLatestSaldo()
  penarikanEditMode.value = false
  penarikanForm.id = null
  penarikanForm.tanggal = new Date().toISOString().split('T')[0]
  penarikanForm.jumlah = 0
  penarikanForm.keterangan = ''
  showPenarikanModal.value = true
}

function editPenarikan(item) {
  fetchLatestSaldo()
  penarikanEditMode.value = true
  penarikanForm.id = item.id
  penarikanForm.tanggal = item.tanggal.split('T')[0]
  penarikanForm.jumlah = item.jumlah
  penarikanForm.keterangan = item.keterangan
  showPenarikanModal.value = true
}

function closePenarikanModal() {
  showPenarikanModal.value = false
}

async function handlePenarikanSubmit() {
  if (penarikanForm.jumlah > (latestSaldo.value?.saldo_bank || 0)) {
    notificationStore.error('Saldo bank tidak mencukupi')
    return
  }
  submitting.value = true
  try {
    const payload = { tanggal: penarikanForm.tanggal, jumlah: parseFloat(penarikanForm.jumlah), keterangan: penarikanForm.keterangan }
    if (penarikanEditMode.value) {
      await api.put(`/penarikan-tunai/${penarikanForm.id}`, payload)
      notificationStore.success('Penarikan tunai berhasil diupdate')
    } else {
      await api.post('/penarikan-tunai', payload)
      notificationStore.success('Penarikan tunai berhasil ditambahkan')
    }
    closePenarikanModal()
    fetchPenarikanList()
    fetchLatestSaldo()
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal menyimpan data')
  } finally {
    submitting.value = false
  }
}

function confirmDeletePenarikan(item) {
  deletePenarikanConfirm.value = item
}

async function handleDeletePenarikan() {
  submitting.value = true
  try {
    await api.delete(`/penarikan-tunai/${deletePenarikanConfirm.value.id}`)
    notificationStore.success('Penarikan tunai berhasil dihapus')
    deletePenarikanConfirm.value = null
    fetchPenarikanList()
    fetchLatestSaldo()
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal menghapus data')
  } finally {
    submitting.value = false
  }
}

// ========== Setor Kas BUD Functions ==========
async function fetchSetorList() {
  loadingSetor.value = true
  try {
    const response = await api.get('/setor-kas-bud', { params: { page: setorMeta.value.page, per_page: 5 } })
    if (response.data.success) {
      setorList.value = response.data.data
      setorMeta.value = response.data.meta || setorMeta.value
    }
  } catch (error) {
    console.error('Error fetching setor list:', error)
  } finally {
    loadingSetor.value = false
  }
}

function changeSetorPage(page) {
  setorMeta.value.page = page
  fetchSetorList()
}

function openSetorModal() {
  setorForm.tanggal = new Date().toISOString().split('T')[0]
  setorForm.jumlah = latestSaldo.value?.total_saldo || 0
  setorForm.keterangan = ''
  showSetorModal.value = true
}

function closeSetorModal() {
  showSetorModal.value = false
}

async function handleSetorSubmit() {
  submitting.value = true
  try {
    await api.post('/setor-kas-bud', {
      tanggal: setorForm.tanggal,
      jumlah: parseFloat(setorForm.jumlah),
      keterangan: setorForm.keterangan
    })
    notificationStore.success('Setor ke Kas BUD berhasil dicatat')
    closeSetorModal()
    fetchSetorList()
    fetchLatestSaldo()
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal menyimpan data')
  } finally {
    submitting.value = false
  }
}

function confirmDeleteSetor(item) {
  deleteSetorConfirm.value = item
}

async function handleDeleteSetor() {
  submitting.value = true
  try {
    await api.delete(`/setor-kas-bud/${deleteSetorConfirm.value.id}`)
    notificationStore.success('Setor Kas BUD berhasil dihapus')
    deleteSetorConfirm.value = null
    fetchSetorList()
    fetchLatestSaldo()
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal menghapus data')
  } finally {
    submitting.value = false
  }
}

// ========== Utility Functions ==========
function formatRupiah(amount) {
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(amount)
}

function formatDate(date) {
  return new Date(date).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })
}
</script>
