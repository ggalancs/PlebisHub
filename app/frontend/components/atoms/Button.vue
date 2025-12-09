<script setup lang="ts">
import { computed } from 'vue'

export interface ButtonProps {
  /** Button variant */
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger' | 'success' | 'outline'
  /** Button size */
  size?: 'sm' | 'md' | 'lg'
  /** Disabled state */
  disabled?: boolean
  /** Loading state */
  loading?: boolean
  /** Full width button */
  fullWidth?: boolean
  /** Button type */
  type?: 'button' | 'submit' | 'reset'
  /** Icon only button */
  iconOnly?: boolean
}

const props = withDefaults(defineProps<ButtonProps>(), {
  variant: 'primary',
  size: 'md',
  disabled: false,
  loading: false,
  fullWidth: false,
  type: 'button',
  iconOnly: false,
})

defineEmits<{
  click: [event: MouseEvent]
}>()

const buttonClasses = computed(() => {
  const classes: string[] = [
    // Base styles
    'inline-flex items-center justify-center gap-2',
    'font-medium rounded-lg transition-all duration-200',
    'focus:outline-none focus:ring-2 focus:ring-offset-2',
    'disabled:opacity-50 disabled:cursor-not-allowed disabled:pointer-events-none',
  ]

  // Size variants
  const sizeClasses = {
    sm: props.iconOnly ? 'p-2' : 'px-3 py-1.5 text-sm',
    md: props.iconOnly ? 'p-2.5' : 'px-4 py-2 text-base',
    lg: props.iconOnly ? 'p-3' : 'px-6 py-3 text-lg',
  }
  classes.push(sizeClasses[props.size])

  // Variant styles
  const variantClasses = {
    primary:
      'bg-primary-700 text-white hover:bg-primary-800 active:bg-primary-900 focus:ring-primary-600',
    secondary:
      'bg-secondary-600 text-white hover:bg-secondary-700 active:bg-secondary-800 focus:ring-secondary-600',
    ghost:
      'bg-transparent text-primary-700 hover:bg-primary-50 active:bg-primary-100 focus:ring-primary-600 border border-primary-700',
    danger: 'bg-red-600 text-white hover:bg-red-700 active:bg-red-800 focus:ring-red-600',
    success: 'bg-green-600 text-white hover:bg-green-700 active:bg-green-800 focus:ring-green-600',
    outline:
      'bg-transparent text-gray-700 hover:bg-gray-50 active:bg-gray-100 focus:ring-gray-300 border border-gray-300',
  }
  classes.push(variantClasses[props.variant])

  // Full width
  if (props.fullWidth) {
    classes.push('w-full')
  }

  return classes.join(' ')
})
</script>

<template>
  <button
    :type="type"
    :disabled="disabled || loading"
    :class="buttonClasses"
    @click="$emit('click', $event)"
  >
    <!-- Loading spinner -->
    <svg
      v-if="loading"
      class="h-5 w-5 animate-spin"
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
    >
      <circle
        class="opacity-25"
        cx="12"
        cy="12"
        r="10"
        stroke="currentColor"
        stroke-width="4"
      ></circle>
      <path
        class="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
      ></path>
    </svg>

    <!-- Default slot for button content -->
    <slot />
  </button>
</template>
