<script setup lang="ts">
/**
 * Select Component
 *
 * A styled select dropdown with support for validation states.
 */

import { computed } from 'vue'

export interface SelectOption {
  value: string | number
  label: string
  disabled?: boolean
}

interface Props {
  modelValue?: string | number
  options: SelectOption[]
  placeholder?: string
  disabled?: boolean
  error?: boolean
  errorMessage?: string
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: '',
  options: () => [],
  disabled: false,
  error: false,
})

const emit = defineEmits<{
  (e: 'update:modelValue', value: string | number): void
}>()

const value = computed({
  get: () => props.modelValue,
  set: (val) => emit('update:modelValue', val),
})

const selectClasses = computed(() => [
  'form-select w-full px-3 py-2 rounded-lg border transition-colors appearance-none',
  'focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500',
  'bg-no-repeat bg-right pr-10',
  props.error
    ? 'border-red-500 focus:ring-red-500 focus:border-red-500'
    : 'border-gray-300 dark:border-gray-600',
  props.disabled ? 'opacity-50 cursor-not-allowed bg-gray-100' : 'bg-white dark:bg-gray-800',
])
</script>

<template>
  <div class="select-wrapper">
    <div class="relative">
      <select
        v-model="value"
        :disabled="disabled"
        :class="selectClasses"
      >
        <option v-if="placeholder" value="" disabled>
          {{ placeholder }}
        </option>
        <option
          v-for="option in options"
          :key="option.value"
          :value="option.value"
          :disabled="option.disabled"
        >
          {{ option.label }}
        </option>
      </select>

      <!-- Dropdown arrow -->
      <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
        <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
        </svg>
      </div>
    </div>

    <p v-if="error && errorMessage" class="mt-1 text-sm text-red-500">
      {{ errorMessage }}
    </p>
  </div>
</template>
