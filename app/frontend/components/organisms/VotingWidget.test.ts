import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import VotingWidget from './VotingWidget.vue'
import type { VoteData } from './VotingWidget.vue'

const mockVoteData: VoteData = {
  votes: 234,
  supportsCount: 567,
  hotness: 8900,
  hasVoted: false,
  hasSupported: false,
  closed: false,
}

describe('VotingWidget', () => {
  describe('rendering', () => {
    it('should render the component', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
        },
      })

      expect(wrapper.find('.voting-widget').exists()).toBe(true)
    })

    it('should display vote count', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('234')
      expect(wrapper.text()).toContain('votos')
    })

    it('should display support count', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('567')
      expect(wrapper.text()).toContain('apoyos')
    })

    it('should display singular label for 1 vote', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, votes: 1 },
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('voto')
    })

    it('should display singular label for 1 support', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, supportsCount: 1 },
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('apoyo')
    })

    it('should display hotness badge by default', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
        },
      })

      expect(wrapper.find('.voting-widget__hotness').exists()).toBe(true)
    })

    it('should not display hotness in compact mode', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
          compact: true,
        },
      })

      expect(wrapper.find('.voting-widget__hotness').exists()).toBe(false)
    })
  })

  describe('hotness levels', () => {
    it('should show "cool" for hotness < 5000', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, hotness: 3000 },
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('Activa')
    })

    it('should show "warm" for hotness >= 5000', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, hotness: 6000 },
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('Popular')
    })

    it('should show "hot" for hotness >= 10000', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, hotness: 12000 },
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('Candente')
    })

    it('should show "very-hot" for hotness >= 15000', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, hotness: 20000 },
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('Muy Candente')
    })
  })

  describe('number formatting', () => {
    it('should format numbers < 1000 as-is', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, votes: 234 },
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('234')
    })

    it('should format numbers >= 1000 with K suffix', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, votes: 1234 },
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('1.2K')
    })

    it('should format numbers >= 1000000 with M suffix', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, votes: 1234567 },
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('1.2M')
    })
  })

  describe('voting', () => {
    it('should emit vote event when authenticated user clicks vote button', async () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
          isAuthenticated: true,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      await buttons[0].trigger('click')

      expect(wrapper.emitted('vote')).toBeTruthy()
      expect(wrapper.emitted('vote')).toHaveLength(1)
    })

    it('should emit login-required event when unauthenticated user tries to vote', async () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
          isAuthenticated: false,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      await buttons[0].trigger('click')

      expect(wrapper.emitted('login-required')).toBeTruthy()
      expect(wrapper.emitted('login-required')?.[0]).toEqual(['vote'])
    })

    it('should not emit vote event when already voted', async () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, hasVoted: true },
          itemId: 1,
          isAuthenticated: true,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      await buttons[0].trigger('click')

      expect(wrapper.emitted('vote')).toBeFalsy()
    })

    it('should not emit vote event when voting is closed', async () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, closed: true },
          itemId: 1,
          isAuthenticated: true,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      await buttons[0].trigger('click')

      expect(wrapper.emitted('vote')).toBeFalsy()
    })

    it('should not emit vote event when disabled', async () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
          isAuthenticated: true,
          disabled: true,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      await buttons[0].trigger('click')

      expect(wrapper.emitted('vote')).toBeFalsy()
    })

    it('should show "Votado" when user has voted', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, hasVoted: true },
          itemId: 1,
          isAuthenticated: true,
        },
      })

      expect(wrapper.text()).toContain('Votado')
    })
  })

  describe('supporting', () => {
    it('should emit support event when authenticated user clicks support button', async () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
          isAuthenticated: true,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      await buttons[1].trigger('click')

      expect(wrapper.emitted('support')).toBeTruthy()
      expect(wrapper.emitted('support')).toHaveLength(1)
    })

    it('should emit login-required event when unauthenticated user tries to support', async () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
          isAuthenticated: false,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      await buttons[1].trigger('click')

      expect(wrapper.emitted('login-required')).toBeTruthy()
      expect(wrapper.emitted('login-required')?.[0]).toEqual(['support'])
    })

    it('should not emit support event when already supported', async () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, hasSupported: true },
          itemId: 1,
          isAuthenticated: true,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      await buttons[1].trigger('click')

      expect(wrapper.emitted('support')).toBeFalsy()
    })

    it('should not emit support event when voting is closed', async () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, closed: true },
          itemId: 1,
          isAuthenticated: true,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      await buttons[1].trigger('click')

      expect(wrapper.emitted('support')).toBeFalsy()
    })

    it('should show "Apoyado" when user has supported', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, hasSupported: true },
          itemId: 1,
          isAuthenticated: true,
        },
      })

      expect(wrapper.text()).toContain('Apoyado')
    })
  })

  describe('loading states', () => {
    it('should show loading state for vote button', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
          isAuthenticated: true,
          loadingVote: true,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      expect(buttons[0].props('loading')).toBe(true)
    })

    it('should show loading state for support button', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
          isAuthenticated: true,
          loadingSupport: true,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      expect(buttons[1].props('loading')).toBe(true)
    })

    it('should disable vote button when loading', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
          isAuthenticated: true,
          loadingVote: true,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      expect(buttons[0].props('disabled')).toBe(true)
    })
  })

  describe('closed voting', () => {
    it('should show closed message when voting is closed', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, closed: true },
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('La votación ha finalizado')
    })

    it('should add closed class when voting is closed', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, closed: true },
          itemId: 1,
        },
      })

      expect(wrapper.find('.voting-widget--closed').exists()).toBe(true)
    })

    it('should disable both buttons when voting is closed', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, closed: true },
          itemId: 1,
          isAuthenticated: true,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      expect(buttons[0].props('disabled')).toBe(true)
      expect(buttons[1].props('disabled')).toBe(true)
    })
  })

  describe('authentication', () => {
    it('should show authentication message when not authenticated', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
          isAuthenticated: false,
        },
      })

      expect(wrapper.text()).toContain('Inicia sesión para participar')
    })

    it('should not show authentication message when authenticated', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
          isAuthenticated: true,
        },
      })

      expect(wrapper.text()).not.toContain('Inicia sesión para participar')
    })

    it('should not show authentication message when closed', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, closed: true },
          itemId: 1,
          isAuthenticated: false,
        },
      })

      expect(wrapper.text()).not.toContain('Inicia sesión para participar')
    })
  })

  describe('layout variants', () => {
    it('should apply compact class in compact mode', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
          compact: true,
        },
      })

      expect(wrapper.find('.voting-widget--compact').exists()).toBe(true)
    })

    it('should apply vertical class in vertical mode', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
          vertical: true,
        },
      })

      expect(wrapper.find('.voting-widget--vertical').exists()).toBe(true)
    })

    it('should use smaller button size in compact mode', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
          compact: true,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      expect(buttons[0].props('size')).toBe('sm')
    })
  })

  describe('custom labels', () => {
    it('should use custom vote label', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
          voteLabel: 'Vote Now',
        },
      })

      expect(wrapper.text()).toContain('Vote Now')
    })

    it('should use custom support label', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
          supportLabel: 'Support Now',
        },
      })

      expect(wrapper.text()).toContain('Support Now')
    })

    it('should not show labels when showLabels is false', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
          showLabels: false,
        },
      })

      expect(wrapper.text()).not.toContain('Votar')
      expect(wrapper.text()).not.toContain('Apoyar')
    })
  })

  describe('button variants', () => {
    it('should use primary variant for vote button when voted', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, hasVoted: true },
          itemId: 1,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      expect(buttons[0].props('variant')).toBe('primary')
    })

    it('should use success variant for support button when supported', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, hasSupported: true },
          itemId: 1,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      expect(buttons[1].props('variant')).toBe('success')
    })

    it('should use outline variant for vote button when not voted', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      expect(buttons[0].props('variant')).toBe('outline')
    })
  })

  describe('accessibility', () => {
    it('should have proper aria-label for vote button', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      expect(buttons[0].props('ariaLabel')).toBe('Votar')
    })

    it('should have proper aria-label when voted', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: { ...mockVoteData, hasVoted: true },
          itemId: 1,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      expect(buttons[0].props('ariaLabel')).toBe('Ya has votado')
    })

    it('should have proper aria-label for support button', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      expect(buttons[1].props('ariaLabel')).toBe('Apoyar')
    })
  })

  describe('disabled state', () => {
    it('should disable both buttons when disabled prop is true', () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
          isAuthenticated: true,
          disabled: true,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      expect(buttons[0].props('disabled')).toBe(true)
      expect(buttons[1].props('disabled')).toBe(true)
    })

    it('should not emit events when disabled', async () => {
      const wrapper = mount(VotingWidget, {
        props: {
          voteData: mockVoteData,
          itemId: 1,
          isAuthenticated: true,
          disabled: true,
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      await buttons[0].trigger('click')
      await buttons[1].trigger('click')

      expect(wrapper.emitted('vote')).toBeFalsy()
      expect(wrapper.emitted('support')).toBeFalsy()
    })
  })
})
