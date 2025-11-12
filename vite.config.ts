import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import RubyPlugin from 'vite-plugin-ruby'
import { resolve } from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  // Security headers are managed by Rails SecureHeaders gem (config/initializers/secure_headers.rb)
  // Removed viteSecurityHeadersPlugin to avoid duplicate CSP headers
  plugins: [vue(), RubyPlugin()],
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
        // Optimized chunking strategy: ~8 chunks for better HTTP/2 performance
        // Reduced from 15+ chunks to minimize request overhead
        manualChunks: (id) => {
          // Vendor chunks (large, stable dependencies)
          if (id.includes('node_modules')) {
            // Core Vue ecosystem
            if (id.includes('vue') || id.includes('pinia') || id.includes('@vueuse')) {
              return 'vue-vendor'
            }
            // UI + Security vendors combined (both are UI-related)
            if (id.includes('lucide-vue-next') || id.includes('dompurify')) {
              return 'ui-vendor'
            }
            // Other node_modules go to default vendor chunk
            return 'vendor'
          }

          // Group organisms by type (forms vs display) instead of by engine
          if (id.includes('/components/organisms/')) {
            // All forms together (heavy, interactive)
            if (id.includes('Form')) return 'organisms-forms'
            // Display components (cards, stats) together
            if (id.includes('Stats') || id.includes('Card') || id.includes('List')) return 'organisms-display'
            // Common organisms
            return 'organisms-common'
          }

          // Combine atoms + molecules (both are small, frequently used together)
          if (id.includes('/components/atoms/') || id.includes('/components/molecules/')) {
            return 'components'
          }

          // Combine composables + types (both are utilities, small size)
          if (id.includes('/composables/') || id.includes('/types/')) {
            return 'utils'
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
