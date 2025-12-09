<script setup lang="ts">
/**
 * Flash Messages Component
 *
 * Displays toast-style notifications for success, error, warning, and info messages.
 * Works with both Vue and Rails flash messages.
 *
 * Usage in ERB:
 * <%= vue_component('FlashMessages') %>
 *
 * Usage with Rails flash:
 * <div data-vue-component="FlashMessages"
 *      data-vue-props='<%= flash.map { |k,v| { type: k, message: v } }.to_json %>'>
 * </div>
 */

import { computed, onMounted } from 'vue'
import { useFlash, type FlashType } from '@/composables/useFlash'
import { X, CheckCircle, XCircle, AlertTriangle, Info } from 'lucide-vue-next'

// Props for initial messages from Rails
interface Props {
  initialMessages?: Array<{ type: FlashType; message: string; title?: string }>
  position?: 'top-right' | 'top-left' | 'bottom-right' | 'bottom-left' | 'top-center' | 'bottom-center'
  maxMessages?: number
}

const props = withDefaults(defineProps<Props>(), {
  initialMessages: () => [],
  position: 'top-right',
  maxMessages: 5,
})

const flash = useFlash()

// Icon components mapping
const icons = {
  success: CheckCircle,
  error: XCircle,
  warning: AlertTriangle,
  info: Info,
}

// Style classes mapping
const styles = {
  success: 'bg-green-50 border-green-200 text-green-800',
  error: 'bg-red-50 border-red-200 text-red-800',
  warning: 'bg-yellow-50 border-yellow-200 text-yellow-800',
  info: 'bg-blue-50 border-blue-200 text-blue-800',
}

const iconStyles = {
  success: 'text-green-500',
  error: 'text-red-500',
  warning: 'text-yellow-500',
  info: 'text-blue-500',
}

// Position classes
const positionClasses = computed(() => {
  switch (props.position) {
    case 'top-left':
      return 'top-4 left-4'
    case 'bottom-right':
      return 'bottom-4 right-4'
    case 'bottom-left':
      return 'bottom-4 left-4'
    case 'top-center':
      return 'top-4 left-1/2 -translate-x-1/2'
    case 'bottom-center':
      return 'bottom-4 left-1/2 -translate-x-1/2'
    default:
      return 'top-4 right-4'
  }
})

// Visible messages (limited by maxMessages)
const visibleMessages = computed(() => {
  return flash.messages.value.slice(-props.maxMessages)
})

// Add initial messages from props
onMounted(() => {
  props.initialMessages.forEach(({ type, message, title }) => {
    flash.add(type, message, { title })
  })
})
</script>

<template>
  <Teleport to="body">
    <div
      :class="[
        'fixed z-50 flex flex-col gap-3 max-w-md w-full pointer-events-none',
        positionClasses,
      ]"
      role="region"
      aria-label="Notificaciones"
      aria-live="polite"
    >
      <TransitionGroup
        name="flash"
        tag="div"
        class="flex flex-col gap-3"
      >
        <div
          v-for="msg in visibleMessages"
          :key="msg.id"
          :class="[
            'flex items-start gap-3 p-4 rounded-lg border shadow-lg pointer-events-auto',
            'animate-slide-up',
            styles[msg.type],
          ]"
          role="alert"
        >
          <!-- Icon -->
          <component
            :is="icons[msg.type]"
            :class="['w-5 h-5 flex-shrink-0 mt-0.5', iconStyles[msg.type]]"
            aria-hidden="true"
          />

          <!-- Content -->
          <div class="flex-1 min-w-0">
            <p v-if="msg.title" class="font-medium text-sm">
              {{ msg.title }}
            </p>
            <p :class="['text-sm', msg.title ? 'mt-1 opacity-90' : '']">
              {{ msg.message }}
            </p>
          </div>

          <!-- Dismiss button -->
          <button
            v-if="msg.dismissible !== false"
            @click="flash.remove(msg.id)"
            class="flex-shrink-0 p-1 -m-1 rounded-lg hover:bg-black/5 transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500"
            :aria-label="`Cerrar notificación: ${msg.message}`"
          >
            <X class="w-4 h-4 opacity-60" />
          </button>
        </div>
      </TransitionGroup>
    </div>
  </Teleport>
</template>

<style scoped>
/* Flash message animations */
.flash-enter-active,
.flash-leave-active {
  transition: all 0.3s ease;
}

.flash-enter-from {
  opacity: 0;
  transform: translateX(100%);
}

.flash-leave-to {
  opacity: 0;
  transform: translateX(100%);
}

.flash-move {
  transition: transform 0.3s ease;
}

/* For top-left and bottom-left positions */
[class*="left-4"] .flash-enter-from,
[class*="left-4"] .flash-leave-to {
  transform: translateX(-100%);
}

/* For center positions */
[class*="left-1/2"] .flash-enter-from,
[class*="left-1/2"] .flash-leave-to {
  transform: translateX(-50%) translateY(-20px);
  opacity: 0;
}
</style>
