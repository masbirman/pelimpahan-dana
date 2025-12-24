<template>
  <div class="max-w-3xl mx-auto space-y-6 animate-fadeIn">
    <div>
      <h1 class="text-2xl font-bold text-secondary-900">Pengaturan</h1>
      <p class="text-secondary-500">Kelola pengaturan aplikasi</p>
    </div>

    <!-- Tabs -->
    <div class="border-b border-secondary-200">
      <nav class="flex gap-4">
        <button 
          @click="activeTab = 'branding'" 
          :class="['pb-3 px-1 text-sm font-medium border-b-2 transition-colors', activeTab === 'branding' ? 'border-primary-600 text-primary-600' : 'border-transparent text-secondary-500 hover:text-secondary-700']"
        >
          Branding Aplikasi
        </button>
        <button 
          @click="activeTab = 'countdown'" 
          :class="['pb-3 px-1 text-sm font-medium border-b-2 transition-colors', activeTab === 'countdown' ? 'border-primary-600 text-primary-600' : 'border-transparent text-secondary-500 hover:text-secondary-700']"
        >
          Countdown Dashboard
        </button>
        <button 
          @click="activeTab = 'report'" 
          :class="['pb-3 px-1 text-sm font-medium border-b-2 transition-colors', activeTab === 'report' ? 'border-primary-600 text-primary-600' : 'border-transparent text-secondary-500 hover:text-secondary-700']"
        >
          Pengaturan Laporan
        </button>
        <button 
          @click="activeTab = 'lock'" 
          :class="['pb-3 px-1 text-sm font-medium border-b-2 transition-colors', activeTab === 'lock' ? 'border-red-600 text-red-600' : 'border-transparent text-secondary-500 hover:text-secondary-700']"
        >
          🔒 Kunci Tahun
        </button>
        <button 
          @click="activeTab = 'login-content'" 
          :class="['pb-3 px-1 text-sm font-medium border-b-2 transition-colors', activeTab === 'login-content' ? 'border-primary-600 text-primary-600' : 'border-transparent text-secondary-500 hover:text-secondary-700']"
        >
          🖼️ Konten Login
        </button>
      </nav>
    </div>

    <!-- Branding Tab -->
    <div v-if="activeTab === 'branding'" class="card">
      <div class="card-header">
        <h3 class="font-semibold text-secondary-900">Branding Aplikasi</h3>
      </div>
      <div class="card-body space-y-6">
        <p class="text-sm text-secondary-500">
          Ganti logo dan nama aplikasi yang tampil di sidebar.
        </p>

        <!-- App Name -->
        <div>
          <label class="block text-sm font-medium text-secondary-700 mb-1">Nama Aplikasi</label>
          <input v-model="branding.app_name" type="text" class="input" placeholder="Nama aplikasi (contoh: Pelimpahan)" />
        </div>

        <!-- App Subtitle -->
        <div>
          <label class="block text-sm font-medium text-secondary-700 mb-1">Subtitle Aplikasi</label>
          <input v-model="branding.app_subtitle" type="text" class="input" placeholder="Subtitle (contoh: Dana UP/GU)" />
        </div>

        <!-- Logo Upload -->
        <div>
          <label class="block text-sm font-medium text-secondary-700 mb-2">Logo Aplikasi</label>
          <div class="flex items-center gap-6">
            <!-- Preview -->
            <div class="w-16 h-16 rounded-xl bg-gradient-to-br from-primary-500 to-primary-700 flex items-center justify-center overflow-hidden">
              <img v-if="branding.logo_url" :src="branding.logo_url" alt="Logo" class="w-full h-full object-cover" />
              <svg v-else class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div class="flex-1">
              <input ref="logoInput" type="file" accept="image/*" class="hidden" @change="uploadLogo" />
              <button @click="$refs.logoInput.click()" class="btn-secondary text-sm">
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
                Upload Logo
              </button>
              <p class="text-xs text-secondary-500 mt-1">PNG, JPG, WEBP. Max 2MB. Ukuran ideal: 100x100px</p>
            </div>
          </div>
        </div>

        <!-- Preview -->
        <div class="p-4 bg-secondary-50 rounded-xl">
          <p class="text-xs text-secondary-500 mb-3">Preview Sidebar:</p>
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-primary-500 to-primary-700 flex items-center justify-center overflow-hidden">
              <img v-if="branding.logo_url" :src="branding.logo_url" alt="Logo" class="w-full h-full object-cover" />
              <svg v-else class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <div>
              <h1 class="font-bold text-secondary-900 text-sm">{{ branding.app_name || 'Pelimpahan' }}</h1>
              <p class="text-xs text-secondary-500">{{ branding.app_subtitle || 'Dana UP/GU' }}</p>
            </div>
          </div>
        </div>

        <div class="flex justify-end gap-3 pt-4 border-t border-secondary-200">
          <router-link to="/" class="btn-secondary">Batal</router-link>
          <button @click="saveBranding" :disabled="savingBranding" class="btn-primary">
            {{ savingBranding ? 'Menyimpan...' : 'Simpan Branding' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Countdown Tab -->
    <div v-if="activeTab === 'countdown'" class="card">
      <div class="card-header">
        <h3 class="font-semibold text-secondary-900">Countdown Dashboard</h3>
      </div>
      <div class="card-body space-y-4">
        <p class="text-sm text-secondary-500">
          Tampilkan countdown di halaman dashboard untuk event atau deadline tertentu.
        </p>

        <!-- Active Toggle -->
        <div class="flex items-center justify-between p-4 bg-secondary-50 rounded-lg">
          <div>
            <p class="font-medium text-secondary-900">Aktifkan Countdown</p>
            <p class="text-sm text-secondary-500">Tampilkan countdown di dashboard</p>
          </div>
          <label class="relative inline-flex items-center cursor-pointer">
            <input type="checkbox" v-model="countdown.active" class="sr-only peer">
            <div class="w-11 h-6 bg-secondary-300 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-100 rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-secondary-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"></div>
          </label>
        </div>

        <div v-if="countdown.active" class="space-y-4 pt-4 border-t border-secondary-200">
          <div>
            <label class="block text-sm font-medium text-secondary-700 mb-1">Judul Countdown</label>
            <input v-model="countdown.title" type="text" class="input" placeholder="Contoh: Deadline Laporan Akhir Tahun" />
          </div>

          <div>
            <label class="block text-sm font-medium text-secondary-700 mb-1">Deskripsi (opsional)</label>
            <input v-model="countdown.description" type="text" class="input" placeholder="Contoh: Laporan harus diselesaikan sebelum..." />
          </div>

          <div>
            <label class="block text-sm font-medium text-secondary-700 mb-1">Tanggal Target</label>
            <input v-model="countdown.target_date" type="datetime-local" class="input" />
          </div>

          <!-- Preview -->
          <div class="p-4 bg-gradient-to-r from-primary-50 to-blue-50 rounded-xl border border-primary-100 mt-4">
            <p class="text-xs text-secondary-500 mb-2">Preview:</p>
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm font-medium text-primary-700">{{ countdown.title || 'Judul Countdown' }}</p>
                <p class="text-xs text-secondary-500 mt-1">{{ countdown.description || 'Deskripsi countdown' }}</p>
              </div>
              <div class="flex gap-2 text-center">
                <div class="bg-white px-2 py-1 rounded shadow-sm">
                  <p class="text-lg font-bold text-primary-700">{{ previewCountdown.days }}</p>
                  <p class="text-xs text-secondary-500">Hari</p>
                </div>
                <div class="bg-white px-2 py-1 rounded shadow-sm">
                  <p class="text-lg font-bold text-primary-700">{{ previewCountdown.hours }}</p>
                  <p class="text-xs text-secondary-500">Jam</p>
                </div>
                <div class="bg-white px-2 py-1 rounded shadow-sm">
                  <p class="text-lg font-bold text-primary-700">{{ previewCountdown.minutes }}</p>
                  <p class="text-xs text-secondary-500">Menit</p>
                </div>
                <div class="bg-white px-2 py-1 rounded shadow-sm">
                  <p class="text-lg font-bold text-primary-700">{{ previewCountdown.seconds }}</p>
                  <p class="text-xs text-secondary-500">Detik</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="flex justify-end gap-3 pt-4 border-t border-secondary-200">
          <router-link to="/" class="btn-secondary">Batal</router-link>
          <button @click="saveCountdown" :disabled="savingCountdown" class="btn-primary">
            {{ savingCountdown ? 'Menyimpan...' : 'Simpan Countdown' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Report Header Tab -->
    <div v-if="activeTab === 'report'" class="space-y-6">
      <!-- Kop Surat -->
      <div class="card">
        <div class="card-header">
          <h3 class="font-semibold text-secondary-900">Kop Surat (Letterhead)</h3>
        </div>
        <div class="card-body space-y-4">
          <p class="text-sm text-secondary-500">Atur kop surat yang akan tampil di bagian atas laporan saat dicetak.</p>

          <!-- Logo Upload -->
          <div>
            <label class="block text-sm font-medium text-secondary-700 mb-2">Logo Instansi</label>
            <div class="flex items-center gap-6">
              <div class="w-20 h-20 rounded-lg bg-secondary-100 flex items-center justify-center overflow-hidden border">
                <img v-if="reportLogoUrl" :src="reportLogoUrl" alt="Logo" class="w-full h-full object-contain" />
                <svg v-else class="w-8 h-8 text-secondary-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
              </div>
              <div>
                <input ref="reportLogoInput" type="file" accept="image/*" class="hidden" @change="uploadReportLogo" />
                <button @click="$refs.reportLogoInput.click()" class="btn-secondary text-sm">
                  <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                  </svg>
                  Upload Logo
                </button>
                <p class="text-xs text-secondary-500 mt-1">PNG/JPG. Max 2MB. Ideal: logo instansi Anda</p>
              </div>
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-secondary-700 mb-1">Nama Instansi</label>
            <input v-model="reportHeader.header.instansi" type="text" class="input" placeholder="Contoh: PEMERINTAH PROVINSI SULAWESI TENGAH" />
          </div>

          <div>
            <label class="block text-sm font-medium text-secondary-700 mb-1">Nama Dinas/OPD</label>
            <input v-model="reportHeader.header.dinas" type="text" class="input" placeholder="Contoh: DINAS PENDIDIKAN" />
          </div>

          <div>
            <label class="block text-sm font-medium text-secondary-700 mb-1">Alamat Lengkap</label>
            <input v-model="reportHeader.header.alamat" type="text" class="input" placeholder="Contoh: Jalan Setia Budi No. 9 Palu Telp. (0451) 421290" />
          </div>

          <!-- Preview Kop Surat -->
          <div class="p-4 bg-secondary-50 rounded-xl mt-4">
            <p class="text-xs text-secondary-500 mb-3">Preview Kop Surat:</p>
            <div class="bg-white p-4 rounded border">
              <div class="flex items-center gap-4">
                <div class="w-16 h-16 flex-shrink-0">
                  <img v-if="reportLogoUrl" :src="reportLogoUrl" class="w-full h-full object-contain" />
                  <div v-else class="w-full h-full bg-secondary-200 rounded flex items-center justify-center">
                    <span class="text-xs text-secondary-400">Logo</span>
                  </div>
                </div>
                <div class="text-center flex-1">
                  <p class="text-xs font-medium text-secondary-600">{{ reportHeader.header.instansi || 'PEMERINTAH PROVINSI ...' }}</p>
                  <p class="text-lg font-bold text-secondary-900">{{ reportHeader.header.dinas || 'DINAS ...' }}</p>
                  <p class="text-xs text-secondary-500">{{ reportHeader.header.alamat || 'Alamat lengkap...' }}</p>
                </div>
              </div>
              <hr class="mt-3 border-t-2 border-secondary-900" />
            </div>
          </div>
        </div>
      </div>

      <!-- Penandatanganan -->
      <div class="card">
        <div class="card-header">
          <h3 class="font-semibold text-secondary-900">Penandatanganan</h3>
        </div>
        <div class="card-body space-y-6">
          <p class="text-sm text-secondary-500">Atur pejabat yang menandatangani laporan (tampil di bagian bawah laporan).</p>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Penandatangan Kiri -->
            <div class="space-y-4 p-4 bg-secondary-50 rounded-xl">
              <h4 class="font-medium text-secondary-900">Penandatangan Kiri</h4>
              <div>
                <label class="block text-sm font-medium text-secondary-700 mb-1">Jabatan</label>
                <input v-model="reportHeader.signatory_left.jabatan" type="text" class="input" placeholder="Contoh: Bendahara Pengeluaran," />
              </div>
              <div>
                <label class="block text-sm font-medium text-secondary-700 mb-1">Nama Lengkap (dengan gelar)</label>
                <input v-model="reportHeader.signatory_left.nama" type="text" class="input" placeholder="Contoh: ASTUTY SULISTIYANTY, ST" />
              </div>
              <div>
                <label class="block text-sm font-medium text-secondary-700 mb-1">NIP</label>
                <input v-model="reportHeader.signatory_left.nip" type="text" class="input" placeholder="Contoh: NIP. 19800924 201001 2 004" />
              </div>
            </div>

            <!-- Penandatangan Kanan -->
            <div class="space-y-4 p-4 bg-secondary-50 rounded-xl">
              <h4 class="font-medium text-secondary-900">Penandatangan Kanan</h4>
              <div>
                <label class="block text-sm font-medium text-secondary-700 mb-1">Jabatan</label>
                <input v-model="reportHeader.signatory_right.jabatan" type="text" class="input" placeholder="Contoh: Pengguna Anggaran," />
              </div>
              <div>
                <label class="block text-sm font-medium text-secondary-700 mb-1">Nama Lengkap (dengan gelar)</label>
                <input v-model="reportHeader.signatory_right.nama" type="text" class="input" placeholder="Contoh: YUDIAWATI V. WINDARRUSLIANA, SKM., M.Kes" />
              </div>
              <div>
                <label class="block text-sm font-medium text-secondary-700 mb-1">NIP</label>
                <input v-model="reportHeader.signatory_right.nip" type="text" class="input" placeholder="Contoh: NIP. 19670712 199003 2 013" />
              </div>
            </div>
          </div>

          <!-- Preview Tanda Tangan -->
          <div class="p-4 bg-secondary-50 rounded-xl">
            <p class="text-xs text-secondary-500 mb-3">Preview Tanda Tangan:</p>
            <div class="bg-white p-4 rounded border">
              <div class="grid grid-cols-2 gap-8 text-center text-sm">
                <div>
                  <p class="text-secondary-700">{{ reportHeader.signatory_left.jabatan || 'Jabatan Kiri,' }}</p>
                  <div class="h-16"></div>
                  <p class="font-bold text-secondary-900 underline">{{ reportHeader.signatory_left.nama || 'NAMA LENGKAP' }}</p>
                  <p class="text-secondary-600 text-xs">{{ reportHeader.signatory_left.nip || 'NIP. ...' }}</p>
                </div>
                <div>
                  <p class="text-secondary-700">{{ reportHeader.signatory_right.jabatan || 'Jabatan Kanan,' }}</p>
                  <div class="h-16"></div>
                  <p class="font-bold text-secondary-900 underline">{{ reportHeader.signatory_right.nama || 'NAMA LENGKAP' }}</p>
                  <p class="text-secondary-600 text-xs">{{ reportHeader.signatory_right.nip || 'NIP. ...' }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="flex justify-end gap-3">
        <router-link to="/" class="btn-secondary">Batal</router-link>
        <button @click="saveReportHeader" :disabled="savingReport" class="btn-primary">
          {{ savingReport ? 'Menyimpan...' : 'Simpan Pengaturan Laporan' }}
        </button>
      </div>
    </div>

    <!-- Lock Year Tab -->
    <div v-if="activeTab === 'lock'" class="card">
      <div class="card-header bg-red-50">
        <h3 class="font-semibold text-red-900">🔒 Kunci Tahun Anggaran</h3>
      </div>
      <div class="card-body space-y-6">
        <div v-if="lockStatus.locked" class="p-4 bg-red-100 border border-red-300 rounded-xl">
          <div class="flex items-center gap-3">
            <span class="text-2xl">🔒</span>
            <div>
              <p class="font-bold text-red-800">Tahun Anggaran {{ lockStatus.tahun }} DIKUNCI</p>
              <p class="text-sm text-red-700">Dikunci pada: {{ lockStatus.locked_at || '-' }}</p>
              <p v-if="lockStatus.locked_reason" class="text-sm text-red-600 mt-1">Alasan: {{ lockStatus.locked_reason }}</p>
            </div>
          </div>
        </div>
        <div v-else class="p-4 bg-green-100 border border-green-300 rounded-xl">
          <div class="flex items-center gap-3">
            <span class="text-2xl">🔓</span>
            <div>
              <p class="font-bold text-green-800">Tahun Anggaran {{ lockStatus.tahun }} AKTIF</p>
              <p class="text-sm text-green-700">User dapat melakukan input pelimpahan dan transaksi lainnya.</p>
            </div>
          </div>
        </div>

        <div class="p-4 bg-secondary-50 rounded-xl space-y-4">
          <p class="text-sm text-secondary-600">
            <strong>Perhatian:</strong> Mengunci tahun anggaran akan mencegah semua user (kecuali Super Admin) untuk:
          </p>
          <ul class="list-disc list-inside text-sm text-secondary-600 space-y-1">
            <li>Input Pelimpahan baru</li>
            <li>Input Setoran Pengembalian</li>
            <li>Top Up Bank / Penarikan Tunai</li>
            <li>Setor ke Kas BUD</li>
          </ul>
        </div>

        <div>
          <label class="block text-sm font-medium text-secondary-700 mb-1">Alasan (opsional)</label>
          <input v-model="lockReason" type="text" class="input" placeholder="Contoh: Tutup Buku Tahun 2025" />
        </div>

        <div class="flex justify-end gap-3 pt-4 border-t border-secondary-200">
          <button v-if="lockStatus.locked" @click="toggleLock(false)" :disabled="togglingLock" class="btn-primary bg-green-600 hover:bg-green-700">
            {{ togglingLock ? 'Memproses...' : '🔓 Buka Kunci Tahun' }}
          </button>
          <button v-else @click="toggleLock(true)" :disabled="togglingLock" class="btn-danger">
            {{ togglingLock ? 'Memproses...' : '🔒 Kunci Tahun Anggaran' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Login Content Tab -->
    <div v-if="activeTab === 'login-content'" class="space-y-6">
      <div class="card">
        <div class="card-header flex items-center justify-between">
          <div>
            <h3 class="font-semibold text-secondary-900">Konten Halaman Login</h3>
            <p class="text-sm text-secondary-500">Kelola konten kiri halaman login berdasarkan jadwal</p>
          </div>
          <button @click="openContentModal(null)" class="btn-primary text-sm">
            + Tambah Konten
          </button>
        </div>
        <div class="card-body p-0">
          <div v-if="loginContents.length === 0" class="p-8 text-center text-secondary-500">
            <p>Belum ada konten. Klik "Tambah Konten" untuk menambah.</p>
          </div>
          <div v-else class="divide-y divide-secondary-200">
            <div v-for="content in loginContents" :key="content.id" class="p-4 flex items-center justify-between hover:bg-secondary-50">
              <div class="flex items-center gap-4">
                <div v-if="content.image_url" class="w-16 h-16 rounded-lg overflow-hidden bg-secondary-100">
                  <img :src="apiBaseUrl + content.image_url" class="w-full h-full object-cover" />
                </div>
                <div v-else class="w-16 h-16 rounded-lg bg-secondary-100 flex items-center justify-center text-2xl">🖼️</div>
                <div>
                  <p class="font-medium text-secondary-900">{{ content.title }}</p>
                  <p class="text-sm text-secondary-500">{{ formatDate(content.start_date) }} - {{ formatDate(content.end_date) }}</p>
                  <span :class="isContentActive(content) ? 'text-green-600 text-xs' : 'text-secondary-400 text-xs'">
                    {{ isContentActive(content) ? '✅ Aktif Sekarang' : '⏳ Terjadwal' }}
                  </span>
                </div>
              </div>
              <div class="flex items-center gap-2">
                <button @click="openContentModal(content)" class="p-2 text-primary-600 hover:bg-primary-50 rounded-lg">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" /></svg>
                </button>
                <button @click="deleteContent(content)" class="p-2 text-red-600 hover:bg-red-50 rounded-lg">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Login Content Modal -->
    <div v-if="showContentModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-black/50" @click="showContentModal = false"></div>
      <div class="relative bg-white rounded-xl shadow-xl max-w-lg w-full max-h-[90vh] overflow-y-auto">
        <div class="p-6 border-b border-secondary-200">
          <h3 class="text-lg font-semibold text-secondary-900">{{ editingContent ? 'Edit Konten' : 'Tambah Konten' }}</h3>
        </div>
        <div class="p-6 space-y-4">
          <div>
            <label class="label">Judul <span class="text-red-500">*</span></label>
            <input v-model="contentForm.title" type="text" class="input" placeholder="Selamat Natal 2025! 🎄" required />
          </div>
          <div>
            <label class="label">Deskripsi</label>
            <textarea v-model="contentForm.description" class="input" rows="3" placeholder="Pesan singkat..."></textarea>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="label">Tanggal Mulai <span class="text-red-500">*</span></label>
              <input v-model="contentForm.start_date" type="date" class="input" required />
            </div>
            <div>
              <label class="label">Tanggal Selesai <span class="text-red-500">*</span></label>
              <input v-model="contentForm.end_date" type="date" class="input" required />
            </div>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="label">Lebar Gambar (px)</label>
              <input v-model.number="contentForm.image_width" type="number" class="input" min="200" max="800" />
              <p class="text-xs text-secondary-400 mt-1">200-800px. Landscape: 600-800px</p>
            </div>
            <div>
              <label class="label">Font Judul (px)</label>
              <input v-model.number="contentForm.title_size" type="number" class="input" min="12" max="48" />
            </div>
          </div>
          <div>
            <label class="label">Gambar Ilustrasi</label>
            <div v-if="editingContent?.image_url || previewImageUrl" class="mb-2">
              <img :src="previewImageUrl || (apiBaseUrl + editingContent.image_url)" class="max-w-full max-h-48 object-contain rounded-lg bg-secondary-100" />
            </div>
            <input type="file" ref="imageInput" @change="handleImageSelect" accept="image/*" class="input" />
            <p class="text-xs text-secondary-500 mt-1">PNG, JPG, WebP. Max 2MB. Landscape direkomendasikan.</p>
          </div>
        </div>
        <div class="p-6 border-t border-secondary-200 flex justify-end gap-3">
          <button @click="showContentModal = false" class="btn-secondary">Batal</button>
          <button @click="saveContent" :disabled="savingContent" class="btn-primary">
            {{ savingContent ? 'Menyimpan...' : 'Simpan' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import api from '@/services/api'
import { useNotificationStore } from '@/stores/notification'

const notificationStore = useNotificationStore()

const activeTab = ref('branding')
const loading = ref(false)

// Branding settings
const savingBranding = ref(false)
const branding = ref({
  app_name: '',
  app_subtitle: '',
  logo_url: ''
})

// Lock Year settings
const lockStatus = ref({
  locked: false,
  tahun: '2025',
  locked_at: null,
  locked_reason: ''
})
const lockReason = ref('')
const togglingLock = ref(false)

// Countdown settings
const savingCountdown = ref(false)
const countdown = ref({
  active: false,
  title: '',
  description: '',
  target_date: ''
})

const previewCountdown = ref({ days: '00', hours: '00', minutes: '00', seconds: '00' })
let previewInterval = null

// Report Header settings
const savingReport = ref(false)
const reportHeader = ref({
  header: {
    logo_url: '',
    instansi: '',
    dinas: '',
    alamat: ''
  },
  signatory_left: {
    jabatan: '',
    nama: '',
    nip: ''
  },
  signatory_right: {
    jabatan: '',
    nama: '',
    nip: ''
  }
})

// Login Content settings
const loginContents = ref([])
const showContentModal = ref(false)
const editingContent = ref(null)
const savingContent = ref(false)
const previewImageUrl = ref(null)
const selectedFile = ref(null)
const imageInput = ref(null)
const contentForm = ref({
  title: '',
  description: '',
  start_date: '',
  end_date: '',
  image_width: 400,
  title_size: 28,
  desc_size: 16
})

// Helper to get full logo URL from relative path
const apiBaseUrl = import.meta.env.VITE_API_URL?.replace('/api', '') || 'http://localhost:8000'
const reportLogoUrl = computed(() => {
  const url = reportHeader.value.header.logo_url
  if (!url) return ''
  if (url.startsWith('http')) return url
  return apiBaseUrl + url
})

function updatePreview() {
  if (!countdown.value.target_date) {
    previewCountdown.value = { days: '00', hours: '00', minutes: '00', seconds: '00' }
    return
  }
  
  const now = new Date().getTime()
  const target = new Date(countdown.value.target_date).getTime()
  const diff = target - now
  
  if (diff <= 0) {
    previewCountdown.value = { days: '00', hours: '00', minutes: '00', seconds: '00' }
    return
  }
  
  const days = Math.floor(diff / (1000 * 60 * 60 * 24))
  const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
  const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
  const seconds = Math.floor((diff % (1000 * 60)) / 1000)
  
  previewCountdown.value = {
    days: String(days).padStart(2, '0'),
    hours: String(hours).padStart(2, '0'),
    minutes: String(minutes).padStart(2, '0'),
    seconds: String(seconds).padStart(2, '0')
  }
}

watch(() => countdown.value.target_date, updatePreview)

onMounted(async () => {
  loading.value = true
  
  // Load branding settings
  try {
    const response = await api.get('/settings/branding')
    if (response.data.success && response.data.data) {
      branding.value = {
        app_name: response.data.data.app_name || 'Pelimpahan',
        app_subtitle: response.data.data.app_subtitle || 'Dana UP/GU',
        logo_url: response.data.data.logo_url || ''
      }
    }
  } catch (error) {
    console.log('No branding settings found')
  }
  
  // Load countdown settings
  try {
    const response = await api.get('/settings/countdown')
    if (response.data.success && response.data.data) {
      countdown.value = {
        active: response.data.data.active || false,
        title: response.data.data.title || '',
        description: response.data.data.description || '',
        target_date: response.data.data.target_date || ''
      }
    }
  } catch (error) {
    console.log('No countdown settings found')
  }
  
  // Load login contents
  await loadLoginContents()
  
  loading.value = false
  previewInterval = setInterval(updatePreview, 1000)
  updatePreview()
})

onUnmounted(() => {
  if (previewInterval) clearInterval(previewInterval)
})

async function uploadLogo(event) {
  const file = event.target.files[0]
  if (!file) return
  
  if (file.size > 2 * 1024 * 1024) {
    notificationStore.error('Ukuran file maksimal 2MB')
    return
  }
  
  try {
    const formData = new FormData()
    formData.append('logo', file)
    const response = await api.post('/settings/logo', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    if (response.data.success) {
      branding.value.logo_url = response.data.data.logo_url
      notificationStore.success('Logo berhasil diupload')
    }
  } catch (error) {
    notificationStore.error('Gagal mengupload logo')
  }
}

async function saveBranding() {
  savingBranding.value = true
  try {
    const response = await api.put('/settings/branding', branding.value)
    if (response.data.success) {
      notificationStore.success('Pengaturan branding berhasil disimpan')
    }
  } catch (error) {
    notificationStore.error('Gagal menyimpan pengaturan')
  } finally {
    savingBranding.value = false
  }
}

async function saveCountdown() {
  savingCountdown.value = true
  try {
    const response = await api.put('/settings/countdown', countdown.value)
    if (response.data.success) {
      notificationStore.success('Pengaturan countdown berhasil disimpan')
    }
  } catch (error) {
    notificationStore.error('Gagal menyimpan pengaturan')
  } finally {
    savingCountdown.value = false
  }
}

// Report Header Functions
async function loadReportHeader() {
  try {
    const response = await api.get('/settings/report-header')
    if (response.data.success && response.data.data) {
      const data = response.data.data
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
    console.log('No report header settings found')
  }
}

async function uploadReportLogo(event) {
  const file = event.target.files[0]
  if (!file) return
  
  if (file.size > 2 * 1024 * 1024) {
    notificationStore.error('Ukuran file maksimal 2MB')
    return
  }
  
  try {
    const formData = new FormData()
    formData.append('logo', file)
    const response = await api.post('/settings/report-logo', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    if (response.data.success) {
      reportHeader.value.header.logo_url = response.data.data.logo_url
      notificationStore.success('Logo kop surat berhasil diupload')
    }
  } catch (error) {
    notificationStore.error('Gagal mengupload logo')
  }
}

async function saveReportHeader() {
  savingReport.value = true
  try {
    const response = await api.put('/settings/report-header', reportHeader.value)
    if (response.data.success) {
      notificationStore.success('Pengaturan laporan berhasil disimpan')
    }
  } catch (error) {
    notificationStore.error('Gagal menyimpan pengaturan')
  } finally {
    savingReport.value = false
  }
}

// Load report header on mount
onMounted(async () => {
  await loadReportHeader()
  await loadLockStatus()
})

// Lock Status Functions
async function loadLockStatus() {
  try {
    const response = await api.get('/settings/lock-status')
    if (response.data.success && response.data.data) {
      lockStatus.value = response.data.data
    }
  } catch (error) {
    console.log('No lock status found')
  }
}

async function toggleLock(lock) {
  togglingLock.value = true
  try {
    const response = await api.post('/settings/toggle-lock', {
      locked: lock,
      reason: lockReason.value
    })
    if (response.data.success) {
      lockStatus.value = response.data.data
      notificationStore.success(response.data.message)
      lockReason.value = ''
    }
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal mengubah status kunci')
  } finally {
    togglingLock.value = false
  }
}

// ========== LOGIN CONTENT FUNCTIONS ==========
async function loadLoginContents() {
  try {
    const response = await api.get('/login-content')
    if (response.data.success) {
      loginContents.value = response.data.data || []
    }
  } catch (error) {
    console.log('Failed to load login contents')
  }
}

function openContentModal(content) {
  // Reset preview
  previewImageUrl.value = null
  selectedFile.value = null
  
  if (content) {
    editingContent.value = content
    contentForm.value = {
      title: content.title,
      description: content.description || '',
      start_date: content.start_date?.split('T')[0] || '',
      end_date: content.end_date?.split('T')[0] || '',
      image_width: content.image_width || 400,
      title_size: content.title_size || 28,
      desc_size: content.desc_size || 16
    }
  } else {
    editingContent.value = null
    contentForm.value = {
      title: '',
      description: '',
      start_date: '',
      end_date: '',
      image_width: 400,
      title_size: 28,
      desc_size: 16
    }
  }
  showContentModal.value = true
}

async function saveContent() {
  if (!contentForm.value.title || !contentForm.value.start_date || !contentForm.value.end_date) {
    notificationStore.error('Judul dan tanggal wajib diisi')
    return
  }
  
  savingContent.value = true
  try {
    let contentId
    if (editingContent.value) {
      await api.put(`/login-content/${editingContent.value.id}`, contentForm.value)
      contentId = editingContent.value.id
      notificationStore.success('Konten berhasil diupdate')
    } else {
      const response = await api.post('/login-content', contentForm.value)
      contentId = response.data.data?.id
      notificationStore.success('Konten berhasil ditambahkan')
    }
    
    // Upload image if selected
    if (selectedFile.value && contentId) {
      const formData = new FormData()
      formData.append('image', selectedFile.value)
      await api.post(`/login-content/${contentId}/image`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })
    }
    
    showContentModal.value = false
    previewImageUrl.value = null
    selectedFile.value = null
    await loadLoginContents()
  } catch (error) {
    notificationStore.error(error.response?.data?.message || 'Gagal menyimpan')
  } finally {
    savingContent.value = false
  }
}

async function deleteContent(content) {
  if (!confirm(`Hapus konten "${content.title}"?`)) return
  
  try {
    await api.delete(`/login-content/${content.id}`)
    notificationStore.success('Konten berhasil dihapus')
    await loadLoginContents()
  } catch (error) {
    notificationStore.error('Gagal menghapus')
  }
}

function handleImageSelect(event) {
  const file = event.target.files[0]
  if (!file) return
  
  if (file.size > 2 * 1024 * 1024) {
    notificationStore.error('Ukuran file maksimal 2MB')
    return
  }
  
  selectedFile.value = file
  previewImageUrl.value = URL.createObjectURL(file)
}

function isContentActive(content) {
  const today = new Date().toISOString().split('T')[0]
  const start = content.start_date?.split('T')[0]
  const end = content.end_date?.split('T')[0]
  return start <= today && today <= end && content.is_active
}

function formatDate(dateStr) {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' })
}
</script>
