<script setup lang="ts">
import { computed } from 'vue'
import Icon from '../atoms/Icon.vue'

export interface AlertBannerProps {
  /** Alert variant */
  variant?: 'success' | 'warning' | 'danger' | 'info'
  /** Alert title */
  title?: string
  /** Alert message/description */
  message?: string
  /** Show icon */
  showIcon?: boolean
  /** Custom icon name */
  icon?: string
  /** Show close button */
  closable?: boolean
  /** Banner style (filled or outlined) */
  style?: 'filled' | 'outlined'
}

const props = withDefaults(defineProps<AlertBannerProps>(), {
  variant: 'info',
  showIcon: true,
  closable: false,
  style: 'filled',
})

const emit = defineEmits<{
  close: []
}>()

const handleClose = () => {
  emit('close')
}

const containerClasses = computed(() => {
  const classes: string[] = ['rounded-lg p-4 border']

  if (props.style === 'filled') {
    const filledClasses = {
      success: 'bg-green-50 border-green-200',
      warning: 'bg-yellow-50 border-yellow-200',
      danger: 'bg-red-50 border-red-200',
      info: 'bg-blue-50 border-blue-200',
    }
    classes.push(filledClasses[props.variant])
  } else {
    classes.push('bg-white')
    const outlinedClasses = {
      success: 'border-green-300',
      warning: 'border-yellow-300',
      danger: 'border-red-300',
      info: 'border-blue-300',
    }
    classes.push(outlinedClasses[props.variant])
  }

  return classes.join(' ')
})

const iconClasses = computed(() => {
  const iconColors = {
    success: 'text-green-600',
    warning: 'text-yellow-600',
    danger: 'text-red-600',
    info: 'text-blue-600',
  }
  return iconColors[props.variant]
})

const titleClasses = computed(() => {
  const titleColors = {
    success: 'text-green-900',
    warning: 'text-yellow-900',
    danger: 'text-red-900',
    info: 'text-blue-900',
  }
  return `text-sm font-medium ${titleColors[props.variant]}`
})

const messageClasses = computed(() => {
  const messageColors = {
    success: 'text-green-700',
    warning: 'text-yellow-700',
    danger: 'text-red-700',
    info: 'text-blue-700',
  }
  return `text-sm mt-1 ${messageColors[props.variant]}`
})

const closeButtonClasses = computed(() => {
  const buttonColors = {
    success: 'text-green-600 hover:text-green-800',
    warning: 'text-yellow-600 hover:text-yellow-800',
    danger: 'text-red-600 hover:text-red-800',
    info: 'text-blue-600 hover:text-blue-800',
  }
  return `transition-colors ${buttonColors[props.variant]}`
})

const defaultIcon = computed(() => {
  if (props.icon) return props.icon

  const defaultIcons = {
    success: 'check-circle',
    warning: 'alert-triangle',
    danger: 'x-circle',
    info: 'info',
  }
  return defaultIcons[props.variant]
})
</script>

<template>
  <div :class="containerClasses" role="alert">
    <div class="flex">
      <!-- Icon -->
      <div v-if="showIcon" class="flex-shrink-0">
        <Icon :name="defaultIcon" :class="iconClasses" size="lg" />
      </div>

      <!-- Content -->
      <div class="flex-1" :class="showIcon ? 'ml-3' : ''">
        <!-- Title -->
        <h3 v-if="title || $slots.title" :class="titleClasses">
          <slot name="title">{{ title }}</slot>
        </h3>

        <!-- Message -->
        <div v-if="message || $slots.default" :class="messageClasses">
          <slot>{{ message }}</slot>
        </div>

        <!-- Actions slot -->
        <div v-if="$slots.actions" class="mt-3">
          <slot name="actions" />
        </div>
      </div>

      <!-- Close button -->
      <div v-if="closable" class="ml-auto flex-shrink-0 pl-3">
        <button type="button" :class="closeButtonClasses" @click="handleClose">
          <Icon name="x" size="md" aria-label="Close" />
        </button>
      </div>
    </div>
  </div>
</template>
