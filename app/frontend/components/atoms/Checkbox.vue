<script setup lang="ts">
import { computed } from 'vue'

export interface CheckboxProps {
  /** Checkbox checked state (v-model) */
  modelValue?: boolean
  /** Checkbox label */
  label?: string
  /** Helper text */
  helperText?: string
  /** Error message */
  error?: string
  /** Disabled state */
  disabled?: boolean
  /** Indeterminate state */
  indeterminate?: boolean
  /** Required field */
  required?: boolean
  /** Checkbox value (for array v-model) */
  value?: string | number
  /** Checkbox name */
  name?: string
  /** Checkbox id */
  id?: string
  /** Size */
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<CheckboxProps>(), {
  modelValue: false,
  size: 'md',
  disabled: false,
  indeterminate: false,
  required: false,
})

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  change: [event: Event]
}>()

const checkboxId = computed(() => props.id || `checkbox-${Math.random().toString(36).substr(2, 9)}`)

const checkboxClasses = computed(() => {
  const classes: string[] = [
    'rounded border-2 transition-all duration-200',
    'focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-600',
    'disabled:bg-gray-100 disabled:cursor-not-allowed disabled:border-gray-300',
  ]

  // Size variants
  const sizeClasses = {
    sm: 'h-4 w-4',
    md: 'h-5 w-5',
    lg: 'h-6 w-6',
  }
  classes.push(sizeClasses[props.size])

  // State classes
  if (props.error) {
    classes.push('border-red-500 text-red-600')
  } else if (props.modelValue || props.indeterminate) {
    classes.push('bg-primary-700 border-primary-700 text-white')
  } else {
    classes.push('border-gray-300 text-white bg-white hover:border-primary-600')
  }

  return classes.join(' ')
})

const labelClasses = computed(() => {
  const classes: string[] = ['ml-2 text-gray-900']

  // Size variants
  const sizeClasses = {
    sm: 'text-sm',
    md: 'text-base',
    lg: 'text-lg',
  }
  classes.push(sizeClasses[props.size])

  if (props.disabled) {
    classes.push('text-gray-400 cursor-not-allowed')
  } else {
    classes.push('cursor-pointer')
  }

  return classes.join(' ')
})

const handleChange = (event: Event) => {
  const target = event.target as HTMLInputElement
  emit('update:modelValue', target.checked)
  emit('change', event)
}
</script>

<template>
  <div>
    <div class="flex items-start">
      <div class="flex h-6 items-center">
        <input
          :id="checkboxId"
          type="checkbox"
          :checked="modelValue"
          :value="value"
          :name="name"
          :disabled="disabled"
          :required="required"
          :indeterminate="indeterminate"
          :class="checkboxClasses"
          :aria-invalid="!!error"
          :aria-describedby="
            error ? `${checkboxId}-error` : helperText ? `${checkboxId}-helper` : undefined
          "
          @change="handleChange"
        />
      </div>

      <div v-if="label" class="ml-3 flex-1">
        <label :for="checkboxId" :class="labelClasses">
          {{ label }}
          <span v-if="required" class="text-red-500" aria-label="required">*</span>
        </label>

        <!-- Helper text -->
        <p
          v-if="helperText && !error"
          :id="`${checkboxId}-helper`"
          class="mt-1 text-sm text-gray-500"
        >
          {{ helperText }}
        </p>

        <!-- Error message -->
        <p v-if="error" :id="`${checkboxId}-error`" class="mt-1 text-sm text-red-600" role="alert">
          {{ error }}
        </p>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* Custom checkbox styles */
input[type='checkbox']:indeterminate {
  background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 16 16'%3e%3cpath stroke='white' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M4 8h8'/%3e%3c/svg%3e");
  background-size: 100% 100%;
  background-position: center;
  background-repeat: no-repeat;
}

input[type='checkbox']:checked {
  background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16' fill='white'%3e%3cpath d='M12.207 4.793a1 1 0 010 1.414l-5 5a1 1 0 01-1.414 0l-2-2a1 1 0 011.414-1.414L6.5 9.086l4.293-4.293a1 1 0 011.414 0z'/%3e%3c/svg%3e");
  background-size: 100% 100%;
  background-position: center;
  background-repeat: no-repeat;
}
</style>
