<template>
  <button
    type="button"
    :class="[
      'relative inline-flex flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out',
      'focus:ring-primary focus:outline-none focus:ring-2 focus:ring-offset-2',
      sizeClasses,
      colorClasses,
      disabled && 'cursor-not-allowed opacity-50',
    ]"
    role="switch"
    :aria-checked="modelValue"
    :aria-label="ariaLabel || label"
    :disabled="disabled"
    @click="toggle"
  >
    <span class="sr-only">{{ label }}</span>
    <span
      :class="[
        'pointer-events-none inline-block transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out',
        thumbSizeClasses,
        thumbPositionClasses,
      ]"
    >
      <Icon v-if="showIcon && icon" :name="icon" :size="iconSize" :class="iconColorClasses" />
      <Icon
        v-else-if="showIcon"
        :name="modelValue ? 'check' : 'x'"
        :size="iconSize"
        :class="iconColorClasses"
      />
    </span>
  </button>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import Icon from '../atoms/Icon.vue'

/**
 * Toggle/Switch component for binary on/off states
 */
export interface Props {
  /**
   * Current value (on/off)
   */
  modelValue: boolean
  /**
   * Label for the toggle (used for accessibility)
   */
  label?: string
  /**
   * Size of the toggle
   * @default 'md'
   */
  size?: 'sm' | 'md' | 'lg'
  /**
   * Color variant when enabled
   * @default 'primary'
   */
  variant?: 'primary' | 'success' | 'warning' | 'danger'
  /**
   * Whether the toggle is disabled
   * @default false
   */
  disabled?: boolean
  /**
   * Whether to show an icon in the thumb
   * @default false
   */
  showIcon?: boolean
  /**
   * Custom icon name (if not provided, shows check/x based on state)
   */
  icon?: string
  /**
   * ARIA label for accessibility
   */
  ariaLabel?: string
}

const props = withDefaults(defineProps<Props>(), {
  size: 'md',
  variant: 'primary',
  disabled: false,
  showIcon: false,
})

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  change: [value: boolean]
}>()

const sizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'h-5 w-9'
    case 'lg':
      return 'h-8 w-16'
    default:
      return 'h-6 w-11'
  }
})

const thumbSizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'h-4 w-4'
    case 'lg':
      return 'h-7 w-7'
    default:
      return 'h-5 w-5'
  }
})

const thumbPositionClasses = computed(() => {
  if (!props.modelValue) {
    return 'translate-x-0'
  }

  switch (props.size) {
    case 'sm':
      return 'translate-x-4'
    case 'lg':
      return 'translate-x-8'
    default:
      return 'translate-x-5'
  }
})

const iconSize = computed(() => {
  switch (props.size) {
    case 'sm':
      return 12
    case 'lg':
      return 18
    default:
      return 14
  }
})

const colorClasses = computed(() => {
  if (!props.modelValue) {
    return 'bg-gray-200'
  }

  switch (props.variant) {
    case 'success':
      return 'bg-green-600'
    case 'warning':
      return 'bg-yellow-500'
    case 'danger':
      return 'bg-red-600'
    default:
      return 'bg-primary'
  }
})

const iconColorClasses = computed(() => {
  if (!props.modelValue) {
    return 'text-gray-400'
  }

  switch (props.variant) {
    case 'success':
      return 'text-green-600'
    case 'warning':
      return 'text-yellow-500'
    case 'danger':
      return 'text-red-600'
    default:
      return 'text-primary'
  }
})

const toggle = () => {
  if (props.disabled) return

  const newValue = !props.modelValue
  emit('update:modelValue', newValue)
  emit('change', newValue)
}
</script>
