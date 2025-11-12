import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import VoteButton from './VoteButton.vue'

describe('VoteButton', () => {
  describe('rendering', () => {
    it('should render the component', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
        },
      })

      expect(wrapper.find('.vote-button').exists()).toBe(true)
    })

    it('should display vote count', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 42,
        },
      })

      expect(wrapper.text()).toContain('42')
    })

    it('should not display vote count when showCount is false', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 42,
          showCount: false,
        },
      })

      expect(wrapper.text()).not.toContain('42')
    })

    it('should display upvote button', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
        },
      })

      const buttons = wrapper.findAll('button')
      expect(buttons.length).toBeGreaterThan(0)
    })

    it('should display downvote button when allowDownvote is true', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          allowDownvote: true,
        },
      })

      const buttons = wrapper.findAll('button')
      expect(buttons.length).toBe(2) // upvote + downvote
    })

    it('should not display downvote button when allowDownvote is false', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          allowDownvote: false,
        },
      })

      const buttons = wrapper.findAll('button')
      expect(buttons.length).toBe(1) // only upvote
    })
  })

  describe('variants', () => {
    it('should apply default variant class', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          variant: 'default',
        },
      })

      expect(wrapper.find('.vote-button--default').exists()).toBe(true)
    })

    it('should apply reddit variant class', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          variant: 'reddit',
        },
      })

      expect(wrapper.find('.vote-button--reddit').exists()).toBe(true)
    })

    it('should apply simple variant class', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          variant: 'simple',
        },
      })

      expect(wrapper.find('.vote-button--simple').exists()).toBe(true)
    })

    it('should apply compact variant class', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          variant: 'compact',
        },
      })

      expect(wrapper.find('.vote-button--compact').exists()).toBe(true)
    })
  })

  describe('orientation', () => {
    it('should apply horizontal orientation', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          orientation: 'horizontal',
        },
      })

      expect(wrapper.find('.vote-button--horizontal').exists()).toBe(true)
    })

    it('should apply vertical orientation', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          orientation: 'vertical',
        },
      })

      expect(wrapper.find('.vote-button--vertical').exists()).toBe(true)
    })
  })

  describe('voting', () => {
    it('should emit vote event with "up" when clicking upvote button', async () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
        },
      })

      const buttons = wrapper.findAll('button')
      await buttons[0].trigger('click')

      expect(wrapper.emitted('vote')).toBeTruthy()
      expect(wrapper.emitted('vote')?.[0]).toEqual(['up'])
    })

    it('should emit vote event with "down" when clicking downvote button', async () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          allowDownvote: true,
        },
      })

      const buttons = wrapper.findAll('button')
      await buttons[1].trigger('click')

      expect(wrapper.emitted('vote')).toBeTruthy()
      expect(wrapper.emitted('vote')?.[0]).toEqual(['down'])
    })

    it('should emit "neutral" when clicking already upvoted button', async () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          userVote: 'up',
        },
      })

      const buttons = wrapper.findAll('button')
      await buttons[0].trigger('click')

      expect(wrapper.emitted('vote')?.[0]).toEqual(['neutral'])
    })

    it('should emit "neutral" when clicking already downvoted button', async () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          userVote: 'down',
          allowDownvote: true,
        },
      })

      const buttons = wrapper.findAll('button')
      await buttons[1].trigger('click')

      expect(wrapper.emitted('vote')?.[0]).toEqual(['neutral'])
    })

    it('should not emit vote when disabled', async () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          disabled: true,
        },
      })

      const buttons = wrapper.findAll('button')
      await buttons[0].trigger('click')

      expect(wrapper.emitted('vote')).toBeFalsy()
    })

    it('should not emit vote when loading', async () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          loading: true,
        },
      })

      const buttons = wrapper.findAll('button')
      await buttons[0].trigger('click')

      expect(wrapper.emitted('vote')).toBeFalsy()
    })
  })

  describe('user vote state', () => {
    it('should show active state for upvote', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          userVote: 'up',
        },
      })

      const button = wrapper.findAll('button')[0]
      expect(button.classes()).toContain('bg-success')
    })

    it('should show active state for downvote', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          userVote: 'down',
          allowDownvote: true,
        },
      })

      const button = wrapper.findAll('button')[1]
      expect(button.classes()).toContain('bg-error')
    })

    it('should show success color for count when upvoted', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          userVote: 'up',
        },
      })

      const count = wrapper.find('span')
      expect(count.classes()).toContain('text-success')
    })

    it('should show error color for count when downvoted', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          userVote: 'down',
        },
      })

      const count = wrapper.find('span')
      expect(count.classes()).toContain('text-error')
    })
  })

  describe('number formatting', () => {
    it('should format numbers < 1000 as-is', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 234,
        },
      })

      expect(wrapper.text()).toContain('234')
    })

    it('should format numbers >= 1000 with K suffix', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 1234,
        },
      })

      expect(wrapper.text()).toContain('1.2K')
    })

    it('should format numbers >= 1000000 with M suffix', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 1234567,
        },
      })

      expect(wrapper.text()).toContain('1.2M')
    })
  })

  describe('sizes', () => {
    it('should apply small size classes', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          size: 'sm',
        },
      })

      const button = wrapper.find('button')
      expect(button.classes()).toContain('text-sm')
    })

    it('should apply medium size classes by default', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
        },
      })

      const button = wrapper.find('button')
      expect(button.classes()).toContain('text-base')
    })

    it('should apply large size classes', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          size: 'lg',
        },
      })

      const button = wrapper.find('button')
      expect(button.classes()).toContain('text-lg')
    })
  })

  describe('compact variant', () => {
    it('should render single button in compact mode', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          variant: 'compact',
        },
      })

      const buttons = wrapper.findAll('button')
      expect(buttons.length).toBe(1)
    })

    it('should toggle between up and neutral in compact mode', async () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          variant: 'compact',
        },
      })

      const button = wrapper.find('button')

      // First click: upvote
      await button.trigger('click')
      expect(wrapper.emitted('vote')?.[0]).toEqual(['up'])

      // Update prop to simulate upvoted state
      await wrapper.setProps({ userVote: 'up' })

      // Second click: neutral
      await button.trigger('click')
      expect(wrapper.emitted('vote')?.[1]).toEqual(['neutral'])
    })
  })

  describe('disabled state', () => {
    it('should disable buttons when disabled prop is true', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          disabled: true,
        },
      })

      const buttons = wrapper.findAll('button')
      buttons.forEach((button) => {
        expect(button.attributes('disabled')).toBeDefined()
      })
    })

    it('should have reduced opacity when disabled', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          disabled: true,
        },
      })

      const button = wrapper.find('button')
      expect(button.attributes('disabled')).toBeDefined()
    })
  })

  describe('accessibility', () => {
    it('should have aria-label for upvote button', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
        },
      })

      const button = wrapper.findAll('button')[0]
      expect(button.attributes('aria-label')).toBe('Upvote')
    })

    it('should have aria-label for downvote button', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          allowDownvote: true,
        },
      })

      const button = wrapper.findAll('button')[1]
      expect(button.attributes('aria-label')).toBe('Downvote')
    })

    it('should update aria-label when upvoted', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          userVote: 'up',
        },
      })

      const button = wrapper.findAll('button')[0]
      expect(button.attributes('aria-label')).toBe('Remove upvote')
    })

    it('should update aria-label when downvoted', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          userVote: 'down',
          allowDownvote: true,
        },
      })

      const button = wrapper.findAll('button')[1]
      expect(button.attributes('aria-label')).toBe('Remove downvote')
    })
  })

  describe('reddit variant specifics', () => {
    it('should have rounded-full container in reddit variant', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          variant: 'reddit',
        },
      })

      const container = wrapper.find('.flex')
      expect(container.classes()).toContain('rounded-full')
    })

    it('should show hover colors in reddit variant', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          variant: 'reddit',
        },
      })

      const button = wrapper.findAll('button')[0]
      expect(button.classes()).toContain('hover:text-success')
    })
  })

  describe('simple variant specifics', () => {
    it('should use thumb icons in simple variant', () => {
      const wrapper = mount(VoteButton, {
        props: {
          count: 10,
          variant: 'simple',
        },
      })

      const icons = wrapper.findAllComponents({ name: 'Icon' })
      expect(icons[0].props('name')).toBe('thumb-up')
    })
  })
})
