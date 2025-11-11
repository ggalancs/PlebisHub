<script setup lang="ts">
import { computed } from 'vue'
import Input from '../atoms/Input.vue'
import type { InputProps } from '../atoms/Input.vue'

export interface FormFieldProps extends Omit<InputProps, 'error' | 'helperText'> {
  /** Field label */
  label?: string
  /** Required field indicator */
  required?: boolean
  /** Error message */
  error?: string
  /** Helper text */
  helperText?: string
  /** Label position */
  labelPosition?: 'top' | 'left'
  /** Field layout (full width or inline) */
  layout?: 'vertical' | 'horizontal'
}

const props = withDefaults(defineProps<FormFieldProps>(), {
  labelPosition: 'top',
  layout: 'vertical',
  required: false,
})

const emit = defineEmits<{
  'update:modelValue': [value: string | number]
}>()

const handleInput = (value: string | number) => {
  emit('update:modelValue', value)
}

const containerClasses = computed(() => {
  const classes: string[] = []

  if (props.layout === 'horizontal') {
    classes.push('flex items-start gap-4')
  } else {
    classes.push('space-y-1')
  }

  return classes.join(' ')
})

const labelClasses = computed(() => {
  const classes: string[] = ['block text-sm font-medium']

  if (props.error) {
    classes.push('text-red-600')
  } else if (props.disabled) {
    classes.push('text-gray-400')
  } else {
    classes.push('text-gray-700')
  }

  if (props.layout === 'horizontal') {
    classes.push('pt-2 min-w-[120px]')
  } else {
    classes.push('mb-1')
  }

  return classes.join(' ')
})
</script>

<template>
  <div :class="containerClasses">
    <!-- Label -->
    <label v-if="label" :class="labelClasses">
      {{ label }}
      <span v-if="required" class="ml-0.5 text-red-600" aria-label="required">*</span>
    </label>

    <!-- Input wrapper -->
    <div :class="layout === 'horizontal' ? 'flex-1' : ''">
      <!-- Input component -->
      <Input
        :model-value="modelValue"
        :type="type"
        :placeholder="placeholder"
        :disabled="disabled"
        :readonly="readonly"
        :size="size"
        :show-password-toggle="showPasswordToggle"
        :error="error"
        :helper-text="helperText"
        @update:model-value="handleInput"
      >
        <!-- Pass through prefix/suffix slots -->
        <template v-if="$slots.prefix" #prefix>
          <slot name="prefix" />
        </template>
        <template v-if="$slots.suffix" #suffix>
          <slot name="suffix" />
        </template>
      </Input>
    </div>
  </div>
</template>
