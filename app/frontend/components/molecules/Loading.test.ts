import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Loading from './Loading.vue'
import Icon from '../atoms/Icon.vue'

describe('Loading', () => {
  // Basic rendering
  describe('Basic Rendering', () => {
    it('renders when modelValue is true', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      expect(wrapper.find('[role="dialog"]').exists()).toBe(true)
    })

    it('does not render when modelValue is false', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: false,
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      expect(wrapper.find('[role="dialog"]').exists()).toBe(false)
    })

    it('has correct ARIA attributes', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          label: 'Loading content',
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.attributes('aria-modal')).toBe('true')
      expect(dialog.attributes('aria-busy')).toBe('true')
      expect(dialog.attributes('aria-label')).toBe('Loading content')
    })

    it('uses default label when none provided', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      const dialog = wrapper.find('[role="dialog"]')
      expect(dialog.attributes('aria-label')).toBe('Loading')
    })
  })

  // Spinner types
  describe('Spinner Types', () => {
    it('renders spinner type by default', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      expect(wrapper.findComponent(Icon).exists()).toBe(true)
      expect(wrapper.findComponent(Icon).props('name')).toBe('loader-2')
    })

    it('renders dots spinner', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          spinner: 'dots',
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      const dots = wrapper.findAll('.rounded-full.animate-bounce')
      expect(dots).toHaveLength(3)
    })

    it('renders pulse spinner', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          spinner: 'pulse',
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      expect(wrapper.find('.animate-pulse').exists()).toBe(true)
    })

    it('renders progress bar', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          spinner: 'bar',
          progress: 50,
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      const progressBar = wrapper.find('[role="progressbar"]')
      expect(progressBar.exists()).toBe(true)
      expect(progressBar.attributes('aria-valuenow')).toBe('50')
    })
  })

  // Sizes
  describe('Sizes', () => {
    it('renders small size spinner', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          size: 'sm',
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      expect(wrapper.findComponent(Icon).props('size')).toBe(32)
    })

    it('renders medium size spinner', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          size: 'md',
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      expect(wrapper.findComponent(Icon).props('size')).toBe(48)
    })

    it('renders large size spinner', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          size: 'lg',
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      expect(wrapper.findComponent(Icon).props('size')).toBe(64)
    })

    it('applies correct size classes to dots', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          spinner: 'dots',
          size: 'lg',
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      const dot = wrapper.find('.rounded-full.animate-bounce')
      expect(dot.classes()).toContain('w-4')
      expect(dot.classes()).toContain('h-4')
    })
  })

  // Opacity variants
  describe('Opacity Variants', () => {
    it('renders default opacity', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      const overlay = wrapper.find('[role="dialog"]')
      expect(overlay.classes()).toContain('bg-white/80')
    })

    it('renders light opacity', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          opacity: 'light',
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      const overlay = wrapper.find('[role="dialog"]')
      expect(overlay.classes()).toContain('bg-white/70')
    })

    it('renders dark opacity', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          opacity: 'dark',
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      const overlay = wrapper.find('[role="dialog"]')
      expect(overlay.classes()).toContain('bg-black/70')
    })
  })

  // Blur effect
  describe('Blur Effect', () => {
    it('does not apply blur by default', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      const overlay = wrapper.find('[role="dialog"]')
      expect(overlay.classes()).not.toContain('backdrop-blur-sm')
    })

    it('applies blur when enabled', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          blur: true,
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      const overlay = wrapper.find('[role="dialog"]')
      expect(overlay.classes()).toContain('backdrop-blur-sm')
    })
  })

  // Text content
  describe('Text Content', () => {
    it('renders text prop', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          text: 'Loading data...',
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      expect(wrapper.text()).toContain('Loading data...')
    })

    it('renders default slot content', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
        },
        slots: {
          default: '<p>Custom loading message</p>',
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      expect(wrapper.html()).toContain('Custom loading message')
    })

    it('applies correct text size classes', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          text: 'Loading',
          size: 'lg',
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      expect(wrapper.find('.text-lg').exists()).toBe(true)
    })

    it('uses dark text color for dark opacity', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          text: 'Loading',
          opacity: 'dark',
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      expect(wrapper.find('.text-white').exists()).toBe(true)
    })
  })

  // Progress bar
  describe('Progress Bar', () => {
    it('renders progress bar with correct width', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          spinner: 'bar',
          progress: 75,
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      const progressBar = wrapper.find('[role="progressbar"]')
      const innerBar = progressBar.find('.h-full')
      expect(innerBar.attributes('style')).toContain('width: 75%')
    })

    it('has correct ARIA attributes for progress', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          spinner: 'bar',
          progress: 33,
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      const progressBar = wrapper.find('[role="progressbar"]')
      expect(progressBar.attributes('aria-valuenow')).toBe('33')
      expect(progressBar.attributes('aria-valuemin')).toBe('0')
      expect(progressBar.attributes('aria-valuemax')).toBe('100')
    })

    it('applies correct height for small size', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          spinner: 'bar',
          size: 'sm',
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      expect(wrapper.find('.h-1').exists()).toBe(true)
    })

    it('applies correct height for large size', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          spinner: 'bar',
          size: 'lg',
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      expect(wrapper.find('.h-3').exists()).toBe(true)
    })
  })

  // Animation delays for dots
  describe('Dots Animation', () => {
    it('applies staggered animation delays to dots', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          spinner: 'dots',
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      const dots = wrapper.findAll('.rounded-full.animate-bounce')
      expect(dots[0].attributes('style')).toContain('animation-delay: 0s')
      expect(dots[1].attributes('style')).toContain('animation-delay: 0.15s')
      expect(dots[2].attributes('style')).toContain('animation-delay: 0.3s')
    })
  })

  // Combinations
  describe('Combinations', () => {
    it('renders large dark blurred loading with text', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          size: 'lg',
          opacity: 'dark',
          blur: true,
          text: 'Processing...',
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      const overlay = wrapper.find('[role="dialog"]')
      expect(overlay.classes()).toContain('bg-black/70')
      expect(overlay.classes()).toContain('backdrop-blur-sm')
      expect(wrapper.text()).toContain('Processing...')
      expect(wrapper.findComponent(Icon).props('size')).toBe(64)
    })

    it('renders dots spinner with light opacity and custom text', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          spinner: 'dots',
          opacity: 'light',
          text: 'Loading your content',
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      const overlay = wrapper.find('[role="dialog"]')
      expect(overlay.classes()).toContain('bg-white/70')
      expect(wrapper.findAll('.animate-bounce')).toHaveLength(3)
      expect(wrapper.text()).toContain('Loading your content')
    })

    it('renders progress bar with dark theme', () => {
      const wrapper = mount(Loading, {
        props: {
          modelValue: true,
          spinner: 'bar',
          progress: 60,
          opacity: 'dark',
          text: '60% complete',
        },
        global: {
          components: { Icon },
          stubs: {
            Teleport: true,
          },
        },
      })

      expect(wrapper.find('[role="progressbar"]').exists()).toBe(true)
      expect(wrapper.find('.bg-black\\/70').exists()).toBe(true)
      expect(wrapper.text()).toContain('60% complete')
    })
  })
})
