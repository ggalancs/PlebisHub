import { ref, computed, watch, type Ref, type ComputedRef } from 'vue'

export interface PaginationOptions {
  /**
   * Current page number (1-indexed)
   * @default 1
   */
  currentPage?: number

  /**
   * Number of items per page
   * @default 10
   */
  pageSize?: number

  /**
   * Total number of items
   * @default 0
   */
  total?: number

  /**
   * Number of page buttons to show in pagination
   * @default 7
   */
  siblingCount?: number
}

export interface PaginationReturn {
  /** Current page number (1-indexed) */
  currentPage: Ref<number>

  /** Number of items per page */
  pageSize: Ref<number>

  /** Total number of items */
  total: Ref<number>

  /** Total number of pages */
  totalPages: ComputedRef<number>

  /** Whether there is a previous page */
  hasPrevPage: ComputedRef<boolean>

  /** Whether there is a next page */
  hasNextPage: ComputedRef<boolean>

  /** Whether pagination is needed (more than one page) */
  isPaginationNeeded: ComputedRef<boolean>

  /** Start index of current page (0-indexed) */
  startIndex: ComputedRef<number>

  /** End index of current page (0-indexed) */
  endIndex: ComputedRef<number>

  /** Array of page numbers to display in pagination UI */
  pageRange: ComputedRef<(number | string)[]>

  /** Go to specific page */
  goToPage: (page: number) => void

  /** Go to next page */
  nextPage: () => void

  /** Go to previous page */
  prevPage: () => void

  /** Go to first page */
  firstPage: () => void

  /** Go to last page */
  lastPage: () => void

  /** Change page size (resets to page 1) */
  changePageSize: (newSize: number) => void

  /** Get paginated slice of an array */
  paginateArray: <T>(array: T[]) => T[]
}

/**
 * usePagination Composable
 *
 * Provides complete pagination logic and utilities
 *
 * @param options - Pagination configuration options
 * @returns Pagination state and methods
 *
 * @example
 * ```ts
 * // Basic usage
 * const items = ref([...]) // 100 items
 * const pagination = usePagination({
 *   total: items.value.length,
 *   pageSize: 10,
 *   currentPage: 1
 * })
 *
 * const paginatedItems = computed(() => {
 *   return pagination.paginateArray(items.value)
 * })
 *
 * // In template:
 * // <div v-for="item in paginatedItems" :key="item.id">{{ item }}</div>
 * // <button @click="pagination.prevPage()" :disabled="!pagination.hasPrevPage">Prev</button>
 * // <button @click="pagination.nextPage()" :disabled="!pagination.hasNextPage">Next</button>
 * ```
 *
 * @example
 * ```ts
 * // With API calls
 * const { data, total } = await fetchItems(pagination.currentPage.value, pagination.pageSize.value)
 *
 * watch([() => pagination.currentPage.value, () => pagination.pageSize.value], async () => {
 *   const result = await fetchItems(pagination.currentPage.value, pagination.pageSize.value)
 *   data.value = result.data
 *   pagination.total.value = result.total
 * })
 * ```
 */
export function usePagination(options: PaginationOptions = {}): PaginationReturn {
  const currentPage = ref(options.currentPage ?? 1)
  const pageSize = ref(options.pageSize ?? 10)
  const total = ref(options.total ?? 0)
  const siblingCount = options.siblingCount ?? 1

  // Computed: Total number of pages
  const totalPages = computed(() => {
    if (total.value === 0 || pageSize.value === 0) return 1
    return Math.ceil(total.value / pageSize.value)
  })

  // Computed: Whether there is a previous page
  const hasPrevPage = computed(() => {
    return currentPage.value > 1
  })

  // Computed: Whether there is a next page
  const hasNextPage = computed(() => {
    return currentPage.value < totalPages.value
  })

  // Computed: Whether pagination is needed
  const isPaginationNeeded = computed(() => {
    return totalPages.value > 1
  })

  // Computed: Start index for current page (0-indexed)
  const startIndex = computed(() => {
    return (currentPage.value - 1) * pageSize.value
  })

  // Computed: End index for current page (0-indexed)
  const endIndex = computed(() => {
    return Math.min(startIndex.value + pageSize.value, total.value)
  })

  // Computed: Page numbers to display
  const pageRange = computed<(number | string)[]>(() => {
    const pages: (number | string)[] = []
    const totalPagesValue = totalPages.value

    if (totalPagesValue <= 1) {
      return [1]
    }

    // Always show first page
    pages.push(1)

    // Calculate range around current page
    const leftSiblingIndex = Math.max(currentPage.value - siblingCount, 2)
    const rightSiblingIndex = Math.min(currentPage.value + siblingCount, totalPagesValue - 1)

    const shouldShowLeftDots = leftSiblingIndex > 2
    const shouldShowRightDots = rightSiblingIndex < totalPagesValue - 1

    // Case 1: No dots needed
    if (!shouldShowLeftDots && !shouldShowRightDots) {
      for (let i = 2; i < totalPagesValue; i++) {
        pages.push(i)
      }
    }
    // Case 2: Only right dots
    else if (!shouldShowLeftDots && shouldShowRightDots) {
      for (let i = 2; i <= rightSiblingIndex; i++) {
        pages.push(i)
      }
      pages.push('...')
    }
    // Case 3: Only left dots
    else if (shouldShowLeftDots && !shouldShowRightDots) {
      pages.push('...')
      for (let i = leftSiblingIndex; i < totalPagesValue; i++) {
        pages.push(i)
      }
    }
    // Case 4: Both dots
    else {
      pages.push('...')
      for (let i = leftSiblingIndex; i <= rightSiblingIndex; i++) {
        pages.push(i)
      }
      pages.push('...')
    }

    // Always show last page (if more than one page)
    if (totalPagesValue > 1) {
      pages.push(totalPagesValue)
    }

    return pages
  })

  // Methods
  const goToPage = (page: number) => {
    const pageNumber = Math.max(1, Math.min(page, totalPages.value))
    if (pageNumber !== currentPage.value) {
      currentPage.value = pageNumber
    }
  }

  const nextPage = () => {
    if (hasNextPage.value) {
      currentPage.value++
    }
  }

  const prevPage = () => {
    if (hasPrevPage.value) {
      currentPage.value--
    }
  }

  const firstPage = () => {
    currentPage.value = 1
  }

  const lastPage = () => {
    currentPage.value = totalPages.value
  }

  const changePageSize = (newSize: number) => {
    pageSize.value = Math.max(1, newSize)
    // Reset to page 1 when changing page size
    currentPage.value = 1
  }

  const paginateArray = <T>(array: T[]): T[] => {
    const start = startIndex.value
    const end = endIndex.value
    return array.slice(start, end)
  }

  // Watch for changes that might invalidate current page
  watch([totalPages], () => {
    if (currentPage.value > totalPages.value) {
      currentPage.value = totalPages.value
    }
  })

  return {
    currentPage,
    pageSize,
    total,
    totalPages,
    hasPrevPage,
    hasNextPage,
    isPaginationNeeded,
    startIndex,
    endIndex,
    pageRange,
    goToPage,
    nextPage,
    prevPage,
    firstPage,
    lastPage,
    changePageSize,
    paginateArray,
  }
}
