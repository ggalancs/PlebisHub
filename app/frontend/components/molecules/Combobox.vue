<script setup lang="ts">
import { ref, computed, watch, nextTick, onMounted, onUnmounted } from 'vue'
import Icon from '../atoms/Icon.vue'
import Input from '../atoms/Input.vue'

export interface ComboboxOption {
  label: string
  value: string | number
  disabled?: boolean
  description?: string
  icon?: string
}

export interface Props {
  modelValue: string | number | (string | number)[] | null
  options: ComboboxOption[]
  label?: string
  description?: string
  placeholder?: string
  disabled?: boolean
  required?: boolean
  error?: string
  multiple?: boolean
  searchable?: boolean
  clearable?: boolean
  loading?: boolean
  loadingText?: string
  noResultsText?: string
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<Props>(), {
  disabled: false,
  required: false,
  multiple: false,
  searchable: true,
  clearable: true,
  loading: false,
  loadingText: 'Loading...',
  noResultsText: 'No results found',
  size: 'md',
  placeholder: 'Search...',
})

const emit = defineEmits<{
  'update:modelValue': [value: string | number | (string | number)[] | null]
  change: [value: string | number | (string | number)[] | null]
  search: [query: string]
  open: []
  close: []
}>()

const isOpen = ref(false)
const searchQuery = ref('')
const focusedIndex = ref(-1)
const inputRef = ref<HTMLElement | null>(null)
const listboxRef = ref<HTMLElement | null>(null)

// Size classes
const sizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'text-sm'
    case 'lg':
      return 'text-lg'
    default:
      return 'text-base'
  }
})

// Filtered options based on search query
const filteredOptions = computed(() => {
  if (!props.searchable || !searchQuery.value) {
    return props.options
  }

  const query = searchQuery.value.toLowerCase()
  return props.options.filter((option) =>
    option.label.toLowerCase().includes(query) ||
    option.description?.toLowerCase().includes(query)
  )
})

// Selected options
const selectedOptions = computed(() => {
  if (props.multiple) {
    const values = Array.isArray(props.modelValue) ? props.modelValue : []
    return props.options.filter((opt) => values.includes(opt.value))
  } else {
    return props.options.filter((opt) => opt.value === props.modelValue)
  }
})

// Display value
const displayValue = computed(() => {
  if (props.multiple) {
    return selectedOptions.value.map((opt) => opt.label).join(', ')
  } else {
    return selectedOptions.value[0]?.label || ''
  }
})

// Check if option is selected
const isSelected = (option: ComboboxOption) => {
  if (props.multiple) {
    const values = Array.isArray(props.modelValue) ? props.modelValue : []
    return values.includes(option.value)
  }
  return props.modelValue === option.value
}

// Open dropdown
const openDropdown = () => {
  if (props.disabled) return
  isOpen.value = true
  focusedIndex.value = -1
  emit('open')
}

// Close dropdown
const closeDropdown = () => {
  isOpen.value = false
  searchQuery.value = ''
  focusedIndex.value = -1
  emit('close')
}

// Toggle dropdown
const toggleDropdown = () => {
  if (isOpen.value) {
    closeDropdown()
  } else {
    openDropdown()
  }
}

// Select option
const selectOption = (option: ComboboxOption) => {
  if (option.disabled) return

  if (props.multiple) {
    const values = Array.isArray(props.modelValue) ? [...props.modelValue] : []
    const index = values.indexOf(option.value)

    if (index > -1) {
      values.splice(index, 1)
    } else {
      values.push(option.value)
    }

    emit('update:modelValue', values)
    emit('change', values)
  } else {
    emit('update:modelValue', option.value)
    emit('change', option.value)
    closeDropdown()
  }
}

// Clear selection
const clearSelection = () => {
  if (props.disabled) return

  const newValue = props.multiple ? [] : null
  emit('update:modelValue', newValue)
  emit('change', newValue)
}

// Handle search input
const handleSearchInput = (value: string | number) => {
  const stringValue = String(value)
  searchQuery.value = stringValue
  emit('search', stringValue)
  focusedIndex.value = -1
}

// Keyboard navigation
const handleKeydown = (e: KeyboardEvent) => {
  if (!isOpen.value && (e.key === 'ArrowDown' || e.key === 'ArrowUp')) {
    e.preventDefault()
    openDropdown()
    return
  }

  if (!isOpen.value) return

  switch (e.key) {
    case 'ArrowDown':
      e.preventDefault()
      focusNextOption()
      break
    case 'ArrowUp':
      e.preventDefault()
      focusPreviousOption()
      break
    case 'Enter':
      e.preventDefault()
      if (focusedIndex.value >= 0 && filteredOptions.value[focusedIndex.value]) {
        selectOption(filteredOptions.value[focusedIndex.value])
      }
      break
    case 'Escape':
      e.preventDefault()
      closeDropdown()
      break
    case 'Home':
      e.preventDefault()
      focusedIndex.value = 0
      scrollToFocusedOption()
      break
    case 'End':
      e.preventDefault()
      focusedIndex.value = filteredOptions.value.length - 1
      scrollToFocusedOption()
      break
    case 'Tab':
      closeDropdown()
      break
  }
}

// Focus next option
const focusNextOption = () => {
  if (focusedIndex.value < filteredOptions.value.length - 1) {
    focusedIndex.value++
    scrollToFocusedOption()
  }
}

// Focus previous option
const focusPreviousOption = () => {
  if (focusedIndex.value > 0) {
    focusedIndex.value--
    scrollToFocusedOption()
  } else if (focusedIndex.value === -1) {
    focusedIndex.value = 0
  }
}

// Scroll to focused option
const scrollToFocusedOption = async () => {
  await nextTick()
  if (!listboxRef.value) return

  const focusedElement = listboxRef.value.querySelector(
    `[data-index="${focusedIndex.value}"]`
  ) as HTMLElement

  if (focusedElement) {
    focusedElement.scrollIntoView({ block: 'nearest' })
  }
}

// Click outside handler
const handleClickOutside = (e: MouseEvent) => {
  if (!isOpen.value) return

  const target = e.target as Node
  // Get the actual DOM element (handles both HTMLElement and Vue component wrapper)
  const element = inputRef.value as any
  const domElement = element?.$el || element
  const comboboxElement = domElement?.closest ? domElement.closest('.combobox-container') : null

  if (comboboxElement && !comboboxElement.contains(target)) {
    closeDropdown()
  }
}

// Watch for open state changes
watch(isOpen, async (newValue) => {
  if (newValue) {
    await nextTick()
    if (props.searchable && inputRef.value) {
      // Get the actual DOM element (handles both HTMLElement and Vue component wrapper)
      const element = inputRef.value as any
      const domElement = element?.$el || element
      const input = domElement?.querySelector ? domElement.querySelector('input') : null
      input?.focus()
    }
  }
})

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})

defineSlots<{
  option?: (props: { option: ComboboxOption; selected: boolean }) => unknown
  'no-results'?: () => unknown
  loading?: () => unknown
}>()
</script>

<template>
  <div class="combobox-container" :class="sizeClasses">
    <!-- Label -->
    <label
      v-if="label"
      class="mb-2 block text-sm font-medium text-gray-700"
    >
      {{ label }}
      <span v-if="required" class="ml-1 text-red-500" aria-label="required">*</span>
    </label>

    <!-- Description -->
    <p v-if="description" class="mb-2 text-sm text-gray-500">
      {{ description }}
    </p>

    <!-- Combobox -->
    <div class="relative">
      <!-- Input/Trigger -->
      <div
        class="relative flex w-full cursor-pointer items-center rounded-md border bg-white"
        :class="[
          error ? 'border-red-500' : 'border-gray-300',
          disabled ? 'cursor-not-allowed bg-gray-100' : 'hover:border-gray-400',
        ]"
        @click="toggleDropdown"
      >
        <div class="flex-1 overflow-hidden">
          <Input
            v-if="searchable && isOpen"
            ref="inputRef"
            :model-value="searchQuery"
            :placeholder="placeholder"
            :disabled="disabled"
            :size="size"
            class="border-0"
            @update:model-value="handleSearchInput"
            @keydown="handleKeydown"
          />
          <div
            v-else
            class="px-3 py-2 text-gray-700"
            :class="{ 'text-gray-400': !displayValue }"
          >
            {{ displayValue || placeholder }}
          </div>
        </div>

        <!-- Icons -->
        <div class="flex items-center gap-1 pr-2">
          <button
            v-if="clearable && displayValue && !disabled"
            type="button"
            class="rounded p-1 hover:bg-gray-100"
            @click.stop="clearSelection"
            aria-label="Clear selection"
          >
            <Icon name="x" :size="16" />
          </button>

          <Icon
            name="chevron-down"
            :size="20"
            class="text-gray-400 transition-transform"
            :class="{ 'rotate-180': isOpen }"
          />
        </div>
      </div>

      <!-- Dropdown -->
      <Transition
        enter-active-class="transition-opacity duration-100"
        leave-active-class="transition-opacity duration-100"
        enter-from-class="opacity-0"
        leave-to-class="opacity-0"
      >
        <div
          v-if="isOpen"
          ref="listboxRef"
          class="absolute z-50 mt-1 max-h-60 w-full overflow-auto rounded-md border border-gray-200 bg-white shadow-lg"
          role="listbox"
          :aria-labelledby="label ? 'combobox-label' : undefined"
          :aria-multiselectable="multiple"
        >
          <!-- Loading -->
          <div
            v-if="loading"
            class="px-3 py-2 text-center text-sm text-gray-500"
          >
            <slot name="loading">
              <div class="flex items-center justify-center gap-2">
                <Icon name="loader-2" :size="16" class="animate-spin" />
                {{ loadingText }}
              </div>
            </slot>
          </div>

          <!-- No results -->
          <div
            v-else-if="filteredOptions.length === 0"
            class="px-3 py-2 text-center text-sm text-gray-500"
          >
            <slot name="no-results">
              {{ noResultsText }}
            </slot>
          </div>

          <!-- Options -->
          <div
            v-else
            v-for="(option, index) in filteredOptions"
            :key="option.value"
            :data-index="index"
            class="cursor-pointer px-3 py-2 transition-colors"
            :class="[
              option.disabled
                ? 'cursor-not-allowed text-gray-400'
                : 'hover:bg-gray-100',
              isSelected(option) ? 'bg-primary-50 text-primary-700' : '',
              focusedIndex === index ? 'bg-gray-100' : '',
            ]"
            role="option"
            :aria-selected="isSelected(option)"
            :aria-disabled="option.disabled"
            @click="selectOption(option)"
            @mouseenter="focusedIndex = index"
          >
            <slot name="option" :option="option" :selected="isSelected(option)">
              <div class="flex items-center justify-between">
                <div class="flex items-center gap-2">
                  <Icon
                    v-if="option.icon"
                    :name="option.icon"
                    :size="18"
                  />
                  <div>
                    <div class="font-medium">{{ option.label }}</div>
                    <div
                      v-if="option.description"
                      class="text-xs text-gray-500"
                    >
                      {{ option.description }}
                    </div>
                  </div>
                </div>
                <Icon
                  v-if="isSelected(option)"
                  name="check"
                  :size="18"
                  class="text-primary-600"
                />
              </div>
            </slot>
          </div>
        </div>
      </Transition>
    </div>

    <!-- Error Message -->
    <p v-if="error" class="mt-2 text-sm text-red-600">
      {{ error }}
    </p>
  </div>
</template>
