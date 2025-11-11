<script setup lang="ts">
import { ref, computed } from 'vue'
import Input from '../atoms/Input.vue'
import Icon from '../atoms/Icon.vue'

export interface SearchBarProps {
  /** Search query value */
  modelValue?: string
  /** Placeholder text */
  placeholder?: string
  /** SearchBar size */
  size?: 'sm' | 'md' | 'lg'
  /** Disabled state */
  disabled?: boolean
  /** Show search button */
  showButton?: boolean
  /** Button text */
  buttonText?: string
  /** Loading state */
  loading?: boolean
  /** Show clear button */
  showClear?: boolean
  /** Debounce delay in ms */
  debounce?: number
}

const props = withDefaults(defineProps<SearchBarProps>(), {
  modelValue: '',
  placeholder: 'Search...',
  size: 'md',
  disabled: false,
  showButton: false,
  buttonText: 'Search',
  loading: false,
  showClear: true,
  debounce: 0,
})

const emit = defineEmits<{
  'update:modelValue': [value: string]
  search: [value: string]
  clear: []
}>()

const inputValue = ref(props.modelValue)
let debounceTimeout: ReturnType<typeof setTimeout>

const handleInput = (value: string | number) => {
  const stringValue = String(value)
  inputValue.value = stringValue
  emit('update:modelValue', stringValue)

  // Debounced search emission
  if (props.debounce > 0) {
    clearTimeout(debounceTimeout)
    debounceTimeout = setTimeout(() => {
      emit('search', stringValue)
    }, props.debounce)
  } else {
    emit('search', stringValue)
  }
}

const handleClear = () => {
  inputValue.value = ''
  emit('update:modelValue', '')
  emit('clear')
  emit('search', '')
}

const handleSearch = () => {
  emit('search', inputValue.value)
}

const showClearButton = computed(() => {
  return props.showClear && inputValue.value.length > 0 && !props.disabled
})

const buttonClasses = computed(() => {
  const classes: string[] = [
    'inline-flex items-center gap-2 px-4 py-2',
    'font-medium text-white rounded-md',
    'transition-colors duration-200',
    'disabled:opacity-50 disabled:cursor-not-allowed',
  ]

  if (props.loading) {
    classes.push('bg-primary-400 cursor-wait')
  } else {
    classes.push('bg-primary-600 hover:bg-primary-700')
  }

  // Size variants
  const sizeClasses = {
    sm: 'text-sm px-3 py-1.5',
    md: 'text-base px-4 py-2',
    lg: 'text-lg px-5 py-3',
  }
  classes.push(sizeClasses[props.size])

  return classes.join(' ')
})
</script>

<template>
  <div class="flex gap-2">
    <div class="flex-1">
      <Input
        :model-value="inputValue"
        type="search"
        :placeholder="placeholder"
        :size="size"
        :disabled="disabled"
        @update:model-value="handleInput"
      >
        <template #prefix>
          <Icon
            name="search"
            :size="size === 'sm' ? 'sm' : size === 'lg' ? 'lg' : 'md'"
            class="text-gray-400"
          />
        </template>
        <template v-if="showClearButton" #suffix>
          <button
            type="button"
            class="pointer-events-auto text-gray-400 transition-colors hover:text-gray-600"
            @click="handleClear"
          >
            <Icon
              name="x"
              :size="size === 'sm' ? 'sm' : size === 'lg' ? 'lg' : 'md'"
              aria-label="Clear search"
            />
          </button>
        </template>
      </Input>
    </div>

    <button
      v-if="showButton"
      type="button"
      :class="buttonClasses"
      :disabled="disabled || loading"
      @click="handleSearch"
    >
      <Icon v-if="loading" name="loader-2" class="animate-spin" />
      <Icon v-else name="search" />
      {{ buttonText }}
    </button>
  </div>
</template>
