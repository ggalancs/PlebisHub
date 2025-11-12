/**
 * Rate Limit Handler Composable
 *
 * Handles 429 (Too Many Requests) responses from the API
 * Provides retry logic and user feedback for rate-limited requests
 */

import { ref, computed } from 'vue'

interface RateLimitInfo {
  limit: number
  remaining: number
  reset: number
  retryAfter: number
}

interface UseRateLimitHandlerOptions {
  onRateLimited?: (info: RateLimitInfo) => void
  autoRetry?: boolean
  maxRetries?: number
}

export function useRateLimitHandler(options: UseRateLimitHandlerOptions = {}) {
  const isRateLimited = ref(false)
  const rateLimitInfo = ref<RateLimitInfo | null>(null)
  const retryCount = ref(0)

  const maxRetries = options.maxRetries ?? 3
  const autoRetry = options.autoRetry ?? false

  /**
   * Parse rate limit headers from response
   */
  const parseRateLimitHeaders = (headers: Headers): RateLimitInfo | null => {
    const limit = headers.get('RateLimit-Limit')
    const remaining = headers.get('RateLimit-Remaining')
    const reset = headers.get('RateLimit-Reset')

    if (!limit || !remaining || !reset) {
      return null
    }

    const resetTime = parseInt(reset, 10)
    const now = Math.floor(Date.now() / 1000)
    const retryAfter = Math.max(0, resetTime - now)

    return {
      limit: parseInt(limit, 10),
      remaining: parseInt(remaining, 10),
      reset: resetTime,
      retryAfter,
    }
  }

  /**
   * Handle a fetch response, checking for rate limiting
   */
  const handleResponse = async <T>(
    response: Response,
    originalRequest?: () => Promise<Response>
  ): Promise<T> => {
    // Check if rate limited
    if (response.status === 429) {
      const info = parseRateLimitHeaders(response.headers)

      if (info) {
        isRateLimited.value = true
        rateLimitInfo.value = info

        // Call user callback if provided
        options.onRateLimited?.(info)

        // Auto retry if enabled
        if (autoRetry && retryCount.value < maxRetries && originalRequest) {
          retryCount.value++

          // Wait for the retry-after period
          await new Promise(resolve => setTimeout(resolve, info.retryAfter * 1000))

          // Retry the request
          const retryResponse = await originalRequest()
          return handleResponse(retryResponse, originalRequest)
        }
      }

      throw new Error('Rate limit exceeded. Please try again later.')
    }

    // Reset rate limit state on successful response
    if (response.ok) {
      isRateLimited.value = false
      rateLimitInfo.value = null
      retryCount.value = 0
    }

    // Check for other errors
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    return response.json() as Promise<T>
  }

  /**
   * Wrapper for fetch that handles rate limiting
   */
  const fetchWithRateLimit = async <T>(
    url: string,
    options: RequestInit = {}
  ): Promise<T> => {
    const makeRequest = () => fetch(url, options)

    try {
      const response = await makeRequest()
      return handleResponse<T>(response, makeRequest)
    } catch (error) {
      if (error instanceof Error && error.message.includes('Rate limit exceeded')) {
        throw error
      }
      throw new Error(`Request failed: ${error}`)
    }
  }

  /**
   * Get human-readable time until retry is allowed
   */
  const getRetryMessage = computed(() => {
    if (!rateLimitInfo.value) {
      return null
    }

    const seconds = rateLimitInfo.value.retryAfter

    if (seconds < 60) {
      return `Inténtalo de nuevo en ${seconds} segundos`
    }

    const minutes = Math.ceil(seconds / 60)
    return `Inténtalo de nuevo en ${minutes} ${minutes === 1 ? 'minuto' : 'minutos'}`
  })

  /**
   * Reset rate limit state
   */
  const reset = () => {
    isRateLimited.value = false
    rateLimitInfo.value = null
    retryCount.value = 0
  }

  /**
   * Check if we can retry now
   */
  const canRetry = computed(() => {
    if (!rateLimitInfo.value) {
      return true
    }

    const now = Math.floor(Date.now() / 1000)
    return now >= rateLimitInfo.value.reset
  })

  return {
    // State
    isRateLimited,
    rateLimitInfo,
    retryCount,

    // Computed
    getRetryMessage,
    canRetry,

    // Methods
    fetchWithRateLimit,
    handleResponse,
    parseRateLimitHeaders,
    reset,
  }
}

/**
 * Global composable for tracking rate limits across the app
 */
const globalRateLimitState = ref<Record<string, RateLimitInfo>>({})

export function useGlobalRateLimit() {
  const setRateLimit = (endpoint: string, info: RateLimitInfo) => {
    globalRateLimitState.value[endpoint] = info
  }

  const getRateLimit = (endpoint: string): RateLimitInfo | undefined => {
    return globalRateLimitState.value[endpoint]
  }

  const clearRateLimit = (endpoint: string) => {
    delete globalRateLimitState.value[endpoint]
  }

  const isEndpointRateLimited = (endpoint: string): boolean => {
    const info = getRateLimit(endpoint)
    if (!info) {
      return false
    }

    const now = Math.floor(Date.now() / 1000)
    return now < info.reset
  }

  return {
    globalRateLimitState,
    setRateLimit,
    getRateLimit,
    clearRateLimit,
    isEndpointRateLimited,
  }
}
