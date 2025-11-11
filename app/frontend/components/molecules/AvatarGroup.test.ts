import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import AvatarGroup from './AvatarGroup.vue'
import type { AvatarGroupItem } from './AvatarGroup.vue'

const sampleItems: AvatarGroupItem[] = [
  { id: 1, name: 'Alice', src: 'https://i.pravatar.cc/40?img=1' },
  { id: 2, name: 'Bob', src: 'https://i.pravatar.cc/40?img=2' },
  { id: 3, name: 'Carol', src: 'https://i.pravatar.cc/40?img=3' },
  { id: 4, name: 'Dave', src: 'https://i.pravatar.cc/40?img=4' },
  { id: 5, name: 'Eve', src: 'https://i.pravatar.cc/40?img=5' },
  { id: 6, name: 'Frank', src: 'https://i.pravatar.cc/40?img=6' },
]

describe('AvatarGroup', () => {
  // Basic Rendering Tests
  it('renders with default props', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems },
    })
    expect(wrapper.exists()).toBe(true)
    expect(wrapper.find('.avatar-group').exists()).toBe(true)
  })

  it('renders all avatars when count is less than max', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems.slice(0, 3), max: 5 },
    })
    const avatars = wrapper.findAllComponents({ name: 'Avatar' })
    expect(avatars).toHaveLength(3)
  })

  it('renders maximum avatars when count exceeds max', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems, max: 3 },
    })
    const avatars = wrapper.findAllComponents({ name: 'Avatar' })
    expect(avatars).toHaveLength(3)
  })

  it('shows overflow counter when items exceed max', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems, max: 3 },
    })
    const overflow = wrapper.find('.bg-gray-200')
    expect(overflow.exists()).toBe(true)
    expect(overflow.text()).toBe('+3')
  })

  it('does not show overflow counter when items do not exceed max', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems.slice(0, 3), max: 5 },
    })
    const overflow = wrapper.find('.bg-gray-200')
    expect(overflow.exists()).toBe(false)
  })

  // Size Tests
  it('applies small size to avatars', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems.slice(0, 2), size: 'sm' },
    })
    const avatars = wrapper.findAllComponents({ name: 'Avatar' })
    avatars.forEach((avatar) => {
      expect(avatar.props('size')).toBe('sm')
    })
  })

  it('applies medium size to avatars', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems.slice(0, 2), size: 'md' },
    })
    const avatars = wrapper.findAllComponents({ name: 'Avatar' })
    avatars.forEach((avatar) => {
      expect(avatar.props('size')).toBe('md')
    })
  })

  it('applies large size to avatars', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems.slice(0, 2), size: 'lg' },
    })
    const avatars = wrapper.findAllComponents({ name: 'Avatar' })
    avatars.forEach((avatar) => {
      expect(avatar.props('size')).toBe('lg')
    })
  })

  it('applies xl size to avatars', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems.slice(0, 2), size: 'xl' },
    })
    const avatars = wrapper.findAllComponents({ name: 'Avatar' })
    avatars.forEach((avatar) => {
      expect(avatar.props('size')).toBe('xl')
    })
  })

  it('overflow counter has correct size classes for sm', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems, max: 2, size: 'sm' },
    })
    const overflow = wrapper.find('.bg-gray-200')
    expect(overflow.classes()).toContain('w-8')
    expect(overflow.classes()).toContain('h-8')
    expect(overflow.classes()).toContain('text-xs')
  })

  it('overflow counter has correct size classes for lg', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems, max: 2, size: 'lg' },
    })
    const overflow = wrapper.find('.bg-gray-200')
    expect(overflow.classes()).toContain('w-12')
    expect(overflow.classes()).toContain('h-12')
  })

  // Tooltip Tests
  it('shows tooltip with all names when showTooltip is true', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems.slice(0, 3), showTooltip: true },
    })
    const group = wrapper.find('.avatar-group')
    expect(group.attributes('aria-label')).toContain('Alice')
    expect(group.attributes('aria-label')).toContain('Bob')
    expect(group.attributes('aria-label')).toContain('Carol')
  })

  it('shows individual name tooltips on avatars', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems.slice(0, 2), showTooltip: true },
    })
    const avatarContainers = wrapper.findAll('[title]')
    expect(avatarContainers.length).toBeGreaterThan(0)
    expect(avatarContainers[0].attributes('title')).toBe('Alice')
  })

  it('shows overflow counter tooltip', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems, max: 3, showTooltip: true },
    })
    const overflow = wrapper.find('.bg-gray-200')
    expect(overflow.attributes('title')).toBe('+3 more')
  })

  // Accessibility Tests
  it('has correct role attribute', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems },
    })
    expect(wrapper.find('.avatar-group').attributes('role')).toBe('group')
  })

  it('has aria-label with all names when showTooltip is true', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems.slice(0, 2), showTooltip: true },
    })
    const ariaLabel = wrapper.find('.avatar-group').attributes('aria-label')
    expect(ariaLabel).toContain('Alice')
    expect(ariaLabel).toContain('Bob')
  })

  it('has default aria-label when showTooltip is false', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems, showTooltip: false },
    })
    expect(wrapper.find('.avatar-group').attributes('aria-label')).toBe('Avatar group')
  })

  // Avatar Props Tests
  it('passes correct src to avatars', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems.slice(0, 2) },
    })
    const avatars = wrapper.findAllComponents({ name: 'Avatar' })
    expect(avatars[0].props('src')).toBe('https://i.pravatar.cc/40?img=1')
    expect(avatars[1].props('src')).toBe('https://i.pravatar.cc/40?img=2')
  })

  it('passes alt text to avatars', () => {
    const items = [
      { id: 1, name: 'Alice', alt: 'Alice Avatar' },
      { id: 2, name: 'Bob', alt: 'Bob Avatar' },
    ]
    const wrapper = mount(AvatarGroup, {
      props: { items },
    })
    const avatars = wrapper.findAllComponents({ name: 'Avatar' })
    expect(avatars[0].props('alt')).toBe('Alice Avatar')
    expect(avatars[1].props('alt')).toBe('Bob Avatar')
  })

  it('uses name as alt text when alt is not provided', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems.slice(0, 1) },
    })
    const avatar = wrapper.findComponent({ name: 'Avatar' })
    expect(avatar.props('alt')).toBe('Alice')
  })

  // Styling Tests
  it('avatars have ring styling', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems.slice(0, 2) },
    })
    const avatars = wrapper.findAllComponents({ name: 'Avatar' })
    avatars.forEach((avatar) => {
      expect(avatar.classes()).toContain('ring-2')
      expect(avatar.classes()).toContain('ring-white')
    })
  })

  it('overflow counter has rounded-full class', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems, max: 2 },
    })
    const overflow = wrapper.find('.bg-gray-200')
    expect(overflow.classes()).toContain('rounded-full')
  })

  it('overflow counter has border', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems, max: 2 },
    })
    const overflow = wrapper.find('.bg-gray-200')
    expect(overflow.classes()).toContain('border-2')
    expect(overflow.classes()).toContain('border-white')
  })

  // Edge Cases
  it('handles empty items array', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: [] },
    })
    expect(wrapper.find('.avatar-group').exists()).toBe(true)
    expect(wrapper.findAllComponents({ name: 'Avatar' })).toHaveLength(0)
  })

  it('handles single item', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems.slice(0, 1) },
    })
    expect(wrapper.findAllComponents({ name: 'Avatar' })).toHaveLength(1)
    expect(wrapper.find('.bg-gray-200').exists()).toBe(false)
  })

  it('calculates correct overflow count', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems, max: 4 },
    })
    const overflow = wrapper.find('.bg-gray-200')
    expect(overflow.text()).toBe('+2')
  })

  it('handles max value of 1', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems, max: 1 },
    })
    expect(wrapper.findAllComponents({ name: 'Avatar' })).toHaveLength(1)
    const overflow = wrapper.find('.bg-gray-200')
    expect(overflow.text()).toBe('+5')
  })

  it('shows all items when max equals items length', () => {
    const wrapper = mount(AvatarGroup, {
      props: { items: sampleItems, max: 6 },
    })
    expect(wrapper.findAllComponents({ name: 'Avatar' })).toHaveLength(6)
    expect(wrapper.find('.bg-gray-200').exists()).toBe(false)
  })
})
