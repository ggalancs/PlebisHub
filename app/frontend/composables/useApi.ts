/**
 * API Composable
 * Replaces jQuery AJAX with modern fetch-based API calls
 */

import { ref, type Ref } from 'vue'

export interface ApiOptions {
  /** Base URL for all requests */
  baseUrl?: string
  /** Default headers */
  headers?: Record<string, string>
  /** Include credentials */
  withCredentials?: boolean
  /** Request timeout in ms */
  timeout?: number
  /** Retry failed requests */
  retry?: number
  /** Retry delay in ms */
  retryDelay?: number
}

export interface RequestOptions {
  /** Request headers */
  headers?: Record<string, string>
  /** Query parameters */
  params?: Record<string, string | number | boolean>
  /** Request body (for POST, PUT, PATCH) */
  body?: unknown
  /** Request timeout in ms */
  timeout?: number
  /** Abort signal */
  signal?: AbortSignal
}

export interface ApiResponse<T = unknown> {
  data: T | null
  error: string | null
  status: number
  ok: boolean
}

// Get CSRF token from meta tag
function getCsrfToken(): string {
  const meta = document.querySelector<HTMLMetaElement>('meta[name="csrf-token"]')
  return meta?.content || ''
}

// Build URL with query params
function buildUrl(url: string, params?: Record<string, string | number | boolean>): string {
  if (!params) return url

  const searchParams = new URLSearchParams()
  Object.entries(params).forEach(([key, value]) => {
    if (value !== undefined && value !== null) {
      searchParams.append(key, String(value))
    }
  })

  const queryString = searchParams.toString()
  if (!queryString) return url

  return url.includes('?') ? `${url}&${queryString}` : `${url}?${queryString}`
}

// Default options
const defaultOptions: ApiOptions = {
  baseUrl: '',
  headers: {},
  withCredentials: true,
  timeout: 30000,
  retry: 0,
  retryDelay: 1000,
}

/**
 * Create an API client with default options
 */
export function createApiClient(options: ApiOptions = {}) {
  const config = { ...defaultOptions, ...options }

  async function request<T = unknown>(
    method: string,
    url: string,
    requestOptions: RequestOptions = {}
  ): Promise<ApiResponse<T>> {
    const fullUrl = buildUrl(`${config.baseUrl}${url}`, requestOptions.params)

    const headers: Record<string, string> = {
      Accept: 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': getCsrfToken(),
      ...config.headers,
      ...requestOptions.headers,
    }

    // Add Content-Type for requests with body
    if (requestOptions.body && !(requestOptions.body instanceof FormData)) {
      headers['Content-Type'] = 'application/json'
    }

    const fetchOptions: RequestInit = {
      method,
      headers,
      credentials: config.withCredentials ? 'include' : 'same-origin',
      signal: requestOptions.signal,
    }

    if (requestOptions.body) {
      fetchOptions.body =
        requestOptions.body instanceof FormData
          ? requestOptions.body
          : JSON.stringify(requestOptions.body)
    }

    // Create timeout controller
    const timeout = requestOptions.timeout ?? config.timeout
    const timeoutController = new AbortController()
    const timeoutId = timeout
      ? setTimeout(() => timeoutController.abort(), timeout)
      : null

    // Combine signals
    if (!requestOptions.signal) {
      fetchOptions.signal = timeoutController.signal
    }

    let lastError: string | null = null
    const maxRetries = config.retry ?? 0

    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        const response = await fetch(fullUrl, fetchOptions)

        if (timeoutId) clearTimeout(timeoutId)

        let data: T | null = null
        const contentType = response.headers.get('Content-Type')

        if (contentType?.includes('application/json')) {
          try {
            data = await response.json()
          } catch {
            // Empty or invalid JSON response
          }
        }

        if (!response.ok) {
          // Extract error message from response
          let errorMessage = `Error ${response.status}: ${response.statusText}`
          if (data && typeof data === 'object') {
            const errorData = data as Record<string, unknown>
            errorMessage =
              (errorData.error as string) ||
              (errorData.message as string) ||
              (errorData.errors as string) ||
              errorMessage
          }

          // Handle specific status codes
          if (response.status === 401) {
            // Emit unauthorized event
            document.dispatchEvent(new CustomEvent('api:unauthorized'))
          }
          if (response.status === 422) {
            // Validation errors
            return {
              data: data,
              error: errorMessage,
              status: response.status,
              ok: false,
            }
          }
          if (response.status >= 500 && attempt < maxRetries) {
            // Retry on server errors
            lastError = errorMessage
            await new Promise((resolve) => setTimeout(resolve, config.retryDelay))
            continue
          }

          return {
            data: null,
            error: errorMessage,
            status: response.status,
            ok: false,
          }
        }

        return {
          data,
          error: null,
          status: response.status,
          ok: true,
        }
      } catch (error) {
        if (timeoutId) clearTimeout(timeoutId)

        if (error instanceof DOMException && error.name === 'AbortError') {
          lastError = 'La solicitud ha expirado'
        } else {
          lastError = error instanceof Error ? error.message : 'Error de red'
        }

        if (attempt < maxRetries) {
          await new Promise((resolve) => setTimeout(resolve, config.retryDelay))
          continue
        }

        return {
          data: null,
          error: lastError,
          status: 0,
          ok: false,
        }
      }
    }

    return {
      data: null,
      error: lastError || 'Error desconocido',
      status: 0,
      ok: false,
    }
  }

  return {
    get: <T = unknown>(url: string, options?: RequestOptions) =>
      request<T>('GET', url, options),

    post: <T = unknown>(url: string, body?: unknown, options?: RequestOptions) =>
      request<T>('POST', url, { ...options, body }),

    put: <T = unknown>(url: string, body?: unknown, options?: RequestOptions) =>
      request<T>('PUT', url, { ...options, body }),

    patch: <T = unknown>(url: string, body?: unknown, options?: RequestOptions) =>
      request<T>('PATCH', url, { ...options, body }),

    delete: <T = unknown>(url: string, options?: RequestOptions) =>
      request<T>('DELETE', url, options),

    request,
  }
}

// Default API client
const defaultClient = createApiClient()

/**
 * API Composable for use in Vue components
 */
export function useApi<T = unknown>(initialUrl?: string) {
  const data: Ref<T | null> = ref(null)
  const error: Ref<string | null> = ref(null)
  const isLoading = ref(false)
  const status = ref(0)

  async function execute(
    url: string,
    options?: RequestOptions & { method?: string }
  ): Promise<ApiResponse<T>> {
    isLoading.value = true
    error.value = null

    try {
      const method = options?.method ?? 'GET'
      const response = await defaultClient.request<T>(method, url, options)

      data.value = response.data
      error.value = response.error
      status.value = response.status

      return response
    } finally {
      isLoading.value = false
    }
  }

  async function get(url?: string, options?: RequestOptions) {
    return execute(url || initialUrl || '', { ...options, method: 'GET' })
  }

  async function post(url?: string, body?: unknown, options?: RequestOptions) {
    return execute(url || initialUrl || '', { ...options, method: 'POST', body })
  }

  async function put(url?: string, body?: unknown, options?: RequestOptions) {
    return execute(url || initialUrl || '', { ...options, method: 'PUT', body })
  }

  async function patch(url?: string, body?: unknown, options?: RequestOptions) {
    return execute(url || initialUrl || '', { ...options, method: 'PATCH', body })
  }

  async function del(url?: string, options?: RequestOptions) {
    return execute(url || initialUrl || '', { ...options, method: 'DELETE' })
  }

  return {
    data,
    error,
    isLoading,
    status,
    execute,
    get,
    post,
    put,
    patch,
    delete: del,
  }
}

// Export default client methods for direct use
export const api = defaultClient
