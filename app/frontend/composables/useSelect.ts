/**
 * Select Composable
 * Replaces Select2 jQuery plugin with Vue reactive system
 */

import { ref, computed, watch, onMounted, onUnmounted, type Ref } from 'vue'
import { useDebounce } from './useDebounce'

export interface SelectOption {
  value: string | number
  label: string
  disabled?: boolean
  group?: string
  data?: Record<string, unknown>
}

export interface UseSelectOptions {
  /** Initial selected value(s) */
  modelValue?: string | number | (string | number)[] | null
  /** Available options */
  options?: SelectOption[]
  /** Allow multiple selection */
  multiple?: boolean
  /** Allow clearing selection */
  clearable?: boolean
  /** Enable search/filter */
  searchable?: boolean
  /** Placeholder text */
  placeholder?: string
  /** Disable the select */
  disabled?: boolean
  /** Async search function */
  searchFn?: (query: string) => Promise<SelectOption[]>
  /** Debounce delay for async search (ms) */
  searchDelay?: number
  /** Minimum characters before search */
  minSearchLength?: number
  /** No results message */
  noResultsMessage?: string
  /** Loading message */
  loadingMessage?: string
  /** Create new options from search */
  creatable?: boolean
  /** Custom filter function */
  filterFn?: (option: SelectOption, query: string) => boolean
}

export function useSelect(options: UseSelectOptions = {}) {
  // State
  const isOpen = ref(false)
  const searchQuery = ref('')
  const isLoading = ref(false)
  const highlightedIndex = ref(-1)
  const asyncOptions = ref<SelectOption[]>([])

  // Selected value(s)
  const selectedValue: Ref<string | number | (string | number)[] | null> = ref(
    options.modelValue ?? (options.multiple ? [] : null)
  )

  // Debounced search
  const debouncedQuery = useDebounce(searchQuery, options.searchDelay ?? 300)

  // All available options (static + async)
  const allOptions = computed(() => {
    if (asyncOptions.value.length > 0) {
      return asyncOptions.value
    }
    return options.options ?? []
  })

  // Filtered options based on search
  const filteredOptions = computed(() => {
    const query = searchQuery.value.toLowerCase().trim()

    if (!query || !options.searchable) {
      return allOptions.value
    }

    if (options.filterFn) {
      return allOptions.value.filter((opt) => options.filterFn!(opt, query))
    }

    return allOptions.value.filter(
      (opt) =>
        opt.label.toLowerCase().includes(query) || String(opt.value).toLowerCase().includes(query)
    )
  })

  // Grouped options
  const groupedOptions = computed(() => {
    const groups: Record<string, SelectOption[]> = {}
    const ungrouped: SelectOption[] = []

    filteredOptions.value.forEach((opt) => {
      if (opt.group) {
        if (!groups[opt.group]) {
          groups[opt.group] = []
        }
        groups[opt.group].push(opt)
      } else {
        ungrouped.push(opt)
      }
    })

    return { groups, ungrouped }
  })

  // Selected option object(s)
  const selectedOptions = computed(() => {
    if (options.multiple) {
      const values = selectedValue.value as (string | number)[]
      return allOptions.value.filter((opt) => values.includes(opt.value))
    }
    return allOptions.value.find((opt) => opt.value === selectedValue.value) || null
  })

  // Display value
  const displayValue = computed(() => {
    if (options.multiple) {
      const selected = selectedOptions.value as SelectOption[]
      if (selected.length === 0) return options.placeholder || ''
      return selected.map((opt) => opt.label).join(', ')
    }
    const selected = selectedOptions.value as SelectOption | null
    return selected?.label || options.placeholder || ''
  })

  // Has selection
  const hasSelection = computed(() => {
    if (options.multiple) {
      return (selectedValue.value as (string | number)[]).length > 0
    }
    return selectedValue.value !== null && selectedValue.value !== ''
  })

  // Async search
  watch(debouncedQuery, async (query) => {
    if (!options.searchFn) return

    const minLength = options.minSearchLength ?? 0
    if (query.length < minLength) {
      asyncOptions.value = []
      return
    }

    isLoading.value = true
    try {
      asyncOptions.value = await options.searchFn(query)
    } catch (e) {
      console.error('[useSelect] Search failed:', e)
      asyncOptions.value = []
    } finally {
      isLoading.value = false
    }
  })

  // Methods
  function open() {
    if (options.disabled) return
    isOpen.value = true
    highlightedIndex.value = -1
  }

  function close() {
    isOpen.value = false
    searchQuery.value = ''
    highlightedIndex.value = -1
  }

  function toggle() {
    if (isOpen.value) {
      close()
    } else {
      open()
    }
  }

  function select(value: string | number) {
    if (options.multiple) {
      const current = selectedValue.value as (string | number)[]
      const index = current.indexOf(value)
      if (index === -1) {
        selectedValue.value = [...current, value]
      } else {
        selectedValue.value = current.filter((v) => v !== value)
      }
    } else {
      selectedValue.value = value
      close()
    }
  }

  function deselect(value: string | number) {
    if (options.multiple) {
      selectedValue.value = (selectedValue.value as (string | number)[]).filter((v) => v !== value)
    } else {
      selectedValue.value = null
    }
  }

  function clear() {
    selectedValue.value = options.multiple ? [] : null
    searchQuery.value = ''
  }

  function isSelected(value: string | number): boolean {
    if (options.multiple) {
      return (selectedValue.value as (string | number)[]).includes(value)
    }
    return selectedValue.value === value
  }

  function highlightNext() {
    const max = filteredOptions.value.length - 1
    highlightedIndex.value = Math.min(highlightedIndex.value + 1, max)
  }

  function highlightPrev() {
    highlightedIndex.value = Math.max(highlightedIndex.value - 1, 0)
  }

  function selectHighlighted() {
    if (highlightedIndex.value >= 0 && highlightedIndex.value < filteredOptions.value.length) {
      select(filteredOptions.value[highlightedIndex.value].value)
    }
  }

  // Keyboard navigation
  function handleKeydown(e: KeyboardEvent) {
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault()
        if (!isOpen.value) {
          open()
        } else {
          highlightNext()
        }
        break
      case 'ArrowUp':
        e.preventDefault()
        highlightPrev()
        break
      case 'Enter':
        e.preventDefault()
        if (isOpen.value) {
          selectHighlighted()
        } else {
          open()
        }
        break
      case 'Escape':
        e.preventDefault()
        close()
        break
      case 'Tab':
        close()
        break
    }
  }

  // Click outside handler
  let clickOutsideHandler: ((e: MouseEvent) => void) | null = null

  onMounted(() => {
    clickOutsideHandler = (_e: MouseEvent) => {
      // This should be handled by the component with a ref to the container
    }
  })

  onUnmounted(() => {
    if (clickOutsideHandler) {
      document.removeEventListener('click', clickOutsideHandler)
    }
  })

  return {
    // State
    isOpen,
    isLoading,
    searchQuery,
    highlightedIndex,

    // Computed
    filteredOptions,
    groupedOptions,
    selectedValue,
    selectedOptions,
    displayValue,
    hasSelection,

    // Methods
    open,
    close,
    toggle,
    select,
    deselect,
    clear,
    isSelected,
    highlightNext,
    highlightPrev,
    selectHighlighted,
    handleKeydown,
  }
}
