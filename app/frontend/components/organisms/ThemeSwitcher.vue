<template>
  <div class="theme-switcher">
    <div class="theme-switcher-header">
      <h3 class="theme-switcher-title">Seleccionar Tema</h3>
      <button
        v-if="isDark"
        @click="toggleDarkMode"
        class="dark-mode-toggle"
        aria-label="Cambiar a modo claro"
      >
        <svg class="icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"
          />
        </svg>
        Modo Claro
      </button>
      <button
        v-else
        @click="toggleDarkMode"
        class="dark-mode-toggle"
        aria-label="Cambiar a modo oscuro"
      >
        <svg class="icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"
          />
        </svg>
        Modo Oscuro
      </button>
    </div>

    <div v-if="isLoading" class="theme-switcher-loading">
      <div class="spinner"></div>
      <p>Cargando temas...</p>
    </div>

    <div v-else class="theme-grid">
      <div
        v-for="theme in themes"
        :key="theme.id"
        class="theme-card"
        :class="{
          active: currentTheme?.id === theme.id,
        }"
        @click="handleThemeSelect(theme)"
        role="button"
        tabindex="0"
        @keydown.enter="handleThemeSelect(theme)"
        @keydown.space.prevent="handleThemeSelect(theme)"
      >
        <div class="theme-card-header">
          <h4 class="theme-card-title">{{ theme.name }}</h4>
          <svg
            v-if="currentTheme?.id === theme.id"
            class="theme-card-check"
            fill="currentColor"
            viewBox="0 0 20 20"
          >
            <path
              fill-rule="evenodd"
              d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
              clip-rule="evenodd"
            />
          </svg>
        </div>

        <div class="theme-card-colors">
          <div
            v-if="theme.colors.primary"
            class="color-swatch"
            :style="{ backgroundColor: theme.colors.primary }"
            :title="`Primary: ${theme.colors.primary}`"
          ></div>
          <div
            v-if="theme.colors.secondary"
            class="color-swatch"
            :style="{ backgroundColor: theme.colors.secondary }"
            :title="`Secondary: ${theme.colors.secondary}`"
          ></div>
          <div
            v-if="theme.colors.success"
            class="color-swatch"
            :style="{ backgroundColor: theme.colors.success }"
            :title="`Success: ${theme.colors.success}`"
          ></div>
        </div>

        <div v-if="theme.fontFamily" class="theme-card-font">
          <span :style="{ fontFamily: theme.fontFamily }">Aa</span>
        </div>
      </div>
    </div>

    <div v-if="!isLoading && themes.length === 0" class="theme-switcher-empty">
      <p>No hay temas disponibles</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useTheme, type Theme } from '@/composables/useTheme'

const { currentTheme, themes, isDark, isLoading, setTheme, toggleDarkMode, loadThemes } = useTheme()

const handleThemeSelect = (theme: Theme) => {
  setTheme(theme.id)
}

onMounted(async () => {
  await loadThemes()
})
</script>

<style scoped>
.theme-switcher {
  background: white;
  border-radius: 0.75rem;
  padding: 1.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);
}

.theme-switcher-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.theme-switcher-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.dark-mode-toggle {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  background-color: #f3f4f6;
  border: 1px solid #e5e7eb;
  border-radius: 0.375rem;
  font-size: 0.875rem;
  font-weight: 500;
  color: #374151;
  cursor: pointer;
  transition: all 0.2s;
}

.dark-mode-toggle:hover {
  background-color: #e5e7eb;
  border-color: #d1d5db;
}

.dark-mode-toggle:focus {
  outline: none;
  box-shadow: 0 0 0 2px #fff, 0 0 0 4px #3b82f6;
}

.icon {
  width: 1.25rem;
  height: 1.25rem;
}

.theme-switcher-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  color: #6b7280;
}

.spinner {
  width: 2rem;
  height: 2rem;
  border: 3px solid #e5e7eb;
  border-top-color: #3b82f6;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.theme-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 1rem;
}

.theme-card {
  background: white;
  border: 2px solid #e5e7eb;
  border-radius: 0.5rem;
  padding: 1rem;
  cursor: pointer;
  transition: all 0.2s;
}

.theme-card:hover {
  border-color: #d1d5db;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.theme-card:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.theme-card.active {
  border-color: #3b82f6;
  background-color: #eff6ff;
}

.theme-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
}

.theme-card-title {
  font-size: 1rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.theme-card-check {
  width: 1.25rem;
  height: 1.25rem;
  color: #3b82f6;
  flex-shrink: 0;
}

.theme-card-colors {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.color-swatch {
  width: 2rem;
  height: 2rem;
  border-radius: 0.25rem;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
}

.theme-card-font {
  text-align: center;
  font-size: 1.5rem;
  color: #6b7280;
}

.theme-switcher-empty {
  text-align: center;
  padding: 3rem;
  color: #6b7280;
}

/* Dark mode styles */
.dark .theme-switcher {
  background: #1f2937;
}

.dark .theme-switcher-title {
  color: #f9fafb;
}

.dark .dark-mode-toggle {
  background-color: #374151;
  border-color: #4b5563;
  color: #f3f4f6;
}

.dark .dark-mode-toggle:hover {
  background-color: #4b5563;
  border-color: #6b7280;
}

.dark .theme-card {
  background: #374151;
  border-color: #4b5563;
}

.dark .theme-card:hover {
  border-color: #6b7280;
}

.dark .theme-card.active {
  border-color: #60a5fa;
  background-color: #1e3a8a;
}

.dark .theme-card-title {
  color: #f9fafb;
}

.dark .spinner {
  border-color: #4b5563;
  border-top-color: #60a5fa;
}
</style>
