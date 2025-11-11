<template>
  <component
    :is="href ? 'a' : clickable ? 'button' : 'div'"
    :href="href"
    :class="[
      'flex items-center transition-colors',
      paddingClasses,
      hoverClasses,
      activeClasses,
      disabledClasses,
      dividerClasses,
    ]"
    :disabled="clickable && disabled"
    @click="handleClick"
  >
    <!-- Leading content -->
    <div v-if="$slots.leading || icon || avatar" :class="['flex-shrink-0', leadingGapClasses]">
      <slot name="leading">
        <img
          v-if="avatar"
          :src="avatar"
          :alt="avatarAlt || ''"
          :class="['rounded-full object-cover', avatarSizeClasses]"
        />
        <div v-else-if="icon" :class="['flex items-center justify-center', iconContainerClasses]">
          <Icon :name="icon" :size="iconSize" :class="iconColorClasses" />
        </div>
      </slot>
    </div>

    <!-- Main content -->
    <div class="min-w-0 flex-1">
      <div
        v-if="title || $slots.default"
        :class="['font-medium', titleSizeClasses, titleColorClasses]"
      >
        <slot>{{ title }}</slot>
      </div>
      <div v-if="subtitle || $slots.subtitle" :class="['text-sm', subtitleColorClasses, 'mt-0.5']">
        <slot name="subtitle">{{ subtitle }}</slot>
      </div>
    </div>

    <!-- Trailing content -->
    <div
      v-if="$slots.trailing || badge || chevron"
      :class="['flex flex-shrink-0 items-center', trailingGapClasses]"
    >
      <slot name="trailing">
        <span
          v-if="badge"
          :class="['rounded-full px-2 py-0.5 text-xs font-medium', badgeColorClasses]"
        >
          {{ badge }}
        </span>
        <Icon v-if="chevron" name="chevron-right" :size="16" class="text-gray-400" />
      </slot>
    </div>
  </component>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import Icon from '../atoms/Icon.vue'

/**
 * List item component for building structured lists
 */
export interface Props {
  /**
   * Main title text
   */
  title?: string
  /**
   * Subtitle or description text
   */
  subtitle?: string
  /**
   * Optional icon name
   */
  icon?: string
  /**
   * Optional avatar image URL
   */
  avatar?: string
  /**
   * Alt text for avatar
   */
  avatarAlt?: string
  /**
   * Optional badge text
   */
  badge?: string
  /**
   * Show chevron icon on the right
   * @default false
   */
  chevron?: boolean
  /**
   * Optional href for link behavior
   */
  href?: string
  /**
   * Whether item is clickable (renders as button)
   * @default false
   */
  clickable?: boolean
  /**
   * Whether item is active/selected
   * @default false
   */
  active?: boolean
  /**
   * Whether item is disabled
   * @default false
   */
  disabled?: boolean
  /**
   * Show bottom divider
   * @default false
   */
  divider?: boolean
  /**
   * Size variant
   * @default 'md'
   */
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<Props>(), {
  chevron: false,
  clickable: false,
  active: false,
  disabled: false,
  divider: false,
  size: 'md',
})

const emit = defineEmits<{
  click: [event: MouseEvent]
}>()

const paddingClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'px-3 py-2'
    case 'lg':
      return 'px-4 py-4'
    default:
      return 'px-4 py-3'
  }
})

const leadingGapClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'mr-2'
    case 'lg':
      return 'mr-4'
    default:
      return 'mr-3'
  }
})

const trailingGapClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'ml-2 gap-1'
    case 'lg':
      return 'ml-4 gap-3'
    default:
      return 'ml-3 gap-2'
  }
})

const hoverClasses = computed(() => {
  if (props.disabled) return ''
  if (props.href || props.clickable) {
    return 'hover:bg-gray-50 cursor-pointer'
  }
  return ''
})

const activeClasses = computed(() => {
  if (props.active) {
    return 'bg-primary/10 text-primary'
  }
  return ''
})

const disabledClasses = computed(() => {
  if (props.disabled) {
    return 'opacity-50 cursor-not-allowed'
  }
  return ''
})

const dividerClasses = computed(() => {
  if (props.divider) {
    return 'border-b border-gray-200'
  }
  return ''
})

const iconSize = computed(() => {
  switch (props.size) {
    case 'sm':
      return 16
    case 'lg':
      return 24
    default:
      return 20
  }
})

const avatarSizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'w-8 h-8'
    case 'lg':
      return 'w-12 h-12'
    default:
      return 'w-10 h-10'
  }
})

const iconContainerClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'w-8 h-8'
    case 'lg':
      return 'w-12 h-12'
    default:
      return 'w-10 h-10'
  }
})

const iconColorClasses = computed(() => {
  if (props.active) {
    return 'text-primary'
  }
  return 'text-gray-500'
})

const titleSizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'text-sm'
    case 'lg':
      return 'text-base'
    default:
      return 'text-sm'
  }
})

const titleColorClasses = computed(() => {
  if (props.active) {
    return 'text-primary'
  }
  return 'text-gray-900'
})

const subtitleColorClasses = computed(() => {
  return 'text-gray-600'
})

const badgeColorClasses = computed(() => {
  return 'bg-gray-100 text-gray-700'
})

const handleClick = (event: MouseEvent) => {
  if (!props.disabled) {
    emit('click', event)
  }
}
</script>
