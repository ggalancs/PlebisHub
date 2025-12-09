<script setup lang="ts">
import { computed } from 'vue'
import Icon from '../atoms/Icon.vue'

export interface TagProps {
  /**
   * Text label for the tag
   */
  label?: string
  /**
   * Visual variant
   * @default 'default'
   */
  variant?: 'default' | 'primary' | 'success' | 'warning' | 'danger' | 'info'
  /**
   * Size of the tag
   * @default 'md'
   */
  size?: 'sm' | 'md' | 'lg'
  /**
   * Whether the tag can be removed
   * @default false
   */
  removable?: boolean
  /**
   * Whether the tag is disabled
   * @default false
   */
  disabled?: boolean
  /**
   * Whether the tag is clickable
   * @default false
   */
  clickable?: boolean
  /**
   * Icon name to display (from lucide-vue-next)
   */
  icon?: string
  /**
   * Image URL for avatar
   */
  avatar?: string
  /**
   * Outlined style instead of filled
   * @default false
   */
  outlined?: boolean
}

const props = withDefaults(defineProps<TagProps>(), {
  label: '',
  variant: 'default',
  size: 'md',
  removable: false,
  disabled: false,
  clickable: false,
  icon: undefined,
  avatar: undefined,
  outlined: false,
})

const emit = defineEmits<{
  click: [event: MouseEvent]
  remove: []
}>()

const handleClick = (event: MouseEvent | KeyboardEvent) => {
  if (!props.disabled && props.clickable) {
    emit('click', event as MouseEvent)
  }
}

const handleRemove = (event: MouseEvent) => {
  event.stopPropagation()
  if (!props.disabled) {
    emit('remove')
  }
}

const tagClasses = computed(() => {
  const base = 'tag inline-flex items-center gap-1.5 font-medium rounded-full transition-colors'

  const sizes = {
    sm: 'text-xs px-2 py-0.5',
    md: 'text-sm px-3 py-1',
    lg: 'text-base px-4 py-1.5',
  }

  const variantsFilled = {
    default: 'bg-gray-100 text-gray-700 hover:bg-gray-200',
    primary: 'bg-primary text-white hover:bg-primary/90',
    success: 'bg-green-500 text-white hover:bg-green-600',
    warning: 'bg-yellow-500 text-white hover:bg-yellow-600',
    danger: 'bg-red-500 text-white hover:bg-red-600',
    info: 'bg-blue-500 text-white hover:bg-blue-600',
  }

  const variantsOutlined = {
    default: 'border border-gray-300 text-gray-700 hover:bg-gray-50',
    primary: 'border border-primary text-primary hover:bg-primary/5',
    success: 'border border-green-500 text-green-600 hover:bg-green-50',
    warning: 'border border-yellow-500 text-yellow-600 hover:bg-yellow-50',
    danger: 'border border-red-500 text-red-600 hover:bg-red-50',
    info: 'border border-blue-500 text-blue-600 hover:bg-blue-50',
  }

  const variants = props.outlined ? variantsOutlined : variantsFilled

  const interactive = props.clickable && !props.disabled ? 'cursor-pointer' : ''
  const disabledClass = props.disabled ? 'opacity-50 cursor-not-allowed' : ''

  return [base, sizes[props.size], variants[props.variant], interactive, disabledClass]
})

const iconSize = computed(() => {
  return props.size === 'sm' ? 12 : props.size === 'lg' ? 18 : 14
})

const avatarSize = computed(() => {
  return props.size === 'sm' ? 'w-4 h-4' : props.size === 'lg' ? 'w-6 h-6' : 'w-5 h-5'
})

const removeIconSize = computed(() => {
  return props.size === 'sm' ? 12 : props.size === 'lg' ? 16 : 14
})
</script>

<template>
  <span
    :class="tagClasses"
    :role="clickable ? 'button' : undefined"
    :tabindex="clickable && !disabled ? 0 : undefined"
    :aria-disabled="disabled || undefined"
    @click="handleClick"
    @keydown.enter="handleClick"
    @keydown.space.prevent="handleClick"
  >
    <!-- Avatar -->
    <img
      v-if="avatar"
      :src="avatar"
      :alt="label"
      :class="['rounded-full object-cover', avatarSize]"
    />

    <!-- Icon -->
    <Icon v-if="icon && !avatar" :name="icon" :size="iconSize" />

    <!-- Label -->
    <slot>
      <span>{{ label }}</span>
    </slot>

    <!-- Remove Button -->
    <button
      v-if="removable"
      type="button"
      class="remove-button inline-flex items-center justify-center rounded-full transition-colors hover:bg-black/10"
      :class="{
        'h-3 w-3': size === 'sm',
        'h-4 w-4': size === 'md',
        'h-5 w-5': size === 'lg',
      }"
      :disabled="disabled"
      :aria-label="`Remove ${label}`"
      @click="handleRemove"
    >
      <Icon name="x" :size="removeIconSize" />
    </button>
  </span>
</template>

<style scoped>
.tag {
  max-width: 100%;
}

.tag > span {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
