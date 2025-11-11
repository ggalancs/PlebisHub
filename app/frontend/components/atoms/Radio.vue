<script setup lang="ts">
import { computed } from 'vue'

export interface RadioProps {
  /** Radio selected value (v-model) */
  modelValue?: string | number | boolean
  /** Radio value */
  value: string | number | boolean
  /** Radio label */
  label?: string
  /** Helper text */
  helperText?: string
  /** Error message */
  error?: string
  /** Disabled state */
  disabled?: boolean
  /** Required field */
  required?: boolean
  /** Radio name (for grouping) */
  name?: string
  /** Radio id */
  id?: string
  /** Size */
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<RadioProps>(), {
  size: 'md',
  disabled: false,
  required: false,
})

const emit = defineEmits<{
  'update:modelValue': [value: string | number | boolean]
  change: [event: Event]
}>()

const radioId = computed(() => props.id || `radio-${Math.random().toString(36).substr(2, 9)}`)

const isChecked = computed(() => props.modelValue === props.value)

const radioClasses = computed(() => {
  const classes: string[] = [
    'rounded-full border-2 transition-all duration-200',
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
  } else if (isChecked.value) {
    classes.push('bg-white border-primary-700')
  } else {
    classes.push('border-gray-300 bg-white hover:border-primary-600')
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
  if (target.checked) {
    emit('update:modelValue', props.value)
    emit('change', event)
  }
}
</script>

<template>
  <div>
    <div class="flex items-start">
      <div class="flex h-6 items-center">
        <input
          :id="radioId"
          type="radio"
          :checked="isChecked"
          :value="value"
          :name="name"
          :disabled="disabled"
          :required="required"
          :class="radioClasses"
          :aria-invalid="!!error"
          :aria-describedby="
            error ? `${radioId}-error` : helperText ? `${radioId}-helper` : undefined
          "
          @change="handleChange"
        />
      </div>

      <div v-if="label" class="ml-3 flex-1">
        <label :for="radioId" :class="labelClasses">
          {{ label }}
          <span v-if="required" class="text-red-500" aria-label="required">*</span>
        </label>

        <!-- Helper text -->
        <p v-if="helperText && !error" :id="`${radioId}-helper`" class="mt-1 text-sm text-gray-500">
          {{ helperText }}
        </p>

        <!-- Error message -->
        <p v-if="error" :id="`${radioId}-error`" class="mt-1 text-sm text-red-600" role="alert">
          {{ error }}
        </p>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* Custom radio button with inner circle */
input[type='radio']:checked {
  background-image: radial-gradient(circle, #612d62 40%, transparent 40%);
}

input[type='radio']:disabled:checked {
  background-image: radial-gradient(circle, #9ca3af 40%, transparent 40%);
}
</style>
