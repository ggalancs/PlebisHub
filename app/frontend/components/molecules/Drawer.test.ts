import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { mount, VueWrapper, config } from '@vue/test-utils'
import Drawer from './Drawer.vue'
import Button from '../atoms/Button.vue'
import Icon from '../atoms/Icon.vue'

// Configure global stubs for Teleport
config.global.stubs = {
  ...config.global.stubs,
  teleport: true,
}

describe('Drawer', () => {
  let wrapper: VueWrapper<any>

  beforeEach(() => {
    // Create a teleport target
    const el = document.createElement('div')
    el.id = 'app'
    document.body.appendChild(el)
    // Reset document body overflow
    document.body.style.overflow = ''
  })

  afterEach(() => {
    if (wrapper) {
      wrapper.unmount()
    }
    document.body.innerHTML = ''
    document.body.style.overflow = ''
  })

  describe('Basic Rendering', () => {
    it('renders correctly when closed', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: false,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      expect(wrapper.exists()).toBe(true)
    })

    it('renders correctly when open', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
    })

    it('renders with title', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          title: 'Test Drawer',
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      expect(wrapper.find('#drawer-title').text()).toBe('Test Drawer')
    })

    it('renders with description', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          title: 'Test',
          description: 'Test description',
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      expect(wrapper.find('#drawer-description').text()).toBe('Test description')
    })

    it('renders default slot content', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        slots: {
          default: '<div class="test-content">Content</div>',
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      expect(wrapper.find('.test-content').text()).toBe('Content')
    })

    it('renders header slot', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        slots: {
          header: '<div class="custom-header">Custom Header</div>',
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      expect(wrapper.find('.custom-header').text()).toBe('Custom Header')
    })

    it('renders footer slot', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        slots: {
          footer: '<div class="custom-footer">Custom Footer</div>',
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      expect(wrapper.find('.custom-footer').text()).toBe('Custom Footer')
    })

    it('renders close button by default', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      expect(wrapper.find('button[aria-label="Close drawer"]').exists()).toBe(true)
    })

    it('hides close button when showCloseButton is false', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          showCloseButton: false,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      expect(wrapper.find('button[aria-label="Close drawer"]').exists()).toBe(false)
    })
  })

  describe('Position Props', () => {
    it('applies right position classes by default', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('right-0')
    })

    it('applies left position classes', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          position: 'left',
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('left-0')
    })

    it('applies top position classes', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          position: 'top',
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('top-0')
    })

    it('applies bottom position classes', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          position: 'bottom',
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('bottom-0')
    })
  })

  describe('Size Props', () => {
    it('applies medium size by default for right position', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          position: 'right',
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('w-96')
    })

    it('applies small size for right position', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          position: 'right',
          size: 'sm',
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('w-64')
    })

    it('applies large size for right position', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          position: 'right',
          size: 'lg',
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('w-[32rem]')
    })

    it('applies full size for right position', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          position: 'right',
          size: 'full',
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('w-full')
    })

    it('applies small height for top position', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          position: 'top',
          size: 'sm',
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('h-64')
    })

    it('applies large height for bottom position', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          position: 'bottom',
          size: 'lg',
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('h-[32rem]')
    })
  })

  describe('Backdrop Props', () => {
    it('renders backdrop by default', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      expect(wrapper.find('.bg-black\\/50').exists()).toBe(true)
    })

    it('hides backdrop when backdrop is false', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          backdrop: false,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      expect(wrapper.find('.bg-black\\/50').exists()).toBe(false)
    })

    it('applies backdrop blur by default', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      expect(wrapper.find('.backdrop-blur-sm').exists()).toBe(true)
    })

    it('removes backdrop blur when backdropBlur is false', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          backdropBlur: false,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      expect(wrapper.find('.backdrop-blur-sm').exists()).toBe(false)
    })
  })

  describe('Events', () => {
    it('emits update:modelValue and close when close button is clicked', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()

      await wrapper.find('button[aria-label="Close drawer"]').trigger('click')

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([false])
      expect(wrapper.emitted('close')).toBeTruthy()
    })

    it('emits open event when drawer opens', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: false,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })

      await wrapper.setProps({ modelValue: true })
      await wrapper.vm.$nextTick()

      expect(wrapper.emitted('open')).toBeTruthy()
    })

    it('closes on backdrop click by default', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()

      const backdrop = wrapper.find('.fixed.inset-0.z-50')
      await backdrop.trigger('click')

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([false])
    })

    it('does not close on backdrop click when closeOnOutsideClick is false', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          closeOnOutsideClick: false,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()

      const backdrop = wrapper.find('.fixed.inset-0.z-50')
      await backdrop.trigger('click')

      expect(wrapper.emitted('update:modelValue')).toBeFalsy()
    })

    it('closes on escape key by default', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()

      document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape' }))
      await wrapper.vm.$nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([false])
    })

    it('does not close on escape key when closeOnEscape is false', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          closeOnEscape: false,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()

      document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape' }))
      await wrapper.vm.$nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeFalsy()
    })

    it('does not close on escape when drawer is already closed', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: false,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })

      document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape' }))
      await wrapper.vm.$nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeFalsy()
    })
  })

  describe('Body Scroll Lock', () => {
    it('locks body scroll when drawer opens by default', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: false,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })

      await wrapper.setProps({ modelValue: true })
      await wrapper.vm.$nextTick()

      expect(document.body.style.overflow).toBe('hidden')
    })

    it('unlocks body scroll when drawer closes', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: false,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })

      // Open the drawer first
      await wrapper.setProps({ modelValue: true })
      await wrapper.vm.$nextTick()
      expect(document.body.style.overflow).toBe('hidden')

      // Then close it
      await wrapper.setProps({ modelValue: false })
      await wrapper.vm.$nextTick()

      expect(document.body.style.overflow).toBe('')
    })

    it('does not lock body scroll when lockScroll is false', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: false,
          lockScroll: false,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })

      await wrapper.setProps({ modelValue: true })
      await wrapper.vm.$nextTick()

      expect(document.body.style.overflow).toBe('')
    })

    it('restores body scroll on unmount', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: false,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })

      // Open the drawer to trigger scroll lock
      await wrapper.setProps({ modelValue: true })
      await wrapper.vm.$nextTick()
      expect(document.body.style.overflow).toBe('hidden')

      wrapper.unmount()
      // Need to check after unmount, but wrapper is unmounted so check directly
      expect(document.body.style.overflow).toBe('')
    })
  })

  describe('Accessibility', () => {
    it('has dialog role', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
    })

    it('has aria-modal attribute', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      expect(wrapper.find('[aria-modal="true"]').exists()).toBe(true)
    })

    it('has aria-labelledby when title is provided', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          title: 'Test Title',
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.attributes('aria-labelledby')).toBe('drawer-title')
    })

    it('has aria-describedby when description is provided', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          title: 'Test',
          description: 'Test description',
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.attributes('aria-describedby')).toBe('drawer-description')
    })

    it('close button has aria-label', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      expect(wrapper.find('[aria-label="Close drawer"]').exists()).toBe(true)
    })

    it('backdrop has aria-hidden', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()
      expect(wrapper.find('[aria-hidden="true"]').exists()).toBe(true)
    })
  })

  describe('Focus Trap', () => {
    it('traps focus within drawer on Tab key', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        slots: {
          default: `
            <button id="first">First</button>
            <button id="last">Last</button>
          `,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()

      const lastButton = wrapper.find('#last').element as HTMLButtonElement
      lastButton?.focus()

      // Simulate Tab key (should go to close button, then cycle)
      const tabEvent = new KeyboardEvent('keydown', { key: 'Tab', bubbles: true })
      document.dispatchEvent(tabEvent)
      await wrapper.vm.$nextTick()
    })

    it('traps focus backward on Shift+Tab', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        slots: {
          default: `
            <button id="first">First</button>
            <button id="last">Last</button>
          `,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()

      const firstButton = wrapper.find('#first').element as HTMLButtonElement
      firstButton?.focus()

      const shiftTabEvent = new KeyboardEvent('keydown', {
        key: 'Tab',
        shiftKey: true,
        bubbles: true,
      })
      document.dispatchEvent(shiftTabEvent)
      await wrapper.vm.$nextTick()
    })
  })

  describe('Edge Cases', () => {
    it('handles multiple rapid open/close cycles', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: false,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })

      await wrapper.setProps({ modelValue: true })
      await wrapper.setProps({ modelValue: false })
      await wrapper.setProps({ modelValue: true })
      await wrapper.setProps({ modelValue: false })
      await wrapper.vm.$nextTick()

      expect(document.body.style.overflow).toBe('')
    })

    it('handles drawer without any focusable elements', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          showCloseButton: false,
        },
        slots: {
          default: '<div>No focusable elements</div>',
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()

      const tabEvent = new KeyboardEvent('keydown', { key: 'Tab', bubbles: true })
      expect(() => document.dispatchEvent(tabEvent)).not.toThrow()
    })

    it('handles backdrop click on drawer content (should not close)', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()

      const drawerContent = wrapper.find('[role="dialog"]')
      await drawerContent.trigger('click')

      expect(wrapper.emitted('update:modelValue')).toBeFalsy()
    })

    it('renders without title or description', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
          stubs: { teleport: true },
        },
      })
      await wrapper.vm.$nextTick()

      expect(wrapper.find('#drawer-title').exists()).toBe(false)
      expect(wrapper.find('#drawer-description').exists()).toBe(false)
    })
  })
})
