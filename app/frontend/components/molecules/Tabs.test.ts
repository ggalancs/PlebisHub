import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Tabs from './Tabs.vue'
import TabPanel from './TabPanel.vue'

describe('Tabs', () => {
  const defaultItems = [
    { key: 'tab1', label: 'Tab 1' },
    { key: 'tab2', label: 'Tab 2' },
    { key: 'tab3', label: 'Tab 3' },
  ]

  describe('rendering', () => {
    it('renders tab list', () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems },
      })

      expect(wrapper.find('[role="tablist"]').exists()).toBe(true)
    })

    it('renders all tab buttons', () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems },
      })

      const tabs = wrapper.findAll('[role="tab"]')
      expect(tabs.length).toBe(3)
    })

    it('renders tab labels', () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems },
      })

      expect(wrapper.text()).toContain('Tab 1')
      expect(wrapper.text()).toContain('Tab 2')
      expect(wrapper.text()).toContain('Tab 3')
    })

    it('sets first tab as active by default', () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems },
      })

      const tabs = wrapper.findAll('[role="tab"]')
      expect(tabs[0].attributes('aria-selected')).toBe('true')
      expect(tabs[1].attributes('aria-selected')).toBe('false')
      expect(tabs[2].attributes('aria-selected')).toBe('false')
    })

    it('renders with specified active tab', () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems, modelValue: 'tab2' },
      })

      const tabs = wrapper.findAll('[role="tab"]')
      expect(tabs[0].attributes('aria-selected')).toBe('false')
      expect(tabs[1].attributes('aria-selected')).toBe('true')
      expect(tabs[2].attributes('aria-selected')).toBe('false')
    })

    it('renders tab icons', () => {
      const itemsWithIcons = [
        { key: 'home', label: 'Home', icon: 'home' },
        { key: 'settings', label: 'Settings', icon: 'settings' },
      ]

      const wrapper = mount(Tabs, {
        props: { items: itemsWithIcons },
      })

      const icons = wrapper.findAllComponents({ name: 'Icon' })
      expect(icons.length).toBeGreaterThanOrEqual(2)
    })

    it('renders tab badges', () => {
      const itemsWithBadges = [
        { key: 'inbox', label: 'Inbox', badge: 5 },
        { key: 'sent', label: 'Sent', badge: '10+' },
      ]

      const wrapper = mount(Tabs, {
        props: { items: itemsWithBadges },
      })

      expect(wrapper.text()).toContain('5')
      expect(wrapper.text()).toContain('10+')
    })
  })

  describe('variants', () => {
    it('renders underline variant by default', () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems },
      })

      const tabList = wrapper.find('[role="tablist"]')
      expect(tabList.classes()).toContain('border-b')
    })

    it('renders pills variant', () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems, variant: 'pills' },
      })

      const tabs = wrapper.findAll('[role="tab"]')
      expect(tabs[0].classes()).toContain('rounded-md')
    })

    it('renders cards variant', () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems, variant: 'cards' },
      })

      const tabs = wrapper.findAll('[role="tab"]')
      expect(tabs[0].classes()).toContain('rounded-t-md')
      expect(tabs[0].classes()).toContain('border')
    })
  })

  describe('sizes', () => {
    it('renders small size', () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems, size: 'sm' },
      })

      const tab = wrapper.find('[role="tab"]')
      expect(tab.classes()).toContain('text-sm')
    })

    it('renders medium size by default', () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems },
      })

      const tab = wrapper.find('[role="tab"]')
      expect(tab.classes()).toContain('text-base')
    })

    it('renders large size', () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems, size: 'lg' },
      })

      const tab = wrapper.find('[role="tab"]')
      expect(tab.classes()).toContain('text-lg')
    })
  })

  describe('full width', () => {
    it('renders full width tabs', () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems, fullWidth: true },
      })

      const tabs = wrapper.findAll('[role="tab"]')
      tabs.forEach((tab) => {
        expect(tab.classes()).toContain('flex-1')
      })
    })

    it('does not render full width by default', () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems },
      })

      const tabs = wrapper.findAll('[role="tab"]')
      expect(tabs[0].classes()).not.toContain('flex-1')
    })
  })

  describe('vertical orientation', () => {
    it('renders vertical tabs', () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems, vertical: true },
      })

      const tabList = wrapper.find('[role="tablist"]')
      expect(tabList.attributes('aria-orientation')).toBe('vertical')
      expect(tabList.classes()).toContain('flex-col')
    })

    it('renders horizontal by default', () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems },
      })

      const tabList = wrapper.find('[role="tablist"]')
      expect(tabList.attributes('aria-orientation')).toBe('horizontal')
    })
  })

  describe('disabled tabs', () => {
    it('renders disabled tabs', () => {
      const items = [
        { key: 'tab1', label: 'Tab 1' },
        { key: 'tab2', label: 'Tab 2', disabled: true },
      ]

      const wrapper = mount(Tabs, {
        props: { items },
      })

      const tabs = wrapper.findAll('[role="tab"]')
      expect(tabs[1].attributes('aria-disabled')).toBe('true')
      expect(tabs[1].classes()).toContain('cursor-not-allowed')
    })

    it('does not allow clicking disabled tabs', async () => {
      const items = [
        { key: 'tab1', label: 'Tab 1' },
        { key: 'tab2', label: 'Tab 2', disabled: true },
      ]

      const wrapper = mount(Tabs, {
        props: { items, modelValue: 'tab1' },
      })

      const tabs = wrapper.findAll('[role="tab"]')
      await tabs[1].trigger('click')

      // Active tab should still be tab1
      expect(tabs[0].attributes('aria-selected')).toBe('true')
      expect(tabs[1].attributes('aria-selected')).toBe('false')
    })
  })

  describe('behavior', () => {
    it('changes active tab on click', async () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems, modelValue: 'tab1' },
      })

      const tabs = wrapper.findAll('[role="tab"]')
      await tabs[1].trigger('click')

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['tab2'])
    })

    it('emits tab-change event', async () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems, modelValue: 'tab1' },
      })

      const tabs = wrapper.findAll('[role="tab"]')
      await tabs[2].trigger('click')

      expect(wrapper.emitted('tab-change')).toBeTruthy()
      expect(wrapper.emitted('tab-change')?.[0]).toEqual(['tab3'])
    })

    it('does not change tab when clicking the active tab', async () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems, modelValue: 'tab1' },
      })

      const tabs = wrapper.findAll('[role="tab"]')
      await tabs[0].trigger('click')

      // Should still emit the events
      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['tab1'])
    })
  })

  describe('accessibility', () => {
    it('has proper ARIA roles', () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems },
      })

      expect(wrapper.find('[role="tablist"]').exists()).toBe(true)
      expect(wrapper.findAll('[role="tab"]').length).toBe(3)
    })

    it('sets aria-selected correctly', () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems, modelValue: 'tab2' },
      })

      const tabs = wrapper.findAll('[role="tab"]')
      expect(tabs[0].attributes('aria-selected')).toBe('false')
      expect(tabs[1].attributes('aria-selected')).toBe('true')
      expect(tabs[2].attributes('aria-selected')).toBe('false')
    })

    it('sets aria-controls for each tab', () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems },
      })

      const tabs = wrapper.findAll('[role="tab"]')
      expect(tabs[0].attributes('aria-controls')).toBe('panel-tab1')
      expect(tabs[1].attributes('aria-controls')).toBe('panel-tab2')
      expect(tabs[2].attributes('aria-controls')).toBe('panel-tab3')
    })

    it('sets tabindex correctly', () => {
      const wrapper = mount(Tabs, {
        props: { items: defaultItems, modelValue: 'tab2' },
      })

      const tabs = wrapper.findAll('[role="tab"]')
      expect(tabs[0].attributes('tabindex')).toBe('-1')
      expect(tabs[1].attributes('tabindex')).toBe('0')
      expect(tabs[2].attributes('tabindex')).toBe('-1')
    })
  })

  describe('with TabPanel', () => {
    it('shows active panel', () => {
      const wrapper = mount({
        components: { Tabs, TabPanel },
        template: `
          <Tabs :items="items" v-model="activeTab">
            <TabPanel tab-key="tab1">Content 1</TabPanel>
            <TabPanel tab-key="tab2">Content 2</TabPanel>
          </Tabs>
        `,
        data() {
          return {
            activeTab: 'tab1',
            items: [
              { key: 'tab1', label: 'Tab 1' },
              { key: 'tab2', label: 'Tab 2' },
            ],
          }
        },
      })

      const panels = wrapper.findAll('[role="tabpanel"]')
      expect(panels[0].attributes('hidden')).toBeUndefined()
      expect(panels[1].attributes('hidden')).toBe('')
    })

    it('switches panels when tab changes', async () => {
      const wrapper = mount({
        components: { Tabs, TabPanel },
        template: `
          <Tabs :items="items" v-model="activeTab">
            <TabPanel tab-key="tab1">Content 1</TabPanel>
            <TabPanel tab-key="tab2">Content 2</TabPanel>
          </Tabs>
        `,
        data() {
          return {
            activeTab: 'tab1',
            items: [
              { key: 'tab1', label: 'Tab 1' },
              { key: 'tab2', label: 'Tab 2' },
            ],
          }
        },
      })

      const tabs = wrapper.findAll('[role="tab"]')
      await tabs[1].trigger('click')
      await wrapper.vm.$nextTick()

      const panels = wrapper.findAll('[role="tabpanel"]')
      expect(panels[0].attributes('hidden')).toBe('')
      expect(panels[1].attributes('hidden')).toBeUndefined()
    })

    it('hides inactive panels', () => {
      const wrapper = mount({
        components: { Tabs, TabPanel },
        template: `
          <Tabs :items="items" model-value="tab1">
            <TabPanel tab-key="tab1">Content 1</TabPanel>
            <TabPanel tab-key="tab2">Content 2</TabPanel>
          </Tabs>
        `,
        data() {
          return {
            items: [
              { key: 'tab1', label: 'Tab 1' },
              { key: 'tab2', label: 'Tab 2' },
            ],
          }
        },
      })

      const panels = wrapper.findAll('[role="tabpanel"]')
      expect(panels[0].attributes('hidden')).toBeUndefined()
      expect(panels[1].attributes('hidden')).toBe('')
    })
  })

  describe('lazy loading', () => {
    it('does not render unvisited panels when lazy is true', () => {
      const wrapper = mount({
        components: { Tabs, TabPanel },
        template: `
          <Tabs :items="items" model-value="tab1" :lazy="true">
            <TabPanel tab-key="tab1">Content 1</TabPanel>
            <TabPanel tab-key="tab2">Content 2</TabPanel>
            <TabPanel tab-key="tab3">Content 3</TabPanel>
          </Tabs>
        `,
        data() {
          return {
            items: [
              { key: 'tab1', label: 'Tab 1' },
              { key: 'tab2', label: 'Tab 2' },
              { key: 'tab3', label: 'Tab 3' },
            ],
          }
        },
      })

      // Only active panel should be in DOM
      const panels = wrapper.findAll('[role="tabpanel"]')
      expect(panels.length).toBe(1)
    })

    it('renders all panels when lazy is false', () => {
      const wrapper = mount({
        components: { Tabs, TabPanel },
        template: `
          <Tabs :items="items" model-value="tab1" :lazy="false">
            <TabPanel tab-key="tab1">Content 1</TabPanel>
            <TabPanel tab-key="tab2">Content 2</TabPanel>
            <TabPanel tab-key="tab3">Content 3</TabPanel>
          </Tabs>
        `,
        data() {
          return {
            items: [
              { key: 'tab1', label: 'Tab 1' },
              { key: 'tab2', label: 'Tab 2' },
              { key: 'tab3', label: 'Tab 3' },
            ],
          }
        },
      })

      const panels = wrapper.findAll('[role="tabpanel"]')
      expect(panels.length).toBe(3)
    })

    it('loads panel once visited and keeps it loaded', async () => {
      const wrapper = mount({
        components: { Tabs, TabPanel },
        template: `
          <Tabs :items="items" v-model="activeTab" :lazy="true">
            <TabPanel tab-key="tab1">Content 1</TabPanel>
            <TabPanel tab-key="tab2">Content 2</TabPanel>
          </Tabs>
        `,
        data() {
          return {
            activeTab: 'tab1',
            items: [
              { key: 'tab1', label: 'Tab 1' },
              { key: 'tab2', label: 'Tab 2' },
            ],
          }
        },
      })

      // Initially only tab1 panel
      expect(wrapper.findAll('[role="tabpanel"]').length).toBe(1)

      // Click tab2
      const tabs = wrapper.findAll('[role="tab"]')
      await tabs[1].trigger('click')
      await wrapper.vm.$nextTick()

      // Now both panels should exist (tab2 is now loaded)
      expect(wrapper.findAll('[role="tabpanel"]').length).toBe(2)

      // Go back to tab1
      await tabs[0].trigger('click')
      await wrapper.vm.$nextTick()

      // Both panels should still exist
      expect(wrapper.findAll('[role="tabpanel"]').length).toBe(2)
    })
  })

  describe('combinations', () => {
    it('renders with all features', () => {
      const items = [
        { key: 'home', label: 'Home', icon: 'home', badge: 5 },
        { key: 'profile', label: 'Profile', icon: 'user', disabled: true },
        {
          key: 'settings',
          label: 'Settings',
          icon: 'settings',
          badge: '2',
          badgeVariant: 'danger' as const,
        },
      ]

      const wrapper = mount(Tabs, {
        props: {
          items,
          modelValue: 'home',
          variant: 'pills',
          size: 'lg',
          fullWidth: true,
        },
      })

      expect(wrapper.find('[role="tablist"]').exists()).toBe(true)
      expect(wrapper.findAll('[role="tab"]').length).toBe(3)
    })

    it('works with minimal props', () => {
      const items = [{ key: 'tab1', label: 'Tab 1' }]

      const wrapper = mount(Tabs, {
        props: { items },
      })

      expect(wrapper.find('[role="tablist"]').exists()).toBe(true)
      expect(wrapper.findAll('[role="tab"]').length).toBe(1)
    })
  })
})
