<script setup lang="ts">
import { computed } from 'vue'

export interface NotificationBadgeProps {
  /**
   * Number to display
   * @default 0
   */
  count?: number
  /**
   * Maximum number to display before showing +
   * @default 99
   */
  max?: number
  /**
   * Show badge even when count is 0
   * @default false
   */
  showZero?: boolean
  /**
   * Show dot instead of number
   * @default false
   */
  dot?: boolean
  /**
   * Color variant
   * @default 'primary'
   */
  variant?: 'primary' | 'success' | 'warning' | 'danger' | 'gray'
  /**
   * Position of the badge
   * @default 'top-right'
   */
  position?: 'top-right' | 'top-left' | 'bottom-right' | 'bottom-left'
}

const props = withDefaults(defineProps<NotificationBadgeProps>(), {
  count: 0,
  max: 99,
  showZero: false,
  dot: false,
  variant: 'primary',
  position: 'top-right',
})

const shouldShow = computed(() => {
  return props.showZero || props.count > 0
})

const displayCount = computed(() => {
  if (props.dot) return ''
  if (props.count > props.max) return `${props.max}+`
  return props.count.toString()
})

const badgeClasses = computed(() => {
  const base = [
    'notification-badge',
    'absolute inline-flex items-center justify-center',
    'font-medium text-white rounded-full',
    'border-2 border-white',
  ]

  const variants = {
    primary: 'bg-primary',
    success: 'bg-green-500',
    warning: 'bg-yellow-500',
    danger: 'bg-red-500',
    gray: 'bg-gray-500',
  }

  const positions = {
    'top-right': 'top-0 right-0 translate-x-1/2 -translate-y-1/2',
    'top-left': 'top-0 left-0 -translate-x-1/2 -translate-y-1/2',
    'bottom-right': 'bottom-0 right-0 translate-x-1/2 translate-y-1/2',
    'bottom-left': 'bottom-0 left-0 -translate-x-1/2 translate-y-1/2',
  }

  const size = props.dot ? 'w-2 h-2' : 'min-w-[20px] h-5 px-1.5 text-xs'

  return [...base, variants[props.variant], positions[props.position], size]
})
</script>

<template>
  <div class="notification-badge-container relative inline-block">
    <slot />

    <span
      v-if="shouldShow"
      :class="badgeClasses"
      :aria-label="dot ? 'Notification' : `${count} notifications`"
    >
      {{ displayCount }}
    </span>
  </div>
</template>
