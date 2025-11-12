import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import ImpulsaProjectCard from './ImpulsaProjectCard.vue'
import type { ImpulsaProject } from './ImpulsaProjectCard.vue'

const mockProject: ImpulsaProject = {
  id: 1,
  title: 'Proyecto de Ejemplo',
  description: 'Esta es una descripción de prueba del proyecto.',
  category: 'social',
  fundingGoal: 10000,
  fundingReceived: 5000,
  votes: 42,
  hasVoted: false,
  status: 'voting',
  author: 'Juan Pérez',
  createdAt: new Date('2024-01-01'),
}

describe('ImpulsaProjectCard', () => {
  describe('rendering', () => {
    it('should render the component', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
        },
      })

      expect(wrapper.find('.impulsa-project-card').exists()).toBe(true)
    })

    it('should display project title', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
        },
      })

      expect(wrapper.text()).toContain('Proyecto de Ejemplo')
    })

    it('should display project description', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
        },
      })

      expect(wrapper.text()).toContain('Esta es una descripción de prueba')
    })

    it('should display project author', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
        },
      })

      expect(wrapper.text()).toContain('Juan Pérez')
    })

    it('should display category', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
        },
      })

      expect(wrapper.text()).toContain('Social')
    })

    it('should display status badge', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
        },
      })

      expect(wrapper.text()).toContain('En Votación')
    })
  })

  describe('funding display', () => {
    it('should display funding goal', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
        },
      })

      expect(wrapper.text()).toContain('10.000')
    })

    it('should display funding received', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
        },
      })

      expect(wrapper.text()).toContain('5.000')
    })

    it('should calculate funding progress correctly', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
        },
      })

      expect(wrapper.text()).toContain('50%')
    })

    it('should show progress bar', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
        },
      })

      expect(wrapper.findComponent({ name: 'ProgressBar' }).exists()).toBe(true)
    })

    it('should display vote count', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
        },
      })

      expect(wrapper.text()).toContain('42 votos')
    })
  })

  describe('status variants', () => {
    it('should show draft status', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, status: 'draft' },
        },
      })

      expect(wrapper.text()).toContain('Borrador')
    })

    it('should show submitted status', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, status: 'submitted' },
        },
      })

      expect(wrapper.text()).toContain('Presentado')
    })

    it('should show evaluation status', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, status: 'evaluation' },
        },
      })

      expect(wrapper.text()).toContain('En Evaluación')
    })

    it('should show funded status', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, status: 'funded' },
        },
      })

      expect(wrapper.text()).toContain('Financiado')
    })

    it('should show rejected status', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, status: 'rejected' },
        },
      })

      expect(wrapper.text()).toContain('No Financiado')
    })

    it('should show completed status', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, status: 'completed' },
        },
      })

      expect(wrapper.text()).toContain('Completado')
    })
  })

  describe('categories', () => {
    it('should show technology category', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, category: 'technology' },
        },
      })

      expect(wrapper.text()).toContain('Tecnología')
    })

    it('should show culture category', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, category: 'culture' },
        },
      })

      expect(wrapper.text()).toContain('Cultura')
    })

    it('should show education category', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, category: 'education' },
        },
      })

      expect(wrapper.text()).toContain('Educación')
    })

    it('should show environment category', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, category: 'environment' },
        },
      })

      expect(wrapper.text()).toContain('Medio Ambiente')
    })

    it('should show health category', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, category: 'health' },
        },
      })

      expect(wrapper.text()).toContain('Salud')
    })
  })

  describe('voting', () => {
    it('should show vote button when status is voting', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, status: 'voting' },
        },
      })

      const button = wrapper.findComponent({ name: 'Button' })
      expect(button.exists()).toBe(true)
      expect(button.text()).toContain('Votar')
    })

    it('should not show vote button when status is not voting', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, status: 'submitted' },
        },
      })

      expect(wrapper.text()).not.toContain('Votar')
    })

    it('should emit vote event when clicking vote button', async () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
          isAuthenticated: true,
        },
      })

      const button = wrapper.findComponent({ name: 'Button' })
      await button.trigger('click')

      expect(wrapper.emitted('vote')).toBeTruthy()
    })

    it('should emit login-required when not authenticated', async () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
          isAuthenticated: false,
        },
      })

      const button = wrapper.findComponent({ name: 'Button' })
      await button.trigger('click')

      expect(wrapper.emitted('login-required')).toBeTruthy()
    })

    it('should show voted button when hasVoted is true', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, hasVoted: true },
        },
      })

      expect(wrapper.text()).toContain('Votado')
    })

    it('should disable vote button when loading', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
          loadingVote: true,
        },
      })

      const button = wrapper.findComponent({ name: 'Button' })
      expect(button.props('loading')).toBe(true)
    })

    it('should hide vote button when showVoteButton is false', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
          showVoteButton: false,
        },
      })

      expect(wrapper.text()).not.toContain('Votar')
    })
  })

  describe('compact mode', () => {
    it('should apply compact class', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
          compact: true,
        },
      })

      expect(wrapper.find('.impulsa-project-card--compact').exists()).toBe(true)
    })

    it('should not show description in compact mode', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
          compact: true,
        },
      })

      // Description should not be rendered in a separate paragraph
      expect(wrapper.findAll('p').length).toBe(0)
    })

    it('should use smaller button in compact mode', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
          compact: true,
          isAuthenticated: true,
        },
      })

      const button = wrapper.findComponent({ name: 'Button' })
      expect(button.props('size')).toBe('sm')
    })
  })

  describe('image display', () => {
    it('should show image when imageUrl is provided', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, imageUrl: 'https://example.com/image.jpg' },
        },
      })

      const img = wrapper.find('img')
      expect(img.exists()).toBe(true)
      expect(img.attributes('src')).toBe('https://example.com/image.jpg')
    })

    it('should not show image in compact mode', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, imageUrl: 'https://example.com/image.jpg' },
          compact: true,
        },
      })

      expect(wrapper.find('img').exists()).toBe(false)
    })
  })

  describe('description truncation', () => {
    it('should truncate long description', () => {
      const longDescription = 'A'.repeat(200)
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, description: longDescription },
        },
      })

      expect(wrapper.text()).toContain('...')
    })

    it('should show full description when showFullDescription is true', () => {
      const longDescription = 'A'.repeat(200)
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, description: longDescription },
          showFullDescription: true,
        },
      })

      expect(wrapper.text()).not.toContain('...')
    })
  })

  describe('click events', () => {
    it('should emit click event when card is clicked', async () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
        },
      })

      await wrapper.find('.impulsa-project-card').trigger('click')

      expect(wrapper.emitted('click')).toBeTruthy()
    })

    it('should not emit click when disabled', async () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
          disabled: true,
        },
      })

      await wrapper.find('.impulsa-project-card').trigger('click')

      expect(wrapper.emitted('click')).toBeFalsy()
    })
  })

  describe('funding progress edge cases', () => {
    it('should handle 0% funding', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, fundingReceived: 0 },
        },
      })

      expect(wrapper.text()).toContain('0%')
    })

    it('should handle 100% funding', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, fundingReceived: 10000 },
        },
      })

      expect(wrapper.text()).toContain('100%')
    })

    it('should cap at 100% even if over-funded', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: { ...mockProject, fundingReceived: 15000 },
        },
      })

      expect(wrapper.text()).toContain('100%')
    })
  })

  describe('authentication messages', () => {
    it('should show login prompt when not authenticated', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
          isAuthenticated: false,
        },
      })

      expect(wrapper.text()).toContain('Inicia sesión para votar')
    })

    it('should not show login prompt when authenticated', () => {
      const wrapper = mount(ImpulsaProjectCard, {
        props: {
          project: mockProject,
          isAuthenticated: true,
        },
      })

      expect(wrapper.text()).not.toContain('Inicia sesión para votar')
    })
  })
})
