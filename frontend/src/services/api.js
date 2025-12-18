import axios from 'axios'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:8000/api',
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  },
  withCredentials: true
})

// Request interceptor
api.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// Response interceptor
api.interceptors.response.use(
  response => response,
  error => {
    // Only redirect to login if it's an actual authentication error
    if (error.response?.status === 401 && error.response?.data?.message?.includes('Unauthorized')) {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    // For 403 Forbidden, just show error message (don't redirect)
    return Promise.reject(error)
  }
)

export default api
