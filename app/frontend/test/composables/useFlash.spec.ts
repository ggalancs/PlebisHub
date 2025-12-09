/**
 * Tests for useFlash composable
 */

import { describe, it, expect, beforeEach, vi, afterEach } from 'vitest'
import { useFlash, addFlash, removeFlash, clearFlashes, flashMessages } from '@/composables/useFlash'

describe('useFlash', () => {
  beforeEach(() => {
    // Clear all messages before each test
    clearFlashes()
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  describe('add', () => {
    it('should add a flash message', () => {
      const flash = useFlash()
      flash.add('success', 'Test message')

      expect(flash.messages.value).toHaveLength(1)
      expect(flash.messages.value[0].type).toBe('success')
      expect(flash.messages.value[0].message).toBe('Test message')
    })

    it('should generate unique ids for messages', () => {
      const flash = useFlash()
      flash.add('success', 'Message 1')
      flash.add('error', 'Message 2')

      expect(flash.messages.value[0].id).not.toBe(flash.messages.value[1].id)
    })

    it('should support optional title', () => {
      const flash = useFlash()
      flash.add('info', 'Message', { title: 'Custom Title' })

      expect(flash.messages.value[0].title).toBe('Custom Title')
    })

    it('should auto-remove messages after duration', () => {
      const flash = useFlash()
      flash.add('success', 'Auto remove me', { duration: 3000 })

      expect(flash.messages.value).toHaveLength(1)

      vi.advanceTimersByTime(3000)

      expect(flash.messages.value).toHaveLength(0)
    })

    it('should not auto-remove when duration is 0', () => {
      const flash = useFlash()
      flash.add('success', 'Stay forever', { duration: 0 })

      vi.advanceTimersByTime(10000)

      expect(flash.messages.value).toHaveLength(1)
    })
  })

  describe('remove', () => {
    it('should remove a specific message by id', () => {
      const flash = useFlash()
      flash.add('success', 'Message 1')
      flash.add('error', 'Message 2')

      const idToRemove = flash.messages.value[0].id

      flash.remove(idToRemove)

      expect(flash.messages.value).toHaveLength(1)
      expect(flash.messages.value[0].message).toBe('Message 2')
    })

    it('should do nothing if id does not exist', () => {
      const flash = useFlash()
      flash.add('success', 'Message 1')

      flash.remove(999999) // non-existent ID

      expect(flash.messages.value).toHaveLength(1)
    })
  })

  describe('clear', () => {
    it('should remove all messages', () => {
      const flash = useFlash()
      flash.add('success', 'Message 1')
      flash.add('error', 'Message 2')
      flash.add('warning', 'Message 3')

      flash.clear()

      expect(flash.messages.value).toHaveLength(0)
    })
  })

  describe('convenience methods', () => {
    it('should add success message', () => {
      const flash = useFlash()
      flash.success('Success!')

      expect(flash.messages.value[0].type).toBe('success')
    })

    it('should add error message', () => {
      const flash = useFlash()
      flash.error('Error!')

      expect(flash.messages.value[0].type).toBe('error')
    })

    it('should add warning message', () => {
      const flash = useFlash()
      flash.warning('Warning!')

      expect(flash.messages.value[0].type).toBe('warning')
    })

    it('should add info message', () => {
      const flash = useFlash()
      flash.info('Info!')

      expect(flash.messages.value[0].type).toBe('info')
    })
  })

  describe('global functions', () => {
    it('addFlash should add messages globally', () => {
      addFlash('success', 'Global message')

      expect(flashMessages.value).toHaveLength(1)
      expect(flashMessages.value[0].message).toBe('Global message')
    })

    it('removeFlash should remove messages globally', () => {
      addFlash('success', 'To remove')
      const id = flashMessages.value[0].id

      removeFlash(id)

      expect(flashMessages.value).toHaveLength(0)
    })

    it('clearFlashes should clear all globally', () => {
      addFlash('success', 'Message 1')
      addFlash('error', 'Message 2')

      clearFlashes()

      expect(flashMessages.value).toHaveLength(0)
    })
  })

  describe('shared state', () => {
    it('should share state between multiple useFlash instances', () => {
      const flash1 = useFlash()
      const flash2 = useFlash()

      flash1.add('success', 'From flash1')

      expect(flash2.messages.value).toHaveLength(1)
      expect(flash2.messages.value[0].message).toBe('From flash1')
    })
  })
})
