<template>
  <kbd
    :class="[
      'inline-flex items-center justify-center rounded border text-center font-mono font-semibold shadow-sm transition-all',
      sizeClasses,
      variantClasses,
      disabled && 'cursor-not-allowed opacity-50',
    ]"
    :title="title"
  >
    <Icon v-if="icon" :name="icon" :size="iconSize" class="flex-shrink-0" />
    <span v-if="$slots.default || keys">
      <slot>{{ displayKeys }}</slot>
    </span>
  </kbd>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import Icon from '../atoms/Icon.vue'

/**
 * Keyboard key display component for showing keyboard shortcuts
 */
export interface Props {
  /**
   * The keyboard key(s) to display
   * Can be a single key or an array for combinations
   */
  keys?: string | string[]
  /**
   * Optional icon to display
   */
  icon?: string
  /**
   * Size of the keyboard key
   * @default 'md'
   */
  size?: 'sm' | 'md' | 'lg'
  /**
   * Visual variant
   * @default 'default'
   */
  variant?: 'default' | 'outline' | 'solid'
  /**
   * Whether the key is disabled
   * @default false
   */
  disabled?: boolean
  /**
   * Optional tooltip text
   */
  title?: string
}

const props = withDefaults(defineProps<Props>(), {
  size: 'md',
  variant: 'default',
  disabled: false,
})

const sizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'px-1.5 py-0.5 text-xs min-w-[1.5rem] gap-1'
    case 'lg':
      return 'px-3 py-1.5 text-base min-w-[3rem] gap-2'
    default:
      return 'px-2 py-1 text-sm min-w-[2rem] gap-1.5'
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

const variantClasses = computed(() => {
  switch (props.variant) {
    case 'outline':
      return 'bg-transparent border-gray-300 text-gray-700 hover:bg-gray-50'
    case 'solid':
      return 'bg-gray-700 border-gray-800 text-white'
    default:
      return 'bg-gray-50 border-gray-200 text-gray-700 hover:bg-gray-100'
  }
})

const displayKeys = computed(() => {
  if (!props.keys) return ''

  if (Array.isArray(props.keys)) {
    return props.keys.join(' + ')
  }

  return props.keys
})
</script>
