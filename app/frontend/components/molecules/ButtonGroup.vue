<template>
  <div
    :class="['inline-flex', orientationClasses, sizeClasses]"
    role="group"
    :aria-label="ariaLabel"
  >
    <component
      :is="button.href ? 'a' : 'button'"
      v-for="(button, index) in buttons"
      :key="button.id || index"
      :href="button.href"
      :type="button.href ? undefined : 'button'"
      :disabled="button.disabled || disabled"
      :class="[
        'relative inline-flex items-center justify-center font-medium transition-all',
        'focus:ring-primary focus:z-10 focus:outline-none focus:ring-2 focus:ring-offset-0',
        buttonSizeClasses,
        getButtonClasses(button, index),
        getRoundedClasses(index),
        getBorderClasses(index),
      ]"
      @click="handleClick($event, button, index)"
    >
      <Icon
        v-if="button.icon"
        :name="button.icon"
        :size="iconSize"
        :class="{ 'mr-2': button.label }"
      />
      <span v-if="button.label">{{ button.label }}</span>
    </component>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import Icon from '../atoms/Icon.vue'

/**
 * Button group component for grouping related buttons together
 */
export interface ButtonGroupItem {
  /**
   * Unique identifier
   */
  id?: string | number
  /**
   * Button label
   */
  label?: string
  /**
   * Optional icon
   */
  icon?: string
  /**
   * Optional href for link
   */
  href?: string
  /**
   * Whether this button is active/selected
   */
  active?: boolean
  /**
   * Whether this button is disabled
   */
  disabled?: boolean
}

export interface Props {
  /**
   * Array of button items
   */
  buttons: ButtonGroupItem[]
  /**
   * Visual variant
   * @default 'default'
   */
  variant?: 'default' | 'outlined' | 'ghost'
  /**
   * Size of buttons
   * @default 'md'
   */
  size?: 'sm' | 'md' | 'lg'
  /**
   * Orientation of the group
   * @default 'horizontal'
   */
  orientation?: 'horizontal' | 'vertical'
  /**
   * Whether all buttons are disabled
   * @default false
   */
  disabled?: boolean
  /**
   * ARIA label for the button group
   */
  ariaLabel?: string
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'default',
  size: 'md',
  orientation: 'horizontal',
  disabled: false,
})

const emit = defineEmits<{
  click: [button: ButtonGroupItem, index: number, event: MouseEvent]
}>()

const orientationClasses = computed(() => {
  return props.orientation === 'vertical' ? 'flex-col' : 'flex-row'
})

const sizeClasses = computed(() => {
  return props.orientation === 'vertical' ? 'w-full' : ''
})

const buttonSizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'px-3 py-1.5 text-sm gap-1.5'
    case 'lg':
      return 'px-6 py-3 text-base gap-2'
    default:
      return 'px-4 py-2 text-sm gap-2'
  }
})

const iconSize = computed(() => {
  switch (props.size) {
    case 'sm':
      return 14
    case 'lg':
      return 20
    default:
      return 16
  }
})

const getButtonClasses = (button: ButtonGroupItem, _index: number) => {
  const isActive = button.active
  const isDisabled = button.disabled || props.disabled

  const classes = []

  if (isDisabled) {
    classes.push('opacity-50', 'cursor-not-allowed')
  }

  switch (props.variant) {
    case 'outlined':
      if (isActive) {
        classes.push('bg-primary', 'text-white', 'border-primary')
      } else {
        classes.push('bg-white', 'text-gray-700', 'border-gray-300')
        if (!isDisabled) {
          classes.push('hover:bg-gray-50')
        }
      }
      break
    case 'ghost':
      if (isActive) {
        classes.push('bg-primary/10', 'text-primary')
      } else {
        classes.push('bg-transparent', 'text-gray-700')
        if (!isDisabled) {
          classes.push('hover:bg-gray-100')
        }
      }
      break
    default:
      if (isActive) {
        classes.push('bg-primary', 'text-white')
      } else {
        classes.push('bg-gray-100', 'text-gray-700')
        if (!isDisabled) {
          classes.push('hover:bg-gray-200')
        }
      }
  }

  return classes
}

const getRoundedClasses = (index: number) => {
  const isFirst = index === 0
  const isLast = index === props.buttons.length - 1
  const isVertical = props.orientation === 'vertical'

  if (props.buttons.length === 1) {
    return 'rounded-md'
  }

  if (isVertical) {
    if (isFirst) return 'rounded-t-md'
    if (isLast) return 'rounded-b-md'
    return ''
  } else {
    if (isFirst) return 'rounded-l-md'
    if (isLast) return 'rounded-r-md'
    return ''
  }
}

const getBorderClasses = (index: number) => {
  const isVertical = props.orientation === 'vertical'
  const classes = []

  if (props.variant === 'outlined') {
    classes.push('border')

    if (isVertical) {
      if (index > 0) {
        classes.push('-mt-[1px]')
      }
    } else {
      if (index > 0) {
        classes.push('-ml-[1px]')
      }
    }
  }

  return classes
}

const handleClick = (event: MouseEvent, button: ButtonGroupItem, index: number) => {
  if (button.disabled || props.disabled) {
    event.preventDefault()
    return
  }

  if (!button.href) {
    event.preventDefault()
  }

  emit('click', button, index, event)
}
</script>
