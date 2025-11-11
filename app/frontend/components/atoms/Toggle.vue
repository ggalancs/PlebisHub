<script setup lang="ts">
import { computed } from 'vue'

export interface ToggleProps {
  /** Toggle state */
  modelValue?: boolean
  /** Toggle size */
  size?: 'sm' | 'md' | 'lg'
  /** Label text */
  label?: string
  /** Label position */
  labelPosition?: 'left' | 'right'
  /** Disabled state */
  disabled?: boolean
  /** Variant color when enabled */
  variant?: 'primary' | 'secondary' | 'success' | 'danger' | 'warning' | 'info'
  /** Error message */
  error?: string
  /** Helper text */
  helperText?: string
}

const props = withDefaults(defineProps<ToggleProps>(), {
  modelValue: false,
  size: 'md',
  labelPosition: 'right',
  disabled: false,
  variant: 'primary',
})

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
}>()

const handleChange = (event: Event) => {
  const target = event.target as HTMLInputElement
  emit('update:modelValue', target.checked)
}

const toggleClasses = computed(() => {
  const classes: string[] = [
    'relative inline-flex items-center cursor-pointer rounded-full transition-colors duration-200',
  ]

  if (props.disabled) {
    classes.push('cursor-not-allowed opacity-50')
  }

  // Size variants
  const sizeClasses = {
    sm: 'h-5 w-9',
    md: 'h-6 w-11',
    lg: 'h-7 w-14',
  }
  classes.push(sizeClasses[props.size])

  // Background color (checked state)
  if (props.modelValue) {
    const variantClasses = {
      primary: 'bg-primary-600',
      secondary: 'bg-secondary-600',
      success: 'bg-green-600',
      danger: 'bg-red-600',
      warning: 'bg-yellow-500',
      info: 'bg-blue-600',
    }
    classes.push(variantClasses[props.variant])
  } else {
    classes.push('bg-gray-300')
  }

  return classes.join(' ')
})

const knobClasses = computed(() => {
  const classes: string[] = [
    'absolute bg-white rounded-full shadow-sm transition-transform duration-200',
  ]

  // Size variants for knob
  const sizeClasses = {
    sm: 'h-4 w-4',
    md: 'h-5 w-5',
    lg: 'h-6 w-6',
  }
  classes.push(sizeClasses[props.size])

  // Position based on state
  const positionClasses = {
    sm: props.modelValue ? 'translate-x-4' : 'translate-x-0.5',
    md: props.modelValue ? 'translate-x-5' : 'translate-x-0.5',
    lg: props.modelValue ? 'translate-x-7' : 'translate-x-0.5',
  }
  classes.push(positionClasses[props.size])

  return classes.join(' ')
})

const labelClasses = computed(() => {
  const classes: string[] = ['text-gray-700 font-medium select-none']

  if (props.disabled) {
    classes.push('text-gray-400 cursor-not-allowed')
  } else {
    classes.push('cursor-pointer')
  }

  // Size-based text size
  const textSizeClasses = {
    sm: 'text-sm',
    md: 'text-base',
    lg: 'text-lg',
  }
  classes.push(textSizeClasses[props.size])

  return classes.join(' ')
})

const containerClasses = computed(() => {
  const classes = ['inline-flex items-center']

  if (props.labelPosition === 'left') {
    classes.push('flex-row-reverse')
  }

  return classes.join(' ')
})

const gapClass = computed(() => {
  const gapClasses = {
    sm: 'gap-2',
    md: 'gap-2.5',
    lg: 'gap-3',
  }
  return gapClasses[props.size]
})
</script>

<template>
  <div>
    <label :class="[containerClasses, gapClass]">
      <input
        type="checkbox"
        :checked="modelValue"
        :disabled="disabled"
        class="sr-only"
        @change="handleChange"
      />
      <span :class="toggleClasses" :aria-checked="modelValue" role="switch">
        <span :class="knobClasses" aria-hidden="true"></span>
      </span>
      <span v-if="label || $slots.default" :class="labelClasses">
        <slot>{{ label }}</slot>
      </span>
    </label>
    <p v-if="error" class="mt-1 text-sm text-red-600">{{ error }}</p>
    <p v-if="helperText && !error" class="mt-1 text-sm text-gray-500">{{ helperText }}</p>
  </div>
</template>
