<script setup lang="ts">
/**
 * ProgressBar Component
 *
 * A simple progress bar with customizable color and size.
 */

import { computed } from 'vue'

interface Props {
  value: number
  max?: number
  size?: 'sm' | 'md' | 'lg'
  variant?: 'primary' | 'success' | 'warning' | 'error'
  showLabel?: boolean
  label?: string
}

const props = withDefaults(defineProps<Props>(), {
  max: 100,
  size: 'md',
  variant: 'primary',
  showLabel: false,
})

const percentage = computed(() => {
  const pct = Math.min(Math.max((props.value / props.max) * 100, 0), 100)
  return Math.round(pct)
})

const sizeClasses = {
  sm: 'h-1',
  md: 'h-2',
  lg: 'h-4',
}

const variantClasses = {
  primary: 'bg-primary-500',
  success: 'bg-green-500',
  warning: 'bg-yellow-500',
  error: 'bg-red-500',
}
</script>

<template>
  <div class="progress-bar-wrapper">
    <div
      class="w-full bg-gray-200 rounded-full overflow-hidden"
      :class="sizeClasses[size]"
      role="progressbar"
      :aria-valuenow="percentage"
      :aria-valuemin="0"
      :aria-valuemax="100"
    >
      <div
        class="h-full rounded-full transition-all duration-300"
        :class="variantClasses[variant]"
        :style="{ width: `${percentage}%` }"
      />
    </div>

    <div v-if="showLabel" class="mt-1 text-sm text-gray-600 flex justify-between">
      <span v-if="label">{{ label }}</span>
      <span class="text-gray-500">{{ percentage }}%</span>
    </div>
  </div>
</template>
