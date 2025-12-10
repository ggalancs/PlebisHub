import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import ProposalCard from './ProposalCard.vue'
import type { Proposal } from './ProposalCard.vue'

const mockProposal: Proposal = {
  id: 1,
  title: 'Test Proposal',
  description: 'This is a test proposal description',
  votes: 42,
  supportsCount: 75,
  hotness: 1500,
  createdAt: new Date('2025-01-01'),
  finishesAt: new Date('2025-04-01'),
  redditThreshold: false,
  supported: false,
  finished: false,
  discarded: false,
}

describe('ProposalCard', () => {
  describe('rendering', () => {
    it('should render proposal title', () => {
      const wrapper = mount(ProposalCard, {
        props: { proposal: mockProposal },
      })

      expect(wrapper.text()).toContain('Test Proposal')
    })

    it('should render proposal description', () => {
      const wrapper = mount(ProposalCard, {
        props: { proposal: mockProposal },
      })

      expect(wrapper.text()).toContain('This is a test proposal description')
    })

    it('should render support count', () => {
      const wrapper = mount(ProposalCard, {
        props: { proposal: mockProposal },
      })

      expect(wrapper.text()).toContain('75 apoyos')
    })

    it('should render votes count', () => {
      const wrapper = mount(ProposalCard, {
        props: { proposal: mockProposal },
      })

      expect(wrapper.text()).toContain('42 votos')
    })

    it('should render hotness score', () => {
      const wrapper = mount(ProposalCard, {
        props: { proposal: mockProposal },
      })

      expect(wrapper.text()).toContain('1500 hotness')
    })
  })

  describe('status badge', () => {
    it('should show "Activa" for active proposal', () => {
      const wrapper = mount(ProposalCard, {
        props: { proposal: mockProposal },
      })

      expect(wrapper.text()).toContain('Activa')
    })

    it('should show "Umbral alcanzado" when threshold reached', () => {
      const proposal = { ...mockProposal, redditThreshold: true }
      const wrapper = mount(ProposalCard, {
        props: { proposal },
      })

      expect(wrapper.text()).toContain('Umbral alcanzado')
    })

    it('should show "Finalizada" when finished', () => {
      const proposal = { ...mockProposal, finished: true }
      const wrapper = mount(ProposalCard, {
        props: { proposal },
      })

      expect(wrapper.text()).toContain('Finalizada')
    })

    it('should show "Descartada" when discarded', () => {
      const proposal = { ...mockProposal, discarded: true }
      const wrapper = mount(ProposalCard, {
        props: { proposal },
      })

      expect(wrapper.text()).toContain('Descartada')
    })
  })

  describe('support button', () => {
    it('should render support button when showSupportButton is true', () => {
      const wrapper = mount(ProposalCard, {
        props: {
          proposal: mockProposal,
          showSupportButton: true,
          isAuthenticated: true,
        },
      })

      const buttons = wrapper.findAll('button')
      const supportButton = buttons.find((b) => b.text().includes('Apoyar'))
      expect(supportButton?.text()).toContain('Apoyar propuesta')
    })

    it('should not render support button when showSupportButton is false', () => {
      const wrapper = mount(ProposalCard, {
        props: {
          proposal: mockProposal,
          showSupportButton: false,
        },
      })

      expect(wrapper.text()).not.toContain('Apoyar propuesta')
    })

    it('should show "Apoyada" when proposal is already supported', () => {
      const proposal = { ...mockProposal, supported: true }
      const wrapper = mount(ProposalCard, {
        props: {
          proposal,
          showSupportButton: true,
          isAuthenticated: true,
        },
      })

      const buttons = wrapper.findAll('button')
      const supportButton = buttons.find((b) => b.text().includes('Apoyada'))
      expect(supportButton?.text()).toContain('Apoyada')
    })

    it('should be disabled when not authenticated', () => {
      const wrapper = mount(ProposalCard, {
        props: {
          proposal: mockProposal,
          showSupportButton: true,
          isAuthenticated: false,
        },
      })

      // When not authenticated, the button is not shown - only a span with message
      expect(wrapper.text()).toContain('Inicia sesión para apoyar')
    })

    it('should be enabled when authenticated', () => {
      const wrapper = mount(ProposalCard, {
        props: {
          proposal: mockProposal,
          showSupportButton: true,
          isAuthenticated: true,
        },
      })

      const buttons = wrapper.findAll('button')
      const supportButton = buttons.find((b) => b.text().includes('Apoyar'))
      expect(supportButton?.attributes('disabled')).toBeUndefined()
    })

    it('should be disabled when proposal is finished', () => {
      const proposal = { ...mockProposal, finished: true }
      const wrapper = mount(ProposalCard, {
        props: {
          proposal,
          showSupportButton: true,
          isAuthenticated: true,
        },
      })

      expect(wrapper.text()).not.toContain('Apoyar propuesta')
    })

    it('should be disabled when proposal is discarded', () => {
      const proposal = { ...mockProposal, discarded: true }
      const wrapper = mount(ProposalCard, {
        props: {
          proposal,
          showSupportButton: true,
          isAuthenticated: true,
        },
      })

      expect(wrapper.text()).not.toContain('Apoyar propuesta')
    })

    it('should show loading state', () => {
      const wrapper = mount(ProposalCard, {
        props: {
          proposal: mockProposal,
          showSupportButton: true,
          loadingSupport: true,
          isAuthenticated: true,
        },
      })

      const buttons = wrapper.findAll('button')
      const supportButton = buttons.find((b) => b.text().includes('Apoyar'))
      expect(supportButton?.attributes('disabled')).toBeDefined()
    })

    it('should emit support event when clicked', async () => {
      const wrapper = mount(ProposalCard, {
        props: {
          proposal: mockProposal,
          showSupportButton: true,
          isAuthenticated: true,
        },
      })

      const buttons = wrapper.findAll('button')
      const supportButton = buttons.find((b) => b.text().includes('Apoyar'))
      await supportButton?.trigger('click')

      expect(wrapper.emitted('support')).toBeTruthy()
      expect(wrapper.emitted('support')?.[0]).toEqual([1])
    })

    it('should not emit support event when loading', async () => {
      const wrapper = mount(ProposalCard, {
        props: {
          proposal: mockProposal,
          showSupportButton: true,
          isAuthenticated: true,
          loadingSupport: true,
        },
      })

      const buttons = wrapper.findAll('button')
      const supportButton = buttons.find((b) => b.text().includes('Apoyar'))
      await supportButton?.trigger('click')

      expect(wrapper.emitted('support')).toBeFalsy()
    })

    it('should not emit support event when already supported', async () => {
      const proposal = { ...mockProposal, supported: true }
      const wrapper = mount(ProposalCard, {
        props: {
          proposal,
          showSupportButton: true,
          isAuthenticated: true,
        },
      })

      const buttons = wrapper.findAll('button')
      const supportButton = buttons.find((b) => b.text().includes('Apoyada'))
      await supportButton?.trigger('click')

      expect(wrapper.emitted('support')).toBeFalsy()
    })
  })

  describe('view button', () => {
    it('should render view details button', () => {
      const wrapper = mount(ProposalCard, {
        props: { proposal: mockProposal },
      })

      expect(wrapper.text()).toContain('Ver detalles')
    })

    it('should emit view event when clicked', async () => {
      const wrapper = mount(ProposalCard, {
        props: { proposal: mockProposal },
      })

      const buttons = wrapper.findAll('button')
      const viewButton = buttons.find((b) => b.text().includes('Ver detalles'))
      await viewButton?.trigger('click')

      expect(wrapper.emitted('view')).toBeTruthy()
      expect(wrapper.emitted('view')?.[0]).toEqual([1])
    })

    it('should emit view event when title is clicked', async () => {
      const wrapper = mount(ProposalCard, {
        props: { proposal: mockProposal },
      })

      await wrapper.find('h3').trigger('click')

      expect(wrapper.emitted('view')).toBeTruthy()
      expect(wrapper.emitted('view')?.[0]).toEqual([1])
    })
  })

  describe('description truncation', () => {
    it('should truncate long descriptions in card view', () => {
      const longDescription = 'A'.repeat(200)
      const proposal = { ...mockProposal, description: longDescription }
      const wrapper = mount(ProposalCard, {
        props: {
          proposal,
          detailed: false,
        },
      })

      const text = wrapper.text()
      expect(text).not.toContain(longDescription)
      expect(text).toContain('...')
    })

    it('should not truncate descriptions in detailed view', () => {
      const longDescription = 'A'.repeat(200)
      const proposal = { ...mockProposal, description: longDescription }
      const wrapper = mount(ProposalCard, {
        props: {
          proposal,
          detailed: true,
        },
      })

      const text = wrapper.text()
      expect(text).toContain(longDescription)
      expect(text).not.toContain('...')
    })

    it('should not truncate short descriptions', () => {
      const shortDescription = 'Short description'
      const proposal = { ...mockProposal, description: shortDescription }
      const wrapper = mount(ProposalCard, {
        props: { proposal },
      })

      const text = wrapper.text()
      expect(text).toContain(shortDescription)
      expect(text).not.toContain('...')
    })
  })

  describe('progress bar', () => {
    it('should show support progress', () => {
      const wrapper = mount(ProposalCard, {
        props: { proposal: mockProposal },
      })

      // Should render ProgressBar component
      expect(wrapper.findComponent({ name: 'ProgressBar' }).exists()).toBe(true)
    })

    it('should use success color when threshold reached', () => {
      const proposal = { ...mockProposal, redditThreshold: true }
      const wrapper = mount(ProposalCard, {
        props: { proposal },
      })

      const progressBar = wrapper.findComponent({ name: 'ProgressBar' })
      expect(progressBar.props('variant')).toBe('success')
    })

    it('should use primary color when threshold not reached', () => {
      const wrapper = mount(ProposalCard, {
        props: { proposal: mockProposal },
      })

      const progressBar = wrapper.findComponent({ name: 'ProgressBar' })
      expect(progressBar.props('variant')).toBe('primary')
    })
  })

  describe('date formatting', () => {
    it('should format creation date', () => {
      const wrapper = mount(ProposalCard, {
        props: { proposal: mockProposal },
      })

      // Should contain formatted date (locale dependent)
      expect(wrapper.text()).toMatch(/enero|January/i)
    })

    it('should handle string dates', () => {
      const proposal = {
        ...mockProposal,
        createdAt: '2025-01-01T00:00:00.000Z',
        finishesAt: '2025-04-01T00:00:00.000Z',
      }
      const wrapper = mount(ProposalCard, {
        props: { proposal },
      })

      expect(wrapper.text()).toMatch(/enero|January/i)
    })
  })

  describe('days remaining', () => {
    it('should show days remaining for active proposal', () => {
      const wrapper = mount(ProposalCard, {
        props: { proposal: mockProposal },
      })

      expect(wrapper.text()).toMatch(/\d+ días restantes/)
    })

    it('should not show days remaining for finished proposal', () => {
      const proposal = { ...mockProposal, finished: true }
      const wrapper = mount(ProposalCard, {
        props: { proposal },
      })

      expect(wrapper.text()).not.toContain('días restantes')
    })
  })

  describe('opacity for finished/discarded', () => {
    it('should have reduced opacity for finished proposals', () => {
      const proposal = { ...mockProposal, finished: true }
      const wrapper = mount(ProposalCard, {
        props: { proposal },
      })

      expect(wrapper.find('.proposal-card').classes()).toContain('opacity-60')
    })

    it('should have reduced opacity for discarded proposals', () => {
      const proposal = { ...mockProposal, discarded: true }
      const wrapper = mount(ProposalCard, {
        props: { proposal },
      })

      expect(wrapper.find('.proposal-card').classes()).toContain('opacity-60')
    })

    it('should not have reduced opacity for active proposals', () => {
      const wrapper = mount(ProposalCard, {
        props: { proposal: mockProposal },
      })

      expect(wrapper.find('.proposal-card').classes()).not.toContain('opacity-60')
    })
  })

  describe('authentication message', () => {
    it('should show login message when not authenticated', () => {
      const wrapper = mount(ProposalCard, {
        props: {
          proposal: mockProposal,
          showSupportButton: true,
          isAuthenticated: false,
        },
      })

      expect(wrapper.text()).toContain('Inicia sesión para apoyar')
    })

    it('should not show login message when authenticated', () => {
      const wrapper = mount(ProposalCard, {
        props: {
          proposal: mockProposal,
          showSupportButton: true,
          isAuthenticated: true,
        },
      })

      expect(wrapper.text()).not.toContain('Inicia sesión para apoyar')
    })
  })
})
