<script setup lang="ts">
import { computed } from 'vue'

export interface BadgeProps {
  /** Badge variant/color */
  variant?: 'primary' | 'secondary' | 'success' | 'danger' | 'warning' | 'info' | 'neutral'
  /** Badge size */
  size?: 'sm' | 'md' | 'lg'
  /** Dot indicator */
  dot?: boolean
  /** Rounded pill shape */
  pill?: boolean
  /** Removable badge with close button */
  removable?: boolean
}

const props = withDefaults(defineProps<BadgeProps>(), {
  variant: 'primary',
  size: 'md',
  dot: false,
  pill: false,
  removable: false,
})

const emit = defineEmits<{
  remove: []
}>()

const badgeClasses = computed(() => {
  const classes: string[] = [
    'inline-flex items-center gap-1.5 font-medium transition-colors duration-200',
  ]

  // Size variants
  const sizeClasses = {
    sm: 'px-2 py-0.5 text-xs',
    md: 'px-2.5 py-0.5 text-sm',
    lg: 'px-3 py-1 text-base',
  }
  classes.push(sizeClasses[props.size])

  // Shape
  if (props.pill) {
    classes.push('rounded-full')
  } else {
    classes.push('rounded-md')
  }

  // Variant colors
  const variantClasses = {
    primary: 'bg-primary-100 text-primary-800',
    secondary: 'bg-secondary-100 text-secondary-800',
    success: 'bg-green-100 text-green-800',
    danger: 'bg-red-100 text-red-800',
    warning: 'bg-yellow-100 text-yellow-800',
    info: 'bg-blue-100 text-blue-800',
    neutral: 'bg-gray-100 text-gray-800',
  }
  classes.push(variantClasses[props.variant])

  return classes.join(' ')
})

const dotClasses = computed(() => {
  const classes: string[] = ['rounded-full']

  // Size variants for dot
  const sizeClasses = {
    sm: 'h-1.5 w-1.5',
    md: 'h-2 w-2',
    lg: 'h-2.5 w-2.5',
  }
  classes.push(sizeClasses[props.size])

  // Variant colors for dot
  const variantClasses = {
    primary: 'bg-primary-600',
    secondary: 'bg-secondary-600',
    success: 'bg-green-600',
    danger: 'bg-red-600',
    warning: 'bg-yellow-600',
    info: 'bg-blue-600',
    neutral: 'bg-gray-600',
  }
  classes.push(variantClasses[props.variant])

  return classes.join(' ')
})

const closeButtonClasses = computed(() => {
  const classes: string[] = [
    'ml-0.5 inline-flex items-center justify-center rounded-sm',
    'hover:bg-black/10 focus:outline-none focus:ring-2 focus:ring-offset-1',
    'transition-colors duration-200',
  ]

  // Size variants for close button
  const sizeClasses = {
    sm: 'h-3 w-3',
    md: 'h-4 w-4',
    lg: 'h-5 w-5',
  }
  classes.push(sizeClasses[props.size])

  // Focus ring color based on variant
  const focusRingClasses = {
    primary: 'focus:ring-primary-600',
    secondary: 'focus:ring-secondary-600',
    success: 'focus:ring-green-600',
    danger: 'focus:ring-red-600',
    warning: 'focus:ring-yellow-600',
    info: 'focus:ring-blue-600',
    neutral: 'focus:ring-gray-600',
  }
  classes.push(focusRingClasses[props.variant])

  return classes.join(' ')
})

const handleRemove = () => {
  emit('remove')
}
</script>

<template>
  <span :class="badgeClasses">
    <!-- Dot indicator -->
    <span v-if="dot" :class="dotClasses" aria-hidden="true"></span>

    <!-- Badge content -->
    <slot />

    <!-- Remove button -->
    <button
      v-if="removable"
      type="button"
      :class="closeButtonClasses"
      aria-label="Remove"
      @click="handleRemove"
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="2"
        stroke="currentColor"
        class="h-full w-full"
      >
        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
      </svg>
    </button>
  </span>
</template>
