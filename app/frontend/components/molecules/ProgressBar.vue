<script setup lang="ts">
import { computed } from 'vue'

export interface ProgressBarProps {
  /** Current progress value (0-100) */
  value: number
  /** Maximum value (default 100) */
  max?: number
  /** Label text */
  label?: string
  /** Show percentage */
  showPercentage?: boolean
  /** Size */
  size?: 'sm' | 'md' | 'lg'
  /** Variant */
  variant?: 'default' | 'success' | 'warning' | 'danger' | 'info' | 'primary'
  /** Animated */
  animated?: boolean
  /** Striped pattern */
  striped?: boolean
}

const props = withDefaults(defineProps<ProgressBarProps>(), {
  max: 100,
  size: 'md',
  variant: 'primary',
  animated: false,
  striped: false,
  showPercentage: false,
})

const percentage = computed(() => {
  return Math.min(100, Math.max(0, (props.value / props.max) * 100))
})

const heightClasses = computed(() => {
  const sizeMap = {
    sm: 'h-2',
    md: 'h-3',
    lg: 'h-4',
  }
  return sizeMap[props.size]
})

const variantClasses = computed(() => {
  const colorMap: Record<string, string> = {
    default: 'bg-gray-600',
    success: 'bg-green-600',
    warning: 'bg-yellow-600',
    danger: 'bg-red-600',
    info: 'bg-blue-600',
    primary: 'bg-primary-600',
  }
  return colorMap[props.variant]
})

const barClasses = computed(() => {
  const classes = [
    variantClasses.value,
    'transition-all',
    'duration-300',
    'ease-in-out',
    'h-full',
    'rounded-full',
  ]

  if (props.striped) {
    classes.push('bg-gradient-to-r', 'from-transparent', 'to-black/10')
    classes.push('bg-[length:1rem_1rem]')
    classes.push(
      '[background-image:repeating-linear-gradient(45deg,transparent,transparent_10px,rgba(255,255,255,.1)_10px,rgba(255,255,255,.1)_20px)]'
    )
  }

  if (props.animated && props.striped) {
    classes.push('animate-[progress_1s_linear_infinite]')
  }

  return classes.join(' ')
})
</script>

<template>
  <div class="progress-bar-container">
    <!-- Label -->
    <div v-if="label || showPercentage" class="mb-2 flex items-center justify-between">
      <span v-if="label" class="text-sm font-medium text-gray-700">{{ label }}</span>
      <span v-if="showPercentage" class="text-sm font-medium text-gray-600">
        {{ Math.round(percentage) }}%
      </span>
    </div>

    <!-- Progress bar -->
    <div
      :class="[
        'progress-bar-track',
        'w-full',
        'bg-gray-200',
        'rounded-full',
        'overflow-hidden',
        heightClasses,
      ]"
      role="progressbar"
      :aria-valuenow="value"
      :aria-valuemin="0"
      :aria-valuemax="max"
    >
      <div :class="barClasses" :style="{ width: `${percentage}%` }" />
    </div>
  </div>
</template>

<style scoped>
@keyframes progress {
  from {
    background-position: 0 0;
  }
  to {
    background-position: 2rem 0;
  }
}
</style>
