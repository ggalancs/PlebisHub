import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import CollaborationSummary from './CollaborationSummary.vue'
import type { Collaboration } from './CollaborationSummary.vue'

const mockCollaboration: Collaboration = {
  id: '1',
  title: 'Huerto Comunitario',
  description: 'Un proyecto para crear un huerto comunitario en el barrio.',
  type: 'project',
  location: 'Plaza Mayor',
  startDate: '2025-01-15',
  endDate: '2025-06-15',
  minCollaborators: 5,
  maxCollaborators: 20,
  skills: ['Jardinería', 'Agricultura', 'Sostenibilidad'],
  imageUrl: 'https://example.com/image.jpg',
  creator: {
    id: 'u1',
    name: 'María García',
    avatar: 'https://example.com/avatar.jpg',
  },
  currentCollaborators: 10,
  status: 'open',
  createdAt: '2025-01-01',
  updatedAt: '2025-01-05',
}

describe('CollaborationSummary', () => {
  describe('rendering', () => {
    it('should render the component', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      expect(wrapper.find('.collaboration-summary').exists()).toBe(true)
    })

    it('should display collaboration title', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      expect(wrapper.text()).toContain('Huerto Comunitario')
    })

    it('should display collaboration description', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      expect(wrapper.text()).toContain('Un proyecto para crear un huerto comunitario en el barrio.')
    })

    it('should display collaboration image', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      const img = wrapper.find('img')
      expect(img.exists()).toBe(true)
      expect(img.attributes('src')).toBe('https://example.com/image.jpg')
      expect(img.attributes('alt')).toBe('Huerto Comunitario')
    })

    it('should not display image when imageUrl is not provided', () => {
      const collabWithoutImage = { ...mockCollaboration, imageUrl: undefined }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: collabWithoutImage,
        },
      })
      const img = wrapper.find('img')
      expect(img.exists()).toBe(false)
    })

    it('should show loading state', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
          loading: true,
        },
      })
      const card = wrapper.findComponent({ name: 'Card' })
      expect(card.props('loading')).toBe(true)
    })
  })

  describe('type and status', () => {
    it('should display type badge', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      expect(wrapper.text()).toContain('Proyecto')
    })

    it('should display status badge', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      expect(wrapper.text()).toContain('Abierta')
    })

    it('should display initiative type', () => {
      const initiative = { ...mockCollaboration, type: 'initiative' as const }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: initiative,
        },
      })
      expect(wrapper.text()).toContain('Iniciativa')
    })

    it('should display event type', () => {
      const event = { ...mockCollaboration, type: 'event' as const }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: event,
        },
      })
      expect(wrapper.text()).toContain('Evento')
    })

    it('should display campaign type', () => {
      const campaign = { ...mockCollaboration, type: 'campaign' as const }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: campaign,
        },
      })
      expect(wrapper.text()).toContain('Campaña')
    })

    it('should display workshop type', () => {
      const workshop = { ...mockCollaboration, type: 'workshop' as const }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: workshop,
        },
      })
      expect(wrapper.text()).toContain('Taller')
    })

    it('should display other type', () => {
      const other = { ...mockCollaboration, type: 'other' as const }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: other,
        },
      })
      expect(wrapper.text()).toContain('Otro')
    })

    it('should display in_progress status', () => {
      const inProgress = { ...mockCollaboration, status: 'in_progress' as const }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: inProgress,
        },
      })
      expect(wrapper.text()).toContain('En Progreso')
    })

    it('should display completed status', () => {
      const completed = { ...mockCollaboration, status: 'completed' as const }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: completed,
        },
      })
      expect(wrapper.text()).toContain('Completada')
    })

    it('should display cancelled status', () => {
      const cancelled = { ...mockCollaboration, status: 'cancelled' as const }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: cancelled,
        },
      })
      expect(wrapper.text()).toContain('Cancelada')
    })
  })

  describe('location', () => {
    it('should display location when provided', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      expect(wrapper.text()).toContain('Plaza Mayor')
    })

    it('should not display location when not provided', () => {
      const collabWithoutLocation = { ...mockCollaboration, location: undefined }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: collabWithoutLocation,
        },
      })
      const mapPinIcon = wrapper.findAllComponents({ name: 'Icon' }).find(
        i => i.props('name') === 'map-pin'
      )
      expect(mapPinIcon).toBeUndefined()
    })
  })

  describe('creator', () => {
    it('should display creator name', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      expect(wrapper.text()).toContain('Creado por')
      expect(wrapper.text()).toContain('María García')
    })

    it('should display creator avatar', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      const avatar = wrapper.findComponent({ name: 'Avatar' })
      expect(avatar.exists()).toBe(true)
      expect(avatar.props('src')).toBe('https://example.com/avatar.jpg')
      expect(avatar.props('alt')).toBe('María García')
    })
  })

  describe('dates', () => {
    it('should display start date when provided', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      expect(wrapper.text()).toContain('Fechas')
      expect(wrapper.text()).toContain('Inicio:')
    })

    it('should display end date when provided', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      expect(wrapper.text()).toContain('Fin:')
    })

    it('should not display dates section when no dates provided', () => {
      const collabWithoutDates = {
        ...mockCollaboration,
        startDate: undefined,
        endDate: undefined,
      }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: collabWithoutDates,
        },
      })
      expect(wrapper.text()).not.toContain('Fechas')
    })

    it('should display only start date when end date not provided', () => {
      const collabWithStartOnly = {
        ...mockCollaboration,
        endDate: undefined,
      }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: collabWithStartOnly,
        },
      })
      expect(wrapper.text()).toContain('Inicio:')
      expect(wrapper.text()).not.toContain('Fin:')
    })
  })

  describe('collaborators', () => {
    it('should display current collaborators count', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      expect(wrapper.text()).toContain('Colaboradores')
      expect(wrapper.text()).toContain('Actuales:')
      expect(wrapper.text()).toContain('10')
    })

    it('should display min collaborators when provided', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      expect(wrapper.text()).toContain('Mínimo:')
      expect(wrapper.text()).toContain('5')
    })

    it('should display max collaborators when provided', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      expect(wrapper.text()).toContain('Máximo:')
      expect(wrapper.text()).toContain('20')
    })

    it('should not display min when not provided', () => {
      const collabWithoutMin = { ...mockCollaboration, minCollaborators: undefined }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: collabWithoutMin,
        },
      })
      expect(wrapper.text()).not.toContain('Mínimo:')
    })

    it('should not display max when not provided', () => {
      const collabWithoutMax = { ...mockCollaboration, maxCollaborators: undefined }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: collabWithoutMax,
        },
      })
      expect(wrapper.text()).not.toContain('Máximo:')
    })

    it('should calculate progress percentage', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      // 10/20 = 50%
      expect(wrapper.text()).toContain('50%')
    })

    it('should show green progress bar when < 80%', () => {
      const collab = { ...mockCollaboration, currentCollaborators: 10, maxCollaborators: 20 }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: collab,
        },
      })
      const progressBar = wrapper.find('.bg-green-500')
      expect(progressBar.exists()).toBe(true)
    })

    it('should show yellow progress bar when >= 80% and < 100%', () => {
      const collab = { ...mockCollaboration, currentCollaborators: 17, maxCollaborators: 20 }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: collab,
        },
      })
      const progressBar = wrapper.find('.bg-yellow-500')
      expect(progressBar.exists()).toBe(true)
    })

    it('should show red progress bar when full', () => {
      const collab = { ...mockCollaboration, currentCollaborators: 20, maxCollaborators: 20 }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: collab,
        },
      })
      const progressBar = wrapper.find('.bg-red-500')
      expect(progressBar.exists()).toBe(true)
    })

    it('should show "Cupo completo" message when full', () => {
      const collab = { ...mockCollaboration, currentCollaborators: 20, maxCollaborators: 20 }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: collab,
        },
      })
      expect(wrapper.text()).toContain('Cupo completo')
    })

    it('should not show "Cupo completo" when not full', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      expect(wrapper.text()).not.toContain('Cupo completo')
    })
  })

  describe('skills', () => {
    it('should display skills section', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      expect(wrapper.text()).toContain('Habilidades Requeridas')
    })

    it('should display all skills as badges', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      expect(wrapper.text()).toContain('Jardinería')
      expect(wrapper.text()).toContain('Agricultura')
      expect(wrapper.text()).toContain('Sostenibilidad')
    })

    it('should not display skills section when empty', () => {
      const collabWithoutSkills = { ...mockCollaboration, skills: [] }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: collabWithoutSkills,
        },
      })
      expect(wrapper.text()).not.toContain('Habilidades Requeridas')
    })
  })

  describe('metadata', () => {
    it('should display created date', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      expect(wrapper.text()).toContain('Creado:')
    })

    it('should display updated date when provided', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      expect(wrapper.text()).toContain('Actualizado:')
    })

    it('should not display updated date when not provided', () => {
      const collabWithoutUpdated = { ...mockCollaboration, updatedAt: undefined }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: collabWithoutUpdated,
        },
      })
      expect(wrapper.text()).not.toContain('Actualizado:')
    })
  })

  describe('actions', () => {
    it('should display actions when showActions is true', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
          showActions: true,
        },
      })
      const buttons = wrapper.findAllComponents({ name: 'Button' })
      expect(buttons.length).toBeGreaterThan(0)
    })

    it('should not display actions when showActions is false', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
          showActions: false,
        },
      })
      const buttons = wrapper.findAllComponents({ name: 'Button' })
      expect(buttons.length).toBe(0)
    })

    it('should show join button when status is open and not full', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      const joinButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Unirse')
      )
      expect(joinButton?.exists()).toBe(true)
    })

    it('should not show join button when status is not open', () => {
      const collab = { ...mockCollaboration, status: 'completed' as const }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: collab,
        },
      })
      const joinButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Unirse')
      )
      expect(joinButton).toBeUndefined()
    })

    it('should not show join button when full', () => {
      const collab = { ...mockCollaboration, currentCollaborators: 20, maxCollaborators: 20 }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: collab,
        },
      })
      const joinButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Unirse')
      )
      expect(joinButton).toBeUndefined()
    })

    it('should show leave button when status is in_progress', () => {
      const collab = { ...mockCollaboration, status: 'in_progress' as const }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: collab,
        },
      })
      const leaveButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Abandonar')
      )
      expect(leaveButton?.exists()).toBe(true)
    })

    it('should not show leave button when status is not in_progress', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      const leaveButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Abandonar')
      )
      expect(leaveButton).toBeUndefined()
    })

    it('should always show contact button', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      const contactButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Contactar')
      )
      expect(contactButton?.exists()).toBe(true)
    })

    it('should always show edit button', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      const editButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Editar')
      )
      expect(editButton?.exists()).toBe(true)
    })

    it('should always show delete button', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      const deleteButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Eliminar')
      )
      expect(deleteButton?.exists()).toBe(true)
    })
  })

  describe('events', () => {
    it('should emit join event when join button is clicked', async () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      const joinButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Unirse')
      )
      await joinButton?.trigger('click')
      expect(wrapper.emitted('join')).toBeTruthy()
    })

    it('should emit leave event when leave button is clicked', async () => {
      const collab = { ...mockCollaboration, status: 'in_progress' as const }
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: collab,
        },
      })
      const leaveButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Abandonar')
      )
      await leaveButton?.trigger('click')
      expect(wrapper.emitted('leave')).toBeTruthy()
    })

    it('should emit contact event when contact button is clicked', async () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      const contactButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Contactar')
      )
      await contactButton?.trigger('click')
      expect(wrapper.emitted('contact')).toBeTruthy()
    })

    it('should emit edit event when edit button is clicked', async () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      const editButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Editar')
      )
      await editButton?.trigger('click')
      expect(wrapper.emitted('edit')).toBeTruthy()
    })

    it('should emit delete event when delete button is clicked', async () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      const deleteButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Eliminar')
      )
      await deleteButton?.trigger('click')
      expect(wrapper.emitted('delete')).toBeTruthy()
    })
  })

  describe('icons', () => {
    it('should display appropriate icons', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      const icons = wrapper.findAllComponents({ name: 'Icon' })
      expect(icons.length).toBeGreaterThan(0)
    })

    it('should have calendar icon in dates section', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      const calendarIcon = wrapper.findAllComponents({ name: 'Icon' }).find(
        i => i.props('name') === 'calendar'
      )
      expect(calendarIcon?.exists()).toBe(true)
    })

    it('should have users icon in collaborators section', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      const usersIcon = wrapper.findAllComponents({ name: 'Icon' }).find(
        i => i.props('name') === 'users'
      )
      expect(usersIcon?.exists()).toBe(true)
    })

    it('should have zap icon in skills section', () => {
      const wrapper = mount(CollaborationSummary, {
        props: {
          collaboration: mockCollaboration,
        },
      })
      const zapIcon = wrapper.findAllComponents({ name: 'Icon' }).find(
        i => i.props('name') === 'zap'
      )
      expect(zapIcon?.exists()).toBe(true)
    })
  })
})
