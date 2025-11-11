<script setup lang="ts">
import { computed, ref } from 'vue'

export interface InputProps {
  /** Input type */
  type?: 'text' | 'email' | 'password' | 'number' | 'tel' | 'url' | 'search' | 'date'
  /** Input value (v-model) */
  modelValue?: string | number
  /** Input placeholder */
  placeholder?: string
  /** Input label */
  label?: string
  /** Helper text */
  helperText?: string
  /** Error message */
  error?: string
  /** Disabled state */
  disabled?: boolean
  /** Required field */
  required?: boolean
  /** Read-only state */
  readonly?: boolean
  /** Input size */
  size?: 'sm' | 'md' | 'lg'
  /** Full width */
  fullWidth?: boolean
  /** Input name */
  name?: string
  /** Input id */
  id?: string
  /** Autocomplete */
  autocomplete?: string
  /** Min value (for number) */
  min?: number
  /** Max value (for number) */
  max?: number
  /** Step (for number) */
  step?: number
  /** Pattern (for validation) */
  pattern?: string
  /** Max length */
  maxlength?: number
  /** Show password toggle (for password type) */
  showPasswordToggle?: boolean
}

const props = withDefaults(defineProps<InputProps>(), {
  type: 'text',
  size: 'md',
  fullWidth: false,
  required: false,
  disabled: false,
  readonly: false,
  showPasswordToggle: true,
})

const emit = defineEmits<{
  'update:modelValue': [value: string | number]
  blur: [event: FocusEvent]
  focus: [event: FocusEvent]
  change: [event: Event]
  input: [event: Event]
}>()

const inputRef = ref<HTMLInputElement>()
const showPassword = ref(false)

const inputId = computed(() => props.id || `input-${Math.random().toString(36).substr(2, 9)}`)

const inputType = computed(() => {
  if (props.type === 'password' && showPassword.value) {
    return 'text'
  }
  return props.type
})

const inputClasses = computed(() => {
  const classes: string[] = [
    'block w-full rounded-lg border transition-all duration-200',
    'focus:outline-none focus:ring-2 focus:ring-offset-0',
    'disabled:bg-gray-50 disabled:text-gray-500 disabled:cursor-not-allowed',
    'read-only:bg-gray-50 read-only:cursor-default',
  ]

  // Size variants
  const sizeClasses = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-base',
    lg: 'px-5 py-3 text-lg',
  }
  classes.push(sizeClasses[props.size])

  // Error state
  if (props.error) {
    classes.push(
      'border-red-300 text-red-900 placeholder-red-300',
      'focus:ring-red-500 focus:border-red-500'
    )
  } else {
    classes.push(
      'border-gray-300 text-gray-900 placeholder-gray-400',
      'focus:ring-primary-600 focus:border-primary-600',
      'hover:border-gray-400'
    )
  }

  return classes.join(' ')
})

const containerClasses = computed(() => {
  return props.fullWidth ? 'w-full' : ''
})

const handleInput = (event: Event) => {
  const target = event.target as HTMLInputElement
  const value = props.type === 'number' ? Number(target.value) : target.value
  emit('update:modelValue', value)
  emit('input', event)
}

const handleBlur = (event: FocusEvent) => {
  emit('blur', event)
}

const handleFocus = (event: FocusEvent) => {
  emit('focus', event)
}

const handleChange = (event: Event) => {
  emit('change', event)
}

const togglePasswordVisibility = () => {
  showPassword.value = !showPassword.value
}

const focus = () => {
  inputRef.value?.focus()
}

const blur = () => {
  inputRef.value?.blur()
}

defineExpose({
  focus,
  blur,
  inputRef,
})
</script>

<template>
  <div :class="containerClasses">
    <!-- Label -->
    <label v-if="label" :for="inputId" class="mb-1 block text-sm font-medium text-gray-700">
      {{ label }}
      <span v-if="required" class="text-red-500" aria-label="required">*</span>
    </label>

    <!-- Input wrapper (for password toggle) -->
    <div class="relative">
      <!-- Prefix slot -->
      <div
        v-if="$slots.prefix"
        class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3"
      >
        <slot name="prefix" />
      </div>

      <!-- Input -->
      <input
        :id="inputId"
        ref="inputRef"
        :type="inputType"
        :value="modelValue"
        :name="name"
        :placeholder="placeholder"
        :disabled="disabled"
        :readonly="readonly"
        :required="required"
        :autocomplete="autocomplete"
        :min="min"
        :max="max"
        :step="step"
        :pattern="pattern"
        :maxlength="maxlength"
        :class="[
          inputClasses,
          $slots.prefix ? 'pl-10' : '',
          $slots.suffix && type !== 'password' ? 'pr-10' : '',
        ]"
        :aria-invalid="!!error"
        :aria-describedby="
          error ? `${inputId}-error` : helperText ? `${inputId}-helper` : undefined
        "
        @input="handleInput"
        @blur="handleBlur"
        @focus="handleFocus"
        @change="handleChange"
      />

      <!-- Suffix slot (if not password type with toggle) -->
      <div
        v-if="$slots.suffix && !(type === 'password' && showPasswordToggle)"
        class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3"
      >
        <slot name="suffix" />
      </div>

      <!-- Password toggle button -->
      <button
        v-if="type === 'password' && showPasswordToggle && !disabled"
        type="button"
        class="absolute inset-y-0 right-0 flex items-center pr-3 text-gray-400 hover:text-gray-600"
        tabindex="-1"
        @click="togglePasswordVisibility"
      >
        <svg
          v-if="showPassword"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="h-5 w-5"
          aria-hidden="true"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.523 10.523 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228l-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.242 4.242L9.88 9.88"
          />
        </svg>
        <svg
          v-else
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="h-5 w-5"
          aria-hidden="true"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M2.036 12.322a1.012 1.012 0 010-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178z"
          />
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
          />
        </svg>
        <span class="sr-only">
          {{ showPassword ? 'Hide password' : 'Show password' }}
        </span>
      </button>
    </div>

    <!-- Helper text -->
    <p v-if="helperText && !error" :id="`${inputId}-helper`" class="mt-1 text-sm text-gray-500">
      {{ helperText }}
    </p>

    <!-- Error message -->
    <p v-if="error" :id="`${inputId}-error`" class="mt-1 text-sm text-red-600" role="alert">
      {{ error }}
    </p>
  </div>
</template>
