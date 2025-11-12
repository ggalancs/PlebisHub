import { ref, watch, type Ref } from 'vue'

/**
 * useDebounce Composable
 *
 * Debounces a reactive value, useful for search inputs, API calls, etc.
 *
 * @param value - The reactive value to debounce
 * @param delay - Delay in milliseconds (default: 300ms)
 * @returns A ref containing the debounced value
 *
 * @example
 * ```ts
 * const searchQuery = ref('')
 * const debouncedQuery = useDebounce(searchQuery, 500)
 *
 * watch(debouncedQuery, (newValue) => {
 *   // This will only trigger 500ms after user stops typing
 *   fetchSearchResults(newValue)
 * })
 * ```
 */
export function useDebounce<T>(value: Ref<T>, delay = 300): Ref<T> {
  const debouncedValue = ref<T>(value.value) as Ref<T>
  let timeoutId: ReturnType<typeof setTimeout> | null = null

  watch(
    value,
    (newValue) => {
      if (timeoutId !== null) {
        clearTimeout(timeoutId)
      }

      timeoutId = setTimeout(() => {
        debouncedValue.value = newValue
        timeoutId = null
      }, delay)
    },
    { immediate: false }
  )

  return debouncedValue
}

/**
 * useDebouncedFn Composable
 *
 * Returns a debounced version of a function
 *
 * @param fn - The function to debounce
 * @param delay - Delay in milliseconds (default: 300ms)
 * @returns A debounced version of the function
 *
 * @example
 * ```ts
 * const expensiveOperation = (query: string) => {
 *   console.log('Searching for:', query)
 *   // ... API call
 * }
 *
 * const debouncedSearch = useDebouncedFn(expensiveOperation, 500)
 *
 * // Call it multiple times rapidly
 * debouncedSearch('hello')  // Won't execute
 * debouncedSearch('hello w') // Won't execute
 * debouncedSearch('hello world') // Will execute after 500ms
 * ```
 */
export function useDebouncedFn<T extends (...args: any[]) => any>(
  fn: T,
  delay = 300
): (...args: Parameters<T>) => void {
  let timeoutId: ReturnType<typeof setTimeout> | null = null

  return (...args: Parameters<T>) => {
    if (timeoutId !== null) {
      clearTimeout(timeoutId)
    }

    timeoutId = setTimeout(() => {
      fn(...args)
      timeoutId = null
    }, delay)
  }
}

/**
 * useDebouncedFnWithCancel Composable
 *
 * Returns a debounced function with cancel capability
 *
 * @param fn - The function to debounce
 * @param delay - Delay in milliseconds (default: 300ms)
 * @returns Object with debounced function and cancel method
 *
 * @example
 * ```ts
 * const { debouncedFn, cancel } = useDebouncedFnWithCancel(
 *   (query: string) => console.log(query),
 *   500
 * )
 *
 * debouncedFn('hello')
 * cancel() // Cancels the pending execution
 * ```
 */
export function useDebouncedFnWithCancel<T extends (...args: any[]) => any>(
  fn: T,
  delay = 300
): {
  debouncedFn: (...args: Parameters<T>) => void
  cancel: () => void
  flush: () => void
} {
  let timeoutId: ReturnType<typeof setTimeout> | null = null
  let pendingArgs: Parameters<T> | null = null

  const cancel = () => {
    if (timeoutId !== null) {
      clearTimeout(timeoutId)
      timeoutId = null
      pendingArgs = null
    }
  }

  const flush = () => {
    if (timeoutId !== null && pendingArgs !== null) {
      clearTimeout(timeoutId)
      fn(...pendingArgs)
      timeoutId = null
      pendingArgs = null
    }
  }

  const debouncedFn = (...args: Parameters<T>) => {
    cancel()
    pendingArgs = args

    timeoutId = setTimeout(() => {
      fn(...args)
      timeoutId = null
      pendingArgs = null
    }, delay)
  }

  return { debouncedFn, cancel, flush }
}
