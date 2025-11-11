import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import AlertBanner from './AlertBanner.vue'
import Icon from '../atoms/Icon.vue'

describe('AlertBanner', () => {
  describe('rendering', () => {
    it('renders alert banner', () => {
      const wrapper = mount(AlertBanner)

      expect(wrapper.find('div[role="alert"]').exists()).toBe(true)
    })

    it('renders title', () => {
      const wrapper = mount(AlertBanner, {
        props: { title: 'Success!' },
      })

      expect(wrapper.text()).toContain('Success!')
    })

    it('renders message', () => {
      const wrapper = mount(AlertBanner, {
        props: { message: 'Operation completed successfully' },
      })

      expect(wrapper.text()).toContain('Operation completed successfully')
    })

    it('renders title and message', () => {
      const wrapper = mount(AlertBanner, {
        props: {
          title: 'Success',
          message: 'Your changes have been saved',
        },
      })

      expect(wrapper.text()).toContain('Success')
      expect(wrapper.text()).toContain('Your changes have been saved')
    })

    it('renders without title', () => {
      const wrapper = mount(AlertBanner, {
        props: { message: 'Just a message' },
      })

      expect(wrapper.find('h3').exists()).toBe(false)
    })

    it('renders icon by default', () => {
      const wrapper = mount(AlertBanner, {
        props: { message: 'Alert message' },
      })

      expect(wrapper.findComponent(Icon).exists()).toBe(true)
    })

    it('hides icon when showIcon is false', () => {
      const wrapper = mount(AlertBanner, {
        props: { message: 'Alert message', showIcon: false },
      })

      expect(wrapper.findComponent(Icon).exists()).toBe(false)
    })

    it('does not render close button by default', () => {
      const wrapper = mount(AlertBanner, {
        props: { message: 'Alert' },
      })

      const closeButtons = wrapper.findAll('button')
      expect(closeButtons.length).toBe(0)
    })

    it('renders close button when closable', () => {
      const wrapper = mount(AlertBanner, {
        props: { message: 'Alert', closable: true },
      })

      expect(wrapper.find('button[type="button"]').exists()).toBe(true)
    })
  })

  describe('variants', () => {
    it('renders success variant', () => {
      const wrapper = mount(AlertBanner, {
        props: { variant: 'success', message: 'Success message' },
      })

      const container = wrapper.find('div[role="alert"]')
      expect(container.classes()).toContain('bg-green-50')
      expect(container.classes()).toContain('border-green-200')
    })

    it('renders warning variant', () => {
      const wrapper = mount(AlertBanner, {
        props: { variant: 'warning', message: 'Warning message' },
      })

      const container = wrapper.find('div[role="alert"]')
      expect(container.classes()).toContain('bg-yellow-50')
      expect(container.classes()).toContain('border-yellow-200')
    })

    it('renders danger variant', () => {
      const wrapper = mount(AlertBanner, {
        props: { variant: 'danger', message: 'Error message' },
      })

      const container = wrapper.find('div[role="alert"]')
      expect(container.classes()).toContain('bg-red-50')
      expect(container.classes()).toContain('border-red-200')
    })

    it('renders info variant by default', () => {
      const wrapper = mount(AlertBanner, {
        props: { message: 'Info message' },
      })

      const container = wrapper.find('div[role="alert"]')
      expect(container.classes()).toContain('bg-blue-50')
      expect(container.classes()).toContain('border-blue-200')
    })

    it('renders correct icon for each variant', () => {
      const variants = [
        { variant: 'success' as const, icon: 'check-circle' },
        { variant: 'warning' as const, icon: 'alert-triangle' },
        { variant: 'danger' as const, icon: 'x-circle' },
        { variant: 'info' as const, icon: 'info' },
      ]

      variants.forEach(({ variant, icon }) => {
        const wrapper = mount(AlertBanner, {
          props: { variant, message: 'Test' },
        })

        const iconComponent = wrapper.findComponent(Icon)
        expect(iconComponent.props('name')).toBe(icon)
      })
    })
  })

  describe('styles', () => {
    it('renders filled style by default', () => {
      const wrapper = mount(AlertBanner, {
        props: { message: 'Alert' },
      })

      const container = wrapper.find('div[role="alert"]')
      expect(container.classes()).toContain('bg-blue-50')
    })

    it('renders outlined style', () => {
      const wrapper = mount(AlertBanner, {
        props: { message: 'Alert', style: 'outlined', variant: 'success' },
      })

      const container = wrapper.find('div[role="alert"]')
      expect(container.classes()).toContain('bg-white')
      expect(container.classes()).toContain('border-green-300')
    })
  })

  describe('custom icon', () => {
    it('renders custom icon', () => {
      const wrapper = mount(AlertBanner, {
        props: {
          message: 'Custom alert',
          icon: 'star',
        },
      })

      const iconComponent = wrapper.findComponent(Icon)
      expect(iconComponent.props('name')).toBe('star')
    })

    it('custom icon overrides default variant icon', () => {
      const wrapper = mount(AlertBanner, {
        props: {
          variant: 'success',
          message: 'Alert',
          icon: 'heart',
        },
      })

      const iconComponent = wrapper.findComponent(Icon)
      expect(iconComponent.props('name')).toBe('heart')
    })
  })

  describe('behavior', () => {
    it('emits close event when close button clicked', async () => {
      const wrapper = mount(AlertBanner, {
        props: {
          message: 'Alert',
          closable: true,
        },
      })

      const closeButton = wrapper.find('button[type="button"]')
      await closeButton.trigger('click')

      expect(wrapper.emitted('close')).toBeTruthy()
    })
  })

  describe('slots', () => {
    it('renders title slot', () => {
      const wrapper = mount(AlertBanner, {
        slots: {
          title: '<strong>Custom Title</strong>',
        },
      })

      expect(wrapper.html()).toContain('<strong>Custom Title</strong>')
    })

    it('renders default slot for message', () => {
      const wrapper = mount(AlertBanner, {
        slots: {
          default: '<p>Custom message content</p>',
        },
      })

      expect(wrapper.html()).toContain('<p>Custom message content</p>')
    })

    it('renders actions slot', () => {
      const wrapper = mount(AlertBanner, {
        props: { message: 'Alert' },
        slots: {
          actions: '<button class="action-btn">Retry</button>',
        },
      })

      expect(wrapper.find('.action-btn').exists()).toBe(true)
    })

    it('prioritizes title slot over title prop', () => {
      const wrapper = mount(AlertBanner, {
        props: { title: 'Prop title' },
        slots: {
          title: 'Slot title',
        },
      })

      expect(wrapper.text()).toContain('Slot title')
      expect(wrapper.text()).not.toContain('Prop title')
    })

    it('prioritizes default slot over message prop', () => {
      const wrapper = mount(AlertBanner, {
        props: { message: 'Prop message' },
        slots: {
          default: 'Slot message',
        },
      })

      expect(wrapper.text()).toContain('Slot message')
      expect(wrapper.text()).not.toContain('Prop message')
    })
  })

  describe('accessibility', () => {
    it('has role="alert"', () => {
      const wrapper = mount(AlertBanner, {
        props: { message: 'Alert' },
      })

      expect(wrapper.find('div[role="alert"]').exists()).toBe(true)
    })

    it('close button has aria-label', () => {
      const wrapper = mount(AlertBanner, {
        props: { message: 'Alert', closable: true },
      })

      const closeIcon = wrapper.findAllComponents(Icon).find((icon) => icon.props('name') === 'x')
      expect(closeIcon?.props('ariaLabel')).toBe('Close')
    })
  })

  describe('combinations', () => {
    it('renders with all features', () => {
      const wrapper = mount(AlertBanner, {
        props: {
          variant: 'success',
          title: 'Success!',
          message: 'Operation completed',
          showIcon: true,
          closable: true,
          style: 'filled',
        },
      })

      expect(wrapper.text()).toContain('Success!')
      expect(wrapper.text()).toContain('Operation completed')
      expect(wrapper.findComponent(Icon).exists()).toBe(true)
      expect(wrapper.find('button').exists()).toBe(true)
    })

    it('renders without icon and without close button', () => {
      const wrapper = mount(AlertBanner, {
        props: {
          message: 'Simple alert',
          showIcon: false,
          closable: false,
        },
      })

      expect(wrapper.findComponent(Icon).exists()).toBe(false)
      expect(wrapper.find('button').exists()).toBe(false)
    })

    it('renders outlined style with custom icon', () => {
      const wrapper = mount(AlertBanner, {
        props: {
          variant: 'warning',
          message: 'Warning',
          style: 'outlined',
          icon: 'alert-circle',
        },
      })

      const container = wrapper.find('div[role="alert"]')
      expect(container.classes()).toContain('bg-white')
      const icon = wrapper.findComponent(Icon)
      expect(icon.props('name')).toBe('alert-circle')
    })
  })
})
