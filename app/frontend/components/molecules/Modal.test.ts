import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount } from '@vue/test-utils'
import Modal from './Modal.vue'

describe('Modal', () => {
  beforeEach(() => {
    // Create a div element to act as the teleport target
    const el = document.createElement('div')
    el.id = 'modal-root'
    document.body.appendChild(el)
  })

  afterEach(() => {
    document.body.innerHTML = ''
    vi.restoreAllMocks()
  })

  describe('rendering', () => {
    it('does not render when modelValue is false', () => {
      mount(Modal, {
        props: { modelValue: false },
        attachTo: document.body,
      })

      expect(document.querySelector('[role="dialog"]')).toBeNull()
    })

    it('renders when modelValue is true', () => {
      mount(Modal, {
        props: { modelValue: true },
        attachTo: document.body,
      })

      expect(document.querySelector('[role="dialog"]')).toBeTruthy()
    })

    it('renders title', () => {
      mount(Modal, {
        props: { modelValue: true, title: 'Test Modal' },
        attachTo: document.body,
      })

      expect(document.body.textContent).toContain('Test Modal')
    })

    it('renders content slot', () => {
      mount(Modal, {
        props: { modelValue: true },
        slots: {
          default: '<p>Modal Content</p>',
        },
        attachTo: document.body,
      })

      expect(document.body.textContent).toContain('Modal Content')
    })

    it('renders footer slot', () => {
      mount(Modal, {
        props: { modelValue: true },
        slots: {
          footer: '<button>OK</button>',
        },
        attachTo: document.body,
      })

      expect(document.body.textContent).toContain('OK')
    })

    it('renders header slot', () => {
      mount(Modal, {
        props: { modelValue: true },
        slots: {
          header: '<h2>Custom Header</h2>',
        },
        attachTo: document.body,
      })

      expect(document.body.textContent).toContain('Custom Header')
    })

    it('renders close button by default', () => {
      mount(Modal, {
        props: { modelValue: true },
        attachTo: document.body,
      })

      const closeButton = document.querySelector('[aria-label="Close modal"]')
      expect(closeButton).toBeTruthy()
    })

    it('hides close button when showClose is false', () => {
      mount(Modal, {
        props: { modelValue: true, showClose: false },
        attachTo: document.body,
      })

      const closeButton = document.querySelector('[aria-label="Close modal"]')
      expect(closeButton).toBeNull()
    })

    it('renders overlay', () => {
      mount(Modal, {
        props: { modelValue: true },
        attachTo: document.body,
      })

      const overlay = document.querySelector('.bg-black')
      expect(overlay).toBeTruthy()
    })
  })

  describe('sizes', () => {
    it('renders small size', () => {
      mount(Modal, {
        props: { modelValue: true, size: 'sm' },
        attachTo: document.body,
      })

      const modal = document.querySelector('.max-w-md')
      expect(modal).toBeTruthy()
    })

    it('renders medium size by default', () => {
      mount(Modal, {
        props: { modelValue: true },
        attachTo: document.body,
      })

      const modal = document.querySelector('.max-w-lg')
      expect(modal).toBeTruthy()
    })

    it('renders large size', () => {
      mount(Modal, {
        props: { modelValue: true, size: 'lg' },
        attachTo: document.body,
      })

      const modal = document.querySelector('.max-w-2xl')
      expect(modal).toBeTruthy()
    })

    it('renders xl size', () => {
      mount(Modal, {
        props: { modelValue: true, size: 'xl' },
        attachTo: document.body,
      })

      const modal = document.querySelector('.max-w-4xl')
      expect(modal).toBeTruthy()
    })

    it('renders full size', () => {
      mount(Modal, {
        props: { modelValue: true, size: 'full' },
        attachTo: document.body,
      })

      const modal = document.querySelector('.max-w-full')
      expect(modal).toBeTruthy()
    })
  })

  describe('close behavior', () => {
    it('emits update:modelValue when close button clicked', async () => {
      const wrapper = mount(Modal, {
        props: { modelValue: true },
        attachTo: document.body,
      })

      const closeButton = document.querySelector('[aria-label="Close modal"]') as HTMLElement
      closeButton.click()
      await wrapper.vm.$nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([false])
    })

    it('emits close event when close button clicked', async () => {
      const wrapper = mount(Modal, {
        props: { modelValue: true },
        attachTo: document.body,
      })

      const closeButton = document.querySelector('[aria-label="Close modal"]') as HTMLElement
      closeButton.click()
      await wrapper.vm.$nextTick()

      expect(wrapper.emitted('close')).toBeTruthy()
    })

    it('closes on overlay click by default', async () => {
      const wrapper = mount(Modal, {
        props: { modelValue: true },
        attachTo: document.body,
      })

      const dialog = document.querySelector('[role="dialog"]') as HTMLElement
      dialog.click()
      await wrapper.vm.$nextTick()

      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([false])
    })

    it('does not close on overlay click when closeOnOverlay is false', async () => {
      const wrapper = mount(Modal, {
        props: { modelValue: true, closeOnOverlay: false },
        attachTo: document.body,
      })

      const dialog = document.querySelector('[role="dialog"]') as HTMLElement
      dialog.click()
      await wrapper.vm.$nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeFalsy()
    })

    it('does not close when clicking modal content', async () => {
      const wrapper = mount(Modal, {
        props: { modelValue: true },
        slots: {
          default: '<div class="content">Content</div>',
        },
        attachTo: document.body,
      })

      const content = document.querySelector('.content') as HTMLElement
      content.click()
      await wrapper.vm.$nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeFalsy()
    })
  })

  describe('keyboard interaction', () => {
    it('closes on Escape key by default', () => {
      const wrapper = mount(Modal, {
        props: { modelValue: true },
        attachTo: document.body,
      })

      const event = new KeyboardEvent('keydown', { key: 'Escape' })
      document.dispatchEvent(event)

      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([false])
    })

    it('does not close on Escape when closeOnEscape is false', () => {
      const wrapper = mount(Modal, {
        props: { modelValue: true, closeOnEscape: false },
        attachTo: document.body,
      })

      const event = new KeyboardEvent('keydown', { key: 'Escape' })
      document.dispatchEvent(event)

      expect(wrapper.emitted('update:modelValue')).toBeFalsy()
    })

    it('does not close on other keys', () => {
      const wrapper = mount(Modal, {
        props: { modelValue: true },
        attachTo: document.body,
      })

      const event = new KeyboardEvent('keydown', { key: 'Enter' })
      document.dispatchEvent(event)

      expect(wrapper.emitted('update:modelValue')).toBeFalsy()
    })
  })

  describe('body scroll', () => {
    it('restores body scroll when closed', async () => {
      const wrapper = mount(Modal, {
        props: { modelValue: true },
        attachTo: document.body,
      })

      await wrapper.setProps({ modelValue: false })
      await wrapper.vm.$nextTick()

      expect(document.body.style.overflow).toBe('')
    })
  })

  describe('accessibility', () => {
    it('has role="dialog"', () => {
      mount(Modal, {
        props: { modelValue: true },
        attachTo: document.body,
      })

      expect(document.querySelector('[role="dialog"]')).toBeTruthy()
    })

    it('has aria-modal="true"', () => {
      mount(Modal, {
        props: { modelValue: true },
        attachTo: document.body,
      })

      const dialog = document.querySelector('[role="dialog"]')
      expect(dialog?.getAttribute('aria-modal')).toBe('true')
    })

    it('has aria-labelledby pointing to title', () => {
      mount(Modal, {
        props: { modelValue: true, title: 'Test' },
        attachTo: document.body,
      })

      const dialog = document.querySelector('[role="dialog"]')
      expect(dialog?.getAttribute('aria-labelledby')).toBe('modal-title')

      const title = document.querySelector('#modal-title')
      expect(title).toBeTruthy()
    })

    it('close button has aria-label', () => {
      mount(Modal, {
        props: { modelValue: true },
        attachTo: document.body,
      })

      const closeButton = document.querySelector('[aria-label="Close modal"]')
      expect(closeButton).toBeTruthy()
    })
  })

  describe('footer slot', () => {
    it('provides close function to footer slot', async () => {
      const wrapper = mount(Modal, {
        props: { modelValue: true },
        slots: {
          footer: `
            <template #footer="{ close }">
              <button class="cancel-btn" @click="close">Cancel</button>
            </template>
          `,
        },
        attachTo: document.body,
      })

      const button = document.querySelector('.cancel-btn') as HTMLElement
      button.click()
      await wrapper.vm.$nextTick()

      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([false])
    })
  })

  describe('combinations', () => {
    it('renders with all features', () => {
      mount(Modal, {
        props: {
          modelValue: true,
          title: 'Test Modal',
          size: 'lg',
          showClose: true,
          closeOnOverlay: true,
          closeOnEscape: true,
        },
        slots: {
          default: '<p>Content</p>',
          footer: '<button>OK</button>',
        },
        attachTo: document.body,
      })

      expect(document.querySelector('[role="dialog"]')).toBeTruthy()
      expect(document.body.textContent).toContain('Test Modal')
      expect(document.body.textContent).toContain('Content')
      expect(document.body.textContent).toContain('OK')
    })

    it('works with minimal props', () => {
      mount(Modal, {
        props: { modelValue: true },
        slots: {
          default: '<p>Simple content</p>',
        },
        attachTo: document.body,
      })

      expect(document.querySelector('[role="dialog"]')).toBeTruthy()
      expect(document.body.textContent).toContain('Simple content')
    })
  })
})
