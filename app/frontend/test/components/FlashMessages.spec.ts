/**
 * Tests for FlashMessages Vue component
 */

import { describe, it, expect, beforeEach, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import FlashMessages from '@/components/molecules/FlashMessages.vue'
import { clearFlashes } from '@/composables/useFlash'

// Mock Teleport
vi.mock('vue', async () => {
  const actual = await vi.importActual('vue')
  return {
    ...actual,
    Teleport: {
      name: 'Teleport',
      setup(_: unknown, { slots }: { slots: { default?: () => unknown } }) {
        return () => slots.default?.()
      },
    },
  }
})

// Mock lucide-vue-next icons
vi.mock('lucide-vue-next', () => ({
  X: { template: '<svg class="x-icon"></svg>' },
  CheckCircle: { template: '<svg class="check-icon"></svg>' },
  XCircle: { template: '<svg class="x-circle-icon"></svg>' },
  AlertTriangle: { template: '<svg class="alert-icon"></svg>' },
  Info: { template: '<svg class="info-icon"></svg>' },
}))

describe('FlashMessages', () => {
  beforeEach(() => {
    clearFlashes()
  })

  it('renders without initial messages', () => {
    const wrapper = mount(FlashMessages)
    expect(wrapper.findAll('[role="alert"]')).toHaveLength(0)
  })

  it('renders initial messages from props', async () => {
    const wrapper = mount(FlashMessages, {
      props: {
        initialMessages: [
          { type: 'success', message: 'Success message' },
          { type: 'error', message: 'Error message' },
        ],
      },
    })

    await nextTick()

    const alerts = wrapper.findAll('[role="alert"]')
    expect(alerts).toHaveLength(2)
  })

  it('displays correct message text', async () => {
    const wrapper = mount(FlashMessages, {
      props: {
        initialMessages: [
          { type: 'info', message: 'Test message content' },
        ],
      },
    })

    await nextTick()

    expect(wrapper.text()).toContain('Test message content')
  })

  it('displays title when provided', async () => {
    const wrapper = mount(FlashMessages, {
      props: {
        initialMessages: [
          { type: 'success', message: 'Message', title: 'Custom Title' },
        ],
      },
    })

    await nextTick()

    expect(wrapper.text()).toContain('Custom Title')
  })

  it('applies correct styles for success type', async () => {
    const wrapper = mount(FlashMessages, {
      props: {
        initialMessages: [
          { type: 'success', message: 'Success' },
        ],
      },
    })

    await nextTick()

    const alert = wrapper.find('[role="alert"]')
    expect(alert.classes()).toContain('bg-green-50')
  })

  it('applies correct styles for error type', async () => {
    const wrapper = mount(FlashMessages, {
      props: {
        initialMessages: [
          { type: 'error', message: 'Error' },
        ],
      },
    })

    await nextTick()

    const alert = wrapper.find('[role="alert"]')
    expect(alert.classes()).toContain('bg-red-50')
  })

  it('applies correct styles for warning type', async () => {
    const wrapper = mount(FlashMessages, {
      props: {
        initialMessages: [
          { type: 'warning', message: 'Warning' },
        ],
      },
    })

    await nextTick()

    const alert = wrapper.find('[role="alert"]')
    expect(alert.classes()).toContain('bg-yellow-50')
  })

  it('applies correct styles for info type', async () => {
    const wrapper = mount(FlashMessages, {
      props: {
        initialMessages: [
          { type: 'info', message: 'Info' },
        ],
      },
    })

    await nextTick()

    const alert = wrapper.find('[role="alert"]')
    expect(alert.classes()).toContain('bg-blue-50')
  })

  it('has dismiss button by default', async () => {
    const wrapper = mount(FlashMessages, {
      props: {
        initialMessages: [
          { type: 'success', message: 'Dismissible' },
        ],
      },
    })

    await nextTick()

    const dismissButton = wrapper.find('button')
    expect(dismissButton.exists()).toBe(true)
  })

  it('removes message when dismiss button is clicked', async () => {
    const wrapper = mount(FlashMessages, {
      props: {
        initialMessages: [
          { type: 'success', message: 'To be dismissed' },
        ],
      },
    })

    await nextTick()
    expect(wrapper.findAll('[role="alert"]')).toHaveLength(1)

    await wrapper.find('button').trigger('click')
    await nextTick()

    expect(wrapper.findAll('[role="alert"]')).toHaveLength(0)
  })

  it('limits visible messages to maxMessages prop', async () => {
    const wrapper = mount(FlashMessages, {
      props: {
        maxMessages: 2,
        initialMessages: [
          { type: 'success', message: 'Message 1' },
          { type: 'success', message: 'Message 2' },
          { type: 'success', message: 'Message 3' },
        ],
      },
    })

    await nextTick()

    const alerts = wrapper.findAll('[role="alert"]')
    expect(alerts).toHaveLength(2)
  })

  describe('position prop', () => {
    it('applies top-right position by default', () => {
      const wrapper = mount(FlashMessages)
      const container = wrapper.find('[role="region"]')
      expect(container.classes()).toContain('top-4')
      expect(container.classes()).toContain('right-4')
    })

    it('applies top-left position', () => {
      const wrapper = mount(FlashMessages, {
        props: { position: 'top-left' },
      })
      const container = wrapper.find('[role="region"]')
      expect(container.classes()).toContain('top-4')
      expect(container.classes()).toContain('left-4')
    })

    it('applies bottom-right position', () => {
      const wrapper = mount(FlashMessages, {
        props: { position: 'bottom-right' },
      })
      const container = wrapper.find('[role="region"]')
      expect(container.classes()).toContain('bottom-4')
      expect(container.classes()).toContain('right-4')
    })

    it('applies bottom-left position', () => {
      const wrapper = mount(FlashMessages, {
        props: { position: 'bottom-left' },
      })
      const container = wrapper.find('[role="region"]')
      expect(container.classes()).toContain('bottom-4')
      expect(container.classes()).toContain('left-4')
    })
  })

  describe('accessibility', () => {
    it('has proper ARIA attributes on container', () => {
      const wrapper = mount(FlashMessages)
      const region = wrapper.find('[role="region"]')

      expect(region.attributes('aria-label')).toBe('Notificaciones')
      expect(region.attributes('aria-live')).toBe('polite')
    })

    it('each message has role="alert"', async () => {
      const wrapper = mount(FlashMessages, {
        props: {
          initialMessages: [
            { type: 'success', message: 'Alert message' },
          ],
        },
      })

      await nextTick()

      const alert = wrapper.find('[role="alert"]')
      expect(alert.exists()).toBe(true)
    })

    it('dismiss button has accessible label', async () => {
      const wrapper = mount(FlashMessages, {
        props: {
          initialMessages: [
            { type: 'success', message: 'Test message' },
          ],
        },
      })

      await nextTick()

      const button = wrapper.find('button')
      expect(button.attributes('aria-label')).toContain('Cerrar notificación')
    })
  })
})
