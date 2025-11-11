<template>
  <span
    :class="[
      'inline-flex items-center justify-center font-medium transition-colors',
      sizeClasses,
      variantClasses,
      roundedClasses,
      disabled && 'cursor-not-allowed opacity-50',
      removable && !disabled && 'pr-1',
    ]"
  >
    <Icon
      v-if="icon"
      :name="icon"
      :size="iconSize"
      class="flex-shrink-0"
      :class="{ 'mr-1': $slots.default || label }"
    />

    <span v-if="$slots.default || label">
      <slot>{{ label }}</slot>
    </span>

    <button
      v-if="removable && !disabled"
      type="button"
      class="ml-1 flex-shrink-0 rounded-full transition-colors hover:bg-black/10 focus:outline-none focus:ring-2 focus:ring-offset-1"
      :class="removeButtonClasses"
      :aria-label="removeLabel || 'Remove badge'"
      @click.stop="handleRemove"
    >
      <Icon name="x" :size="removeIconSize" />
    </button>
  </span>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import Icon from '../atoms/Icon.vue'

/**
 * Badge component for displaying status labels, tags, or categories
 */
export interface Props {
  /**
   * Badge label text
   */
  label?: string
  /**
   * Color variant
   * @default 'default'
   */
  variant?: 'default' | 'primary' | 'secondary' | 'success' | 'warning' | 'danger' | 'info'
  /**
   * Size of the badge
   * @default 'md'
   */
  size?: 'sm' | 'md' | 'lg'
  /**
   * Border radius style
   * @default 'md'
   */
  rounded?: 'sm' | 'md' | 'lg' | 'full'
  /**
   * Optional icon name
   */
  icon?: string
  /**
   * Whether badge is removable
   * @default false
   */
  removable?: boolean
  /**
   * Whether badge is disabled
   * @default false
   */
  disabled?: boolean
  /**
   * Aria label for remove button
   */
  removeLabel?: string
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'default',
  size: 'md',
  rounded: 'md',
  removable: false,
  disabled: false,
})

const emit = defineEmits<{
  remove: []
}>()

const sizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'px-2 py-0.5 text-xs gap-1'
    case 'lg':
      return 'px-3 py-1.5 text-base gap-2'
    default:
      return 'px-2.5 py-1 text-sm gap-1.5'
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

const removeIconSize = computed(() => {
  switch (props.size) {
    case 'sm':
      return 12
    case 'lg':
      return 16
    default:
      return 14
  }
})

const variantClasses = computed(() => {
  switch (props.variant) {
    case 'primary':
      return 'bg-primary text-white'
    case 'secondary':
      return 'bg-secondary text-white'
    case 'success':
      return 'bg-green-100 text-green-800'
    case 'warning':
      return 'bg-yellow-100 text-yellow-800'
    case 'danger':
      return 'bg-red-100 text-red-800'
    case 'info':
      return 'bg-blue-100 text-blue-800'
    default:
      return 'bg-gray-100 text-gray-800'
  }
})

const roundedClasses = computed(() => {
  switch (props.rounded) {
    case 'sm':
      return 'rounded-sm'
    case 'lg':
      return 'rounded-lg'
    case 'full':
      return 'rounded-full'
    default:
      return 'rounded-md'
  }
})

const removeButtonClasses = computed(() => {
  switch (props.variant) {
    case 'primary':
    case 'secondary':
      return 'focus:ring-white'
    default:
      return 'focus:ring-gray-400'
  }
})

const handleRemove = () => {
  if (!props.disabled) {
    emit('remove')
  }
}
</script>
