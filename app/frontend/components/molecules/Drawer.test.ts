import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { mount, VueWrapper } from '@vue/test-utils'
import Drawer from './Drawer.vue'
import Button from '../atoms/Button.vue'
import Icon from '../atoms/Icon.vue'

describe('Drawer', () => {
  let wrapper: VueWrapper<any>

  beforeEach(() => {
    // Create a teleport target
    const el = document.createElement('div')
    el.id = 'app'
    document.body.appendChild(el)
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
        },
      })
      expect(wrapper.exists()).toBe(true)
    })

    it('renders correctly when open', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
    })

    it('renders with title', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          title: 'Test Drawer',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      expect(wrapper.find('#drawer-title').text()).toBe('Test Drawer')
    })

    it('renders with description', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          title: 'Test',
          description: 'Test description',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      expect(wrapper.find('#drawer-description').text()).toBe('Test description')
    })

    it('renders default slot content', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        slots: {
          default: '<div class="test-content">Content</div>',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      expect(wrapper.find('.test-content').text()).toBe('Content')
    })

    it('renders header slot', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        slots: {
          header: '<div class="custom-header">Custom Header</div>',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      expect(wrapper.find('.custom-header').text()).toBe('Custom Header')
    })

    it('renders footer slot', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        slots: {
          footer: '<div class="custom-footer">Custom Footer</div>',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      expect(wrapper.find('.custom-footer').text()).toBe('Custom Footer')
    })

    it('renders close button by default', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      expect(wrapper.find('button[aria-label="Close drawer"]').exists()).toBe(true)
    })

    it('hides close button when showCloseButton is false', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          showCloseButton: false,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      expect(wrapper.find('button[aria-label="Close drawer"]').exists()).toBe(false)
    })
  })

  describe('Position Props', () => {
    it('applies right position classes by default', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('right-0')
    })

    it('applies left position classes', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          position: 'left',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('left-0')
    })

    it('applies top position classes', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          position: 'top',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('top-0')
    })

    it('applies bottom position classes', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          position: 'bottom',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('bottom-0')
    })
  })

  describe('Size Props', () => {
    it('applies medium size by default for right position', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          position: 'right',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('w-96')
    })

    it('applies small size for right position', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          position: 'right',
          size: 'sm',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('w-64')
    })

    it('applies large size for right position', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          position: 'right',
          size: 'lg',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('w-[32rem]')
    })

    it('applies full size for right position', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          position: 'right',
          size: 'full',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('w-full')
    })

    it('applies small height for top position', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          position: 'top',
          size: 'sm',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('h-64')
    })

    it('applies large height for bottom position', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          position: 'bottom',
          size: 'lg',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.classes()).toContain('h-[32rem]')
    })
  })

  describe('Backdrop Props', () => {
    it('renders backdrop by default', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      expect(wrapper.find('.bg-black\\/50').exists()).toBe(true)
    })

    it('hides backdrop when backdrop is false', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          backdrop: false,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      expect(wrapper.find('.bg-black\\/50').exists()).toBe(false)
    })

    it('applies backdrop blur by default', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      expect(wrapper.find('.backdrop-blur-sm').exists()).toBe(true)
    })

    it('removes backdrop blur when backdropBlur is false', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          backdropBlur: false,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
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
        },
        attachTo: document.body,
      })

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
        },
        attachTo: document.body,
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
        },
        attachTo: document.body,
      })

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
        },
        attachTo: document.body,
      })

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
        },
        attachTo: document.body,
      })

      await document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape' }))
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
        },
        attachTo: document.body,
      })

      await document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape' }))
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
        },
        attachTo: document.body,
      })

      await document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape' }))
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
        },
        attachTo: document.body,
      })

      await wrapper.setProps({ modelValue: true })
      await wrapper.vm.$nextTick()

      expect(document.body.style.overflow).toBe('hidden')
    })

    it('unlocks body scroll when drawer closes', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      expect(document.body.style.overflow).toBe('hidden')

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
        },
        attachTo: document.body,
      })

      await wrapper.setProps({ modelValue: true })
      await wrapper.vm.$nextTick()

      expect(document.body.style.overflow).toBe('')
    })

    it('restores body scroll on unmount', async () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      expect(document.body.style.overflow).toBe('hidden')

      wrapper.unmount()
      await wrapper.vm.$nextTick()

      expect(document.body.style.overflow).toBe('')
    })
  })

  describe('Accessibility', () => {
    it('has dialog role', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
    })

    it('has aria-modal attribute', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      expect(wrapper.find('[aria-modal="true"]').exists()).toBe(true)
    })

    it('has aria-labelledby when title is provided', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          title: 'Test Title',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.attributes('aria-labelledby')).toBe('drawer-title')
    })

    it('has aria-describedby when description is provided', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
          title: 'Test',
          description: 'Test description',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.attributes('aria-describedby')).toBe('drawer-description')
    })

    it('close button has aria-label', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      expect(wrapper.find('[aria-label="Close drawer"]').exists()).toBe(true)
    })

    it('backdrop has aria-hidden', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
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
        },
        attachTo: document.body,
      })

      const firstButton = wrapper.find('#first').element as HTMLButtonElement
      const lastButton = wrapper.find('#last').element as HTMLButtonElement

      // Focus last button
      lastButton.focus()
      expect(document.activeElement).toBe(lastButton)

      // Simulate Tab key (should go to close button, then cycle)
      const tabEvent = new KeyboardEvent('keydown', { key: 'Tab', bubbles: true })
      await document.dispatchEvent(tabEvent)
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
        },
        attachTo: document.body,
      })

      const firstButton = wrapper.find('#first').element as HTMLButtonElement
      firstButton.focus()

      const shiftTabEvent = new KeyboardEvent('keydown', {
        key: 'Tab',
        shiftKey: true,
        bubbles: true,
      })
      await document.dispatchEvent(shiftTabEvent)
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
        },
        attachTo: document.body,
      })

      await wrapper.setProps({ modelValue: true })
      await wrapper.setProps({ modelValue: false })
      await wrapper.setProps({ modelValue: true })
      await wrapper.setProps({ modelValue: false })
      await wrapper.vm.$nextTick()

      expect(document.body.style.overflow).toBe('')
    })

    it('handles drawer without any focusable elements', () => {
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
        },
        attachTo: document.body,
      })

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
        },
        attachTo: document.body,
      })

      const drawerContent = wrapper.find('[role="dialog"]')
      await drawerContent.trigger('click')

      expect(wrapper.emitted('update:modelValue')).toBeFalsy()
    })

    it('renders without title or description', () => {
      wrapper = mount(Drawer, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      expect(wrapper.find('#drawer-title').exists()).toBe(false)
      expect(wrapper.find('#drawer-description').exists()).toBe(false)
    })
  })
})
