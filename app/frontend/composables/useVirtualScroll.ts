/**
 * Virtual Scroll Composable
 *
 * Implements virtual scrolling for large lists to improve performance
 * Only renders items that are visible in the viewport
 *
 * Usage:
 * const { visibleItems, containerProps, wrapperProps } = useVirtualScroll({
 *   items: myLargeArray,
 *   itemHeight: 100,
 *   buffer: 5
 * })
 */

import { ref, computed, watch, onMounted, onUnmounted, type Ref } from 'vue'

export interface VirtualScrollOptions<T> {
  items: Ref<T[]> | T[]
  itemHeight: number | ((item: T, index: number) => number) // Fixed height or dynamic
  buffer?: number // Number of items to render outside viewport
  containerHeight?: number // Fixed container height (optional)
  overscan?: number // Additional items to render for smoother scrolling
}

export interface VirtualScrollReturn<T> {
  visibleItems: Ref<Array<{ item: T; index: number; style: Record<string, string> }>>
  totalHeight: Ref<number>
  containerProps: Record<string, any>
  wrapperProps: Record<string, any>
  scrollToIndex: (index: number) => void
  scrollToTop: () => void
  scrollToBottom: () => void
}

export function useVirtualScroll<T>(
  options: VirtualScrollOptions<T>
): VirtualScrollReturn<T> {
  const items = ref(options.items) as Ref<T[]>
  const buffer = options.buffer ?? 5
  const overscan = options.overscan ?? 2

  // Scroll state
  const containerRef = ref<HTMLElement | null>(null)
  const scrollTop = ref(0)
  const containerHeight = ref(options.containerHeight ?? 600)

  /**
   * Calculate item height
   */
  const getItemHeight = (item: T, index: number): number => {
    if (typeof options.itemHeight === 'function') {
      return options.itemHeight(item, index)
    }
    return options.itemHeight
  }

  /**
   * Calculate positions of all items
   */
  const itemPositions = computed(() => {
    const positions: Array<{ top: number; height: number }> = []
    let currentTop = 0

    items.value.forEach((item, index) => {
      const height = getItemHeight(item, index)
      positions.push({ top: currentTop, height })
      currentTop += height
    })

    return positions
  })

  /**
   * Total height of all items
   */
  const totalHeight = computed(() => {
    if (itemPositions.value.length === 0) return 0
    const lastItem = itemPositions.value[itemPositions.value.length - 1]
    return lastItem.top + lastItem.height
  })

  /**
   * Calculate visible range
   */
  const visibleRange = computed(() => {
    const scrollY = scrollTop.value
    const viewportHeight = containerHeight.value

    // Find first visible item
    let startIndex = 0
    for (let i = 0; i < itemPositions.value.length; i++) {
      const pos = itemPositions.value[i]
      if (pos.top + pos.height >= scrollY) {
        startIndex = Math.max(0, i - buffer - overscan)
        break
      }
    }

    // Find last visible item
    let endIndex = itemPositions.value.length - 1
    for (let i = startIndex; i < itemPositions.value.length; i++) {
      const pos = itemPositions.value[i]
      if (pos.top > scrollY + viewportHeight) {
        endIndex = Math.min(itemPositions.value.length - 1, i + buffer + overscan)
        break
      }
    }

    return { startIndex, endIndex }
  })

  /**
   * Visible items with positioning
   */
  const visibleItems = computed(() => {
    const { startIndex, endIndex } = visibleRange.value
    const result: Array<{ item: T; index: number; style: Record<string, string> }> = []

    for (let i = startIndex; i <= endIndex; i++) {
      if (i >= 0 && i < items.value.length) {
        const pos = itemPositions.value[i]
        result.push({
          item: items.value[i],
          index: i,
          style: {
            position: 'absolute',
            top: `${pos.top}px`,
            left: '0',
            right: '0',
            height: `${pos.height}px`,
          },
        })
      }
    }

    return result
  })

  /**
   * Handle scroll event
   */
  const handleScroll = (event: Event) => {
    const target = event.target as HTMLElement
    scrollTop.value = target.scrollTop
  }

  /**
   * Scroll to specific index
   */
  const scrollToIndex = (index: number) => {
    if (!containerRef.value) return

    const clampedIndex = Math.max(0, Math.min(index, items.value.length - 1))
    const pos = itemPositions.value[clampedIndex]

    if (pos) {
      containerRef.value.scrollTop = pos.top
    }
  }

  /**
   * Scroll to top
   */
  const scrollToTop = () => {
    if (containerRef.value) {
      containerRef.value.scrollTop = 0
    }
  }

  /**
   * Scroll to bottom
   */
  const scrollToBottom = () => {
    if (containerRef.value) {
      containerRef.value.scrollTop = totalHeight.value
    }
  }

  /**
   * Update container height on mount and resize
   */
  const updateContainerHeight = () => {
    if (containerRef.value && !options.containerHeight) {
      containerHeight.value = containerRef.value.clientHeight
    }
  }

  let resizeObserver: ResizeObserver | null = null

  onMounted(() => {
    updateContainerHeight()

    // Watch for container size changes
    if (containerRef.value && typeof ResizeObserver !== 'undefined') {
      resizeObserver = new ResizeObserver(() => {
        updateContainerHeight()
      })
      resizeObserver.observe(containerRef.value)
    }
  })

  onUnmounted(() => {
    if (resizeObserver) {
      resizeObserver.disconnect()
    }
  })

  /**
   * Props for container element
   */
  const containerProps = {
    ref: (el: any) => {
      containerRef.value = el
    },
    onScroll: handleScroll,
    style: {
      overflowY: 'auto',
      overflowX: 'hidden',
      position: 'relative',
      height: options.containerHeight ? `${options.containerHeight}px` : '100%',
    },
  }

  /**
   * Props for wrapper element (holds absolute positioned items)
   */
  const wrapperProps = computed(() => ({
    style: {
      position: 'relative',
      height: `${totalHeight.value}px`,
      width: '100%',
    },
  }))

  // Reset scroll when items change significantly
  watch(
    () => items.value.length,
    (newLength, oldLength) => {
      if (oldLength > 0 && newLength === 0) {
        scrollToTop()
      }
    }
  )

  return {
    visibleItems,
    totalHeight,
    containerProps,
    wrapperProps,
    scrollToIndex,
    scrollToTop,
    scrollToBottom,
  }
}

/**
 * Simpler hook for fixed-height items
 */
export function useFixedHeightVirtualScroll<T>(
  items: Ref<T[]> | T[],
  itemHeight: number,
  containerHeight?: number
) {
  return useVirtualScroll({
    items,
    itemHeight,
    containerHeight,
    buffer: 3,
    overscan: 2,
  })
}

/**
 * Hook for dynamic-height items with estimated heights
 */
export function useDynamicHeightVirtualScroll<T>(
  items: Ref<T[]> | T[],
  estimateHeight: (item: T, index: number) => number,
  containerHeight?: number
) {
  return useVirtualScroll({
    items,
    itemHeight: estimateHeight,
    containerHeight,
    buffer: 5,
    overscan: 3,
  })
}
