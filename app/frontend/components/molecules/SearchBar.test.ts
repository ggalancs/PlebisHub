import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount } from '@vue/test-utils'
import SearchBar from './SearchBar.vue'
import Input from '../atoms/Input.vue'

describe('SearchBar', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.restoreAllMocks()
  })

  describe('rendering', () => {
    it('renders search input', () => {
      const wrapper = mount(SearchBar)

      expect(wrapper.findComponent(Input).exists()).toBe(true)
    })

    it('renders with default placeholder', () => {
      const wrapper = mount(SearchBar)

      const input = wrapper.findComponent(Input)
      expect(input.props('placeholder')).toBe('Search...')
    })

    it('renders with custom placeholder', () => {
      const wrapper = mount(SearchBar, {
        props: { placeholder: 'Search products...' },
      })

      const input = wrapper.findComponent(Input)
      expect(input.props('placeholder')).toBe('Search products...')
    })

    it('renders search icon', () => {
      const wrapper = mount(SearchBar)

      const searchIcon = wrapper.find('svg')
      expect(searchIcon.exists()).toBe(true)
    })

    it('does not render search button by default', () => {
      const wrapper = mount(SearchBar)

      expect(wrapper.find('button[type="button"]').exists()).toBe(false)
    })

    it('renders search button when showButton is true', () => {
      const wrapper = mount(SearchBar, {
        props: { showButton: true },
      })

      const button = wrapper.find('button[type="button"]')
      expect(button.exists()).toBe(true)
      expect(button.text()).toContain('Search')
    })

    it('renders custom button text', () => {
      const wrapper = mount(SearchBar, {
        props: { showButton: true, buttonText: 'Find' },
      })

      expect(wrapper.find('button[type="button"]').text()).toContain('Find')
    })

    it('renders different sizes', () => {
      const sizes = ['sm', 'md', 'lg'] as const

      sizes.forEach((size) => {
        const wrapper = mount(SearchBar, {
          props: { size },
        })

        const input = wrapper.findComponent(Input)
        expect(input.props('size')).toBe(size)
      })
    })

    it('renders disabled state', () => {
      const wrapper = mount(SearchBar, {
        props: { disabled: true },
      })

      const input = wrapper.findComponent(Input)
      expect(input.props('disabled')).toBe(true)
    })

    it('does not render clear button when input is empty', () => {
      const wrapper = mount(SearchBar, {
        props: { modelValue: '' },
      })

      // Clear button should not exist
      const buttons = wrapper.findAll('button')
      expect(buttons.length).toBe(0)
    })

    it('renders clear button when input has value', async () => {
      const wrapper = mount(SearchBar, {
        props: { modelValue: 'test query' },
      })

      await wrapper.vm.$nextTick()

      // Should have clear button in suffix slot
      const clearButton = wrapper.find('button[type="button"]')
      expect(clearButton.exists()).toBe(true)
    })
  })

  describe('behavior', () => {
    it('emits update:modelValue when typing', async () => {
      const wrapper = mount(SearchBar)

      const input = wrapper.findComponent(Input)
      await input.vm.$emit('update:modelValue', 'search term')

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['search term'])
    })

    it('emits search event when typing without debounce', async () => {
      const wrapper = mount(SearchBar, {
        props: { debounce: 0 },
      })

      const input = wrapper.findComponent(Input)
      await input.vm.$emit('update:modelValue', 'test')

      expect(wrapper.emitted('search')).toBeTruthy()
      expect(wrapper.emitted('search')?.[0]).toEqual(['test'])
    })

    it('debounces search event', async () => {
      const wrapper = mount(SearchBar, {
        props: { debounce: 300 },
      })

      const input = wrapper.findComponent(Input)

      // Type multiple times quickly
      await input.vm.$emit('update:modelValue', 't')
      await input.vm.$emit('update:modelValue', 'te')
      await input.vm.$emit('update:modelValue', 'tes')
      await input.vm.$emit('update:modelValue', 'test')

      // Search should not have been emitted yet
      expect(wrapper.emitted('search')).toBeFalsy()

      // Advance timers
      vi.advanceTimersByTime(300)
      await wrapper.vm.$nextTick()

      // Now search should be emitted once with final value
      expect(wrapper.emitted('search')).toBeTruthy()
      expect(wrapper.emitted('search')?.length).toBe(1)
    })

    it('clears input when clear button is clicked', async () => {
      const wrapper = mount(SearchBar, {
        props: { modelValue: 'test query' },
      })

      await wrapper.vm.$nextTick()

      const clearButton = wrapper.find('button[type="button"]')
      await clearButton.trigger('click')

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([''])
      expect(wrapper.emitted('clear')).toBeTruthy()
      expect(wrapper.emitted('search')).toBeTruthy()
    })

    it('emits search event when search button is clicked', async () => {
      const wrapper = mount(SearchBar, {
        props: { showButton: true, modelValue: 'test' },
      })

      const searchButton = wrapper.findAll('button').find((btn) => btn.text().includes('Search'))
      await searchButton?.trigger('click')

      expect(wrapper.emitted('search')).toBeTruthy()
    })

    it('does not emit search when button is disabled', async () => {
      const wrapper = mount(SearchBar, {
        props: { showButton: true, disabled: true },
      })

      const searchButton = wrapper.findAll('button').find((btn) => btn.text().includes('Search'))
      expect(searchButton?.element.disabled).toBe(true)
    })

    it('does not emit search when loading', async () => {
      const wrapper = mount(SearchBar, {
        props: { showButton: true, loading: true },
      })

      const searchButton = wrapper.findAll('button').find((btn) => btn.text().includes('Search'))
      expect(searchButton?.element.disabled).toBe(true)
    })
  })

  describe('loading state', () => {
    it('shows loader icon when loading', () => {
      const wrapper = mount(SearchBar, {
        props: { showButton: true, loading: true },
      })

      const button = wrapper.findAll('button').find((btn) => btn.text().includes('Search'))
      // Check for animate-spin class which is present on the loader icon
      expect(button?.html()).toContain('animate-spin')
    })

    it('disables button when loading', () => {
      const wrapper = mount(SearchBar, {
        props: { showButton: true, loading: true },
      })

      const button = wrapper.findAll('button').find((btn) => btn.text().includes('Search'))
      expect(button?.element.disabled).toBe(true)
    })

    it('applies loading styles to button', () => {
      const wrapper = mount(SearchBar, {
        props: { showButton: true, loading: true },
      })

      const button = wrapper.findAll('button').find((btn) => btn.text().includes('Search'))
      expect(button?.classes()).toContain('bg-primary-400')
      expect(button?.classes()).toContain('cursor-wait')
    })
  })

  describe('clear button', () => {
    it('shows clear button when showClear is true and has value', async () => {
      const wrapper = mount(SearchBar, {
        props: { showClear: true, modelValue: 'test' },
      })

      await wrapper.vm.$nextTick()

      const clearButton = wrapper.find('button[type="button"]')
      expect(clearButton.exists()).toBe(true)
    })

    it('hides clear button when showClear is false', () => {
      const wrapper = mount(SearchBar, {
        props: { showClear: false, modelValue: 'test' },
      })

      const clearButton = wrapper.find('button[type="button"]')
      expect(clearButton.exists()).toBe(false)
    })

    it('hides clear button when input is empty', () => {
      const wrapper = mount(SearchBar, {
        props: { showClear: true, modelValue: '' },
      })

      const clearButton = wrapper.find('button[type="button"]')
      expect(clearButton.exists()).toBe(false)
    })

    it('hides clear button when disabled', () => {
      const wrapper = mount(SearchBar, {
        props: { showClear: true, modelValue: 'test', disabled: true },
      })

      const clearButton = wrapper.find('button[type="button"]')
      expect(clearButton.exists()).toBe(false)
    })
  })

  describe('button sizes', () => {
    it('applies correct button size classes', () => {
      const sizes = ['sm', 'md', 'lg'] as const

      sizes.forEach((size) => {
        const wrapper = mount(SearchBar, {
          props: { showButton: true, size },
        })

        const button = wrapper.findAll('button').find((btn) => btn.text().includes('Search'))
        expect(button?.classes()).toContain(
          size === 'sm' ? 'text-sm' : size === 'md' ? 'text-base' : 'text-lg'
        )
      })
    })
  })

  describe('v-model integration', () => {
    it('works with v-model', async () => {
      const wrapper = mount(SearchBar, {
        props: {
          modelValue: '',
          'onUpdate:modelValue': (value: string) => wrapper.setProps({ modelValue: value }),
        },
      })

      const input = wrapper.findComponent(Input)
      await input.vm.$emit('update:modelValue', 'new value')

      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['new value'])
    })
  })

  describe('combinations', () => {
    it('renders with all features', () => {
      const wrapper = mount(SearchBar, {
        props: {
          modelValue: 'test',
          placeholder: 'Search items...',
          size: 'lg',
          showButton: true,
          buttonText: 'Find',
          showClear: true,
        },
      })

      const input = wrapper.findComponent(Input)
      expect(input.props('placeholder')).toBe('Search items...')
      expect(input.props('size')).toBe('lg')

      const button = wrapper.findAll('button').find((btn) => btn.text().includes('Find'))
      expect(button?.exists()).toBe(true)
    })
  })
})
