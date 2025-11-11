<template>
  <Teleport to="body">
    <Transition
      enter-active-class="transition-opacity duration-200"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition-opacity duration-200"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div
        v-if="modelValue"
        :class="['fixed inset-0 z-50 flex items-center justify-center', overlayClasses]"
        role="dialog"
        aria-modal="true"
        aria-live="polite"
        aria-busy="true"
        :aria-label="label || 'Loading'"
      >
        <div :class="['flex flex-col items-center gap-4', contentClasses]">
          <!-- Spinner -->
          <div v-if="spinner === 'spinner'" :class="spinnerClasses" role="status">
            <Icon name="loader-2" :size="spinnerSize" class="animate-spin" />
          </div>

          <!-- Dots -->
          <div v-else-if="spinner === 'dots'" class="flex gap-2" role="status">
            <div
              v-for="i in 3"
              :key="i"
              :class="['animate-bounce rounded-full', dotSizeClasses, dotColorClasses]"
              :style="{
                animationDelay: `${(i - 1) * 0.15}s`,
              }"
            />
          </div>

          <!-- Pulse -->
          <div
            v-else-if="spinner === 'pulse'"
            :class="['animate-pulse rounded-full', pulseSizeClasses, pulseColorClasses]"
            role="status"
          />

          <!-- Progress Bar -->
          <div
            v-else-if="spinner === 'bar'"
            :class="['w-64 overflow-hidden rounded-full bg-gray-200', barHeightClasses]"
            role="progressbar"
            :aria-valuenow="progress"
            aria-valuemin="0"
            aria-valuemax="100"
          >
            <div
              :class="['h-full transition-all duration-300', barColorClasses]"
              :style="{ width: `${progress}%` }"
            />
          </div>

          <!-- Text -->
          <div v-if="text || $slots.default" :class="['text-center', textClasses]">
            <slot>
              {{ text }}
            </slot>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import Icon from '../atoms/Icon.vue'

/**
 * Loading overlay component that displays a loading indicator over the entire page
 */
export interface Props {
  /**
   * Controls the visibility of the loading overlay
   */
  modelValue: boolean
  /**
   * Type of loading spinner to display
   * @default 'spinner'
   */
  spinner?: 'spinner' | 'dots' | 'pulse' | 'bar'
  /**
   * Size of the loading indicator
   * @default 'md'
   */
  size?: 'sm' | 'md' | 'lg'
  /**
   * Optional text to display below the spinner
   */
  text?: string
  /**
   * Accessible label for screen readers
   */
  label?: string
  /**
   * Opacity of the overlay backdrop
   * @default 'default'
   */
  opacity?: 'light' | 'default' | 'dark'
  /**
   * Progress value for bar spinner (0-100)
   * @default 0
   */
  progress?: number
  /**
   * Whether the backdrop should blur the content
   * @default false
   */
  blur?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  spinner: 'spinner',
  size: 'md',
  opacity: 'default',
  progress: 0,
  blur: false,
})

const overlayClasses = computed(() => {
  const classes = []

  // Opacity
  switch (props.opacity) {
    case 'light':
      classes.push('bg-white/70')
      break
    case 'dark':
      classes.push('bg-black/70')
      break
    default:
      classes.push('bg-white/80')
  }

  // Blur
  if (props.blur) {
    classes.push('backdrop-blur-sm')
  }

  return classes
})

const spinnerSize = computed(() => {
  switch (props.size) {
    case 'sm':
      return 32
    case 'lg':
      return 64
    default:
      return 48
  }
})

const spinnerClasses = computed(() => {
  return 'text-primary'
})

const dotSizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'w-2 h-2'
    case 'lg':
      return 'w-4 h-4'
    default:
      return 'w-3 h-3'
  }
})

const dotColorClasses = computed(() => {
  return 'bg-primary'
})

const pulseSizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'w-12 h-12'
    case 'lg':
      return 'w-24 h-24'
    default:
      return 'w-16 h-16'
  }
})

const pulseColorClasses = computed(() => {
  return 'bg-primary'
})

const barHeightClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'h-1'
    case 'lg':
      return 'h-3'
    default:
      return 'h-2'
  }
})

const barColorClasses = computed(() => {
  return 'bg-primary'
})

const contentClasses = computed(() => {
  return props.opacity === 'dark' ? 'text-white' : 'text-gray-900'
})

const textClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'text-sm'
    case 'lg':
      return 'text-lg'
    default:
      return 'text-base'
  }
})
</script>
