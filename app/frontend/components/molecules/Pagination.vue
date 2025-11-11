<script setup lang="ts">
import { computed } from 'vue'
import Icon from '../atoms/Icon.vue'

export interface PaginationProps {
  /** Current page (1-indexed) */
  currentPage: number
  /** Total number of items */
  totalItems: number
  /** Items per page */
  pageSize?: number
  /** Available page size options */
  pageSizeOptions?: number[]
  /** Show page size selector */
  showPageSize?: boolean
  /** Show total count */
  showTotal?: boolean
  /** Show first/last buttons */
  showFirstLast?: boolean
  /** Maximum number of page buttons to show */
  maxButtons?: number
  /** Disabled state */
  disabled?: boolean
  /** Size variant */
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<PaginationProps>(), {
  pageSize: 10,
  pageSizeOptions: () => [10, 20, 50, 100],
  showPageSize: false,
  showTotal: true,
  showFirstLast: false,
  maxButtons: 7,
  disabled: false,
  size: 'md',
})

const emit = defineEmits<{
  'update:currentPage': [page: number]
  'update:pageSize': [size: number]
  'page-change': [page: number]
  'page-size-change': [size: number]
}>()

const totalPages = computed(() => Math.ceil(props.totalItems / props.pageSize))

const startItem = computed(() => {
  if (props.totalItems === 0) return 0
  return (props.currentPage - 1) * props.pageSize + 1
})

const endItem = computed(() => {
  const end = props.currentPage * props.pageSize
  return Math.min(end, props.totalItems)
})

const pageNumbers = computed(() => {
  const pages: (number | string)[] = []
  const total = totalPages.value
  const current = props.currentPage
  const max = props.maxButtons

  if (total <= max) {
    // Show all pages
    for (let i = 1; i <= total; i++) {
      pages.push(i)
    }
  } else {
    // Always show first page
    pages.push(1)

    let startPage = Math.max(2, current - Math.floor((max - 4) / 2))
    let endPage = Math.min(total - 1, current + Math.floor((max - 4) / 2))

    // Adjust if near start
    if (current <= Math.floor((max - 2) / 2) + 1) {
      startPage = 2
      endPage = max - 2
    }

    // Adjust if near end
    if (current >= total - Math.floor((max - 2) / 2)) {
      startPage = total - (max - 3)
      endPage = total - 1
    }

    // Add ellipsis after first page if needed
    if (startPage > 2) {
      pages.push('...')
    }

    // Add middle pages
    for (let i = startPage; i <= endPage; i++) {
      pages.push(i)
    }

    // Add ellipsis before last page if needed
    if (endPage < total - 1) {
      pages.push('...')
    }

    // Always show last page
    pages.push(total)
  }

  return pages
})

const handlePageChange = (page: number) => {
  if (page === props.currentPage || page < 1 || page > totalPages.value || props.disabled) {
    return
  }
  emit('update:currentPage', page)
  emit('page-change', page)
}

const handlePageSizeChange = (event: Event) => {
  const target = event.target as HTMLSelectElement
  const newSize = Number(target.value)
  emit('update:pageSize', newSize)
  emit('page-size-change', newSize)

  // Adjust current page if necessary
  const newTotalPages = Math.ceil(props.totalItems / newSize)
  if (props.currentPage > newTotalPages) {
    emit('update:currentPage', newTotalPages)
    emit('page-change', newTotalPages)
  }
}

const buttonClasses = computed(() => {
  const baseClasses = [
    'inline-flex items-center justify-center',
    'border border-gray-300 bg-white',
    'text-gray-700 font-medium',
    'transition-colors duration-200',
    'hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-1',
    'disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-white',
  ]

  const sizeClasses = {
    sm: 'min-w-[32px] h-8 px-2 text-sm rounded',
    md: 'min-w-[36px] h-9 px-3 text-sm rounded-md',
    lg: 'min-w-[40px] h-10 px-4 text-base rounded-md',
  }

  return [...baseClasses, sizeClasses[props.size]].join(' ')
})

const activeButtonClasses = computed(() => {
  return [
    buttonClasses.value,
    'bg-primary-600 text-white border-primary-600',
    'hover:bg-primary-700 hover:border-primary-700',
  ].join(' ')
})

const selectClasses = computed(() => {
  const baseClasses = [
    'border border-gray-300 rounded-md',
    'text-gray-700 bg-white',
    'focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-primary-500',
    'disabled:opacity-50 disabled:cursor-not-allowed',
  ]

  const sizeClasses = {
    sm: 'h-8 px-2 text-sm',
    md: 'h-9 px-3 text-sm',
    lg: 'h-10 px-4 text-base',
  }

  return [...baseClasses, sizeClasses[props.size]].join(' ')
})

const iconSize = computed(() => {
  return props.size === 'sm' ? 'sm' : props.size === 'lg' ? 'lg' : 'md'
})

const canGoPrevious = computed(() => props.currentPage > 1 && !props.disabled)
const canGoNext = computed(() => props.currentPage < totalPages.value && !props.disabled)
</script>

<template>
  <nav role="navigation" aria-label="Pagination" class="flex items-center justify-between gap-4">
    <!-- Total count and page size selector -->
    <div v-if="showTotal || showPageSize" class="flex items-center gap-4">
      <!-- Total count -->
      <div v-if="showTotal" class="text-sm text-gray-700">
        <span v-if="totalItems > 0">
          Showing {{ startItem }} to {{ endItem }} of {{ totalItems }} results
        </span>
        <span v-else>No results</span>
      </div>

      <!-- Page size selector -->
      <div v-if="showPageSize" class="flex items-center gap-2">
        <label :for="`page-size-${$.uid}`" class="text-sm text-gray-700">Per page:</label>
        <select
          :id="`page-size-${$.uid}`"
          :value="pageSize"
          :class="selectClasses"
          :disabled="disabled"
          @change="handlePageSizeChange"
        >
          <option v-for="option in pageSizeOptions" :key="option" :value="option">
            {{ option }}
          </option>
        </select>
      </div>
    </div>

    <!-- Pagination controls -->
    <div v-if="totalPages > 0" class="flex items-center gap-1">
      <!-- First page button -->
      <button
        v-if="showFirstLast"
        type="button"
        :class="buttonClasses"
        :disabled="!canGoPrevious"
        :aria-label="'Go to first page'"
        @click="handlePageChange(1)"
      >
        <Icon name="chevrons-left" :size="iconSize" />
      </button>

      <!-- Previous page button -->
      <button
        type="button"
        :class="buttonClasses"
        :disabled="!canGoPrevious"
        :aria-label="'Go to previous page'"
        @click="handlePageChange(currentPage - 1)"
      >
        <Icon name="chevron-left" :size="iconSize" />
      </button>

      <!-- Page number buttons -->
      <button
        v-for="(page, index) in pageNumbers"
        :key="`page-${index}`"
        type="button"
        :class="page === currentPage ? activeButtonClasses : buttonClasses"
        :disabled="page === '...' || disabled"
        :aria-label="page === '...' ? undefined : `Go to page ${page}`"
        :aria-current="page === currentPage ? 'page' : undefined"
        @click="typeof page === 'number' ? handlePageChange(page) : undefined"
      >
        {{ page }}
      </button>

      <!-- Next page button -->
      <button
        type="button"
        :class="buttonClasses"
        :disabled="!canGoNext"
        :aria-label="'Go to next page'"
        @click="handlePageChange(currentPage + 1)"
      >
        <Icon name="chevron-right" :size="iconSize" />
      </button>

      <!-- Last page button -->
      <button
        v-if="showFirstLast"
        type="button"
        :class="buttonClasses"
        :disabled="!canGoNext"
        :aria-label="'Go to last page'"
        @click="handlePageChange(totalPages)"
      >
        <Icon name="chevrons-right" :size="iconSize" />
      </button>
    </div>
  </nav>
</template>
