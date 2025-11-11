<script setup lang="ts">
import { ref, computed } from 'vue'

export interface TooltipProps {
  /** Tooltip content */
  content?: string
  /** Tooltip position */
  position?: 'top' | 'bottom' | 'left' | 'right'
  /** Tooltip variant/color */
  variant?: 'dark' | 'light' | 'primary' | 'danger' | 'success' | 'warning'
  /** Show arrow */
  arrow?: boolean
  /** Delay before showing (ms) */
  delay?: number
}

const props = withDefaults(defineProps<TooltipProps>(), {
  position: 'top',
  variant: 'dark',
  arrow: true,
  delay: 200,
})

const isVisible = ref(false)
let timeoutId: ReturnType<typeof setTimeout>

const show = () => {
  timeoutId = setTimeout(() => {
    isVisible.value = true
  }, props.delay)
}

const hide = () => {
  clearTimeout(timeoutId)
  isVisible.value = false
}

const tooltipClasses = computed(() => {
  const classes: string[] = [
    'absolute z-50 px-3 py-2 text-sm font-medium rounded-lg shadow-lg',
    'transition-opacity duration-200 pointer-events-none whitespace-nowrap',
  ]

  // Position classes
  const positionClasses = {
    top: 'bottom-full left-1/2 -translate-x-1/2 mb-2',
    bottom: 'top-full left-1/2 -translate-x-1/2 mt-2',
    left: 'right-full top-1/2 -translate-y-1/2 mr-2',
    right: 'left-full top-1/2 -translate-y-1/2 ml-2',
  }
  classes.push(positionClasses[props.position])

  // Variant colors
  const variantClasses = {
    dark: 'bg-gray-900 text-white',
    light: 'bg-white text-gray-900 border border-gray-200',
    primary: 'bg-primary-600 text-white',
    danger: 'bg-red-600 text-white',
    success: 'bg-green-600 text-white',
    warning: 'bg-yellow-500 text-white',
  }
  classes.push(variantClasses[props.variant])

  // Visibility
  if (isVisible.value) {
    classes.push('opacity-100 visible')
  } else {
    classes.push('opacity-0 invisible')
  }

  return classes.join(' ')
})

const arrowClasses = computed(() => {
  if (!props.arrow) return ''

  const classes: string[] = ['absolute w-2 h-2 rotate-45']

  // Arrow position
  const arrowPositionClasses = {
    top: 'top-full left-1/2 -translate-x-1/2 -mt-1',
    bottom: 'bottom-full left-1/2 -translate-x-1/2 -mb-1',
    left: 'left-full top-1/2 -translate-y-1/2 -ml-1',
    right: 'right-full top-1/2 -translate-y-1/2 -mr-1',
  }
  classes.push(arrowPositionClasses[props.position])

  // Arrow color
  const arrowColorClasses = {
    dark: 'bg-gray-900',
    light: 'bg-white border-l border-t border-gray-200',
    primary: 'bg-primary-600',
    danger: 'bg-red-600',
    success: 'bg-green-600',
    warning: 'bg-yellow-500',
  }
  classes.push(arrowColorClasses[props.variant])

  return classes.join(' ')
})
</script>

<template>
  <div
    class="relative inline-block"
    @mouseenter="show"
    @mouseleave="hide"
    @focus="show"
    @blur="hide"
  >
    <!-- Trigger slot -->
    <slot />

    <!-- Tooltip -->
    <div v-if="content || $slots.tooltip" :class="tooltipClasses" role="tooltip">
      <!-- Arrow -->
      <div v-if="arrow" :class="arrowClasses"></div>

      <!-- Content -->
      <slot name="tooltip">{{ content }}</slot>
    </div>
  </div>
</template>
