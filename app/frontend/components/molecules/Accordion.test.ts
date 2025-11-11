import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Accordion from './Accordion.vue'
import type { AccordionItem } from './Accordion.vue'

const sampleItems: AccordionItem[] = [
  { id: 1, title: 'Item 1', content: 'Content 1' },
  { id: 2, title: 'Item 2', content: 'Content 2' },
  { id: 3, title: 'Item 3', content: 'Content 3' },
]

describe('Accordion', () => {
  // Basic Rendering Tests
  it('renders with default props', () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems },
    })
    expect(wrapper.exists()).toBe(true)
  })

  it('renders all accordion items', () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems },
    })
    const items = wrapper.findAll('.accordion-item')
    expect(items).toHaveLength(3)
  })

  it('renders item titles correctly', () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems },
    })
    expect(wrapper.text()).toContain('Item 1')
    expect(wrapper.text()).toContain('Item 2')
    expect(wrapper.text()).toContain('Item 3')
  })

  it('does not show content by default', () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems },
    })
    expect(wrapper.text()).not.toContain('Content 1')
    expect(wrapper.text()).not.toContain('Content 2')
  })

  it('renders with empty items array', () => {
    const wrapper = mount(Accordion, {
      props: { items: [] },
    })
    expect(wrapper.exists()).toBe(true)
    expect(wrapper.findAll('.accordion-item')).toHaveLength(0)
  })

  // Variant Tests
  it('renders default variant correctly', () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems, variant: 'default' },
    })
    const container = wrapper.find('.accordion')
    expect(container.exists()).toBe(true)
  })

  it('renders bordered variant correctly', () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems, variant: 'bordered' },
    })
    const container = wrapper.find('.accordion')
    expect(container.classes()).toContain('border')
    expect(container.classes()).toContain('rounded-lg')
  })

  it('renders separated variant correctly', () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems, variant: 'separated' },
    })
    const container = wrapper.find('.accordion')
    expect(container.classes()).toContain('space-y-2')
  })

  // Interaction Tests
  it('opens item when clicked', async () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems },
    })
    const firstButton = wrapper.findAll('button')[0]
    await firstButton.trigger('click')
    expect(wrapper.text()).toContain('Content 1')
  })

  it('closes item when clicked again', async () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems },
    })
    const firstButton = wrapper.findAll('button')[0]
    await firstButton.trigger('click')
    expect(wrapper.text()).toContain('Content 1')
    await firstButton.trigger('click')
    expect(wrapper.text()).not.toContain('Content 1')
  })

  it('in single mode, closes previous item when opening new one', async () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems, multiple: false },
    })
    const buttons = wrapper.findAll('button')

    await buttons[0].trigger('click')
    expect(wrapper.text()).toContain('Content 1')

    await buttons[1].trigger('click')
    expect(wrapper.text()).not.toContain('Content 1')
    expect(wrapper.text()).toContain('Content 2')
  })

  it('in multiple mode, keeps previous items open', async () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems, multiple: true },
    })
    const buttons = wrapper.findAll('button')

    await buttons[0].trigger('click')
    expect(wrapper.text()).toContain('Content 1')

    await buttons[1].trigger('click')
    expect(wrapper.text()).toContain('Content 1')
    expect(wrapper.text()).toContain('Content 2')
  })

  it('can open all items in multiple mode', async () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems, multiple: true },
    })
    const buttons = wrapper.findAll('button')

    for (const button of buttons) {
      await button.trigger('click')
    }

    expect(wrapper.text()).toContain('Content 1')
    expect(wrapper.text()).toContain('Content 2')
    expect(wrapper.text()).toContain('Content 3')
  })

  // Model Value Tests
  it('respects initial modelValue', () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems, modelValue: [1, 2] },
    })
    expect(wrapper.text()).toContain('Content 1')
    expect(wrapper.text()).toContain('Content 2')
    expect(wrapper.text()).not.toContain('Content 3')
  })

  it('opens item specified in modelValue', () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems, modelValue: [2] },
    })
    expect(wrapper.text()).not.toContain('Content 1')
    expect(wrapper.text()).toContain('Content 2')
  })

  // Event Tests
  it('emits update:modelValue when item is opened', async () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems },
    })
    const firstButton = wrapper.findAll('button')[0]
    await firstButton.trigger('click')

    expect(wrapper.emitted('update:modelValue')).toBeTruthy()
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([[1]])
  })

  it('emits change event when item is opened', async () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems },
    })
    const firstButton = wrapper.findAll('button')[0]
    await firstButton.trigger('click')

    expect(wrapper.emitted('change')).toBeTruthy()
    expect(wrapper.emitted('change')?.[0]).toEqual([[1]])
  })

  it('emits update:modelValue when item is closed', async () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems, modelValue: [1] },
    })
    const firstButton = wrapper.findAll('button')[0]
    await firstButton.trigger('click')

    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([[]])
  })

  it('emits correct value in multiple mode', async () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems, multiple: true },
    })
    const buttons = wrapper.findAll('button')

    await buttons[0].trigger('click')
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([[1]])

    await buttons[1].trigger('click')
    expect(wrapper.emitted('update:modelValue')?.[1]).toEqual([[1, 2]])
  })

  // Disabled State Tests
  it('applies disabled styling when globally disabled', () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems, disabled: true },
    })
    const items = wrapper.findAll('.accordion-item')
    items.forEach((item) => {
      expect(item.classes()).toContain('opacity-50')
      expect(item.classes()).toContain('cursor-not-allowed')
    })
  })

  it('does not open item when globally disabled', async () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems, disabled: true },
    })
    const firstButton = wrapper.findAll('button')[0]
    await firstButton.trigger('click')

    expect(wrapper.text()).not.toContain('Content 1')
    expect(wrapper.emitted('update:modelValue')).toBeFalsy()
  })

  it('applies disabled styling to individual disabled item', () => {
    const items = [
      { id: 1, title: 'Item 1', content: 'Content 1', disabled: true },
      { id: 2, title: 'Item 2', content: 'Content 2' },
    ]
    const wrapper = mount(Accordion, {
      props: { items },
    })
    const accordionItems = wrapper.findAll('.accordion-item')

    expect(accordionItems[0].classes()).toContain('opacity-50')
    expect(accordionItems[1].classes()).not.toContain('opacity-50')
  })

  it('does not open individually disabled item', async () => {
    const items = [
      { id: 1, title: 'Item 1', content: 'Content 1', disabled: true },
      { id: 2, title: 'Item 2', content: 'Content 2' },
    ]
    const wrapper = mount(Accordion, {
      props: { items },
    })
    const buttons = wrapper.findAll('button')

    await buttons[0].trigger('click')
    expect(wrapper.text()).not.toContain('Content 1')

    await buttons[1].trigger('click')
    expect(wrapper.text()).toContain('Content 2')
  })

  // Accessibility Tests
  it('has correct ARIA attributes on buttons', () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems },
    })
    const firstButton = wrapper.findAll('button')[0]

    expect(firstButton.attributes('type')).toBe('button')
    expect(firstButton.attributes('aria-expanded')).toBe('false')
    expect(firstButton.attributes('aria-controls')).toBe('accordion-content-1')
  })

  it('updates aria-expanded when item is opened', async () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems },
    })
    const firstButton = wrapper.findAll('button')[0]

    expect(firstButton.attributes('aria-expanded')).toBe('false')

    await firstButton.trigger('click')
    expect(firstButton.attributes('aria-expanded')).toBe('true')
  })

  it('has aria-disabled on disabled buttons', () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems, disabled: true },
    })
    const buttons = wrapper.findAll('button')

    buttons.forEach((button) => {
      expect(button.attributes('aria-disabled')).toBe('true')
      expect(button.attributes('disabled')).toBe('')
    })
  })

  it('has aria-disabled on individually disabled item', () => {
    const items = [
      { id: 1, title: 'Item 1', content: 'Content 1', disabled: true },
      { id: 2, title: 'Item 2', content: 'Content 2' },
    ]
    const wrapper = mount(Accordion, {
      props: { items },
    })
    const buttons = wrapper.findAll('button')

    expect(buttons[0].attributes('aria-disabled')).toBe('true')
    expect(buttons[1].attributes('aria-disabled')).toBeUndefined()
  })

  it('content has correct role and aria-labelledby', async () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems },
    })
    const firstButton = wrapper.findAll('button')[0]
    await firstButton.trigger('click')

    const content = wrapper.find('#accordion-content-1')
    expect(content.attributes('role')).toBe('region')
    expect(content.attributes('aria-labelledby')).toBe('accordion-header-1')
  })

  // Slot Tests
  it('renders custom title slot content', () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems },
      slots: {
        title: '<strong>Custom Title</strong>',
      },
    })
    expect(wrapper.html()).toContain('<strong>Custom Title</strong>')
  })

  it('renders custom content slot', async () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems },
      slots: {
        content: '<div class="custom-content">Custom Content</div>',
      },
    })
    const firstButton = wrapper.findAll('button')[0]
    await firstButton.trigger('click')

    expect(wrapper.html()).toContain('custom-content')
    expect(wrapper.text()).toContain('Custom Content')
  })

  it('renders custom icon slot', () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems },
      slots: {
        icon: '<span class="custom-icon">+</span>',
      },
    })
    expect(wrapper.html()).toContain('custom-icon')
    expect(wrapper.text()).toContain('+')
  })

  it('passes correct slot props to title slot', () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems, modelValue: [1] },
      slots: {
        title: '<span class="custom-title">Custom Title Slot</span>',
      },
    })
    // Verify custom title slot is rendered
    expect(wrapper.html()).toContain('custom-title')
    expect(wrapper.text()).toContain('Custom Title Slot')
  })

  // Icon Rotation Tests
  it('rotates icon when item is open', async () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems },
    })
    const firstButton = wrapper.findAll('button')[0]
    const icon = firstButton.findComponent({ name: 'Icon' })

    expect(icon.classes()).not.toContain('rotate-180')

    await firstButton.trigger('click')
    expect(icon.classes()).toContain('rotate-180')
  })

  it('removes rotation when item is closed', async () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems, modelValue: [1] },
    })
    const firstButton = wrapper.findAll('button')[0]
    const icon = firstButton.findComponent({ name: 'Icon' })

    expect(icon.classes()).toContain('rotate-180')

    await firstButton.trigger('click')
    expect(icon.classes()).not.toContain('rotate-180')
  })

  // Edge Cases
  it('handles items without content gracefully', async () => {
    const items = [{ id: 1, title: 'Item 1' }]
    const wrapper = mount(Accordion, {
      props: { items },
    })
    const firstButton = wrapper.findAll('button')[0]
    await firstButton.trigger('click')

    expect(wrapper.find('#accordion-content-1').exists()).toBe(true)
  })

  it('handles string and number IDs correctly', async () => {
    const items = [
      { id: 'string-id', title: 'String ID', content: 'Content A' },
      { id: 999, title: 'Number ID', content: 'Content B' },
    ]
    const wrapper = mount(Accordion, {
      props: { items },
    })
    const buttons = wrapper.findAll('button')

    await buttons[0].trigger('click')
    expect(wrapper.text()).toContain('Content A')

    await buttons[1].trigger('click')
    expect(wrapper.text()).toContain('Content B')
  })

  it('handles modelValue with string IDs', () => {
    const items = [
      { id: 'a', title: 'Item A', content: 'Content A' },
      { id: 'b', title: 'Item B', content: 'Content B' },
    ]
    const wrapper = mount(Accordion, {
      props: { items, modelValue: ['a'] },
    })
    expect(wrapper.text()).toContain('Content A')
    expect(wrapper.text()).not.toContain('Content B')
  })

  // Combination Tests
  it('works correctly with multiple and disabled combined', async () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems, multiple: true, disabled: false },
    })
    const buttons = wrapper.findAll('button')

    await buttons[0].trigger('click')
    await buttons[1].trigger('click')

    expect(wrapper.text()).toContain('Content 1')
    expect(wrapper.text()).toContain('Content 2')
  })

  it('works with separated variant and multiple items open', async () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems, variant: 'separated', multiple: true },
    })
    const buttons = wrapper.findAll('button')

    await buttons[0].trigger('click')
    await buttons[2].trigger('click')

    expect(wrapper.text()).toContain('Content 1')
    expect(wrapper.text()).toContain('Content 3')
  })

  it('maintains state when switching between items in single mode', async () => {
    const wrapper = mount(Accordion, {
      props: { items: sampleItems, multiple: false },
    })
    const buttons = wrapper.findAll('button')

    // Open first item
    await buttons[0].trigger('click')
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([[1]])

    // Open second item (should close first)
    await buttons[1].trigger('click')
    expect(wrapper.emitted('update:modelValue')?.[1]).toEqual([[2]])

    // Open third item (should close second)
    await buttons[2].trigger('click')
    expect(wrapper.emitted('update:modelValue')?.[2]).toEqual([[3]])
  })
})
