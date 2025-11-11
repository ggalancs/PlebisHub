import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Divider from './Divider.vue'

describe('Divider', () => {
  it('renders with default props', () => {
    const wrapper = mount(Divider)
    expect(wrapper.exists()).toBe(true)
  })

  it('renders horizontal divider by default', () => {
    const wrapper = mount(Divider)
    expect(wrapper.find('.divider-horizontal').exists()).toBe(true)
  })

  it('renders vertical divider', () => {
    const wrapper = mount(Divider, {
      props: { orientation: 'vertical' },
    })
    expect(wrapper.find('.divider-vertical').exists()).toBe(true)
  })

  it('renders label text', () => {
    const wrapper = mount(Divider, {
      props: { label: 'OR' },
    })
    expect(wrapper.text()).toContain('OR')
  })

  it('renders label in center by default', () => {
    const wrapper = mount(Divider, {
      props: { label: 'Center' },
    })
    const lines = wrapper.findAll('.divider-line')
    expect(lines).toHaveLength(2) // Both left and right lines
  })

  it('renders label on left', () => {
    const wrapper = mount(Divider, {
      props: { label: 'Left', labelPosition: 'left' },
    })
    const lines = wrapper.findAll('.divider-line')
    expect(lines).toHaveLength(1) // Only right line
  })

  it('renders label on right', () => {
    const wrapper = mount(Divider, {
      props: { label: 'Right', labelPosition: 'right' },
    })
    const lines = wrapper.findAll('.divider-line')
    expect(lines).toHaveLength(1) // Only left line
  })

  it('applies solid border variant', () => {
    const wrapper = mount(Divider, {
      props: { variant: 'solid' },
    })
    const line = wrapper.find('.divider-line')
    expect(line.classes()).toContain('border-solid')
  })

  it('applies dashed border variant', () => {
    const wrapper = mount(Divider, {
      props: { variant: 'dashed' },
    })
    const line = wrapper.find('.divider-line')
    expect(line.classes()).toContain('border-dashed')
  })

  it('applies dotted border variant', () => {
    const wrapper = mount(Divider, {
      props: { variant: 'dotted' },
    })
    const line = wrapper.find('.divider-line')
    expect(line.classes()).toContain('border-dotted')
  })

  it('has correct ARIA role', () => {
    const wrapper = mount(Divider)
    expect(wrapper.attributes('role')).toBe('separator')
  })

  it('has correct ARIA orientation for horizontal', () => {
    const wrapper = mount(Divider, {
      props: { orientation: 'horizontal' },
    })
    expect(wrapper.attributes('aria-orientation')).toBe('horizontal')
  })

  it('has correct ARIA orientation for vertical', () => {
    const wrapper = mount(Divider, {
      props: { orientation: 'vertical' },
    })
    expect(wrapper.attributes('aria-orientation')).toBe('vertical')
  })

  it('has ARIA label when label prop is provided', () => {
    const wrapper = mount(Divider, {
      props: { label: 'Section divider' },
    })
    expect(wrapper.attributes('aria-label')).toBe('Section divider')
  })

  it('renders slot content', () => {
    const wrapper = mount(Divider, {
      slots: {
        default: '<span class="custom-label">Custom</span>',
      },
    })
    expect(wrapper.html()).toContain('custom-label')
    expect(wrapper.text()).toContain('Custom')
  })

  it('horizontal divider has full width', () => {
    const wrapper = mount(Divider, {
      props: { orientation: 'horizontal' },
    })
    const container = wrapper.find('.divider-horizontal')
    expect(container.classes()).toContain('w-full')
  })

  it('applies gray border color', () => {
    const wrapper = mount(Divider)
    const line = wrapper.find('.divider-line')
    expect(line.classes()).toContain('border-gray-300')
  })

  it('label has correct styling', () => {
    const wrapper = mount(Divider, {
      props: { label: 'Test' },
    })
    const label = wrapper.find('.divider-label')
    expect(label.classes()).toContain('text-gray-500')
    expect(label.classes()).toContain('text-sm')
  })

  it('handles empty label', () => {
    const wrapper = mount(Divider, {
      props: { label: '' },
    })
    expect(wrapper.find('.divider-label').exists()).toBe(false)
  })
})
