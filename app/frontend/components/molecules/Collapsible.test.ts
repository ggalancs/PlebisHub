import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Collapsible from './Collapsible.vue'

describe('Collapsible', () => {
  it('renders with required props', () => {
    const wrapper = mount(Collapsible, {
      props: { title: 'Test Title' },
    })
    expect(wrapper.exists()).toBe(true)
  })

  it('renders title text', () => {
    const wrapper = mount(Collapsible, {
      props: { title: 'My Collapsible' },
    })
    expect(wrapper.text()).toContain('My Collapsible')
  })

  it('is collapsed by default', () => {
    const wrapper = mount(Collapsible, {
      props: { title: 'Title' },
      slots: { default: '<p>Content</p>' },
    })
    expect(wrapper.find('.collapsible-content').exists()).toBe(false)
  })

  it('shows content when modelValue is true', () => {
    const wrapper = mount(Collapsible, {
      props: { title: 'Title', modelValue: true },
      slots: { default: '<p>Content</p>' },
    })
    expect(wrapper.find('.collapsible-content').exists()).toBe(true)
    expect(wrapper.text()).toContain('Content')
  })

  it('emits update:modelValue when clicked', async () => {
    const wrapper = mount(Collapsible, {
      props: { title: 'Title' },
    })
    const button = wrapper.find('button')
    await button.trigger('click')

    expect(wrapper.emitted('update:modelValue')).toBeTruthy()
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([true])
  })

  it('emits toggle event when clicked', async () => {
    const wrapper = mount(Collapsible, {
      props: { title: 'Title' },
    })
    const button = wrapper.find('button')
    await button.trigger('click')

    expect(wrapper.emitted('toggle')).toBeTruthy()
    expect(wrapper.emitted('toggle')?.[0]).toEqual([true])
  })

  it('toggles from open to closed', async () => {
    const wrapper = mount(Collapsible, {
      props: { title: 'Title', modelValue: true },
    })
    const button = wrapper.find('button')
    await button.trigger('click')

    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([false])
  })

  it('does not emit events when disabled', async () => {
    const wrapper = mount(Collapsible, {
      props: { title: 'Title', disabled: true },
    })
    const button = wrapper.find('button')
    await button.trigger('click')

    expect(wrapper.emitted('update:modelValue')).toBeFalsy()
    expect(wrapper.emitted('toggle')).toBeFalsy()
  })

  it('applies disabled styling', () => {
    const wrapper = mount(Collapsible, {
      props: { title: 'Title', disabled: true },
    })
    const button = wrapper.find('button')
    expect(button.classes()).toContain('cursor-not-allowed')
    expect(button.classes()).toContain('opacity-50')
  })

  it('has disabled attribute when disabled', () => {
    const wrapper = mount(Collapsible, {
      props: { title: 'Title', disabled: true },
    })
    const button = wrapper.find('button')
    expect(button.attributes('disabled')).toBe('')
  })

  it('shows chevron-right icon when collapsed', () => {
    const wrapper = mount(Collapsible, {
      props: { title: 'Title', modelValue: false },
    })
    const icon = wrapper.findComponent({ name: 'Icon' })
    expect(icon.props('name')).toBe('chevron-right')
  })

  it('shows chevron-down icon when expanded', () => {
    const wrapper = mount(Collapsible, {
      props: { title: 'Title', modelValue: true },
    })
    const icon = wrapper.findComponent({ name: 'Icon' })
    expect(icon.props('name')).toBe('chevron-down')
  })

  it('uses custom iconCollapsed', () => {
    const wrapper = mount(Collapsible, {
      props: { title: 'Title', modelValue: false, iconCollapsed: 'plus' },
    })
    const icon = wrapper.findComponent({ name: 'Icon' })
    expect(icon.props('name')).toBe('plus')
  })

  it('uses custom iconExpanded', () => {
    const wrapper = mount(Collapsible, {
      props: { title: 'Title', modelValue: true, iconExpanded: 'minus' },
    })
    const icon = wrapper.findComponent({ name: 'Icon' })
    expect(icon.props('name')).toBe('minus')
  })

  it('has correct ARIA attributes', () => {
    const wrapper = mount(Collapsible, {
      props: { title: 'Title', modelValue: false },
    })
    const button = wrapper.find('button')
    expect(button.attributes('aria-expanded')).toBe('false')
    expect(button.attributes('aria-controls')).toBe('collapsible-content')
  })

  it('updates aria-expanded when opened', () => {
    const wrapper = mount(Collapsible, {
      props: { title: 'Title', modelValue: true },
    })
    const button = wrapper.find('button')
    expect(button.attributes('aria-expanded')).toBe('true')
  })

  it('renders slot content', () => {
    const wrapper = mount(Collapsible, {
      props: { title: 'Title', modelValue: true },
      slots: { default: '<div class="custom-content">Custom Content</div>' },
    })
    expect(wrapper.html()).toContain('custom-content')
    expect(wrapper.text()).toContain('Custom Content')
  })

  it('has border and rounded styling', () => {
    const wrapper = mount(Collapsible, {
      props: { title: 'Title' },
    })
    const container = wrapper.find('.collapsible')
    expect(container.classes()).toContain('border')
    expect(container.classes()).toContain('rounded-lg')
  })

  it('button has hover effect when not disabled', () => {
    const wrapper = mount(Collapsible, {
      props: { title: 'Title', disabled: false },
    })
    const button = wrapper.find('button')
    expect(button.classes()).toContain('hover:bg-gray-50')
  })
})
