<script setup lang="ts">
import { computed } from 'vue'

export interface SpinnerProps {
  /** Spinner size */
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl'
  /** Spinner variant/color */
  variant?:
    | 'primary'
    | 'secondary'
    | 'success'
    | 'danger'
    | 'warning'
    | 'info'
    | 'neutral'
    | 'white'
  /** Loading text to display */
  text?: string
  /** Show as overlay (fullscreen or container) */
  overlay?: boolean
  /** Overlay type */
  overlayType?: 'fullscreen' | 'container'
}

const props = withDefaults(defineProps<SpinnerProps>(), {
  size: 'md',
  variant: 'primary',
  overlay: false,
  overlayType: 'container',
})

const spinnerClasses = computed(() => {
  const classes: string[] = ['animate-spin rounded-full border-2 border-solid']

  // Size variants
  const sizeClasses = {
    xs: 'h-4 w-4 border-2',
    sm: 'h-6 w-6 border-2',
    md: 'h-8 w-8 border-2',
    lg: 'h-12 w-12 border-3',
    xl: 'h-16 w-16 border-3',
    '2xl': 'h-20 w-20 border-4',
  }
  classes.push(sizeClasses[props.size])

  // Variant colors
  const variantClasses = {
    primary: 'border-primary-600 border-t-transparent',
    secondary: 'border-secondary-600 border-t-transparent',
    success: 'border-green-600 border-t-transparent',
    danger: 'border-red-600 border-t-transparent',
    warning: 'border-yellow-500 border-t-transparent',
    info: 'border-blue-600 border-t-transparent',
    neutral: 'border-gray-600 border-t-transparent',
    white: 'border-white border-t-transparent',
  }
  classes.push(variantClasses[props.variant])

  return classes.join(' ')
})

const textClasses = computed(() => {
  const classes: string[] = ['mt-2 font-medium']

  // Text size based on spinner size
  const textSizeClasses = {
    xs: 'text-xs',
    sm: 'text-sm',
    md: 'text-base',
    lg: 'text-lg',
    xl: 'text-xl',
    '2xl': 'text-2xl',
  }
  classes.push(textSizeClasses[props.size])

  // Text color based on variant (or white for overlay)
  if (props.overlay) {
    classes.push('text-white')
  } else {
    const textColorClasses = {
      primary: 'text-primary-600',
      secondary: 'text-secondary-600',
      success: 'text-green-600',
      danger: 'text-red-600',
      warning: 'text-yellow-600',
      info: 'text-blue-600',
      neutral: 'text-gray-600',
      white: 'text-white',
    }
    classes.push(textColorClasses[props.variant])
  }

  return classes.join(' ')
})

const containerClasses = computed(() => {
  if (!props.overlay) {
    return 'inline-flex flex-col items-center'
  }

  const baseClasses = [
    'flex flex-col items-center justify-center',
    'bg-black/50 backdrop-blur-sm',
    'z-50',
  ]

  if (props.overlayType === 'fullscreen') {
    baseClasses.push('fixed inset-0')
  } else {
    baseClasses.push('absolute inset-0 rounded-lg')
  }

  return baseClasses.join(' ')
})
</script>

<template>
  <div :class="containerClasses" role="status" aria-live="polite">
    <div :class="spinnerClasses" aria-hidden="true"></div>
    <span v-if="text || $slots.default" :class="textClasses">
      <slot>{{ text }}</slot>
    </span>
    <span class="sr-only">Loading...</span>
  </div>
</template>

<style scoped>
@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.animate-spin {
  animation: spin 0.7s linear infinite;
}

.border-3 {
  border-width: 3px;
}
</style>
