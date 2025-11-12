import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import RubyPlugin from 'vite-plugin-ruby'
import { resolve } from 'path'
import { viteSecurityHeadersPlugin } from './app/frontend/config/security-headers'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue(), RubyPlugin(), viteSecurityHeadersPlugin()],
  resolve: {
    alias: {
      '@': resolve(__dirname, './app/frontend'),
      '@components': resolve(__dirname, './app/frontend/components'),
      '@composables': resolve(__dirname, './app/frontend/composables'),
      '@assets': resolve(__dirname, './app/frontend/assets'),
      '@types': resolve(__dirname, './app/frontend/types'),
    },
  },
  server: {
    hmr: {
      host: 'localhost',
      clientPort: 3036,
    },
  },
  build: {
    // Target modern browsers for optimal performance
    target: 'es2020',
    // Smaller chunk size for better caching
    chunkSizeWarningLimit: 150,
    rollupOptions: {
      output: {
        // Manual chunking strategy for optimal code splitting
        manualChunks: (id) => {
          // Vendor chunks
          if (id.includes('node_modules')) {
            if (id.includes('vue') || id.includes('pinia') || id.includes('@vueuse')) {
              return 'vue-vendor'
            }
            if (id.includes('lucide-vue-next')) {
              return 'ui-vendor'
            }
            if (id.includes('dompurify')) {
              return 'security-vendor'
            }
            // Other node_modules go to default vendor chunk
            return 'vendor'
          }

          // Split organisms by engine for better lazy loading
          if (id.includes('/components/organisms/')) {
            if (id.includes('Proposal')) return 'organisms-proposals'
            if (id.includes('Microcredit')) return 'organisms-microcredit'
            if (id.includes('Collaboration')) return 'organisms-collaborations'
            if (id.includes('Verification') || id.includes('SMS')) return 'organisms-verification'
            if (id.includes('Participation')) return 'organisms-participation'
            if (id.includes('Vote') || id.includes('Comment')) return 'organisms-voting'
            if (id.includes('User') || id.includes('Profile')) return 'organisms-user'
            return 'organisms-common'
          }

          // Split atoms and molecules into separate chunks
          if (id.includes('/components/atoms/')) {
            return 'atoms'
          }
          if (id.includes('/components/molecules/')) {
            return 'molecules'
          }

          // Composables
          if (id.includes('/composables/')) {
            return 'composables'
          }

          // Types and utilities
          if (id.includes('/types/')) {
            return 'types'
          }
        },
      },
    },
  },
  // Optimize deps for faster cold start
  optimizeDeps: {
    include: ['vue', 'pinia', '@vueuse/core', 'lucide-vue-next'],
  },
  test: {
    globals: true,
    environment: 'jsdom',
    root: './app/frontend',
    setupFiles: ['./test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'app/frontend/test/',
        '**/*.d.ts',
        '**/*.config.*',
        '**/mockData',
        '**/__tests__',
        '.storybook/',
      ],
    },
  },
})
