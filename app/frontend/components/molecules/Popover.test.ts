import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { mount, VueWrapper } from '@vue/test-utils'
import { nextTick } from 'vue'
import Popover from './Popover.vue'
import Button from '../atoms/Button.vue'
import Icon from '../atoms/Icon.vue'

// Helper to find teleported content in document.body
const findDialog = () => document.body.querySelector('[role="dialog"]')
const findByAriaLabel = (label: string) => document.body.querySelector(`[aria-label="${label}"]`)
const findById = (id: string) => document.body.querySelector(`#${id}`)
const findByClass = (cls: string) => document.body.querySelector(`.${cls}`)

describe('Popover', () => {
  let wrapper: VueWrapper<any>

  beforeEach(() => {
    const el = document.createElement('div')
    el.id = 'app'
    document.body.appendChild(el)
  })

  afterEach(() => {
    if (wrapper) {
      wrapper.unmount()
    }
    document.body.innerHTML = ''
  })

  describe('Basic Rendering', () => {
    it('renders trigger by default', () => {
      wrapper = mount(Popover, {
        global: {
          components: { Button, Icon },
        },
      })
      expect(wrapper.exists()).toBe(true)
      expect(wrapper.find('button').exists()).toBe(true)
    })

    it('renders custom trigger slot', () => {
      wrapper = mount(Popover, {
        slots: {
          trigger: '<button class="custom-trigger">Custom Trigger</button>',
        },
        global: {
          components: { Button, Icon },
        },
      })
      expect(wrapper.find('.custom-trigger').text()).toBe('Custom Trigger')
    })

    it('does not show popover by default', () => {
      wrapper = mount(Popover, {
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      expect(findDialog()).toBeNull()
    })

    it('renders popover when modelValue is true', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      expect(findDialog()).not.toBeNull()
    })

    it('renders title', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
          title: 'Popover Title',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      const title = findById('popover-title')
      expect(title?.textContent).toBe('Popover Title')
    })

    it('renders content prop', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
          content: 'Popover content',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      const dialog = findDialog()
      expect(dialog?.textContent).toContain('Popover content')
    })

    it('renders default slot content', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
        },
        slots: {
          default: '<p class="custom-content">Custom Content</p>',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      const content = document.body.querySelector('.custom-content')
      expect(content?.textContent).toBe('Custom Content')
    })

    it('renders title slot', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
        },
        slots: {
          title: '<h3 class="custom-title">Custom Title</h3>',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      const title = document.body.querySelector('.custom-title')
      expect(title?.textContent).toBe('Custom Title')
    })

    it('renders arrow by default', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      const dialog = findDialog()
      // Arrow has class pattern like "absolute w-2 h-2"
      const arrow = dialog?.querySelector('.absolute.w-2.h-2')
      expect(arrow).not.toBeNull()
    })

    it('hides arrow when showArrow is false', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
          showArrow: false,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      const dialog = findDialog()
      const arrow = dialog?.querySelector('.absolute.w-2.h-2')
      expect(arrow).toBeNull()
    })

    it('renders close button when showCloseButton is true', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
          showCloseButton: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      expect(findByAriaLabel('Close popover')).not.toBeNull()
    })
  })

  describe('Trigger Click Mode', () => {
    it('opens popover on trigger click in click mode', async () => {
      wrapper = mount(Popover, {
        props: {
          trigger: 'click',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('button').trigger('click')
      await nextTick()

      expect(findDialog()).not.toBeNull()
      expect(wrapper.emitted('open')).toBeTruthy()
    })

    it('closes popover on second click in click mode', async () => {
      wrapper = mount(Popover, {
        props: {
          trigger: 'click',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')
      await nextTick()

      expect(findDialog()).not.toBeNull()

      await trigger.trigger('click')
      await nextTick()

      expect(findDialog()).toBeNull()
      expect(wrapper.emitted('close')).toBeTruthy()
    })

    it('closes on outside click in click mode', async () => {
      wrapper = mount(Popover, {
        props: {
          trigger: 'click',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('button').trigger('click')
      await nextTick()

      expect(findDialog()).not.toBeNull()

      // Simulate outside click by dispatching a click event
      document.body.dispatchEvent(new MouseEvent('click', { bubbles: true }))
      await nextTick()

      expect(findDialog()).toBeNull()
    })

    it('does not close when clicking inside popover', async () => {
      wrapper = mount(Popover, {
        props: {
          trigger: 'click',
          content: 'Content',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('button').trigger('click')
      await nextTick()

      const dialog = findDialog()
      expect(dialog).not.toBeNull()

      // Click inside the popover
      dialog!.dispatchEvent(new MouseEvent('click', { bubbles: true }))
      await nextTick()

      expect(findDialog()).not.toBeNull()
    })
  })

  describe('Trigger Hover Mode', () => {
    it('accepts hover trigger mode and responds to modelValue', async () => {
      // In hover mode, the component uses modelValue for controlled state
      // JSDOM doesn't properly support mouseenter/mouseleave events on divs,
      // so we verify the component accepts the hover prop and works in controlled mode
      wrapper = mount(Popover, {
        props: {
          trigger: 'hover',
          modelValue: false,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      expect(findDialog()).toBeNull()

      // Simulating what happens when mouse enters - controlled state changes
      await wrapper.setProps({ modelValue: true })
      await nextTick()

      expect(findDialog()).not.toBeNull()
    })

    it('closes when modelValue becomes false in hover mode', async () => {
      wrapper = mount(Popover, {
        props: {
          trigger: 'hover',
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      await nextTick()
      expect(findDialog()).not.toBeNull()

      // Simulating what happens when mouse leaves - controlled state changes
      await wrapper.setProps({ modelValue: false })
      await nextTick()

      expect(findDialog()).toBeNull()
    })

    it('does not close on outside click in hover mode', async () => {
      wrapper = mount(Popover, {
        props: {
          trigger: 'hover',
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      await nextTick()
      expect(findDialog()).not.toBeNull()

      // Outside click should not close in hover mode
      document.body.dispatchEvent(new MouseEvent('click', { bubbles: true }))
      await nextTick()

      // Popover stays open because trigger is 'hover', not 'click'
      expect(findDialog()).not.toBeNull()
    })
  })

  describe('Trigger Focus Mode', () => {
    it('accepts focus trigger mode and responds to modelValue', async () => {
      // In focus mode, the component uses modelValue for controlled state
      // JSDOM doesn't properly support focus/blur events on div elements,
      // so we verify the component accepts the focus prop and works in controlled mode
      wrapper = mount(Popover, {
        props: {
          trigger: 'focus',
          modelValue: false,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      expect(findDialog()).toBeNull()

      // Simulating what happens when focus occurs - controlled state changes
      await wrapper.setProps({ modelValue: true })
      await nextTick()

      expect(findDialog()).not.toBeNull()
    })

    it('closes when modelValue becomes false in focus mode', async () => {
      wrapper = mount(Popover, {
        props: {
          trigger: 'focus',
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      await nextTick()
      expect(findDialog()).not.toBeNull()

      // Simulating what happens when blur occurs - controlled state changes
      await wrapper.setProps({ modelValue: false })
      await nextTick()

      expect(findDialog()).toBeNull()
    })
  })

  describe('Controlled Mode', () => {
    it('uses modelValue for controlled state', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: false,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      expect(findDialog()).toBeNull()

      await wrapper.setProps({ modelValue: true })
      await nextTick()

      expect(findDialog()).not.toBeNull()
    })

    it('emits update:modelValue in controlled mode', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: false,
          trigger: 'click',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('button').trigger('click')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([true])
    })
  })

  describe('Placement Props', () => {
    it('applies bottom placement by default', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      // Position is calculated dynamically, just ensure popover exists
      expect(findDialog()).not.toBeNull()
    })

    it('accepts top placement', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
          placement: 'top',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      expect(findDialog()).not.toBeNull()
    })

    it('accepts left placement', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
          placement: 'left',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      expect(findDialog()).not.toBeNull()
    })

    it('accepts right placement', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
          placement: 'right',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      expect(findDialog()).not.toBeNull()
    })

    it('accepts top-start placement', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
          placement: 'top-start',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      expect(findDialog()).not.toBeNull()
    })

    it('accepts bottom-end placement', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
          placement: 'bottom-end',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      expect(findDialog()).not.toBeNull()
    })
  })

  describe('Disabled State', () => {
    it('does not open when disabled', async () => {
      wrapper = mount(Popover, {
        props: {
          disabled: true,
          trigger: 'click',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('button').trigger('click')
      await nextTick()

      expect(findDialog()).toBeNull()
      expect(wrapper.emitted('open')).toBeFalsy()
    })

    it('does not close when disabled and already open', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
          disabled: true,
          showCloseButton: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      await nextTick()
      expect(findDialog()).not.toBeNull()

      const closeBtn = findByAriaLabel('Close popover') as HTMLElement
      closeBtn?.click()
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeFalsy()
    })
  })

  describe('Close Button', () => {
    it('closes popover when close button is clicked', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
          showCloseButton: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      await nextTick()

      const closeBtn = findByAriaLabel('Close popover') as HTMLElement
      closeBtn?.click()
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([false])
      expect(wrapper.emitted('close')).toBeTruthy()
    })
  })

  describe('Keyboard Navigation', () => {
    it('closes on escape key', async () => {
      wrapper = mount(Popover, {
        props: {
          trigger: 'click',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('button').trigger('click')
      await nextTick()

      expect(findDialog()).not.toBeNull()

      const escapeEvent = new KeyboardEvent('keydown', { key: 'Escape' })
      document.dispatchEvent(escapeEvent)
      await nextTick()

      expect(findDialog()).toBeNull()
      expect(wrapper.emitted('close')).toBeTruthy()
    })

    it('does not close on other keys', async () => {
      wrapper = mount(Popover, {
        props: {
          trigger: 'click',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('button').trigger('click')
      await nextTick()

      const enterEvent = new KeyboardEvent('keydown', { key: 'Enter' })
      document.dispatchEvent(enterEvent)
      await nextTick()

      expect(findDialog()).not.toBeNull()
    })
  })

  describe('Accessibility', () => {
    it('has dialog role', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      expect(findDialog()).not.toBeNull()
    })

    it('has aria-modal set to false', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      const dialog = findDialog()
      expect(dialog?.getAttribute('aria-modal')).toBe('false')
    })

    it('has aria-labelledby when title is provided', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
          title: 'Test Title',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      const dialog = findDialog()
      expect(dialog?.getAttribute('aria-labelledby')).toBe('popover-title')
    })

    it('close button has aria-label', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
          showCloseButton: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      expect(findByAriaLabel('Close popover')).not.toBeNull()
    })
  })

  describe('Edge Cases', () => {
    it('handles rapid open/close cycles', async () => {
      wrapper = mount(Popover, {
        props: {
          trigger: 'click',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')
      await trigger.trigger('click')
      await trigger.trigger('click')
      await nextTick()

      // Should be open after odd number of clicks
      expect(findDialog()).not.toBeNull()
    })

    it('handles custom width and maxWidth', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
          width: '400px',
          maxWidth: '500px',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      // Verify the popover renders with custom width/maxWidth props
      // The component accepts these props and applies them via popoverStyle
      expect(findDialog()).not.toBeNull()
      expect(wrapper.vm.width).toBe('400px')
      expect(wrapper.vm.maxWidth).toBe('500px')
    })

    it('handles custom offset', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
          offset: 16,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      expect(findDialog()).not.toBeNull()
    })

    it('renders without title or content', async () => {
      wrapper = mount(Popover, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })
      await nextTick()
      expect(findDialog()).not.toBeNull()
    })
  })
})
