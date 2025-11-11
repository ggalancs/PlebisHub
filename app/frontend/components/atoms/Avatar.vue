<script setup lang="ts">
import { computed } from 'vue'

export interface AvatarProps {
  /** Avatar size */
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl'
  /** Image source */
  src?: string
  /** Alt text for image */
  alt?: string
  /** Initials to display (fallback if no image) */
  initials?: string
  /** Variant color (for initials background) */
  variant?: 'primary' | 'secondary' | 'success' | 'danger' | 'warning' | 'info' | 'neutral'
  /** Shape */
  shape?: 'circle' | 'square'
  /** Status indicator */
  status?: 'online' | 'offline' | 'away' | 'busy' | null
  /** Status position */
  statusPosition?: 'top' | 'bottom'
}

const props = withDefaults(defineProps<AvatarProps>(), {
  size: 'md',
  variant: 'primary',
  shape: 'circle',
  status: null,
  statusPosition: 'bottom',
})

const avatarClasses = computed(() => {
  const classes: string[] = [
    'relative inline-flex items-center justify-center overflow-hidden',
    'font-medium select-none flex-shrink-0',
  ]

  // Size variants
  const sizeClasses = {
    xs: 'h-6 w-6 text-xs',
    sm: 'h-8 w-8 text-sm',
    md: 'h-10 w-10 text-base',
    lg: 'h-12 w-12 text-lg',
    xl: 'h-14 w-14 text-xl',
    '2xl': 'h-16 w-16 text-2xl',
  }
  classes.push(sizeClasses[props.size])

  // Shape
  if (props.shape === 'circle') {
    classes.push('rounded-full')
  } else {
    classes.push('rounded-md')
  }

  // Variant colors (for initials background)
  if (!props.src) {
    const variantClasses = {
      primary: 'bg-primary-600 text-white',
      secondary: 'bg-secondary-600 text-white',
      success: 'bg-green-600 text-white',
      danger: 'bg-red-600 text-white',
      warning: 'bg-yellow-500 text-white',
      info: 'bg-blue-600 text-white',
      neutral: 'bg-gray-600 text-white',
    }
    classes.push(variantClasses[props.variant])
  }

  return classes.join(' ')
})

const statusClasses = computed(() => {
  const classes: string[] = ['absolute block rounded-full ring-2 ring-white']

  // Size variants for status indicator
  const sizeClasses = {
    xs: 'h-1.5 w-1.5',
    sm: 'h-2 w-2',
    md: 'h-2.5 w-2.5',
    lg: 'h-3 w-3',
    xl: 'h-3.5 w-3.5',
    '2xl': 'h-4 w-4',
  }
  classes.push(sizeClasses[props.size])

  // Position
  if (props.statusPosition === 'top') {
    classes.push('top-0 right-0')
  } else {
    classes.push('bottom-0 right-0')
  }

  // Status colors
  if (props.status) {
    const statusColors = {
      online: 'bg-green-500',
      offline: 'bg-gray-400',
      away: 'bg-yellow-500',
      busy: 'bg-red-500',
    }
    classes.push(statusColors[props.status])
  }

  return classes.join(' ')
})

const displayInitials = computed(() => {
  if (!props.initials) return ''
  // Take first 2 characters and uppercase
  return props.initials.substring(0, 2).toUpperCase()
})
</script>

<template>
  <span :class="avatarClasses">
    <!-- Image -->
    <img v-if="src" :src="src" :alt="alt || 'Avatar'" class="h-full w-full object-cover" />

    <!-- Initials fallback -->
    <span v-else-if="initials" aria-hidden="true">
      {{ displayInitials }}
    </span>

    <!-- Icon fallback (slot) -->
    <slot v-else>
      <!-- Default user icon -->
      <svg
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="currentColor"
        class="h-full w-full p-1"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z"
        />
      </svg>
    </slot>

    <!-- Status indicator -->
    <span v-if="status" :class="statusClasses" :aria-label="`Status: ${status}`"></span>
  </span>
</template>
