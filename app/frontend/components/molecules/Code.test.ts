import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount } from '@vue/test-utils'
import Code from './Code.vue'
import Icon from '../atoms/Icon.vue'

describe('Code', () => {
  let clipboardWriteTextSpy: ReturnType<typeof vi.fn>

  beforeEach(() => {
    clipboardWriteTextSpy = vi.fn().mockResolvedValue(undefined)
    Object.assign(navigator, {
      clipboard: {
        writeText: clipboardWriteTextSpy,
      },
    })
  })

  afterEach(() => {
    vi.restoreAllMocks()
  })

  // Basic rendering
  describe('Basic Rendering', () => {
    it('renders inline code by default', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'const x = 1',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('code').exists()).toBe(true)
      expect(wrapper.find('pre').exists()).toBe(false)
    })

    it('renders block code when block prop is true', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'const x = 1',
          block: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('pre').exists()).toBe(true)
      expect(wrapper.find('code').exists()).toBe(true)
    })

    it('renders code from prop', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'console.log("hello")',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('console.log("hello")')
    })

    it('renders code from slot', () => {
      const wrapper = mount(Code, {
        slots: {
          default: 'function test() {}',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('function test() {}')
    })

    it('prefers code prop over slot', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'prop code',
        },
        slots: {
          default: 'slot code',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('prop code')
    })
  })

  // Language
  describe('Language', () => {
    it('adds language class to code block', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'const x = 1',
          block: true,
          language: 'javascript',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('code').classes()).toContain('language-javascript')
    })

    it('shows language label when showLanguage is true', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'print("hello")',
          block: true,
          language: 'python',
          showLanguage: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('python')
    })

    it('hides language label when showLanguage is false', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'print("hello")',
          block: true,
          language: 'python',
          showLanguage: false,
        },
        global: {
          components: { Icon },
        },
      })

      const labels = wrapper.findAll('.bg-gray-700.text-gray-300')
      expect(labels).toHaveLength(0)
    })

    it('does not show language label for inline code', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'x = 1',
          language: 'python',
        },
        global: {
          components: { Icon },
        },
      })

      const labels = wrapper.findAll('.bg-gray-700.text-gray-300')
      expect(labels).toHaveLength(0)
    })
  })

  // Variants
  describe('Variants', () => {
    it('renders default variant for inline code', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'x',
          variant: 'default',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('code').classes()).toContain('bg-gray-100')
      expect(wrapper.find('code').classes()).toContain('text-primary')
    })

    it('renders dark variant for inline code', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'x',
          variant: 'dark',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('code').classes()).toContain('bg-gray-800')
      expect(wrapper.find('code').classes()).toContain('text-gray-100')
    })

    it('renders light variant for inline code', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'x',
          variant: 'light',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('code').classes()).toContain('bg-gray-100')
      expect(wrapper.find('code').classes()).toContain('text-gray-800')
    })

    it('renders default variant for block code', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'const x = 1',
          block: true,
          variant: 'default',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('pre').classes()).toContain('bg-gray-800')
      expect(wrapper.find('pre').classes()).toContain('text-gray-100')
    })

    it('renders dark variant for block code', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'const x = 1',
          block: true,
          variant: 'dark',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('pre').classes()).toContain('bg-gray-900')
      expect(wrapper.find('pre').classes()).toContain('text-gray-100')
    })

    it('renders light variant for block code', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'const x = 1',
          block: true,
          variant: 'light',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('pre').classes()).toContain('bg-gray-50')
      expect(wrapper.find('pre').classes()).toContain('text-gray-900')
    })
  })

  // Copyable
  describe('Copyable', () => {
    it('shows copy button when copyable is true', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'const x = 1',
          block: true,
          copyable: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('button').exists()).toBe(true)
    })

    it('does not show copy button by default', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'const x = 1',
          block: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('button').exists()).toBe(false)
    })

    it('copies code to clipboard when button is clicked', async () => {
      const wrapper = mount(Code, {
        props: {
          code: 'const x = 1',
          block: true,
          copyable: true,
        },
        global: {
          components: { Icon },
        },
      })

      await wrapper.find('button').trigger('click')

      expect(clipboardWriteTextSpy).toHaveBeenCalledWith('const x = 1')
    })

    it('shows check icon after copying', async () => {
      const wrapper = mount(Code, {
        props: {
          code: 'test',
          block: true,
          copyable: true,
        },
        global: {
          components: { Icon },
        },
      })

      await wrapper.find('button').trigger('click')
      await wrapper.vm.$nextTick()

      const icon = wrapper.findComponent(Icon)
      expect(icon.props('name')).toBe('check')
    })

    it('shows copy icon by default', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'test',
          block: true,
          copyable: true,
        },
        global: {
          components: { Icon },
        },
      })

      const icon = wrapper.findComponent(Icon)
      expect(icon.props('name')).toBe('copy')
    })

    it('copies slot content when no code prop provided', async () => {
      const wrapper = mount(Code, {
        props: {
          block: true,
          copyable: true,
        },
        slots: {
          default: 'slot content',
        },
        global: {
          components: { Icon },
        },
      })

      await wrapper.find('button').trigger('click')

      expect(clipboardWriteTextSpy).toHaveBeenCalledWith('slot content')
    })
  })

  // Styling
  describe('Styling', () => {
    it('applies font-mono class', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'x',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('code').classes()).toContain('font-mono')
    })

    it('applies padding and rounded to inline code', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'x',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('code').classes()).toContain('px-1.5')
      expect(wrapper.find('code').classes()).toContain('rounded')
    })

    it('applies padding and rounded-lg to block code', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'x',
          block: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('pre').classes()).toContain('p-4')
      expect(wrapper.find('pre').classes()).toContain('rounded-lg')
    })

    it('applies overflow-x-auto to block code', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'long line of code that might overflow',
          block: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('pre').classes()).toContain('overflow-x-auto')
    })

    it('applies overflow-y-auto when maxHeight is set', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'code',
          block: true,
          maxHeight: '200px',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('pre').classes()).toContain('overflow-y-auto')
    })
  })

  // Edge cases
  describe('Edge Cases', () => {
    it('handles empty code', () => {
      const wrapper = mount(Code, {
        props: {
          code: '',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('')
    })

    it('handles multiline code', () => {
      const code = `function test() {
  return true
}`
      const wrapper = mount(Code, {
        props: {
          code,
          block: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('function test()')
      expect(wrapper.text()).toContain('return true')
    })

    it('handles special characters', () => {
      const wrapper = mount(Code, {
        props: {
          code: '<div>Hello & "World"</div>',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('<div>Hello & "World"</div>')
    })
  })

  // Combinations
  describe('Combinations', () => {
    it('renders dark variant block with language and copy button', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'const x = 1',
          block: true,
          variant: 'dark',
          language: 'javascript',
          copyable: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('pre').classes()).toContain('bg-gray-900')
      expect(wrapper.text()).toContain('javascript')
      expect(wrapper.find('button').exists()).toBe(true)
    })

    it('renders light variant inline code', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'x = 1',
          variant: 'light',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('code').classes()).toContain('bg-gray-100')
      expect(wrapper.find('code').classes()).toContain('text-gray-800')
    })
  })

  // Accessibility
  describe('Accessibility', () => {
    it('uses semantic code element for inline', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'x',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('code').exists()).toBe(true)
    })

    it('uses semantic pre and code elements for block', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'x',
          block: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('pre').exists()).toBe(true)
      expect(wrapper.find('pre code').exists()).toBe(true)
    })

    it('copy button has title attribute', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'x',
          block: true,
          copyable: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('button').attributes('title')).toBe('Copy code')
    })

    it('copy button updates title after copying', async () => {
      const wrapper = mount(Code, {
        props: {
          code: 'x',
          block: true,
          copyable: true,
        },
        global: {
          components: { Icon },
        },
      })

      await wrapper.find('button').trigger('click')
      await wrapper.vm.$nextTick()

      expect(wrapper.find('button').attributes('title')).toBe('Copied!')
    })

    it('copy button has type button', () => {
      const wrapper = mount(Code, {
        props: {
          code: 'x',
          block: true,
          copyable: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('button').attributes('type')).toBe('button')
    })
  })
})
