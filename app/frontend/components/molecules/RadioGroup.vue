<template>
  <fieldset :class="['space-y-3', disabled && 'cursor-not-allowed opacity-50']">
    <legend v-if="label" :class="['text-sm font-medium', labelColorClasses]">
      {{ label }}
      <span v-if="required" class="text-red-500">*</span>
    </legend>
    <p v-if="description" class="mb-3 text-sm text-gray-600">
      {{ description }}
    </p>

    <div :class="orientation === 'horizontal' ? 'flex flex-wrap gap-4' : 'space-y-2'">
      <label
        v-for="option in options"
        :key="option.value"
        :class="[
          'flex cursor-pointer items-center gap-2',
          option.disabled && 'cursor-not-allowed opacity-50',
          disabled && 'cursor-not-allowed',
        ]"
      >
        <input
          type="radio"
          :name="name"
          :value="option.value"
          :checked="modelValue === option.value"
          :disabled="disabled || option.disabled"
          :class="[
            'text-primary focus:ring-primary h-4 w-4 border-gray-300 focus:ring-2 focus:ring-offset-0',
            'cursor-pointer transition-colors',
            (disabled || option.disabled) && 'cursor-not-allowed',
          ]"
          @change="handleChange(option.value)"
        />
        <span :class="['text-sm', option.disabled ? 'text-gray-400' : 'text-gray-700']">
          {{ option.label }}
        </span>
      </label>
    </div>

    <p v-if="error" class="mt-2 text-sm text-red-600">
      {{ error }}
    </p>
  </fieldset>
</template>

<script setup lang="ts">
import { computed } from 'vue'

/**
 * Radio group component for single selection
 */
export interface RadioOption {
  /**
   * Display label
   */
  label: string
  /**
   * Option value
   */
  value: string | number
  /**
   * Whether this option is disabled
   */
  disabled?: boolean
}

export interface Props {
  /**
   * Selected value
   */
  modelValue: string | number | null
  /**
   * Available options
   */
  options: RadioOption[]
  /**
   * Group label
   */
  label?: string
  /**
   * Description text
   */
  description?: string
  /**
   * Name attribute for radio inputs
   */
  name?: string
  /**
   * Orientation of radios
   * @default 'vertical'
   */
  orientation?: 'vertical' | 'horizontal'
  /**
   * Whether the group is disabled
   * @default false
   */
  disabled?: boolean
  /**
   * Whether the field is required
   * @default false
   */
  required?: boolean
  /**
   * Error message
   */
  error?: string
}

const props = withDefaults(defineProps<Props>(), {
  orientation: 'vertical',
  disabled: false,
  required: false,
  name: `radio-group-${Math.random().toString(36).substr(2, 9)}`,
})

const emit = defineEmits<{
  'update:modelValue': [value: string | number]
  change: [value: string | number]
}>()

const labelColorClasses = computed(() => {
  if (props.error) {
    return 'text-red-700'
  }
  return 'text-gray-900'
})

const handleChange = (value: string | number) => {
  if (props.disabled) return

  emit('update:modelValue', value)
  emit('change', value)
}
</script>
