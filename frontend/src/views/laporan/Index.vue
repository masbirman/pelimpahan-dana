<template>
  <div class="space-y-6 animate-fadeIn">
    <!-- Header -->
    <div>
      <h1 class="text-2xl font-bold text-secondary-900">Laporan</h1>
      <p class="text-secondary-500">Pilih jenis laporan yang ingin dicetak</p>
    </div>

    <!-- Report Cards Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <!-- Laporan per Unit -->
      <router-link to="/laporan/per-unit" class="card hover:shadow-lg transition-shadow group">
        <div class="card-body text-center py-8">
          <div class="w-16 h-16 mx-auto mb-4 rounded-2xl bg-blue-100 flex items-center justify-center group-hover:scale-110 transition-transform">
            <svg class="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
            </svg>
          </div>
          <h3 class="text-lg font-semibold text-secondary-900 mb-2">Laporan per Unit Kerja</h3>
          <p class="text-sm text-secondary-500">Rekap pelimpahan berdasarkan unit kerja penerima</p>
        </div>
      </router-link>

      <!-- Laporan per Periode -->
      <router-link to="/laporan/per-periode" class="card hover:shadow-lg transition-shadow group">
        <div class="card-body text-center py-8">
          <div class="w-16 h-16 mx-auto mb-4 rounded-2xl bg-emerald-100 flex items-center justify-center group-hover:scale-110 transition-transform">
            <svg class="w-8 h-8 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
          </div>
          <h3 class="text-lg font-semibold text-secondary-900 mb-2">Laporan per Periode</h3>
          <p class="text-sm text-secondary-500">Rekap pelimpahan berdasarkan rentang tanggal</p>
        </div>
      </router-link>

      <!-- Laporan per Jenis -->
      <router-link to="/laporan/per-jenis" class="card hover:shadow-lg transition-shadow group">
        <div class="card-body text-center py-8">
          <div class="w-16 h-16 mx-auto mb-4 rounded-2xl bg-purple-100 flex items-center justify-center group-hover:scale-110 transition-transform">
            <svg class="w-8 h-8 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
            </svg>
          </div>
          <h3 class="text-lg font-semibold text-secondary-900 mb-2">Laporan per Jenis</h3>
          <p class="text-sm text-secondary-500">Rekap pelimpahan berdasarkan jenis (UP, TUP, LS)</p>
        </div>
      </router-link>
    </div>
  </div>
</template>

<script setup>
</script>
