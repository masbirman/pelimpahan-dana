import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/auth/Login.vue'),
    meta: { guest: true }
  },
  {
    path: '/',
    component: () => import('@/components/layout/AdminLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'Dashboard',
        component: () => import('@/views/dashboard/Dashboard.vue')
      },
      {
        path: 'profile',
        name: 'Profile',
        component: () => import('@/views/Profile.vue')
      },
      // Units
      {
        path: 'units',
        name: 'Units',
        component: () => import('@/views/unit/Index.vue')
      },
      {
        path: 'units/create',
        name: 'CreateUnit',
        component: () => import('@/views/unit/Form.vue')
      },
      {
        path: 'units/:id/edit',
        name: 'EditUnit',
        component: () => import('@/views/unit/Form.vue')
      },
      // Jenis Pelimpahan
      {
        path: 'jenis-pelimpahan',
        name: 'JenisPelimpahan',
        component: () => import('@/views/jenis-pelimpahan/Index.vue')
      },
      {
        path: 'jenis-pelimpahan/create',
        name: 'CreateJenisPelimpahan',
        component: () => import('@/views/jenis-pelimpahan/Form.vue')
      },
      {
        path: 'jenis-pelimpahan/:id/edit',
        name: 'EditJenisPelimpahan',
        component: () => import('@/views/jenis-pelimpahan/Form.vue')
      },
      // Pelimpahan
      {
        path: 'pelimpahan',
        name: 'Pelimpahan',
        component: () => import('@/views/pelimpahan/Index.vue')
      },
      {
        path: 'pelimpahan/create',
        name: 'CreatePelimpahan',
        component: () => import('@/views/pelimpahan/Create.vue')
      },
      {
        path: 'pelimpahan/print',
        name: 'PrintPelimpahan',
        component: () => import('@/views/pelimpahan/ListReport.vue')
      },
      {
        path: 'pelimpahan/:id',
        name: 'ViewPelimpahan',
        component: () => import('@/views/pelimpahan/Report.vue')
      },
      {
        path: 'pelimpahan/:id/edit',
        name: 'EditPelimpahan',
        component: () => import('@/views/pelimpahan/Create.vue')
      },
      // Laporan
      {
        path: 'laporan',
        name: 'Laporan',
        component: () => import('@/views/laporan/Index.vue')
      },
      {
        path: 'laporan/per-unit',
        name: 'LaporanPerUnit',
        component: () => import('@/views/laporan/PerUnit.vue')
      },
      {
        path: 'laporan/per-periode',
        name: 'LaporanPerPeriode',
        component: () => import('@/views/laporan/PerPeriode.vue')
      },
      {
        path: 'laporan/per-jenis',
        name: 'LaporanPerJenis',
        component: () => import('@/views/laporan/PerJenis.vue')
      },
      {
        path: 'laporan/saldo',
        name: 'LaporanSaldo',
        component: () => import('@/views/laporan/Saldo.vue')
      },
      // Saldo Bendahara (Bendahara & Super Admin)
      {
        path: 'saldo-bendahara',
        name: 'SaldoBendahara',
        component: () => import('@/views/saldo-bendahara/Index.vue'),
        meta: { roles: ['bendahara', 'super_admin'] }
      },
      {
        path: 'saldo-bendahara/create',
        name: 'CreateSaldoBendahara',
        component: () => import('@/views/saldo-bendahara/Form.vue'),
        meta: { roles: ['bendahara', 'super_admin'] }
      },
      {
        path: 'saldo-bendahara/:id/edit',
        name: 'EditSaldoBendahara',
        component: () => import('@/views/saldo-bendahara/Form.vue'),
        meta: { roles: ['bendahara', 'super_admin'] }
      },
      // Top Up Saldo (Bendahara & Super Admin)
      {
        path: 'saldo-bendahara/top-up',
        name: 'TopUpSaldo',
        component: () => import('@/views/saldo-bendahara/TopUp.vue'),
        meta: { roles: ['bendahara', 'super_admin'] }
      },
      // Penarikan Tunai (Bendahara & Super Admin)
      {
        path: 'saldo-bendahara/penarikan-tunai',
        name: 'PenarikanTunai',
        component: () => import('@/views/saldo-bendahara/PenarikanTunai.vue'),
        meta: { roles: ['bendahara', 'super_admin'] }
      },
      // Users (Super Admin only)
      {
        path: 'users',
        name: 'Users',
        component: () => import('@/views/user/Index.vue'),
        meta: { roles: ['super_admin'] }
      },
      {
        path: 'users/create',
        name: 'CreateUser',
        component: () => import('@/views/user/Form.vue'),
        meta: { roles: ['super_admin'] }
      },
      {
        path: 'users/:id/edit',
        name: 'EditUser',
        component: () => import('@/views/user/Form.vue'),
        meta: { roles: ['super_admin'] }
      },
      // Settings (Super Admin only)
      {
        path: 'settings',
        name: 'Settings',
        component: () => import('@/views/Settings.vue'),
        meta: { roles: ['super_admin'] }
      }
    ]
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Navigation guard
router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()
  
  // If user has token but no user data, wait for checkAuth to complete
  if (authStore.token && !authStore.user) {
    await authStore.checkAuth()
  }
  
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login')
  } else if (to.meta.guest && authStore.isAuthenticated) {
    next('/')
  } else if (to.meta.roles && !to.meta.roles.includes(authStore.user?.role)) {
    next('/')
  } else {
    next()
  }
})

export default router
