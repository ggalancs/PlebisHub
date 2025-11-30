/**
 * Tests for VirtualScrollList Component
 */

import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import VirtualScrollList from './VirtualScrollList.vue'

describe('VirtualScrollList', () => {
  const generateItems = (count: number) => {
    return Array.from({ length: count }, (_, i) => ({
      id: i,
      title: `Item ${i}`,
      content: `Content for item ${i}`,
    }))
  }

  beforeEach(() => {
    // Mock IntersectionObserver if needed
    global.IntersectionObserver = class IntersectionObserver {
      observe() {}
      unobserve() {}
      disconnect() {}
    } as unknown as typeof IntersectionObserver

    // Mock ResizeObserver
    global.ResizeObserver = class ResizeObserver {
      observe() {}
      unobserve() {}
      disconnect() {}
    } as unknown as typeof ResizeObserver
  })

  it('should render with items', () => {
    const items = generateItems(100)
    const wrapper = mount(VirtualScrollList, {
      props: {
        items,
        itemHeight: 50,
        containerHeight: 400,
      },
      slots: {
        default: `
          <template #default="{ item }">
            <div class="test-item">{{ item.title }}</div>
          </template>
        `,
      },
    })

    expect(wrapper.find('.virtual-scroll-viewport').exists()).toBe(true)
  })

  it('should show empty message when no items', () => {
    const wrapper = mount(VirtualScrollList, {
      props: {
        items: [],
        itemHeight: 50,
        emptyMessage: 'No items found',
      },
    })

    expect(wrapper.text()).toContain('No items found')
  })

  it('should show loading state', () => {
    const items = generateItems(10)
    const wrapper = mount(VirtualScrollList, {
      props: {
        items,
        itemHeight: 50,
        loading: true,
      },
    })

    expect(wrapper.find('.animate-spin').exists()).toBe(true)
  })

  it('should render visible items only', async () => {
    const items = generateItems(1000)
    const wrapper = mount(VirtualScrollList, {
      props: {
        items,
        itemHeight: 50,
        containerHeight: 400,
        buffer: 2,
      },
      slots: {
        default: `
          <template #default="{ item, index }">
            <div :data-index="index">{{ item.title }}</div>
          </template>
        `,
      },
    })

    await wrapper.vm.$nextTick()

    // Should not render all 1000 items
    const renderedItems = wrapper.findAll('[data-index]')
    expect(renderedItems.length).toBeLessThan(1000)
    // Should render at least some items (visible + buffer)
    expect(renderedItems.length).toBeGreaterThan(0)
  })

  it('should show scroll controls for large lists', () => {
    const items = generateItems(100)
    const wrapper = mount(VirtualScrollList, {
      props: {
        items,
        itemHeight: 50,
      },
    })

    expect(wrapper.find('.virtual-scroll-controls').exists()).toBe(true)
    expect(wrapper.text()).toContain('Inicio')
    expect(wrapper.text()).toContain('Final')
  })

  it('should not show scroll controls for small lists', () => {
    const items = generateItems(5)
    const wrapper = mount(VirtualScrollList, {
      props: {
        items,
        itemHeight: 50,
      },
    })

    expect(wrapper.find('.virtual-scroll-controls').exists()).toBe(false)
  })

  it('should expose scroll methods', () => {
    const items = generateItems(100)
    const wrapper = mount(VirtualScrollList, {
      props: {
        items,
        itemHeight: 50,
        containerHeight: 400,
      },
    })

    expect(wrapper.vm.scrollToTop).toBeDefined()
    expect(wrapper.vm.scrollToBottom).toBeDefined()
    expect(wrapper.vm.scrollToIndex).toBeDefined()
  })

  it('should handle dynamic item heights', () => {
    const items = generateItems(50)
    const wrapper = mount(VirtualScrollList, {
      props: {
        items,
        itemHeight: (item: { id: number; title: string; content: string }) => {
          // Vary height based on content
          return item.id % 2 === 0 ? 100 : 50
        },
        containerHeight: 400,
      },
      slots: {
        default: `
          <template #default="{ item }">
            <div>{{ item.title }}</div>
          </template>
        `,
      },
    })

    expect(wrapper.find('.virtual-scroll-viewport').exists()).toBe(true)
  })

  it('should use custom empty message', () => {
    const wrapper = mount(VirtualScrollList, {
      props: {
        items: [],
        itemHeight: 50,
        emptyMessage: 'Custom empty message',
      },
    })

    expect(wrapper.text()).toContain('Custom empty message')
  })

  it('should render slot content correctly', () => {
    const items = generateItems(10)
    const wrapper = mount(VirtualScrollList, {
      props: {
        items,
        itemHeight: 50,
        containerHeight: 400,
      },
      slots: {
        default: `
          <template #default="{ item, index }">
            <div class="custom-item" :data-id="item.id">
              <h3>{{ item.title }}</h3>
              <p>Index: {{ index }}</p>
            </div>
          </template>
        `,
      },
    })

    const customItems = wrapper.findAll('.custom-item')
    expect(customItems.length).toBeGreaterThan(0)
  })
})
