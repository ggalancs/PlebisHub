import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Tag from './Tag.vue'

describe('Tag', () => {
  // Basic Rendering Tests
  it('renders with default props', () => {
    const wrapper = mount(Tag)
    expect(wrapper.exists()).toBe(true)
    expect(wrapper.find('.tag').exists()).toBe(true)
  })

  it('renders label prop', () => {
    const wrapper = mount(Tag, {
      props: { label: 'Test Tag' },
    })
    expect(wrapper.text()).toContain('Test Tag')
  })

  it('renders slot content', () => {
    const wrapper = mount(Tag, {
      slots: {
        default: '<span class="custom-content">Custom Tag</span>',
      },
    })
    expect(wrapper.html()).toContain('custom-content')
    expect(wrapper.text()).toContain('Custom Tag')
  })

  // Variant Tests
  it('renders default variant correctly', () => {
    const wrapper = mount(Tag, {
      props: { variant: 'default', label: 'Default' },
    })
    const tag = wrapper.find('.tag')
    expect(tag.classes()).toContain('bg-gray-100')
    expect(tag.classes()).toContain('text-gray-700')
  })

  it('renders primary variant correctly', () => {
    const wrapper = mount(Tag, {
      props: { variant: 'primary', label: 'Primary' },
    })
    const tag = wrapper.find('.tag')
    expect(tag.classes()).toContain('bg-primary')
    expect(tag.classes()).toContain('text-white')
  })

  it('renders success variant correctly', () => {
    const wrapper = mount(Tag, {
      props: { variant: 'success', label: 'Success' },
    })
    const tag = wrapper.find('.tag')
    expect(tag.classes()).toContain('bg-green-500')
  })

  it('renders warning variant correctly', () => {
    const wrapper = mount(Tag, {
      props: { variant: 'warning', label: 'Warning' },
    })
    const tag = wrapper.find('.tag')
    expect(tag.classes()).toContain('bg-yellow-500')
  })

  it('renders danger variant correctly', () => {
    const wrapper = mount(Tag, {
      props: { variant: 'danger', label: 'Danger' },
    })
    const tag = wrapper.find('.tag')
    expect(tag.classes()).toContain('bg-red-500')
  })

  it('renders info variant correctly', () => {
    const wrapper = mount(Tag, {
      props: { variant: 'info', label: 'Info' },
    })
    const tag = wrapper.find('.tag')
    expect(tag.classes()).toContain('bg-blue-500')
  })

  // Size Tests
  it('renders small size correctly', () => {
    const wrapper = mount(Tag, {
      props: { size: 'sm', label: 'Small' },
    })
    const tag = wrapper.find('.tag')
    expect(tag.classes()).toContain('text-xs')
    expect(tag.classes()).toContain('px-2')
  })

  it('renders medium size correctly', () => {
    const wrapper = mount(Tag, {
      props: { size: 'md', label: 'Medium' },
    })
    const tag = wrapper.find('.tag')
    expect(tag.classes()).toContain('text-sm')
    expect(tag.classes()).toContain('px-3')
  })

  it('renders large size correctly', () => {
    const wrapper = mount(Tag, {
      props: { size: 'lg', label: 'Large' },
    })
    const tag = wrapper.find('.tag')
    expect(tag.classes()).toContain('text-base')
    expect(tag.classes()).toContain('px-4')
  })

  // Outlined Variant Tests
  it('renders outlined variant correctly', () => {
    const wrapper = mount(Tag, {
      props: { outlined: true, variant: 'default', label: 'Outlined' },
    })
    const tag = wrapper.find('.tag')
    expect(tag.classes()).toContain('border')
    expect(tag.classes()).toContain('border-gray-300')
  })

  it('renders outlined primary variant', () => {
    const wrapper = mount(Tag, {
      props: { outlined: true, variant: 'primary', label: 'Outlined Primary' },
    })
    const tag = wrapper.find('.tag')
    expect(tag.classes()).toContain('border-primary')
    expect(tag.classes()).toContain('text-primary')
  })

  it('renders outlined success variant', () => {
    const wrapper = mount(Tag, {
      props: { outlined: true, variant: 'success', label: 'Outlined Success' },
    })
    const tag = wrapper.find('.tag')
    expect(tag.classes()).toContain('border-green-500')
  })

  // Removable Tests
  it('shows remove button when removable is true', () => {
    const wrapper = mount(Tag, {
      props: { removable: true, label: 'Removable' },
    })
    expect(wrapper.find('.remove-button').exists()).toBe(true)
  })

  it('hides remove button when removable is false', () => {
    const wrapper = mount(Tag, {
      props: { removable: false, label: 'Not Removable' },
    })
    expect(wrapper.find('.remove-button').exists()).toBe(false)
  })

  it('emits remove event when remove button is clicked', async () => {
    const wrapper = mount(Tag, {
      props: { removable: true, label: 'Remove Me' },
    })
    const removeButton = wrapper.find('.remove-button')
    await removeButton.trigger('click')

    expect(wrapper.emitted('remove')).toBeTruthy()
  })

  it('does not emit remove when disabled', async () => {
    const wrapper = mount(Tag, {
      props: { removable: true, disabled: true, label: 'Disabled' },
    })
    const removeButton = wrapper.find('.remove-button')
    await removeButton.trigger('click')

    expect(wrapper.emitted('remove')).toBeFalsy()
  })

  it('stops propagation when remove button is clicked', async () => {
    const wrapper = mount(Tag, {
      props: { removable: true, clickable: true, label: 'Test' },
    })
    const removeButton = wrapper.find('.remove-button')
    await removeButton.trigger('click')

    // Should emit remove but not click
    expect(wrapper.emitted('remove')).toBeTruthy()
    expect(wrapper.emitted('click')).toBeFalsy()
  })

  // Clickable Tests
  it('adds cursor-pointer class when clickable', () => {
    const wrapper = mount(Tag, {
      props: { clickable: true, label: 'Clickable' },
    })
    const tag = wrapper.find('.tag')
    expect(tag.classes()).toContain('cursor-pointer')
  })

  it('emits click event when clicked', async () => {
    const wrapper = mount(Tag, {
      props: { clickable: true, label: 'Click Me' },
    })
    await wrapper.trigger('click')

    expect(wrapper.emitted('click')).toBeTruthy()
  })

  it('does not emit click when not clickable', async () => {
    const wrapper = mount(Tag, {
      props: { clickable: false, label: 'Not Clickable' },
    })
    await wrapper.trigger('click')

    expect(wrapper.emitted('click')).toBeFalsy()
  })

  it('does not emit click when disabled', async () => {
    const wrapper = mount(Tag, {
      props: { clickable: true, disabled: true, label: 'Disabled' },
    })
    await wrapper.trigger('click')

    expect(wrapper.emitted('click')).toBeFalsy()
  })

  it('has role="button" when clickable', () => {
    const wrapper = mount(Tag, {
      props: { clickable: true, label: 'Button Tag' },
    })
    expect(wrapper.attributes('role')).toBe('button')
  })

  it('has tabindex when clickable', () => {
    const wrapper = mount(Tag, {
      props: { clickable: true, label: 'Tabbable' },
    })
    expect(wrapper.attributes('tabindex')).toBe('0')
  })

  it('does not have role or tabindex when not clickable', () => {
    const wrapper = mount(Tag, {
      props: { clickable: false, label: 'Not Clickable' },
    })
    expect(wrapper.attributes('role')).toBeUndefined()
    expect(wrapper.attributes('tabindex')).toBeUndefined()
  })

  // Keyboard Tests
  it('handles Enter key press', async () => {
    const wrapper = mount(Tag, {
      props: { clickable: true, label: 'Keyboard' },
    })
    await wrapper.trigger('keydown.enter')

    expect(wrapper.emitted('click')).toBeTruthy()
  })

  it('handles Space key press', async () => {
    const wrapper = mount(Tag, {
      props: { clickable: true, label: 'Keyboard' },
    })
    await wrapper.trigger('keydown.space')

    expect(wrapper.emitted('click')).toBeTruthy()
  })

  // Disabled Tests
  it('applies disabled styling', () => {
    const wrapper = mount(Tag, {
      props: { disabled: true, label: 'Disabled' },
    })
    const tag = wrapper.find('.tag')
    expect(tag.classes()).toContain('opacity-50')
    expect(tag.classes()).toContain('cursor-not-allowed')
  })

  it('has aria-disabled attribute when disabled', () => {
    const wrapper = mount(Tag, {
      props: { disabled: true, label: 'Disabled' },
    })
    expect(wrapper.attributes('aria-disabled')).toBe('true')
  })

  it('disables remove button when disabled', () => {
    const wrapper = mount(Tag, {
      props: { removable: true, disabled: true, label: 'Disabled' },
    })
    const removeButton = wrapper.find('.remove-button')
    expect(removeButton.attributes('disabled')).toBe('')
  })

  // Icon Tests
  it('renders icon when icon prop is provided', () => {
    const wrapper = mount(Tag, {
      props: { icon: 'star', label: 'With Icon' },
    })
    const icon = wrapper.findComponent({ name: 'Icon' })
    expect(icon.exists()).toBe(true)
    expect(icon.props('name')).toBe('star')
  })

  it('does not render icon when icon prop is not provided', () => {
    const wrapper = mount(Tag, {
      props: { label: 'No Icon' },
    })
    const icons = wrapper.findAllComponents({ name: 'Icon' })
    // Should only have remove icon if removable
    expect(icons.length).toBe(0)
  })

  it('icon has correct size for small tag', () => {
    const wrapper = mount(Tag, {
      props: { icon: 'star', size: 'sm', label: 'Small Icon' },
    })
    const icon = wrapper.findComponent({ name: 'Icon' })
    expect(icon.props('size')).toBe(12)
  })

  it('icon has correct size for large tag', () => {
    const wrapper = mount(Tag, {
      props: { icon: 'star', size: 'lg', label: 'Large Icon' },
    })
    const icon = wrapper.findComponent({ name: 'Icon' })
    expect(icon.props('size')).toBe(18)
  })

  // Avatar Tests
  it('renders avatar when avatar prop is provided', () => {
    const wrapper = mount(Tag, {
      props: { avatar: 'https://example.com/avatar.jpg', label: 'With Avatar' },
    })
    const img = wrapper.find('img')
    expect(img.exists()).toBe(true)
    expect(img.attributes('src')).toBe('https://example.com/avatar.jpg')
  })

  it('does not render icon when avatar is provided', () => {
    const wrapper = mount(Tag, {
      props: { icon: 'star', avatar: 'https://example.com/avatar.jpg', label: 'Avatar Priority' },
    })
    const icons = wrapper.findAllComponents({ name: 'Icon' })
    const img = wrapper.find('img')

    expect(img.exists()).toBe(true)
    // Only remove icon should exist if removable
    expect(icons.length).toBe(0)
  })

  it('avatar has correct alt text', () => {
    const wrapper = mount(Tag, {
      props: { avatar: 'https://example.com/avatar.jpg', label: 'John Doe' },
    })
    const img = wrapper.find('img')
    expect(img.attributes('alt')).toBe('John Doe')
  })

  it('avatar has rounded-full class', () => {
    const wrapper = mount(Tag, {
      props: { avatar: 'https://example.com/avatar.jpg', label: 'Avatar' },
    })
    const img = wrapper.find('img')
    expect(img.classes()).toContain('rounded-full')
  })

  // Accessibility Tests
  it('has correct aria-label on remove button', () => {
    const wrapper = mount(Tag, {
      props: { removable: true, label: 'Test Tag' },
    })
    const removeButton = wrapper.find('.remove-button')
    expect(removeButton.attributes('aria-label')).toBe('Remove Test Tag')
  })

  it('remove button has type="button"', () => {
    const wrapper = mount(Tag, {
      props: { removable: true, label: 'Test' },
    })
    const removeButton = wrapper.find('.remove-button')
    expect(removeButton.attributes('type')).toBe('button')
  })

  // Edge Cases
  it('handles empty label', () => {
    const wrapper = mount(Tag, {
      props: { label: '' },
    })
    expect(wrapper.exists()).toBe(true)
  })

  it('handles long text', () => {
    const wrapper = mount(Tag, {
      props: { label: 'This is a very long tag label that should be truncated' },
    })
    // Just verify it renders without breaking
    expect(wrapper.find('.tag').exists()).toBe(true)
    expect(wrapper.text()).toContain('This is a very long tag label')
  })

  // Combination Tests
  it('works with all features combined', () => {
    const wrapper = mount(Tag, {
      props: {
        label: 'Complete Tag',
        variant: 'primary',
        size: 'lg',
        removable: true,
        clickable: true,
        icon: 'star',
      },
    })

    expect(wrapper.find('.tag').classes()).toContain('bg-primary')
    expect(wrapper.find('.tag').classes()).toContain('text-base')
    expect(wrapper.find('.remove-button').exists()).toBe(true)
    expect(wrapper.findComponent({ name: 'Icon' }).exists()).toBe(true)
  })

  it('works with outlined and removable', () => {
    const wrapper = mount(Tag, {
      props: {
        label: 'Outlined Removable',
        outlined: true,
        removable: true,
        variant: 'success',
      },
    })

    const tag = wrapper.find('.tag')
    expect(tag.classes()).toContain('border-green-500')
    expect(wrapper.find('.remove-button').exists()).toBe(true)
  })

  it('works with avatar and removable', () => {
    const wrapper = mount(Tag, {
      props: {
        label: 'User',
        avatar: 'https://example.com/avatar.jpg',
        removable: true,
        variant: 'info',
      },
    })

    expect(wrapper.find('img').exists()).toBe(true)
    expect(wrapper.find('.remove-button').exists()).toBe(true)
    expect(wrapper.find('.tag').classes()).toContain('bg-blue-500')
  })
})
