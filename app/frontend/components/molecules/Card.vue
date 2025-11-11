<script setup lang="ts">
import { computed } from 'vue'

export interface CardProps {
  /** Card variant */
  variant?: 'default' | 'bordered' | 'elevated' | 'flat'
  /** Padding size */
  padding?: 'none' | 'sm' | 'md' | 'lg'
  /** Hoverable effect */
  hoverable?: boolean
  /** Clickable cursor */
  clickable?: boolean
  /** Link href */
  href?: string
  /** Disabled state */
  disabled?: boolean
  /** Title text */
  title?: string
  /** Subtitle text */
  subtitle?: string
  /** Image source */
  imageSrc?: string
  /** Image alt text */
  imageAlt?: string
}

const props = withDefaults(defineProps<CardProps>(), {
  variant: 'default',
  padding: 'md',
  hoverable: false,
  clickable: false,
  disabled: false,
})

const emit = defineEmits<{
  click: [event: MouseEvent]
}>()

const handleClick = (event: MouseEvent) => {
  if (props.disabled) return
  emit('click', event)
}

const cardClasses = computed(() => {
  const classes = ['card', 'bg-white', 'rounded-lg', 'transition-all', 'duration-200']

  // Variant styles
  if (props.variant === 'bordered') {
    classes.push('border', 'border-gray-200')
  } else if (props.variant === 'elevated') {
    classes.push('shadow-lg', 'border', 'border-gray-100')
  } else if (props.variant === 'flat') {
    classes.push('bg-gray-50')
  } else {
    // default
    classes.push('shadow-md', 'border', 'border-gray-100')
  }

  // Hoverable effect
  if (props.hoverable && !props.disabled) {
    if (props.variant === 'elevated') {
      classes.push('hover:shadow-xl')
    } else if (props.variant === 'flat') {
      classes.push('hover:bg-gray-100')
    } else {
      classes.push('hover:shadow-lg')
    }
  }

  // Clickable cursor
  if ((props.clickable || props.href) && !props.disabled) {
    classes.push('cursor-pointer')
  }

  // Disabled state
  if (props.disabled) {
    classes.push('opacity-50', 'cursor-not-allowed')
  }

  return classes.join(' ')
})

const bodyClasses = computed(() => {
  const classes = []

  // Padding
  const paddingMap = {
    none: '',
    sm: 'p-3',
    md: 'p-4',
    lg: 'p-6',
  }

  const paddingClass = paddingMap[props.padding]
  if (paddingClass) {
    classes.push(paddingClass)
  }

  return classes.join(' ')
})

const component = computed(() => {
  return props.href && !props.disabled ? 'a' : 'div'
})
</script>

<template>
  <component
    :is="component"
    :class="cardClasses"
    :href="href && !disabled ? href : undefined"
    :aria-disabled="disabled || undefined"
    @click="handleClick"
  >
    <!-- Image slot -->
    <div v-if="$slots.image || imageSrc" class="card-image">
      <slot name="image">
        <img
          v-if="imageSrc"
          :src="imageSrc"
          :alt="imageAlt || ''"
          class="h-auto w-full rounded-t-lg object-cover"
        />
      </slot>
    </div>

    <!-- Header slot -->
    <div v-if="$slots.header || title || subtitle" :class="[bodyClasses, 'card-header']">
      <slot name="header">
        <div v-if="title || subtitle">
          <h3 v-if="title" class="text-lg font-semibold text-gray-900">{{ title }}</h3>
          <p v-if="subtitle" class="mt-1 text-sm text-gray-500">{{ subtitle }}</p>
        </div>
      </slot>
    </div>

    <!-- Body slot -->
    <div v-if="$slots.default" :class="[bodyClasses, 'card-body']">
      <slot />
    </div>

    <!-- Footer slot -->
    <div v-if="$slots.footer" :class="[bodyClasses, 'card-footer', 'border-t', 'border-gray-200']">
      <slot name="footer" />
    </div>
  </component>
</template>
