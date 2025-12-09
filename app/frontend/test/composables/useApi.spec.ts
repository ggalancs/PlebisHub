/**
 * Tests for useApi composable
 */

import { describe, it, expect, beforeEach, vi, afterEach } from 'vitest'
import { createApiClient } from '@/composables/useApi'

// Mock fetch globally
const mockFetch = vi.fn()
;(globalThis as typeof globalThis & { fetch: typeof mockFetch }).fetch = mockFetch

// Mock CSRF token
document.head.innerHTML = '<meta name="csrf-token" content="test-csrf-token">'

// Helper to create a mock response
function createMockResponse(options: {
  ok?: boolean
  status?: number
  statusText?: string
  data?: unknown
  contentType?: string
}) {
  const {
    ok = true,
    status = 200,
    statusText = 'OK',
    data = {},
    contentType = 'application/json',
  } = options

  return {
    ok,
    status,
    statusText,
    headers: {
      get: (name: string) => (name === 'Content-Type' ? contentType : null),
    },
    json: () => Promise.resolve(data),
  }
}

describe('createApiClient', () => {
  beforeEach(() => {
    mockFetch.mockReset()
  })

  afterEach(() => {
    vi.clearAllMocks()
  })

  describe('GET requests', () => {
    it('should make GET request successfully', async () => {
      mockFetch.mockResolvedValueOnce(
        createMockResponse({ data: { data: 'test' } })
      )

      const client = createApiClient()
      const result = await client.get('/test')

      expect(mockFetch).toHaveBeenCalledWith('/test', expect.objectContaining({
        method: 'GET',
      }))
      expect(result.ok).toBe(true)
      expect(result.data).toEqual({ data: 'test' })
    })

    it('should include CSRF token in headers', async () => {
      mockFetch.mockResolvedValueOnce(createMockResponse({}))

      const client = createApiClient()
      await client.get('/test')

      expect(mockFetch).toHaveBeenCalledWith('/test', expect.objectContaining({
        headers: expect.objectContaining({
          'X-CSRF-Token': 'test-csrf-token',
        }),
      }))
    })

    it('should include query params in URL', async () => {
      mockFetch.mockResolvedValueOnce(createMockResponse({}))

      const client = createApiClient()
      await client.get('/test', { params: { page: 1, search: 'hello' } })

      expect(mockFetch).toHaveBeenCalledWith(
        expect.stringContaining('/test?'),
        expect.anything()
      )
    })
  })

  describe('POST requests', () => {
    it('should make POST request with JSON body', async () => {
      mockFetch.mockResolvedValueOnce(
        createMockResponse({ status: 201, data: { id: 1 } })
      )

      const client = createApiClient()
      const result = await client.post('/users', { name: 'John' })

      expect(mockFetch).toHaveBeenCalledWith('/users', expect.objectContaining({
        method: 'POST',
        body: JSON.stringify({ name: 'John' }),
        headers: expect.objectContaining({
          'Content-Type': 'application/json',
        }),
      }))
      expect(result.ok).toBe(true)
      expect(result.data).toEqual({ id: 1 })
    })
  })

  describe('PUT requests', () => {
    it('should make PUT request', async () => {
      mockFetch.mockResolvedValueOnce(
        createMockResponse({ data: { success: true } })
      )

      const client = createApiClient()
      await client.put('/users/1', { name: 'Jane' })

      expect(mockFetch).toHaveBeenCalledWith('/users/1', expect.objectContaining({
        method: 'PUT',
      }))
    })
  })

  describe('PATCH requests', () => {
    it('should make PATCH request', async () => {
      mockFetch.mockResolvedValueOnce(
        createMockResponse({ data: { success: true } })
      )

      const client = createApiClient()
      await client.patch('/users/1', { name: 'Jane' })

      expect(mockFetch).toHaveBeenCalledWith('/users/1', expect.objectContaining({
        method: 'PATCH',
      }))
    })
  })

  describe('DELETE requests', () => {
    it('should make DELETE request', async () => {
      mockFetch.mockResolvedValueOnce(
        createMockResponse({ status: 204, data: null })
      )

      const client = createApiClient()
      await client.delete('/users/1')

      expect(mockFetch).toHaveBeenCalledWith('/users/1', expect.objectContaining({
        method: 'DELETE',
      }))
    })
  })

  describe('error handling', () => {
    it('should return error on failed request', async () => {
      mockFetch.mockResolvedValueOnce(
        createMockResponse({
          ok: false,
          status: 404,
          statusText: 'Not Found',
          data: { error: 'Resource not found' },
        })
      )

      const client = createApiClient()
      const result = await client.get('/not-found')

      expect(result.ok).toBe(false)
      expect(result.error).toBeTruthy()
      expect(result.status).toBe(404)
    })

    it('should handle network errors', async () => {
      mockFetch.mockRejectedValueOnce(new Error('Network error'))

      const client = createApiClient()
      const result = await client.get('/test')

      expect(result.ok).toBe(false)
      expect(result.error).toBeTruthy()
    })
  })

  describe('base URL', () => {
    it('should prepend base URL to requests', async () => {
      mockFetch.mockResolvedValueOnce(createMockResponse({}))

      const client = createApiClient({ baseUrl: '/api/v1' })
      await client.get('/users')

      expect(mockFetch).toHaveBeenCalledWith('/api/v1/users', expect.anything())
    })
  })

  describe('custom headers', () => {
    it('should include custom headers', async () => {
      mockFetch.mockResolvedValueOnce(createMockResponse({}))

      const client = createApiClient({
        headers: { 'X-Custom-Header': 'custom-value' },
      })
      await client.get('/test')

      expect(mockFetch).toHaveBeenCalledWith('/test', expect.objectContaining({
        headers: expect.objectContaining({
          'X-Custom-Header': 'custom-value',
        }),
      }))
    })
  })
})
