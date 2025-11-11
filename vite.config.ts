import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import RubyPlugin from 'vite-plugin-ruby'
import { resolve } from 'path'

// https://vitejs.dev/config/
export default defineConfig({
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
        // Manual chunking strategy for optimal code splitting
        manualChunks: {
          'vue-vendor': ['vue', 'pinia', '@vueuse/core'],
          'ui-vendor': ['lucide-vue-next'],
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
