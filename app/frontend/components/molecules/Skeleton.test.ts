import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Skeleton from './Skeleton.vue'

describe('Skeleton', () => {
  // Basic Rendering Tests
  it('renders with default props', () => {
    const wrapper = mount(Skeleton)
    expect(wrapper.exists()).toBe(true)
    expect(wrapper.find('.skeleton').exists()).toBe(true)
  })

  it('shows skeleton when loading is true', () => {
    const wrapper = mount(Skeleton, {
      props: { loading: true },
    })
    expect(wrapper.find('.skeleton').exists()).toBe(true)
  })

  it('shows slot content when loading is false', () => {
    const wrapper = mount(Skeleton, {
      props: { loading: false },
      slots: {
        default: '<div class="content">Loaded Content</div>',
      },
    })
    expect(wrapper.find('.skeleton').exists()).toBe(false)
    expect(wrapper.find('.content').exists()).toBe(true)
    expect(wrapper.text()).toContain('Loaded Content')
  })

  it('hides slot content when loading is true', () => {
    const wrapper = mount(Skeleton, {
      props: { loading: true },
      slots: {
        default: '<div class="content">Content</div>',
      },
    })
    expect(wrapper.find('.skeleton').exists()).toBe(true)
    expect(wrapper.find('.content').exists()).toBe(false)
  })

  // Variant Tests
  it('renders rectangle variant by default', () => {
    const wrapper = mount(Skeleton)
    const skeleton = wrapper.find('.skeleton')
    expect(skeleton.classes()).toContain('rounded')
    expect(skeleton.classes()).not.toContain('rounded-full')
  })

  it('renders rectangle variant correctly', () => {
    const wrapper = mount(Skeleton, {
      props: { variant: 'rectangle' },
    })
    const skeleton = wrapper.find('.skeleton')
    expect(skeleton.classes()).toContain('rounded')
  })

  it('renders circle variant correctly', () => {
    const wrapper = mount(Skeleton, {
      props: { variant: 'circle' },
    })
    const skeleton = wrapper.find('.skeleton')
    expect(skeleton.classes()).toContain('rounded-full')
  })

  it('renders text variant correctly', () => {
    const wrapper = mount(Skeleton, {
      props: { variant: 'text' },
    })
    const skeleton = wrapper.find('.skeleton')
    expect(skeleton.classes()).toContain('rounded')
    expect(skeleton.classes()).toContain('h-4')
  })

  // Width and Height Tests
  it('applies width as number (pixels)', () => {
    const wrapper = mount(Skeleton, {
      props: { width: 200 },
    })
    const skeleton = wrapper.find('.skeleton')
    expect(skeleton.attributes('style')).toContain('width: 200px')
  })

  it('applies width as string', () => {
    const wrapper = mount(Skeleton, {
      props: { width: '50%' },
    })
    const skeleton = wrapper.find('.skeleton')
    expect(skeleton.attributes('style')).toContain('width: 50%')
  })

  it('applies height as number (pixels)', () => {
    const wrapper = mount(Skeleton, {
      props: { height: 100 },
    })
    const skeleton = wrapper.find('.skeleton')
    expect(skeleton.attributes('style')).toContain('height: 100px')
  })

  it('applies height as string', () => {
    const wrapper = mount(Skeleton, {
      props: { height: '2rem' },
    })
    const skeleton = wrapper.find('.skeleton')
    expect(skeleton.attributes('style')).toContain('height: 2rem')
  })

  it('applies both width and height', () => {
    const wrapper = mount(Skeleton, {
      props: { width: 200, height: 100 },
    })
    const skeleton = wrapper.find('.skeleton')
    const style = skeleton.attributes('style') || ''
    expect(style).toContain('width: 200px')
    expect(style).toContain('height: 100px')
  })

  it('sets width equal to height for circle when only height is provided', () => {
    const wrapper = mount(Skeleton, {
      props: { variant: 'circle', height: 50 },
    })
    const skeleton = wrapper.find('.skeleton')
    const style = skeleton.attributes('style') || ''
    expect(style).toContain('width: 50px')
    expect(style).toContain('height: 50px')
  })

  it('sets height equal to width for circle when only width is provided', () => {
    const wrapper = mount(Skeleton, {
      props: { variant: 'circle', width: 50 },
    })
    const skeleton = wrapper.find('.skeleton')
    const style = skeleton.attributes('style') || ''
    expect(style).toContain('width: 50px')
    expect(style).toContain('height: 50px')
  })

  // Text Lines Tests
  it('renders single text line by default', () => {
    const wrapper = mount(Skeleton, {
      props: { variant: 'text' },
    })
    const skeletons = wrapper.findAll('.skeleton')
    expect(skeletons).toHaveLength(1)
  })

  it('renders multiple text lines', () => {
    const wrapper = mount(Skeleton, {
      props: { variant: 'text', lines: 3 },
    })
    const skeletons = wrapper.findAll('.skeleton')
    expect(skeletons).toHaveLength(3)
  })

  it('last text line is shorter than others', () => {
    const wrapper = mount(Skeleton, {
      props: { variant: 'text', lines: 3 },
    })
    const skeletons = wrapper.findAll('.skeleton')
    const lastLine = skeletons[2]
    const firstLine = skeletons[0]

    expect(lastLine.attributes('style')).toContain('width: 70%')
    expect(firstLine.attributes('style')).toContain('width: 100%')
  })

  it('single text line has 100% width', () => {
    const wrapper = mount(Skeleton, {
      props: { variant: 'text', lines: 1 },
    })
    const skeleton = wrapper.find('.skeleton')
    expect(skeleton.attributes('style')).toContain('width: 100%')
  })

  it('adds margin between text lines', () => {
    const wrapper = mount(Skeleton, {
      props: { variant: 'text', lines: 3 },
    })
    const skeletons = wrapper.findAll('.skeleton')

    // First two lines should have margin-bottom
    expect(skeletons[0].attributes('style')).toContain('margin-bottom: 0.5rem')
    expect(skeletons[1].attributes('style')).toContain('margin-bottom: 0.5rem')

    // Last line should not have margin-bottom
    expect(skeletons[2].attributes('style')).toContain('margin-bottom: 0')
  })

  // Animation Tests
  it('applies pulse animation by default', () => {
    const wrapper = mount(Skeleton)
    const skeleton = wrapper.find('.skeleton')
    expect(skeleton.classes()).toContain('animate-pulse')
  })

  it('applies pulse animation correctly', () => {
    const wrapper = mount(Skeleton, {
      props: { animation: 'pulse' },
    })
    const skeleton = wrapper.find('.skeleton')
    expect(skeleton.classes()).toContain('animate-pulse')
    expect(skeleton.classes()).not.toContain('skeleton-wave')
  })

  it('applies wave animation correctly', () => {
    const wrapper = mount(Skeleton, {
      props: { animation: 'wave' },
    })
    const skeleton = wrapper.find('.skeleton')
    expect(skeleton.classes()).toContain('skeleton-wave')
    expect(skeleton.classes()).not.toContain('animate-pulse')
  })

  it('applies no animation when animation is none', () => {
    const wrapper = mount(Skeleton, {
      props: { animation: 'none' },
    })
    const skeleton = wrapper.find('.skeleton')
    expect(skeleton.classes()).not.toContain('animate-pulse')
    expect(skeleton.classes()).not.toContain('skeleton-wave')
  })

  // Base Styling Tests
  it('has base skeleton classes', () => {
    const wrapper = mount(Skeleton)
    const skeleton = wrapper.find('.skeleton')
    expect(skeleton.classes()).toContain('skeleton')
    expect(skeleton.classes()).toContain('bg-gray-200')
  })

  // Edge Cases
  it('renders with no dimensions specified', () => {
    const wrapper = mount(Skeleton)
    const skeleton = wrapper.find('.skeleton')
    expect(skeleton.exists()).toBe(true)
    // Should have no width/height in style
    const style = skeleton.attributes('style')
    expect(style).toBeFalsy()
  })

  it('handles zero lines for text variant', () => {
    const wrapper = mount(Skeleton, {
      props: { variant: 'text', lines: 0 },
    })
    const skeletons = wrapper.findAll('.skeleton')
    expect(skeletons).toHaveLength(0)
  })

  it('renders with string dimensions using different units', () => {
    const wrapper = mount(Skeleton, {
      props: { width: '10rem', height: '5em' },
    })
    const skeleton = wrapper.find('.skeleton')
    const style = skeleton.attributes('style') || ''
    expect(style).toContain('width: 10rem')
    expect(style).toContain('height: 5em')
  })

  // Combination Tests
  it('works with circle variant and custom dimensions', () => {
    const wrapper = mount(Skeleton, {
      props: { variant: 'circle', width: 60, height: 60 },
    })
    const skeleton = wrapper.find('.skeleton')
    expect(skeleton.classes()).toContain('rounded-full')
    const style = skeleton.attributes('style') || ''
    expect(style).toContain('width: 60px')
    expect(style).toContain('height: 60px')
  })

  it('works with text variant and wave animation', () => {
    const wrapper = mount(Skeleton, {
      props: { variant: 'text', lines: 2, animation: 'wave' },
    })
    const skeletons = wrapper.findAll('.skeleton')
    expect(skeletons).toHaveLength(2)
    expect(skeletons[0].classes()).toContain('skeleton-wave')
  })

  it('works with rectangle and custom dimensions', () => {
    const wrapper = mount(Skeleton, {
      props: { variant: 'rectangle', width: '100%', height: 200 },
    })
    const skeleton = wrapper.find('.skeleton')
    expect(skeleton.classes()).toContain('rounded')
    const style = skeleton.attributes('style') || ''
    expect(style).toContain('width: 100%')
    expect(style).toContain('height: 200px')
  })

  // Reactivity Tests
  it('updates when loading prop changes', async () => {
    const wrapper = mount(Skeleton, {
      props: { loading: true },
      slots: {
        default: '<div class="content">Content</div>',
      },
    })

    expect(wrapper.find('.skeleton').exists()).toBe(true)
    expect(wrapper.find('.content').exists()).toBe(false)

    await wrapper.setProps({ loading: false })

    expect(wrapper.find('.skeleton').exists()).toBe(false)
    expect(wrapper.find('.content').exists()).toBe(true)
  })

  it('updates when variant changes', async () => {
    const wrapper = mount(Skeleton, {
      props: { variant: 'rectangle' },
    })

    expect(wrapper.find('.skeleton').classes()).toContain('rounded')
    expect(wrapper.find('.skeleton').classes()).not.toContain('rounded-full')

    await wrapper.setProps({ variant: 'circle' })

    expect(wrapper.find('.skeleton').classes()).toContain('rounded-full')
  })

  it('updates when lines change', async () => {
    const wrapper = mount(Skeleton, {
      props: { variant: 'text', lines: 2 },
    })

    expect(wrapper.findAll('.skeleton')).toHaveLength(2)

    await wrapper.setProps({ lines: 4 })

    expect(wrapper.findAll('.skeleton')).toHaveLength(4)
  })

  // Slot Tests
  it('renders slot content correctly when not loading', () => {
    const wrapper = mount(Skeleton, {
      props: { loading: false },
      slots: {
        default: '<div><h1>Title</h1><p>Description</p></div>',
      },
    })

    expect(wrapper.html()).toContain('<h1>Title</h1>')
    expect(wrapper.html()).toContain('<p>Description</p>')
  })

  it('works with complex slot content', () => {
    const wrapper = mount(Skeleton, {
      props: { loading: false },
      slots: {
        default: `
          <div class="card">
            <img src="test.jpg" alt="test" />
            <div class="content">
              <h2>Card Title</h2>
              <p>Card description</p>
            </div>
          </div>
        `,
      },
    })

    expect(wrapper.find('.card').exists()).toBe(true)
    expect(wrapper.text()).toContain('Card Title')
  })
})
