<script setup lang="ts">
/**
 * Cookie Consent Component
 *
 * GDPR-compliant cookie consent banner with customizable options.
 * Stores user preferences in localStorage and emits events for analytics integration.
 *
 * Usage in ERB:
 * <%= vue_component('CookieConsent',
 *   privacyUrl: page_path('privacy'),
 *   cookiesUrl: page_path('cookies')
 * ) %>
 */

import { ref, onMounted } from 'vue'
import { Cookie, Settings } from 'lucide-vue-next'

interface Props {
  privacyUrl?: string
  cookiesUrl?: string
  showSettings?: boolean
}

withDefaults(defineProps<Props>(), {
  privacyUrl: '/pages/privacy',
  cookiesUrl: '/pages/cookies',
  showSettings: true,
})

const emit = defineEmits<{
  (e: 'accept', preferences: CookiePreferences): void
  (e: 'reject'): void
  (e: 'settings'): void
}>()

interface CookiePreferences {
  necessary: boolean
  analytics: boolean
  marketing: boolean
  preferences: boolean
}

const STORAGE_KEY = 'plebis_cookie_consent'

const isVisible = ref(false)
const showPreferences = ref(false)
const preferences = ref<CookiePreferences>({
  necessary: true, // Always required
  analytics: false,
  marketing: false,
  preferences: false,
})

// Check if consent was already given
onMounted(() => {
  const stored = localStorage.getItem(STORAGE_KEY)
  if (!stored) {
    // Show banner after a short delay for better UX
    setTimeout(() => {
      isVisible.value = true
    }, 1000)
  } else {
    try {
      preferences.value = JSON.parse(stored)
      dispatchConsentEvent(preferences.value)
    } catch (e) {
      isVisible.value = true
    }
  }
})

function acceptAll() {
  preferences.value = {
    necessary: true,
    analytics: true,
    marketing: true,
    preferences: true,
  }
  saveAndClose()
}

function acceptSelected() {
  saveAndClose()
}

function rejectAll() {
  preferences.value = {
    necessary: true,
    analytics: false,
    marketing: false,
    preferences: false,
  }
  saveAndClose()
  emit('reject')
}

function saveAndClose() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(preferences.value))
  dispatchConsentEvent(preferences.value)
  emit('accept', preferences.value)
  isVisible.value = false
}

function dispatchConsentEvent(prefs: CookiePreferences) {
  // Dispatch custom event for analytics and other integrations
  window.dispatchEvent(
    new CustomEvent('cookieConsent', {
      detail: prefs,
    })
  )

  // Also set on window for easy access
  ;(window as any).cookieConsent = prefs
}

function toggleSettings() {
  showPreferences.value = !showPreferences.value
  if (showPreferences.value) {
    emit('settings')
  }
}
</script>

<template>
  <Teleport to="body">
    <Transition
      enter-active-class="transition-transform duration-300 ease-out"
      enter-from-class="translate-y-full"
      enter-to-class="translate-y-0"
      leave-active-class="transition-transform duration-200 ease-in"
      leave-from-class="translate-y-0"
      leave-to-class="translate-y-full"
    >
      <div
        v-if="isVisible"
        class="fixed bottom-0 left-0 right-0 z-50 bg-white border-t border-gray-200 shadow-lg"
        role="dialog"
        aria-modal="true"
        aria-labelledby="cookie-consent-title"
      >
        <div class="container mx-auto px-4 py-4 md:py-6">
          <div class="flex flex-col lg:flex-row lg:items-center gap-4">
            <!-- Icon and Title -->
            <div class="flex items-start gap-3 flex-1">
              <div class="flex-shrink-0 p-2 bg-primary-100 rounded-lg">
                <Cookie class="w-6 h-6 text-primary-600" />
              </div>
              <div class="flex-1">
                <h2 id="cookie-consent-title" class="font-semibold text-gray-900 mb-1">
                  Uso de cookies
                </h2>
                <p class="text-sm text-gray-600">
                  Utilizamos cookies propias y de terceros para mejorar tu experiencia.
                  Puedes aceptar todas, rechazarlas o configurar tus preferencias.
                  <a :href="cookiesUrl" class="text-primary-600 hover:underline">
                    Más información
                  </a>
                </p>
              </div>
            </div>

            <!-- Buttons -->
            <div class="flex flex-col sm:flex-row gap-2 lg:flex-shrink-0">
              <button
                v-if="showSettings"
                @click="toggleSettings"
                class="btn btn-ghost text-sm"
              >
                <Settings class="w-4 h-4 mr-1" />
                Configurar
              </button>
              <button
                @click="rejectAll"
                class="btn btn-ghost text-sm"
              >
                Rechazar
              </button>
              <button
                @click="acceptAll"
                class="btn btn-primary text-sm"
              >
                Aceptar todas
              </button>
            </div>
          </div>

          <!-- Cookie Preferences (expandable) -->
          <Transition
            enter-active-class="transition-all duration-300 ease-out"
            enter-from-class="max-h-0 opacity-0"
            enter-to-class="max-h-96 opacity-100"
            leave-active-class="transition-all duration-200 ease-in"
            leave-from-class="max-h-96 opacity-100"
            leave-to-class="max-h-0 opacity-0"
          >
            <div v-if="showPreferences" class="mt-4 pt-4 border-t border-gray-200 overflow-hidden">
              <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                <!-- Necessary Cookies -->
                <div class="p-3 bg-gray-50 rounded-lg">
                  <div class="flex items-center justify-between mb-2">
                    <span class="font-medium text-sm text-gray-900">Necesarias</span>
                    <span class="text-xs text-gray-500 bg-gray-200 px-2 py-0.5 rounded">Siempre activas</span>
                  </div>
                  <p class="text-xs text-gray-600">
                    Esenciales para el funcionamiento del sitio web.
                  </p>
                </div>

                <!-- Analytics Cookies -->
                <div class="p-3 bg-gray-50 rounded-lg">
                  <label class="flex items-center justify-between mb-2 cursor-pointer">
                    <span class="font-medium text-sm text-gray-900">Analíticas</span>
                    <input
                      v-model="preferences.analytics"
                      type="checkbox"
                      class="toggle"
                    />
                  </label>
                  <p class="text-xs text-gray-600">
                    Nos ayudan a entender cómo interactúas con el sitio.
                  </p>
                </div>

                <!-- Marketing Cookies -->
                <div class="p-3 bg-gray-50 rounded-lg">
                  <label class="flex items-center justify-between mb-2 cursor-pointer">
                    <span class="font-medium text-sm text-gray-900">Marketing</span>
                    <input
                      v-model="preferences.marketing"
                      type="checkbox"
                      class="toggle"
                    />
                  </label>
                  <p class="text-xs text-gray-600">
                    Permiten mostrarte contenido personalizado.
                  </p>
                </div>

                <!-- Preferences Cookies -->
                <div class="p-3 bg-gray-50 rounded-lg">
                  <label class="flex items-center justify-between mb-2 cursor-pointer">
                    <span class="font-medium text-sm text-gray-900">Preferencias</span>
                    <input
                      v-model="preferences.preferences"
                      type="checkbox"
                      class="toggle"
                    />
                  </label>
                  <p class="text-xs text-gray-600">
                    Recuerdan tus preferencias y ajustes.
                  </p>
                </div>
              </div>

              <div class="mt-4 flex justify-end">
                <button
                  @click="acceptSelected"
                  class="btn btn-primary text-sm"
                >
                  Guardar preferencias
                </button>
              </div>
            </div>
          </Transition>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
/* Toggle switch styles */
.toggle {
  @apply relative w-10 h-5 bg-gray-300 rounded-full appearance-none cursor-pointer transition-colors;
}

.toggle:checked {
  @apply bg-primary-600;
}

.toggle::before {
  content: '';
  @apply absolute left-0.5 top-0.5 w-4 h-4 bg-white rounded-full shadow transition-transform;
}

.toggle:checked::before {
  @apply translate-x-5;
}

.toggle:focus {
  @apply ring-2 ring-primary-500 ring-offset-2 outline-none;
}
</style>
