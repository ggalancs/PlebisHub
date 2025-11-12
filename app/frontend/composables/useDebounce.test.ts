import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { ref, nextTick } from 'vue'
import { useDebounce, useDebouncedFn, useDebouncedFnWithCancel } from './useDebounce'

describe('useDebounce', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.restoreAllMocks()
  })

  describe('useDebounce (value debouncing)', () => {
    it('should initialize with the initial value', () => {
      const value = ref('initial')
      const debounced = useDebounce(value, 300)

      expect(debounced.value).toBe('initial')
    })

    it('should debounce value changes', async () => {
      const value = ref('initial')
      const debounced = useDebounce(value, 300)

      value.value = 'updated'
      await nextTick()

      // Should not update immediately
      expect(debounced.value).toBe('initial')

      // Fast-forward time by 300ms
      vi.advanceTimersByTime(300)
      await nextTick()

      // Should update after delay
      expect(debounced.value).toBe('updated')
    })

    it('should reset timer on rapid changes', async () => {
      const value = ref('initial')
      const debounced = useDebounce(value, 300)

      // Rapid changes
      value.value = 'change1'
      await nextTick()
      vi.advanceTimersByTime(100)

      value.value = 'change2'
      await nextTick()
      vi.advanceTimersByTime(100)

      value.value = 'change3'
      await nextTick()

      // Should still be initial after 200ms total
      expect(debounced.value).toBe('initial')

      // Wait for full delay
      vi.advanceTimersByTime(300)
      await nextTick()

      // Should only update to the last value
      expect(debounced.value).toBe('change3')
    })

    it('should work with different data types', async () => {
      const numberValue = ref(0)
      const debouncedNumber = useDebounce(numberValue, 200)

      numberValue.value = 42
      await nextTick()
      vi.advanceTimersByTime(200)
      await nextTick()

      expect(debouncedNumber.value).toBe(42)
    })

    it('should work with custom delay', async () => {
      const value = ref('initial')
      const debounced = useDebounce(value, 500)

      value.value = 'updated'
      await nextTick()

      // Should not update after 300ms
      vi.advanceTimersByTime(300)
      await nextTick()
      expect(debounced.value).toBe('initial')

      // Should update after 500ms total
      vi.advanceTimersByTime(200)
      await nextTick()
      expect(debounced.value).toBe('updated')
    })

    it('should use default delay of 300ms when not specified', async () => {
      const value = ref('initial')
      const debounced = useDebounce(value)

      value.value = 'updated'
      await nextTick()

      vi.advanceTimersByTime(299)
      await nextTick()
      expect(debounced.value).toBe('initial')

      vi.advanceTimersByTime(1)
      await nextTick()
      expect(debounced.value).toBe('updated')
    })

    it('should handle multiple watchers on same debounced value', async () => {
      const value = ref('initial')
      const debounced = useDebounce(value, 200)

      let callCount = 0
      const mockCallback = vi.fn(() => callCount++)

      // Watch the debounced value
      const { watch } = await import('vue')
      watch(debounced, mockCallback)

      value.value = 'updated'
      await nextTick()
      vi.advanceTimersByTime(200)
      await nextTick()

      expect(mockCallback).toHaveBeenCalledTimes(1)
      expect(debounced.value).toBe('updated')
    })
  })

  describe('useDebouncedFn (function debouncing)', () => {
    it('should debounce function calls', () => {
      const mockFn = vi.fn()
      const debouncedFn = useDebouncedFn(mockFn, 300)

      debouncedFn('arg1')
      expect(mockFn).not.toHaveBeenCalled()

      vi.advanceTimersByTime(300)
      expect(mockFn).toHaveBeenCalledWith('arg1')
      expect(mockFn).toHaveBeenCalledTimes(1)
    })

    it('should cancel previous calls on rapid invocations', () => {
      const mockFn = vi.fn()
      const debouncedFn = useDebouncedFn(mockFn, 300)

      debouncedFn('call1')
      vi.advanceTimersByTime(100)

      debouncedFn('call2')
      vi.advanceTimersByTime(100)

      debouncedFn('call3')
      vi.advanceTimersByTime(300)

      // Should only call with last arguments
      expect(mockFn).toHaveBeenCalledTimes(1)
      expect(mockFn).toHaveBeenCalledWith('call3')
    })

    it('should work with multiple arguments', () => {
      const mockFn = vi.fn()
      const debouncedFn = useDebouncedFn(mockFn, 200)

      debouncedFn('arg1', 'arg2', 'arg3')
      vi.advanceTimersByTime(200)

      expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2', 'arg3')
    })

    it('should use default delay of 300ms', () => {
      const mockFn = vi.fn()
      const debouncedFn = useDebouncedFn(mockFn)

      debouncedFn('test')

      vi.advanceTimersByTime(299)
      expect(mockFn).not.toHaveBeenCalled()

      vi.advanceTimersByTime(1)
      expect(mockFn).toHaveBeenCalled()
    })

    it('should handle function with return value', () => {
      const mockFn = vi.fn((x: number) => x * 2)
      const debouncedFn = useDebouncedFn(mockFn, 200)

      // Note: debounced function returns void, not the original return value
      debouncedFn(5)
      vi.advanceTimersByTime(200)

      expect(mockFn).toHaveBeenCalledWith(5)
    })
  })

  describe('useDebouncedFnWithCancel', () => {
    it('should debounce function calls', () => {
      const mockFn = vi.fn()
      const { debouncedFn } = useDebouncedFnWithCancel(mockFn, 300)

      debouncedFn('arg1')
      expect(mockFn).not.toHaveBeenCalled()

      vi.advanceTimersByTime(300)
      expect(mockFn).toHaveBeenCalledWith('arg1')
    })

    it('should cancel pending execution', () => {
      const mockFn = vi.fn()
      const { debouncedFn, cancel } = useDebouncedFnWithCancel(mockFn, 300)

      debouncedFn('arg1')
      vi.advanceTimersByTime(100)

      cancel()

      vi.advanceTimersByTime(300)
      expect(mockFn).not.toHaveBeenCalled()
    })

    it('should flush pending execution immediately', () => {
      const mockFn = vi.fn()
      const { debouncedFn, flush } = useDebouncedFnWithCancel(mockFn, 300)

      debouncedFn('arg1')
      vi.advanceTimersByTime(100)

      flush()

      // Should have been called immediately
      expect(mockFn).toHaveBeenCalledWith('arg1')
      expect(mockFn).toHaveBeenCalledTimes(1)

      // Should not call again after delay
      vi.advanceTimersByTime(300)
      expect(mockFn).toHaveBeenCalledTimes(1)
    })

    it('should handle cancel when no pending execution', () => {
      const mockFn = vi.fn()
      const { cancel } = useDebouncedFnWithCancel(mockFn, 300)

      // Should not throw
      expect(() => cancel()).not.toThrow()
      expect(mockFn).not.toHaveBeenCalled()
    })

    it('should handle flush when no pending execution', () => {
      const mockFn = vi.fn()
      const { flush } = useDebouncedFnWithCancel(mockFn, 300)

      // Should not throw or call function
      expect(() => flush()).not.toThrow()
      expect(mockFn).not.toHaveBeenCalled()
    })

    it('should handle multiple cancel calls', () => {
      const mockFn = vi.fn()
      const { debouncedFn, cancel } = useDebouncedFnWithCancel(mockFn, 300)

      debouncedFn('arg1')
      cancel()
      cancel()
      cancel()

      vi.advanceTimersByTime(300)
      expect(mockFn).not.toHaveBeenCalled()
    })

    it('should allow new calls after cancel', () => {
      const mockFn = vi.fn()
      const { debouncedFn, cancel } = useDebouncedFnWithCancel(mockFn, 300)

      debouncedFn('arg1')
      cancel()

      debouncedFn('arg2')
      vi.advanceTimersByTime(300)

      expect(mockFn).toHaveBeenCalledWith('arg2')
      expect(mockFn).toHaveBeenCalledTimes(1)
    })

    it('should reset timer on rapid calls', () => {
      const mockFn = vi.fn()
      const { debouncedFn } = useDebouncedFnWithCancel(mockFn, 300)

      debouncedFn('call1')
      vi.advanceTimersByTime(100)

      debouncedFn('call2')
      vi.advanceTimersByTime(100)

      debouncedFn('call3')
      vi.advanceTimersByTime(300)

      expect(mockFn).toHaveBeenCalledTimes(1)
      expect(mockFn).toHaveBeenCalledWith('call3')
    })
  })

  describe('Real-world scenarios', () => {
    it('should work for search input debouncing', async () => {
      const searchQuery = ref('')
      const debouncedQuery = useDebounce(searchQuery, 300)
      const searchResults = ref<string[]>([])

      // Simulate API call
      const { watch } = await import('vue')
      watch(debouncedQuery, (query) => {
        searchResults.value = [`Result for: ${query}`]
      })

      // User types rapidly
      searchQuery.value = 'h'
      await nextTick()
      searchQuery.value = 'he'
      await nextTick()
      searchQuery.value = 'hel'
      await nextTick()
      searchQuery.value = 'hell'
      await nextTick()
      searchQuery.value = 'hello'
      await nextTick()

      // Results should not update yet
      expect(searchResults.value).toEqual([])

      // After delay, should update with final value
      vi.advanceTimersByTime(300)
      await nextTick()

      expect(searchResults.value).toEqual(['Result for: hello'])
    })

    it('should work for window resize handler', () => {
      const handleResize = vi.fn()
      const { debouncedFn } = useDebouncedFnWithCancel(handleResize, 200)

      // Simulate rapid resize events
      for (let i = 0; i < 10; i++) {
        debouncedFn()
        vi.advanceTimersByTime(50)
      }

      // Should not have been called yet
      expect(handleResize).not.toHaveBeenCalled()

      // Wait for delay
      vi.advanceTimersByTime(200)

      // Should have been called only once
      expect(handleResize).toHaveBeenCalledTimes(1)
    })
  })
})
