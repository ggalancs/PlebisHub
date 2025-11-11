import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Pagination from './Pagination.vue'
import Icon from '../atoms/Icon.vue'

describe('Pagination', () => {
  describe('rendering', () => {
    it('renders pagination nav', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 100 },
      })

      expect(wrapper.find('nav[role="navigation"]').exists()).toBe(true)
    })

    it('renders page number buttons', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 50, pageSize: 10 },
      })

      // Should have 5 pages
      const buttons = wrapper.findAll('button')
      // Previous, 1, 2, 3, 4, 5, Next = 7 buttons
      expect(buttons.length).toBe(7)
    })

    it('renders previous and next buttons', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 2, totalItems: 50 },
      })

      const icons = wrapper.findAllComponents(Icon)
      const iconNames = icons.map((icon) => icon.props('name'))

      expect(iconNames).toContain('chevron-left')
      expect(iconNames).toContain('chevron-right')
    })

    it('renders first and last buttons when showFirstLast is true', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 5, totalItems: 100, showFirstLast: true },
      })

      const icons = wrapper.findAllComponents(Icon)
      const iconNames = icons.map((icon) => icon.props('name'))

      expect(iconNames).toContain('chevrons-left')
      expect(iconNames).toContain('chevrons-right')
    })

    it('does not render first and last buttons by default', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 5, totalItems: 100 },
      })

      const icons = wrapper.findAllComponents(Icon)
      const iconNames = icons.map((icon) => icon.props('name'))

      expect(iconNames).not.toContain('chevrons-left')
      expect(iconNames).not.toContain('chevrons-right')
    })

    it('highlights current page', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 3, totalItems: 50 },
      })

      const buttons = wrapper.findAll('button')
      const currentPageButton = buttons.find((btn) => btn.text() === '3')

      expect(currentPageButton?.classes()).toContain('bg-primary-600')
      expect(currentPageButton?.classes()).toContain('text-white')
    })

    it('renders ellipsis for many pages', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 10, totalItems: 200, pageSize: 10, maxButtons: 7 },
      })

      const buttons = wrapper.findAll('button')
      const ellipsisButton = buttons.find((btn) => btn.text() === '...')

      expect(ellipsisButton?.exists()).toBe(true)
    })

    it('renders total count when showTotal is true', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 100, showTotal: true },
      })

      expect(wrapper.text()).toContain('Showing 1 to 10 of 100 results')
    })

    it('hides total count when showTotal is false', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 100, showTotal: false },
      })

      expect(wrapper.text()).not.toContain('Showing')
    })

    it('renders page size selector when showPageSize is true', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 100, showPageSize: true },
      })

      expect(wrapper.find('select').exists()).toBe(true)
      expect(wrapper.text()).toContain('Per page:')
    })

    it('hides page size selector by default', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 100 },
      })

      expect(wrapper.find('select').exists()).toBe(false)
    })

    it('renders with no results message', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 0, showTotal: true },
      })

      expect(wrapper.text()).toContain('No results')
    })

    it('does not render page buttons when no items', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 0 },
      })

      // Should only show total count section, no page buttons
      const buttons = wrapper.findAll('button')
      expect(buttons.length).toBe(0)
    })
  })

  describe('sizes', () => {
    it('renders small size', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 50, size: 'sm' },
      })

      const button = wrapper.find('button')
      expect(button.classes()).toContain('h-8')
      expect(button.classes()).toContain('text-sm')
    })

    it('renders medium size by default', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 50 },
      })

      const button = wrapper.find('button')
      expect(button.classes()).toContain('h-9')
    })

    it('renders large size', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 50, size: 'lg' },
      })

      const button = wrapper.find('button')
      expect(button.classes()).toContain('h-10')
      expect(button.classes()).toContain('text-base')
    })
  })

  describe('behavior', () => {
    it('emits page-change when page button clicked', async () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 50 },
      })

      const buttons = wrapper.findAll('button')
      const page2Button = buttons.find((btn) => btn.text() === '2')
      await page2Button?.trigger('click')

      expect(wrapper.emitted('page-change')).toBeTruthy()
      expect(wrapper.emitted('page-change')?.[0]).toEqual([2])
    })

    it('emits update:currentPage when page changes', async () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 50 },
      })

      const buttons = wrapper.findAll('button')
      const page3Button = buttons.find((btn) => btn.text() === '3')
      await page3Button?.trigger('click')

      expect(wrapper.emitted('update:currentPage')).toBeTruthy()
      expect(wrapper.emitted('update:currentPage')?.[0]).toEqual([3])
    })

    it('navigates to previous page', async () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 3, totalItems: 50 },
      })

      const buttons = wrapper.findAll('button')
      const prevButton = buttons[0] // First button is previous
      await prevButton.trigger('click')

      expect(wrapper.emitted('page-change')?.[0]).toEqual([2])
    })

    it('navigates to next page', async () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 2, totalItems: 50 },
      })

      const buttons = wrapper.findAll('button')
      const nextButton = buttons[buttons.length - 1] // Last button is next
      await nextButton.trigger('click')

      expect(wrapper.emitted('page-change')?.[0]).toEqual([3])
    })

    it('navigates to first page', async () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 5, totalItems: 100, showFirstLast: true },
      })

      const buttons = wrapper.findAll('button')
      const firstButton = buttons[0] // First button is first page
      await firstButton.trigger('click')

      expect(wrapper.emitted('page-change')?.[0]).toEqual([1])
    })

    it('navigates to last page', async () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 100, pageSize: 10, showFirstLast: true },
      })

      const buttons = wrapper.findAll('button')
      const lastButton = buttons[buttons.length - 1] // Last button is last page
      await lastButton.trigger('click')

      expect(wrapper.emitted('page-change')?.[0]).toEqual([10])
    })

    it('does not emit when clicking current page', async () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 2, totalItems: 50 },
      })

      const buttons = wrapper.findAll('button')
      const currentButton = buttons.find((btn) => btn.text() === '2')
      await currentButton?.trigger('click')

      expect(wrapper.emitted('page-change')).toBeFalsy()
    })

    it('does not emit when clicking ellipsis', async () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 10, totalItems: 200, pageSize: 10, maxButtons: 7 },
      })

      const buttons = wrapper.findAll('button')
      const ellipsisButton = buttons.find((btn) => btn.text() === '...')
      await ellipsisButton?.trigger('click')

      expect(wrapper.emitted('page-change')).toBeFalsy()
    })

    it('emits page-size-change when page size changes', async () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 100, showPageSize: true },
      })

      const select = wrapper.find('select')
      await select.setValue('20')

      expect(wrapper.emitted('page-size-change')).toBeTruthy()
      expect(wrapper.emitted('page-size-change')?.[0]).toEqual([20])
    })

    it('emits update:pageSize when page size changes', async () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 100, showPageSize: true },
      })

      const select = wrapper.find('select')
      await select.setValue('50')

      expect(wrapper.emitted('update:pageSize')).toBeTruthy()
      expect(wrapper.emitted('update:pageSize')?.[0]).toEqual([50])
    })

    it('adjusts current page when page size increases', async () => {
      const wrapper = mount(Pagination, {
        props: {
          currentPage: 10, // Last page with pageSize 10
          totalItems: 100,
          pageSize: 10,
          showPageSize: true,
        },
      })

      const select = wrapper.find('select')
      await select.setValue('50') // This should reduce total pages to 2

      // Should adjust current page to 2 (last valid page)
      expect(wrapper.emitted('update:currentPage')?.[0]).toEqual([2])
    })
  })

  describe('disabled state', () => {
    it('disables all page buttons when disabled', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 2, totalItems: 50, disabled: true },
      })

      const buttons = wrapper.findAll('button')
      buttons.forEach((button) => {
        expect(button.element.disabled).toBe(true)
      })
    })

    it('disables page size selector when disabled', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 100, showPageSize: true, disabled: true },
      })

      const select = wrapper.find('select')
      expect(select.element.disabled).toBe(true)
    })

    it('does not emit events when disabled', async () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 2, totalItems: 50, disabled: true },
      })

      const buttons = wrapper.findAll('button')
      const page3Button = buttons.find((btn) => btn.text() === '3')
      await page3Button?.trigger('click')

      expect(wrapper.emitted('page-change')).toBeFalsy()
    })
  })

  describe('edge cases', () => {
    it('disables previous button on first page', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 50 },
      })

      const buttons = wrapper.findAll('button')
      const prevButton = buttons[0]
      expect(prevButton.element.disabled).toBe(true)
    })

    it('disables next button on last page', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 5, totalItems: 50, pageSize: 10 },
      })

      const buttons = wrapper.findAll('button')
      const nextButton = buttons[buttons.length - 1]
      expect(nextButton.element.disabled).toBe(true)
    })

    it('handles single page', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 5, pageSize: 10 },
      })

      const buttons = wrapper.findAll('button')
      // Previous (disabled), page 1, next (disabled)
      expect(buttons.length).toBe(3)
      expect(buttons[0].element.disabled).toBe(true) // prev
      expect(buttons[2].element.disabled).toBe(true) // next
    })

    it('calculates correct start and end items', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 3, totalItems: 45, pageSize: 10, showTotal: true },
      })

      expect(wrapper.text()).toContain('Showing 21 to 30 of 45 results')
    })

    it('handles last page with fewer items', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 5, totalItems: 45, pageSize: 10, showTotal: true },
      })

      expect(wrapper.text()).toContain('Showing 41 to 45 of 45 results')
    })

    it('handles exactly one full page', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 10, pageSize: 10, showTotal: true },
      })

      expect(wrapper.text()).toContain('Showing 1 to 10 of 10 results')
    })
  })

  describe('page size options', () => {
    it('renders default page size options', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 100, showPageSize: true },
      })

      const options = wrapper.findAll('option')
      expect(options.length).toBe(4) // 10, 20, 50, 100
      expect(options[0].text()).toBe('10')
      expect(options[1].text()).toBe('20')
      expect(options[2].text()).toBe('50')
      expect(options[3].text()).toBe('100')
    })

    it('renders custom page size options', () => {
      const wrapper = mount(Pagination, {
        props: {
          currentPage: 1,
          totalItems: 100,
          showPageSize: true,
          pageSizeOptions: [5, 15, 25],
        },
      })

      const options = wrapper.findAll('option')
      expect(options.length).toBe(3)
      expect(options[0].text()).toBe('5')
      expect(options[1].text()).toBe('15')
      expect(options[2].text()).toBe('25')
    })

    it('shows current page size as selected', () => {
      const wrapper = mount(Pagination, {
        props: {
          currentPage: 1,
          totalItems: 100,
          pageSize: 20,
          showPageSize: true,
        },
      })

      const select = wrapper.find('select')
      expect(select.element.value).toBe('20')
    })
  })

  describe('ellipsis logic', () => {
    it('shows ellipsis when near start', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 3, totalItems: 200, pageSize: 10, maxButtons: 7 },
      })

      const buttons = wrapper.findAll('button')
      const buttonTexts = buttons.map((btn) => btn.text()).filter((text) => text !== '')

      expect(buttonTexts).toContain('...')
    })

    it('shows ellipsis when near end', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 18, totalItems: 200, pageSize: 10, maxButtons: 7 },
      })

      const buttons = wrapper.findAll('button')
      const buttonTexts = buttons.map((btn) => btn.text()).filter((text) => text !== '')

      expect(buttonTexts).toContain('...')
    })

    it('shows two ellipsis when in middle', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 10, totalItems: 200, pageSize: 10, maxButtons: 7 },
      })

      const buttons = wrapper.findAll('button')
      const buttonTexts = buttons.map((btn) => btn.text()).filter((text) => text !== '')
      const ellipsisCount = buttonTexts.filter((text) => text === '...').length

      expect(ellipsisCount).toBe(2)
    })

    it('does not show ellipsis for few pages', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 3, totalItems: 50, pageSize: 10, maxButtons: 7 },
      })

      const buttons = wrapper.findAll('button')
      const buttonTexts = buttons.map((btn) => btn.text()).filter((text) => text !== '')

      expect(buttonTexts).not.toContain('...')
    })
  })

  describe('accessibility', () => {
    it('has navigation role', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 50 },
      })

      expect(wrapper.find('nav[role="navigation"]').exists()).toBe(true)
    })

    it('has aria-label on nav', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 50 },
      })

      const nav = wrapper.find('nav')
      expect(nav.attributes('aria-label')).toBe('Pagination')
    })

    it('has aria-labels on navigation buttons', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 2, totalItems: 50 },
      })

      const buttons = wrapper.findAll('button')
      expect(buttons[0].attributes('aria-label')).toBe('Go to previous page')
      expect(buttons[buttons.length - 1].attributes('aria-label')).toBe('Go to next page')
    })

    it('has aria-label on page number buttons', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 50 },
      })

      const buttons = wrapper.findAll('button')
      const page2Button = buttons.find((btn) => btn.text() === '2')

      expect(page2Button?.attributes('aria-label')).toBe('Go to page 2')
    })

    it('has aria-current on current page', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 3, totalItems: 50 },
      })

      const buttons = wrapper.findAll('button')
      const currentButton = buttons.find((btn) => btn.text() === '3')

      expect(currentButton?.attributes('aria-current')).toBe('page')
    })

    it('ellipsis button has no aria-label', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 10, totalItems: 200, pageSize: 10, maxButtons: 7 },
      })

      const buttons = wrapper.findAll('button')
      const ellipsisButton = buttons.find((btn) => btn.text() === '...')

      expect(ellipsisButton?.attributes('aria-label')).toBeUndefined()
    })

    it('has label for page size selector', () => {
      const wrapper = mount(Pagination, {
        props: { currentPage: 1, totalItems: 100, showPageSize: true },
      })

      const label = wrapper.find('label')
      const select = wrapper.find('select')

      expect(label.exists()).toBe(true)
      expect(label.attributes('for')).toBe(select.attributes('id'))
    })
  })

  describe('combinations', () => {
    it('renders with all features enabled', () => {
      const wrapper = mount(Pagination, {
        props: {
          currentPage: 5,
          totalItems: 200,
          pageSize: 20,
          showPageSize: true,
          showTotal: true,
          showFirstLast: true,
          size: 'lg',
        },
      })

      expect(wrapper.text()).toContain('Showing')
      expect(wrapper.find('select').exists()).toBe(true)

      const icons = wrapper.findAllComponents(Icon)
      const iconNames = icons.map((icon) => icon.props('name'))

      expect(iconNames).toContain('chevrons-left')
      expect(iconNames).toContain('chevrons-right')
    })

    it('works with minimal props', () => {
      const wrapper = mount(Pagination, {
        props: {
          currentPage: 1,
          totalItems: 50,
        },
      })

      expect(wrapper.find('nav').exists()).toBe(true)
      expect(wrapper.findAll('button').length).toBeGreaterThan(0)
    })
  })
})
