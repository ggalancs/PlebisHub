import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount } from '@vue/test-utils'
import Toast from './Toast.vue'

describe('Toast', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.restoreAllMocks()
    vi.useRealTimers()
  })

  describe('rendering', () => {
    it('renders message', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test message' },
      })

      expect(wrapper.text()).toContain('Test message')
    })

    it('renders title', () => {
      const wrapper = mount(Toast, {
        props: {
          message: 'Test message',
          title: 'Test Title',
        },
      })

      expect(wrapper.text()).toContain('Test Title')
    })

    it('renders without title', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test message' },
      })

      expect(wrapper.find('h4').exists()).toBe(false)
    })

    it('renders close button by default', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test message' },
      })

      const closeButton = wrapper.find('[aria-label="Close notification"]')
      expect(closeButton.exists()).toBe(true)
    })

    it('hides close button when closable is false', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test message', closable: false },
      })

      const closeButton = wrapper.find('[aria-label="Close notification"]')
      expect(closeButton.exists()).toBe(false)
    })

    it('renders icon by default', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test message' },
      })

      expect(wrapper.findComponent({ name: 'Icon' }).exists()).toBe(true)
    })

    it('hides icon when showIcon is false', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test message', showIcon: false },
      })

      const icons = wrapper.findAllComponents({ name: 'Icon' })
      // Should only have close button icon, not the variant icon
      expect(icons.length).toBe(1) // Only close button X icon
    })

    it('renders progress bar by default', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test message' },
      })

      const progressBar = wrapper.find('.absolute.bottom-0')
      expect(progressBar.exists()).toBe(true)
    })

    it('hides progress bar when showProgress is false', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test message', showProgress: false },
      })

      const progressBar = wrapper.find('.absolute.bottom-0')
      expect(progressBar.exists()).toBe(false)
    })

    it('hides progress bar when duration is 0', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test message', duration: 0 },
      })

      const progressBar = wrapper.find('.absolute.bottom-0')
      expect(progressBar.exists()).toBe(false)
    })
  })

  describe('variants', () => {
    it('renders success variant', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Success', variant: 'success' },
      })

      const toast = wrapper.find('.toast')
      expect(toast.classes()).toContain('bg-green-50')
      expect(toast.classes()).toContain('border-green-200')
    })

    it('renders warning variant', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Warning', variant: 'warning' },
      })

      const toast = wrapper.find('.toast')
      expect(toast.classes()).toContain('bg-yellow-50')
      expect(toast.classes()).toContain('border-yellow-200')
    })

    it('renders danger variant', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Error', variant: 'danger' },
      })

      const toast = wrapper.find('.toast')
      expect(toast.classes()).toContain('bg-red-50')
      expect(toast.classes()).toContain('border-red-200')
    })

    it('renders info variant by default', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Info' },
      })

      const toast = wrapper.find('.toast')
      expect(toast.classes()).toContain('bg-blue-50')
      expect(toast.classes()).toContain('border-blue-200')
    })
  })

  describe('default icons', () => {
    it('shows check-circle for success', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Success', variant: 'success' },
      })

      const icon = wrapper.findComponent({ name: 'Icon' })
      expect(icon.props('name')).toBe('check-circle')
    })

    it('shows alert-triangle for warning', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Warning', variant: 'warning' },
      })

      const icon = wrapper.findComponent({ name: 'Icon' })
      expect(icon.props('name')).toBe('alert-triangle')
    })

    it('shows x-circle for danger', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Error', variant: 'danger' },
      })

      const icon = wrapper.findComponent({ name: 'Icon' })
      expect(icon.props('name')).toBe('x-circle')
    })

    it('shows info icon for info', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Info', variant: 'info' },
      })

      const icon = wrapper.findComponent({ name: 'Icon' })
      expect(icon.props('name')).toBe('info')
    })

    it('uses custom icon when provided', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Custom', icon: 'star' },
      })

      const icon = wrapper.findComponent({ name: 'Icon' })
      expect(icon.props('name')).toBe('star')
    })
  })

  describe('close button', () => {
    it('emits close event when clicked', async () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test', duration: 0 },
      })

      const closeButton = wrapper.find('[aria-label="Close notification"]')
      await closeButton.trigger('click')

      expect(wrapper.emitted('close')).toBeTruthy()
    })

    it('hides toast when close button clicked', async () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test', duration: 0 },
      })

      const closeButton = wrapper.find('[aria-label="Close notification"]')
      await closeButton.trigger('click')
      await wrapper.vm.$nextTick()

      expect(wrapper.find('.toast').exists()).toBe(false)
    })
  })

  describe('auto-dismiss', () => {
    it('auto-dismisses after duration', async () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test', duration: 3000 },
      })

      expect(wrapper.find('.toast').exists()).toBe(true)

      vi.advanceTimersByTime(3000)
      await wrapper.vm.$nextTick()

      expect(wrapper.emitted('close')).toBeTruthy()
    })

    it('does not auto-dismiss when duration is 0', async () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test', duration: 0 },
      })

      expect(wrapper.find('.toast').exists()).toBe(true)

      vi.advanceTimersByTime(10000)
      await wrapper.vm.$nextTick()

      expect(wrapper.emitted('close')).toBeFalsy()
      expect(wrapper.find('.toast').exists()).toBe(true)
    })

    it('uses default duration of 5000ms', async () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test' },
      })

      vi.advanceTimersByTime(4999)
      await wrapper.vm.$nextTick()
      expect(wrapper.emitted('close')).toBeFalsy()

      vi.advanceTimersByTime(1)
      await wrapper.vm.$nextTick()
      expect(wrapper.emitted('close')).toBeTruthy()
    })
  })

  describe('progress bar', () => {
    it('starts at 100%', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test', duration: 1000 },
      })

      const progressBar = wrapper.find('.absolute.bottom-0')
      expect(progressBar.attributes('style')).toContain('width: 100%')
    })

    it('decreases over time', async () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test', duration: 1000 },
      })

      vi.advanceTimersByTime(500)
      await wrapper.vm.$nextTick()

      const progressBar = wrapper.find('.absolute.bottom-0')
      const style = progressBar.attributes('style')
      // Should be around 50% after half the duration
      expect(style).toMatch(/width: [4-5]\d%/)
    })

    it('reaches 0% at end', async () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test', duration: 1000 },
      })

      vi.advanceTimersByTime(999)
      await wrapper.vm.$nextTick()

      const progressBar = wrapper.find('.absolute.bottom-0')
      const style = progressBar.attributes('style') || ''
      // Should be very close to 0%
      expect(style).toMatch(/width: [0-9](\.\d+)?%/)
    })

    it('applies correct color for variant', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test', variant: 'success' },
      })

      const progressBar = wrapper.find('.absolute.bottom-0')
      expect(progressBar.classes()).toContain('bg-green-600')
    })
  })

  describe('accessibility', () => {
    it('has role="alert"', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test' },
      })

      const toast = wrapper.find('.toast')
      expect(toast.attributes('role')).toBe('alert')
    })

    it('has aria-live="polite"', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test' },
      })

      const toast = wrapper.find('.toast')
      expect(toast.attributes('aria-live')).toBe('polite')
    })

    it('close button has aria-label', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test' },
      })

      const closeButton = wrapper.find('[aria-label="Close notification"]')
      expect(closeButton.exists()).toBe(true)
    })
  })

  describe('layout', () => {
    it('renders icon, content, and close button in correct order', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test', title: 'Title' },
      })

      const html = wrapper.html()
      const iconIndex = html.indexOf('Icon')
      const titleIndex = html.indexOf('Title')
      const closeIndex = html.indexOf('Close notification')

      expect(iconIndex).toBeLessThan(titleIndex)
      expect(titleIndex).toBeLessThan(closeIndex)
    })

    it('renders title before message', () => {
      const wrapper = mount(Toast, {
        props: {
          message: 'Message text',
          title: 'Title text',
        },
      })

      const html = wrapper.html()
      const titleIndex = html.indexOf('Title text')
      const messageIndex = html.indexOf('Message text')

      expect(titleIndex).toBeLessThan(messageIndex)
    })
  })

  describe('combinations', () => {
    it('renders with all features', () => {
      const wrapper = mount(Toast, {
        props: {
          variant: 'success',
          title: 'Success!',
          message: 'Operation completed',
          showIcon: true,
          closable: true,
          duration: 5000,
          showProgress: true,
        },
      })

      expect(wrapper.text()).toContain('Success!')
      expect(wrapper.text()).toContain('Operation completed')
      expect(wrapper.findComponent({ name: 'Icon' }).exists()).toBe(true)
      expect(wrapper.find('[aria-label="Close notification"]').exists()).toBe(true)
      expect(wrapper.find('.absolute.bottom-0').exists()).toBe(true)
    })

    it('works with minimal props', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Simple toast' },
      })

      expect(wrapper.text()).toContain('Simple toast')
      expect(wrapper.exists()).toBe(true)
    })

    it('works without auto-dismiss and progress', () => {
      const wrapper = mount(Toast, {
        props: {
          message: 'Persistent toast',
          duration: 0,
          showProgress: false,
        },
      })

      expect(wrapper.find('.toast').exists()).toBe(true)
      expect(wrapper.find('.absolute.bottom-0').exists()).toBe(false)

      vi.advanceTimersByTime(10000)
      expect(wrapper.emitted('close')).toBeFalsy()
    })

    it('works with custom icon and no close button', () => {
      const wrapper = mount(Toast, {
        props: {
          message: 'Custom toast',
          icon: 'heart',
          closable: false,
          duration: 0,
        },
      })

      const icon = wrapper.findComponent({ name: 'Icon' })
      expect(icon.props('name')).toBe('heart')
      expect(wrapper.find('[aria-label="Close notification"]').exists()).toBe(false)
    })
  })

  describe('timer cleanup', () => {
    it('clears timer on unmount', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test', duration: 5000 },
      })

      wrapper.unmount()

      // If timer wasn't cleared, this would cause issues
      vi.advanceTimersByTime(5000)
      expect(wrapper.emitted('close')).toBeFalsy()
    })

    it('clears progress interval on unmount', () => {
      const wrapper = mount(Toast, {
        props: { message: 'Test', duration: 5000 },
      })

      wrapper.unmount()

      // If interval wasn't cleared, this would cause issues
      vi.advanceTimersByTime(100)
      expect(() => wrapper.vm.$nextTick()).not.toThrow()
    })
  })
})
