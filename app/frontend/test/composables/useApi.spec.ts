/**
 * Tests for useApi composable
 */

import { describe, it, expect, beforeEach, vi, afterEach } from 'vitest'
import { useApi, createApiClient } from '@/composables/useApi'

// Mock fetch globally
const mockFetch = vi.fn()
global.fetch = mockFetch

// Mock CSRF token
document.head.innerHTML = '<meta name="csrf-token" content="test-csrf-token">'

describe('useApi', () => {
  beforeEach(() => {
    mockFetch.mockReset()
  })

  afterEach(() => {
    vi.clearAllMocks()
  })

  describe('request method', () => {
    it('should make GET request successfully', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve({ data: 'test' }),
        headers: new Headers({ 'content-type': 'application/json' }),
      })

      const api = useApi()
      const result = await api.request('/test')

      expect(mockFetch).toHaveBeenCalledWith('/test', expect.objectContaining({
        method: 'GET',
      }))
      expect(result).toEqual({ data: 'test' })
    })

    it('should include CSRF token in headers', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve({}),
        headers: new Headers({ 'content-type': 'application/json' }),
      })

      const api = useApi()
      await api.request('/test', { method: 'POST' })

      expect(mockFetch).toHaveBeenCalledWith('/test', expect.objectContaining({
        headers: expect.objectContaining({
          'X-CSRF-Token': 'test-csrf-token',
        }),
      }))
    })

    it('should serialize JSON body for POST requests', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve({}),
        headers: new Headers({ 'content-type': 'application/json' }),
      })

      const api = useApi()
      await api.request('/test', {
        method: 'POST',
        body: { name: 'test' },
      })

      expect(mockFetch).toHaveBeenCalledWith('/test', expect.objectContaining({
        body: JSON.stringify({ name: 'test' }),
      }))
    })

    it('should track loading state', async () => {
      let resolvePromise: (value: any) => void
      const promise = new Promise((resolve) => {
        resolvePromise = resolve
      })

      mockFetch.mockReturnValueOnce(promise)

      const api = useApi()
      expect(api.loading.value).toBe(false)

      const requestPromise = api.request('/test')
      expect(api.loading.value).toBe(true)

      resolvePromise!({
        ok: true,
        json: () => Promise.resolve({}),
        headers: new Headers({ 'content-type': 'application/json' }),
      })

      await requestPromise
      expect(api.loading.value).toBe(false)
    })

    it('should set error on failed request', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 404,
        statusText: 'Not Found',
        json: () => Promise.resolve({ error: 'Resource not found' }),
        headers: new Headers({ 'content-type': 'application/json' }),
      })

      const api = useApi()

      await expect(api.request('/test')).rejects.toThrow()
      expect(api.error.value).toBeTruthy()
    })

    it('should handle network errors', async () => {
      mockFetch.mockRejectedValueOnce(new Error('Network error'))

      const api = useApi()

      await expect(api.request('/test')).rejects.toThrow('Network error')
      expect(api.error.value).toBeTruthy()
    })
  })

  describe('convenience methods', () => {
    beforeEach(() => {
      mockFetch.mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ success: true }),
        headers: new Headers({ 'content-type': 'application/json' }),
      })
    })

    it('get() should make GET request', async () => {
      const api = useApi()
      await api.get('/users')

      expect(mockFetch).toHaveBeenCalledWith('/users', expect.objectContaining({
        method: 'GET',
      }))
    })

    it('post() should make POST request', async () => {
      const api = useApi()
      await api.post('/users', { name: 'John' })

      expect(mockFetch).toHaveBeenCalledWith('/users', expect.objectContaining({
        method: 'POST',
        body: JSON.stringify({ name: 'John' }),
      }))
    })

    it('put() should make PUT request', async () => {
      const api = useApi()
      await api.put('/users/1', { name: 'Jane' })

      expect(mockFetch).toHaveBeenCalledWith('/users/1', expect.objectContaining({
        method: 'PUT',
      }))
    })

    it('patch() should make PATCH request', async () => {
      const api = useApi()
      await api.patch('/users/1', { name: 'Jane' })

      expect(mockFetch).toHaveBeenCalledWith('/users/1', expect.objectContaining({
        method: 'PATCH',
      }))
    })

    it('delete() should make DELETE request', async () => {
      const api = useApi()
      await api.delete('/users/1')

      expect(mockFetch).toHaveBeenCalledWith('/users/1', expect.objectContaining({
        method: 'DELETE',
      }))
    })
  })

  describe('createApiClient', () => {
    it('should create client with base URL', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve({}),
        headers: new Headers({ 'content-type': 'application/json' }),
      })

      const client = createApiClient({ baseUrl: '/api/v1' })
      await client.get('/users')

      expect(mockFetch).toHaveBeenCalledWith('/api/v1/users', expect.anything())
    })

    it('should include default headers', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve({}),
        headers: new Headers({ 'content-type': 'application/json' }),
      })

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
