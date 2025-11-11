<script setup lang="ts">
import { computed } from 'vue'
import * as icons from 'lucide-vue-next'

export interface IconProps {
  /** Icon name from Lucide library */
  name: string
  /** Icon size */
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl' | number
  /** Icon color */
  color?: string
  /** Stroke width */
  strokeWidth?: number
  /** Additional CSS classes */
  class?: string
  /** Aria label for accessibility */
  ariaLabel?: string
}

const props = withDefaults(defineProps<IconProps>(), {
  size: 'md',
  strokeWidth: 2,
})

const iconComponent = computed(() => {
  // Convert kebab-case to PascalCase for Lucide icon names
  // e.g., 'arrow-right' -> 'ArrowRight'
  const pascalName = props.name
    .split('-')
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join('')

  // Get icon from lucide-vue-next
  const icon = (icons as Record<string, unknown>)[pascalName]

  if (!icon) {
    console.warn(`Icon "${props.name}" (${pascalName}) not found in Lucide library`)
    // Return default icon component (Circle as fallback)
    return icons.Circle
  }

  return icon
})

const sizeClass = computed(() => {
  if (typeof props.size === 'number') {
    return undefined // Will use inline style
  }

  const sizeClasses = {
    xs: 'h-3 w-3',
    sm: 'h-4 w-4',
    md: 'h-5 w-5',
    lg: 'h-6 w-6',
    xl: 'h-8 w-8',
    '2xl': 'h-10 w-10',
  }

  return sizeClasses[props.size]
})

const sizeStyle = computed(() => {
  if (typeof props.size === 'number') {
    return {
      width: `${props.size}px`,
      height: `${props.size}px`,
    }
  }
  return undefined
})

const colorStyle = computed(() => {
  if (props.color) {
    return { color: props.color }
  }
  return undefined
})

const combinedClass = computed(() => {
  const classes = ['inline-block flex-shrink-0']

  if (sizeClass.value) {
    classes.push(sizeClass.value)
  }

  if (props.class) {
    classes.push(props.class)
  }

  return classes.join(' ')
})

const combinedStyle = computed(() => {
  return {
    ...sizeStyle.value,
    ...colorStyle.value,
  }
})
</script>

<template>
  <component
    :is="iconComponent"
    :class="combinedClass"
    :style="combinedStyle"
    :stroke-width="strokeWidth"
    :aria-label="ariaLabel"
    :aria-hidden="!ariaLabel"
  />
</template>
