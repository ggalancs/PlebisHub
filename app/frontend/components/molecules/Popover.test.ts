import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { mount, VueWrapper } from '@vue/test-utils'
import { nextTick } from 'vue'
import Popover from './Popover.vue'
import Button from '../atoms/Button.vue'
import Icon from '../atoms/Icon.vue'

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
      expect(wrapper.find('[role="dialog"]').exists()).toBe(false)
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
      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
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
      expect(wrapper.find('#popover-title').text()).toBe('Popover Title')
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
      expect(wrapper.text()).toContain('Popover content')
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
      expect(wrapper.find('.custom-content').text()).toBe('Custom Content')
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
      expect(wrapper.find('.custom-title').text()).toBe('Custom Title')
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
      const popover = wrapper.find('[role="dialog"]')
      expect(popover.find('.absolute.w-2.h-2').exists()).toBe(true)
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
      const popover = wrapper.find('[role="dialog"]')
      expect(popover.find('.absolute.w-2.h-2').exists()).toBe(false)
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
      expect(wrapper.find('[aria-label="Close popover"]').exists()).toBe(true)
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

      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
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

      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)

      await trigger.trigger('click')
      await nextTick()

      expect(wrapper.find('[role="dialog"]').exists()).toBe(false)
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

      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)

      await document.body.click()
      await nextTick()

      expect(wrapper.find('[role="dialog"]').exists()).toBe(false)
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

      const popover = wrapper.find('[role="dialog"]')
      await popover.trigger('click')
      await nextTick()

      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
    })
  })

  describe('Trigger Hover Mode', () => {
    it('opens popover on trigger hover', async () => {
      wrapper = mount(Popover, {
        props: {
          trigger: 'hover',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('button').trigger('mouseenter')
      await nextTick()

      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
      expect(wrapper.emitted('open')).toBeTruthy()
    })

    it('closes popover on mouse leave in hover mode', async () => {
      wrapper = mount(Popover, {
        props: {
          trigger: 'hover',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('mouseenter')
      await nextTick()

      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)

      await trigger.trigger('mouseleave')
      await nextTick()

      expect(wrapper.find('[role="dialog"]').exists()).toBe(false)
      expect(wrapper.emitted('close')).toBeTruthy()
    })

    it('does not close on outside click in hover mode', async () => {
      wrapper = mount(Popover, {
        props: {
          trigger: 'hover',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('button').trigger('mouseenter')
      await nextTick()

      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)

      await document.body.click()
      await nextTick()

      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
    })
  })

  describe('Trigger Focus Mode', () => {
    it('opens popover on trigger focus', async () => {
      wrapper = mount(Popover, {
        props: {
          trigger: 'focus',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('button').trigger('focus')
      await nextTick()

      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
      expect(wrapper.emitted('open')).toBeTruthy()
    })

    it('closes popover on blur in focus mode', async () => {
      wrapper = mount(Popover, {
        props: {
          trigger: 'focus',
        },
        global: {
          components: { Button, Icon },
        },
        attachTo: document.body,
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('focus')
      await nextTick()

      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)

      await trigger.trigger('blur')
      await nextTick()

      expect(wrapper.find('[role="dialog"]').exists()).toBe(false)
      expect(wrapper.emitted('close')).toBeTruthy()
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

      expect(wrapper.find('[role="dialog"]').exists()).toBe(false)

      await wrapper.setProps({ modelValue: true })
      await nextTick()

      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
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
      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
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
      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
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
      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
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
      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
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
      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
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
      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
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

      expect(wrapper.find('[role="dialog"]').exists()).toBe(false)
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
      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)

      await wrapper.find('[aria-label="Close popover"]').trigger('click')
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

      await wrapper.find('[aria-label="Close popover"]').trigger('click')
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

      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)

      const escapeEvent = new KeyboardEvent('keydown', { key: 'Escape' })
      document.dispatchEvent(escapeEvent)
      await nextTick()

      expect(wrapper.find('[role="dialog"]').exists()).toBe(false)
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

      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
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
      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
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
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.attributes('aria-modal')).toBe('false')
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
      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.attributes('aria-labelledby')).toBe('popover-title')
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
      expect(wrapper.find('[aria-label="Close popover"]').exists()).toBe(true)
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
      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
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
      const popover = wrapper.find('[role="dialog"]')
      expect(popover.attributes('style')).toContain('width: 400px')
      expect(popover.attributes('style')).toContain('max-width: 500px')
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
      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
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
      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
    })
  })
})
