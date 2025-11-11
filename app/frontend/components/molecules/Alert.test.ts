import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Alert from './Alert.vue'

describe('Alert', () => {
  it('renders with default props', () => {
    const wrapper = mount(Alert)
    expect(wrapper.exists()).toBe(true)
    expect(wrapper.find('.alert').exists()).toBe(true)
  })

  it('renders title', () => {
    const wrapper = mount(Alert, {
      props: { title: 'Alert Title' },
    })
    expect(wrapper.text()).toContain('Alert Title')
  })

  it('renders message', () => {
    const wrapper = mount(Alert, {
      props: { message: 'This is an alert message' },
    })
    expect(wrapper.text()).toContain('This is an alert message')
  })

  it('renders both title and message', () => {
    const wrapper = mount(Alert, {
      props: { title: 'Title', message: 'Message' },
    })
    expect(wrapper.text()).toContain('Title')
    expect(wrapper.text()).toContain('Message')
  })

  it('renders info variant by default', () => {
    const wrapper = mount(Alert)
    const alert = wrapper.find('.alert')
    expect(alert.classes()).toContain('bg-blue-50')
    expect(alert.classes()).toContain('border-blue-200')
  })

  it('renders success variant', () => {
    const wrapper = mount(Alert, {
      props: { variant: 'success' },
    })
    const alert = wrapper.find('.alert')
    expect(alert.classes()).toContain('bg-green-50')
  })

  it('renders warning variant', () => {
    const wrapper = mount(Alert, {
      props: { variant: 'warning' },
    })
    const alert = wrapper.find('.alert')
    expect(alert.classes()).toContain('bg-yellow-50')
  })

  it('renders danger variant', () => {
    const wrapper = mount(Alert, {
      props: { variant: 'danger' },
    })
    const alert = wrapper.find('.alert')
    expect(alert.classes()).toContain('bg-red-50')
  })

  it('shows default icon for info variant', () => {
    const wrapper = mount(Alert, {
      props: { variant: 'info' },
    })
    const icon = wrapper.findComponent({ name: 'Icon' })
    expect(icon.props('name')).toBe('info')
  })

  it('shows default icon for success variant', () => {
    const wrapper = mount(Alert, {
      props: { variant: 'success' },
    })
    const icon = wrapper.findComponent({ name: 'Icon' })
    expect(icon.props('name')).toBe('check-circle')
  })

  it('shows default icon for warning variant', () => {
    const wrapper = mount(Alert, {
      props: { variant: 'warning' },
    })
    const icon = wrapper.findComponent({ name: 'Icon' })
    expect(icon.props('name')).toBe('alert-triangle')
  })

  it('shows default icon for danger variant', () => {
    const wrapper = mount(Alert, {
      props: { variant: 'danger' },
    })
    const icon = wrapper.findComponent({ name: 'Icon' })
    expect(icon.props('name')).toBe('alert-circle')
  })

  it('renders custom icon when provided', () => {
    const wrapper = mount(Alert, {
      props: { icon: 'star' },
    })
    const icon = wrapper.findComponent({ name: 'Icon' })
    expect(icon.props('name')).toBe('star')
  })

  it('shows dismiss button when dismissible is true', () => {
    const wrapper = mount(Alert, {
      props: { dismissible: true },
    })
    const dismissButton = wrapper.find('button[aria-label="Dismiss alert"]')
    expect(dismissButton.exists()).toBe(true)
  })

  it('hides dismiss button when dismissible is false', () => {
    const wrapper = mount(Alert, {
      props: { dismissible: false },
    })
    const dismissButton = wrapper.find('button[aria-label="Dismiss alert"]')
    expect(dismissButton.exists()).toBe(false)
  })

  it('emits dismiss event when dismiss button is clicked', async () => {
    const wrapper = mount(Alert, {
      props: { dismissible: true },
    })
    const dismissButton = wrapper.find('button[aria-label="Dismiss alert"]')
    await dismissButton.trigger('click')

    expect(wrapper.emitted('dismiss')).toBeTruthy()
  })

  it('has correct ARIA role', () => {
    const wrapper = mount(Alert)
    expect(wrapper.attributes('role')).toBe('alert')
  })

  it('renders slot content', () => {
    const wrapper = mount(Alert, {
      slots: {
        default: '<div class="custom-content">Custom Alert Content</div>',
      },
    })
    expect(wrapper.html()).toContain('custom-content')
    expect(wrapper.text()).toContain('Custom Alert Content')
  })

  it('title has correct styling', () => {
    const wrapper = mount(Alert, {
      props: { title: 'Title' },
    })
    const title = wrapper.find('h4')
    expect(title.classes()).toContain('font-medium')
  })

  it('dismiss button has correct styling', () => {
    const wrapper = mount(Alert, {
      props: { dismissible: true },
    })
    const button = wrapper.find('button')
    expect(button.classes()).toContain('opacity-70')
    expect(button.classes()).toContain('hover:opacity-100')
  })

  it('applies correct icon color for info variant', () => {
    const wrapper = mount(Alert, {
      props: { variant: 'info' },
    })
    const icons = wrapper.findAllComponents({ name: 'Icon' })
    expect(icons[0].classes()).toContain('text-blue-600')
  })

  it('applies correct icon color for success variant', () => {
    const wrapper = mount(Alert, {
      props: { variant: 'success' },
    })
    const icons = wrapper.findAllComponents({ name: 'Icon' })
    expect(icons[0].classes()).toContain('text-green-600')
  })

  it('handles empty title and message', () => {
    const wrapper = mount(Alert, {
      props: { title: '', message: '' },
    })
    expect(wrapper.find('h4').exists()).toBe(false)
    expect(wrapper.find('p').exists()).toBe(false)
  })
})
