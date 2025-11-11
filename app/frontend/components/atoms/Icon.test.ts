import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount } from '@vue/test-utils'
import Icon from './Icon.vue'

describe('Icon', () => {
  let consoleWarnSpy: ReturnType<typeof vi.spyOn>

  beforeEach(() => {
    consoleWarnSpy = vi.spyOn(console, 'warn').mockImplementation(() => {})
  })

  afterEach(() => {
    consoleWarnSpy.mockRestore()
  })

  describe('rendering', () => {
    it('renders icon element', () => {
      const wrapper = mount(Icon, {
        props: { name: 'home' },
      })

      expect(wrapper.find('svg').exists()).toBe(true)
    })

    it('renders correct icon by name', () => {
      const wrapper = mount(Icon, {
        props: { name: 'home' },
      })

      // Check that an SVG is rendered
      expect(wrapper.find('svg').exists()).toBe(true)
    })

    it('renders kebab-case icon names', () => {
      const wrapper = mount(Icon, {
        props: { name: 'arrow-right' },
      })

      expect(wrapper.find('svg').exists()).toBe(true)
    })

    it('renders icon with default size', () => {
      const wrapper = mount(Icon, {
        props: { name: 'home' },
      })

      const svg = wrapper.find('svg')
      expect(svg.classes()).toContain('h-5')
      expect(svg.classes()).toContain('w-5')
    })

    it('renders with different preset sizes', () => {
      const sizes = ['xs', 'sm', 'md', 'lg', 'xl', '2xl'] as const

      sizes.forEach((size) => {
        const wrapper = mount(Icon, {
          props: { name: 'home', size },
        })

        const svg = wrapper.find('svg')
        const expectedClass =
          size === 'xs'
            ? 'h-3'
            : size === 'sm'
              ? 'h-4'
              : size === 'md'
                ? 'h-5'
                : size === 'lg'
                  ? 'h-6'
                  : size === 'xl'
                    ? 'h-8'
                    : 'h-10'

        expect(svg.classes()).toContain(expectedClass)
      })
    })

    it('renders with custom numeric size', () => {
      const wrapper = mount(Icon, {
        props: { name: 'home', size: 32 },
      })

      const svg = wrapper.find('svg')
      expect(svg.attributes('style')).toContain('width: 32px')
      expect(svg.attributes('style')).toContain('height: 32px')
    })

    it('renders with custom color', () => {
      const wrapper = mount(Icon, {
        props: { name: 'home', color: '#ff0000' },
      })

      const svg = wrapper.find('svg')
      expect(svg.attributes('style')).toContain('color: rgb(255, 0, 0)')
    })

    it('renders with custom color using CSS variable', () => {
      const wrapper = mount(Icon, {
        props: { name: 'home', color: 'var(--color-primary)' },
      })

      const svg = wrapper.find('svg')
      expect(svg.attributes('style')).toContain('color: var(--color-primary)')
    })

    it('renders with custom stroke width', () => {
      const wrapper = mount(Icon, {
        props: { name: 'home', strokeWidth: 3 },
      })

      const svg = wrapper.find('svg')
      expect(svg.attributes('stroke-width')).toBe('3')
    })

    it('renders with default stroke width', () => {
      const wrapper = mount(Icon, {
        props: { name: 'home' },
      })

      const svg = wrapper.find('svg')
      expect(svg.attributes('stroke-width')).toBe('2')
    })

    it('renders with custom CSS classes', () => {
      const wrapper = mount(Icon, {
        props: { name: 'home', class: 'custom-class' },
      })

      const svg = wrapper.find('svg')
      expect(svg.classes()).toContain('custom-class')
    })

    it('always has inline-block class', () => {
      const wrapper = mount(Icon, {
        props: { name: 'home' },
      })

      const svg = wrapper.find('svg')
      expect(svg.classes()).toContain('inline-block')
    })

    it('always has flex-shrink-0 class', () => {
      const wrapper = mount(Icon, {
        props: { name: 'home' },
      })

      const svg = wrapper.find('svg')
      expect(svg.classes()).toContain('flex-shrink-0')
    })
  })

  describe('icon names', () => {
    it('renders common icons', () => {
      const commonIcons = [
        'home',
        'user',
        'settings',
        'search',
        'mail',
        'phone',
        'calendar',
        'star',
      ]

      commonIcons.forEach((iconName) => {
        const wrapper = mount(Icon, {
          props: { name: iconName },
        })

        expect(wrapper.find('svg').exists()).toBe(true)
      })
    })

    it('renders kebab-case icon names correctly', () => {
      const kebabIcons = [
        'arrow-right',
        'arrow-left',
        'arrow-up',
        'arrow-down',
        'check-circle',
        'x-circle',
      ]

      kebabIcons.forEach((iconName) => {
        const wrapper = mount(Icon, {
          props: { name: iconName },
        })

        expect(wrapper.find('svg').exists()).toBe(true)
      })
    })

    it('warns and renders fallback for invalid icon name', () => {
      const wrapper = mount(Icon, {
        props: { name: 'invalid-icon-name-that-does-not-exist' },
      })

      expect(consoleWarnSpy).toHaveBeenCalledWith(
        expect.stringContaining('Icon "invalid-icon-name-that-does-not-exist"')
      )
      expect(wrapper.find('svg').exists()).toBe(true) // Should render fallback
    })
  })

  describe('accessibility', () => {
    it('has aria-label when provided', () => {
      const wrapper = mount(Icon, {
        props: { name: 'home', ariaLabel: 'Home icon' },
      })

      const svg = wrapper.find('svg')
      expect(svg.attributes('aria-label')).toBe('Home icon')
    })

    it('has aria-hidden when no aria-label provided', () => {
      const wrapper = mount(Icon, {
        props: { name: 'home' },
      })

      const svg = wrapper.find('svg')
      expect(svg.attributes('aria-hidden')).toBe('true')
    })

    it('does not have aria-hidden when aria-label is provided', () => {
      const wrapper = mount(Icon, {
        props: { name: 'home', ariaLabel: 'Home' },
      })

      const svg = wrapper.find('svg')
      expect(svg.attributes('aria-hidden')).toBe('false')
    })
  })

  describe('combinations', () => {
    it('renders with all props combined', () => {
      const wrapper = mount(Icon, {
        props: {
          name: 'star',
          size: 'lg',
          color: '#ffaa00',
          strokeWidth: 3,
          class: 'my-custom-class',
          ariaLabel: 'Favorite',
        },
      })

      const svg = wrapper.find('svg')
      expect(svg.exists()).toBe(true)
      expect(svg.classes()).toContain('h-6')
      expect(svg.classes()).toContain('my-custom-class')
      expect(svg.attributes('style')).toContain('color: rgb(255, 170, 0)')
      expect(svg.attributes('stroke-width')).toBe('3')
      expect(svg.attributes('aria-label')).toBe('Favorite')
    })

    it('renders with custom numeric size and color', () => {
      const wrapper = mount(Icon, {
        props: {
          name: 'heart',
          size: 48,
          color: '#ff0000',
        },
      })

      const svg = wrapper.find('svg')
      expect(svg.attributes('style')).toContain('width: 48px')
      expect(svg.attributes('style')).toContain('height: 48px')
      expect(svg.attributes('style')).toContain('color: rgb(255, 0, 0)')
    })
  })

  describe('style composition', () => {
    it('combines size and color styles correctly', () => {
      const wrapper = mount(Icon, {
        props: {
          name: 'home',
          size: 24,
          color: '#00ff00',
        },
      })

      const svg = wrapper.find('svg')
      const style = svg.attributes('style')
      expect(style).toContain('width: 24px')
      expect(style).toContain('height: 24px')
      expect(style).toContain('color: rgb(0, 255, 0)')
    })

    it('does not add size style for preset sizes', () => {
      const wrapper = mount(Icon, {
        props: {
          name: 'home',
          size: 'md',
        },
      })

      const svg = wrapper.find('svg')
      const style = svg.attributes('style')
      // Should not have inline width/height since it uses classes
      if (style) {
        expect(style).not.toContain('width')
        expect(style).not.toContain('height')
      } else {
        // Style attribute should be undefined or empty for preset sizes
        expect(style).toBeUndefined()
      }
    })

    it('does not add color style when color not provided', () => {
      const wrapper = mount(Icon, {
        props: {
          name: 'home',
        },
      })

      const svg = wrapper.find('svg')
      const style = svg.attributes('style')
      if (style) {
        expect(style).not.toContain('color')
      } else {
        // Style attribute should be undefined when no color is provided
        expect(style).toBeUndefined()
      }
    })
  })

  describe('class composition', () => {
    it('combines all classes correctly', () => {
      const wrapper = mount(Icon, {
        props: {
          name: 'home',
          size: 'lg',
          class: 'custom-1 custom-2',
        },
      })

      const svg = wrapper.find('svg')
      expect(svg.classes()).toContain('inline-block')
      expect(svg.classes()).toContain('flex-shrink-0')
      expect(svg.classes()).toContain('h-6')
      expect(svg.classes()).toContain('w-6')
      expect(svg.classes()).toContain('custom-1')
      expect(svg.classes()).toContain('custom-2')
    })

    it('does not add size class for numeric size', () => {
      const wrapper = mount(Icon, {
        props: {
          name: 'home',
          size: 32,
        },
      })

      const svg = wrapper.find('svg')
      expect(svg.classes()).toContain('inline-block')
      expect(svg.classes()).toContain('flex-shrink-0')
      // Should not have h-* or w-* classes
      expect(svg.classes().some((c) => c.startsWith('h-'))).toBe(false)
      expect(svg.classes().some((c) => c.startsWith('w-'))).toBe(false)
    })
  })
})
