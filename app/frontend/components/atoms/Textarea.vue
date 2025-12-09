<script setup lang="ts">
/**
 * Textarea Component
 *
 * A styled textarea with support for validation states and character counting.
 */

import { computed } from 'vue'

interface Props {
  modelValue?: string
  placeholder?: string
  rows?: number
  maxLength?: number
  disabled?: boolean
  readonly?: boolean
  error?: boolean
  errorMessage?: string
  showCount?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: '',
  rows: 3,
  disabled: false,
  readonly: false,
  error: false,
  showCount: false,
})

const emit = defineEmits<{
  (e: 'update:modelValue', value: string): void
}>()

const value = computed({
  get: () => props.modelValue,
  set: (val) => emit('update:modelValue', val),
})

const characterCount = computed(() => props.modelValue?.length || 0)

const inputClasses = computed(() => [
  'form-textarea w-full px-3 py-2 rounded-lg border transition-colors resize-y',
  'focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500',
  props.error
    ? 'border-red-500 focus:ring-red-500 focus:border-red-500'
    : 'border-gray-300 dark:border-gray-600',
  props.disabled ? 'opacity-50 cursor-not-allowed bg-gray-100' : 'bg-white dark:bg-gray-800',
])
</script>

<template>
  <div class="textarea-wrapper">
    <textarea
      v-model="value"
      :placeholder="placeholder"
      :rows="rows"
      :maxlength="maxLength"
      :disabled="disabled"
      :readonly="readonly"
      :class="inputClasses"
    />

    <div v-if="showCount && maxLength" class="mt-1 text-xs text-gray-500 text-right">
      {{ characterCount }} / {{ maxLength }}
    </div>

    <p v-if="error && errorMessage" class="mt-1 text-sm text-red-500">
      {{ errorMessage }}
    </p>
  </div>
</template>
