<script setup lang="ts">
import { computed } from 'vue'

export interface ProgressProps {
  /** Progress value (0-100) */
  value?: number
  /** Maximum value */
  max?: number
  /** Progress variant/color */
  variant?: 'primary' | 'secondary' | 'success' | 'danger' | 'warning' | 'info'
  /** Progress size */
  size?: 'sm' | 'md' | 'lg'
  /** Show progress label */
  showLabel?: boolean
  /** Custom label */
  label?: string
  /** Striped background */
  striped?: boolean
  /** Animated stripes */
  animated?: boolean
  /** Indeterminate state (unknown progress) */
  indeterminate?: boolean
}

const props = withDefaults(defineProps<ProgressProps>(), {
  value: 0,
  max: 100,
  variant: 'primary',
  size: 'md',
  showLabel: false,
  striped: false,
  animated: false,
  indeterminate: false,
})

const percentage = computed(() => {
  if (props.indeterminate) return 100
  return Math.min(Math.max((props.value / props.max) * 100, 0), 100)
})

const containerClasses = computed(() => {
  const classes: string[] = ['w-full bg-gray-200 rounded-full overflow-hidden']

  // Size variants
  const sizeClasses = {
    sm: 'h-2',
    md: 'h-3',
    lg: 'h-4',
  }
  classes.push(sizeClasses[props.size])

  return classes.join(' ')
})

const barClasses = computed(() => {
  const classes: string[] = ['h-full transition-all duration-300 ease-in-out']

  // Variant colors
  const variantClasses = {
    primary: 'bg-primary-600',
    secondary: 'bg-secondary-600',
    success: 'bg-green-600',
    danger: 'bg-red-600',
    warning: 'bg-yellow-500',
    info: 'bg-blue-600',
  }
  classes.push(variantClasses[props.variant])

  // Striped
  if (props.striped || props.animated) {
    classes.push('bg-striped')
  }

  // Animated
  if (props.animated) {
    classes.push('animate-stripes')
  }

  // Indeterminate
  if (props.indeterminate) {
    classes.push('animate-indeterminate')
  }

  return classes.join(' ')
})

const labelText = computed(() => {
  if (props.label) return props.label
  if (props.indeterminate) return 'Loading...'
  return `${Math.round(percentage.value)}%`
})
</script>

<template>
  <div>
    <div v-if="showLabel" class="mb-1 flex justify-between">
      <span class="text-sm font-medium text-gray-700">{{ labelText }}</span>
    </div>
    <div
      :class="containerClasses"
      role="progressbar"
      :aria-valuenow="value"
      :aria-valuemin="0"
      :aria-valuemax="max"
    >
      <div :class="barClasses" :style="{ width: indeterminate ? '30%' : `${percentage}%` }"></div>
    </div>
  </div>
</template>

<style scoped>
.bg-striped {
  background-image: linear-gradient(
    45deg,
    rgba(255, 255, 255, 0.15) 25%,
    transparent 25%,
    transparent 50%,
    rgba(255, 255, 255, 0.15) 50%,
    rgba(255, 255, 255, 0.15) 75%,
    transparent 75%,
    transparent
  );
  background-size: 1rem 1rem;
}

@keyframes stripes {
  0% {
    background-position: 0 0;
  }
  100% {
    background-position: 1rem 0;
  }
}

.animate-stripes {
  animation: stripes 1s linear infinite;
}

@keyframes indeterminate {
  0% {
    transform: translateX(-100%);
  }
  100% {
    transform: translateX(400%);
  }
}

.animate-indeterminate {
  animation: indeterminate 1.5s ease-in-out infinite;
}
</style>
