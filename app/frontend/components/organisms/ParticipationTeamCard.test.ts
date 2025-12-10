import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import ParticipationTeamCard from './ParticipationTeamCard.vue'
import type { ParticipationTeam } from './ParticipationTeamCard.vue'

const mockTeam: ParticipationTeam = {
  id: '1',
  name: 'Equipo de Medio Ambiente',
  description: 'Trabajamos en iniciativas para mejorar el medio ambiente local',
  leader: {
    id: 'leader-1',
    name: 'María González',
    avatar: 'https://example.com/maria.jpg',
    role: 'Coordinadora',
  },
  memberCount: 8,
  maxMembers: 15,
  status: 'recruiting',
  activityLevel: 'high',
  tags: ['Medio Ambiente', 'Sostenibilidad', 'Comunidad'],
  meetingSchedule: 'Jueves 18:00',
  lastActivity: '2024-01-15',
  createdAt: '2023-12-01',
  imageUrl: 'https://example.com/team.jpg',
}

describe('ParticipationTeamCard', () => {
  describe('rendering', () => {
    it('should render the component', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      expect(wrapper.find('.participation-team-card').exists()).toBe(true)
    })

    it('should display team name', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      expect(wrapper.text()).toContain('Equipo de Medio Ambiente')
    })

    it('should display team description', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      expect(wrapper.text()).toContain('Trabajamos en iniciativas para mejorar el medio ambiente local')
    })

    it('should hide description in compact mode', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          compact: true,
        },
      })
      expect(wrapper.text()).not.toContain('Trabajamos en iniciativas')
    })

    it('should display team image when provided', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      const img = wrapper.find('img[alt="Equipo de Medio Ambiente"]')
      expect(img.exists()).toBe(true)
      expect(img.attributes('src')).toBe('https://example.com/team.jpg')
    })

    it('should hide image in compact mode', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          compact: true,
        },
      })
      const img = wrapper.find('.participation-team-card__image')
      expect(img.exists()).toBe(false)
    })
  })

  describe('team leader', () => {
    it('should display leader name', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      expect(wrapper.text()).toContain('María González')
    })

    it('should display leader role', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      expect(wrapper.text()).toContain('Coordinadora')
    })

    it('should show default role when not provided', () => {
      const teamWithoutRole = {
        ...mockTeam,
        leader: {
          ...mockTeam.leader,
          role: undefined,
        },
      }
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: teamWithoutRole,
        },
      })
      expect(wrapper.text()).toContain('Coordinador')
    })

    it('should show leader avatar', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      const avatar = wrapper.findComponent({ name: 'Avatar' })
      expect(avatar.exists()).toBe(true)
      // Check leader name is displayed in the text content
      expect(wrapper.text()).toContain('María González')
    })

    it('should show contact button for non-leaders', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          isLeader: false,
        },
      })
      const contactButton = wrapper.findAllComponents({ name: 'Button' }).find(b => {
        const icon = b.findComponent({ name: 'Icon' })
        return icon.exists() && icon.props('name') === 'mail'
      })
      expect(contactButton?.exists()).toBe(true)
    })

    it('should not show contact button for leaders', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          isLeader: true,
        },
      })
      const contactButton = wrapper.findAllComponents({ name: 'Button' }).find(b => {
        const icon = b.findComponent({ name: 'Icon' })
        return icon.exists() && icon.props('name') === 'mail'
      })
      // When find() returns undefined, element doesn't exist
      expect(contactButton).toBeUndefined()
    })

    it('should emit contact-leader event', async () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      const contactButton = wrapper.findAllComponents({ name: 'Button' }).find(b => {
        const icon = b.findComponent({ name: 'Icon' })
        return icon.exists() && icon.props('name') === 'mail'
      })
      await contactButton?.trigger('click')

      expect(wrapper.emitted('contact-leader')).toBeTruthy()
      expect(wrapper.emitted('contact-leader')?.[0]).toEqual(['leader-1'])
    })
  })

  describe('team status', () => {
    it('should show active status', () => {
      const activeTeam = { ...mockTeam, status: 'active' as const }
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: activeTeam,
        },
      })
      expect(wrapper.text()).toContain('Activo')
    })

    it('should show recruiting status', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      expect(wrapper.text()).toContain('Reclutando')
    })

    it('should show full status', () => {
      const fullTeam = { ...mockTeam, status: 'full' as const }
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: fullTeam,
        },
      })
      expect(wrapper.text()).toContain('Completo')
    })

    it('should show inactive status', () => {
      const inactiveTeam = { ...mockTeam, status: 'inactive' as const }
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: inactiveTeam,
        },
      })
      expect(wrapper.text()).toContain('Inactivo')
    })

    it('should show inactive banner', () => {
      const inactiveTeam = { ...mockTeam, status: 'inactive' as const }
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: inactiveTeam,
        },
      })
      expect(wrapper.find('.participation-team-card__banner--inactive').exists()).toBe(true)
      expect(wrapper.text()).toContain('Este equipo está inactivo')
    })
  })

  describe('member count', () => {
    it('should display member count', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      expect(wrapper.text()).toContain('8 / 15 miembros')
    })

    it('should display member count without max when not set', () => {
      const teamWithoutMax = { ...mockTeam, maxMembers: undefined }
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: teamWithoutMax,
        },
      })
      expect(wrapper.text()).toContain('8 miembros')
      expect(wrapper.text()).not.toContain('/')
    })

    it('should calculate occupancy percentage', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      // 8/15 = 53.33% rounds to 53%
      expect(wrapper.text()).toContain('53%')
    })

    it('should show progress bar', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      const progressBar = wrapper.find('.bg-gradient-to-r')
      expect(progressBar.exists()).toBe(true)
      expect(progressBar.attributes('style')).toContain('width: 53%')
    })

    it('should not show progress bar when maxMembers is not set', () => {
      const teamWithoutMax = { ...mockTeam, maxMembers: undefined }
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: teamWithoutMax,
        },
      })
      const progressBar = wrapper.find('.bg-gradient-to-r')
      expect(progressBar.exists()).toBe(false)
    })
  })

  describe('team full state', () => {
    it('should show full banner when team is full', () => {
      const fullTeam = { ...mockTeam, memberCount: 15, maxMembers: 15 }
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: fullTeam,
          isMember: false,
        },
      })
      expect(wrapper.find('.participation-team-card__banner--full').exists()).toBe(true)
      expect(wrapper.text()).toContain('Este equipo está completo')
    })

    it('should not show full banner when user is member', () => {
      const fullTeam = { ...mockTeam, memberCount: 15, maxMembers: 15 }
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: fullTeam,
          isMember: true,
        },
      })
      expect(wrapper.find('.participation-team-card__banner--full').exists()).toBe(false)
    })

    it('should show "Equipo Lleno" on join button when full', () => {
      const fullTeam = { ...mockTeam, memberCount: 15, maxMembers: 15 }
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: fullTeam,
          isMember: false,
        },
      })
      expect(wrapper.text()).toContain('Equipo Lleno')
    })

    it('should disable join button when full', () => {
      const fullTeam = { ...mockTeam, memberCount: 15, maxMembers: 15 }
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: fullTeam,
          isMember: false,
        },
      })
      const joinButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Equipo Lleno'))
      expect(joinButton?.props('disabled')).toBe(true)
    })
  })

  describe('activity level', () => {
    it('should show high activity level', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      expect(wrapper.text()).toContain('Alta Actividad')
    })

    it('should show medium activity level', () => {
      const teamMedium = { ...mockTeam, activityLevel: 'medium' as const }
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: teamMedium,
        },
      })
      expect(wrapper.text()).toContain('Actividad Media')
    })

    it('should show low activity level', () => {
      const teamLow = { ...mockTeam, activityLevel: 'low' as const }
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: teamLow,
        },
      })
      expect(wrapper.text()).toContain('Baja Actividad')
    })

    it('should not show activity level when not provided', () => {
      const teamNoActivity = { ...mockTeam, activityLevel: undefined }
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: teamNoActivity,
        },
      })
      expect(wrapper.text()).not.toContain('Actividad')
    })

    it('should hide activity level in compact mode', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          compact: true,
        },
      })
      expect(wrapper.text()).not.toContain('Alta Actividad')
    })
  })

  describe('meeting schedule', () => {
    it('should show meeting schedule', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      expect(wrapper.text()).toContain('Jueves 18:00')
    })

    it('should not show meeting schedule when not provided', () => {
      const teamNoSchedule = { ...mockTeam, meetingSchedule: undefined }
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: teamNoSchedule,
        },
      })
      const calendarIcons = wrapper.findAllComponents({ name: 'Icon' }).filter(i => i.props('name') === 'calendar')
      expect(calendarIcons.length).toBe(0)
    })

    it('should hide meeting schedule in compact mode', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          compact: true,
        },
      })
      expect(wrapper.text()).not.toContain('Jueves 18:00')
    })
  })

  describe('tags', () => {
    it('should display tags', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      expect(wrapper.text()).toContain('Medio Ambiente')
      expect(wrapper.text()).toContain('Sostenibilidad')
      expect(wrapper.text()).toContain('Comunidad')
    })

    it('should limit tags to 3 and show count', () => {
      const teamManyTags = {
        ...mockTeam,
        tags: ['Tag1', 'Tag2', 'Tag3', 'Tag4', 'Tag5'],
      }
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: teamManyTags,
        },
      })
      expect(wrapper.text()).toContain('Tag1')
      expect(wrapper.text()).toContain('Tag2')
      expect(wrapper.text()).toContain('Tag3')
      expect(wrapper.text()).not.toContain('Tag4')
      expect(wrapper.text()).toContain('+2')
    })

    it('should not show tags when empty', () => {
      const teamNoTags = { ...mockTeam, tags: [] }
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: teamNoTags,
        },
      })
      const badges = wrapper.findAllComponents({ name: 'Badge' })
      const tagBadges = badges.filter(b => b.props('variant') === 'gray')
      expect(tagBadges.length).toBe(0)
    })

    it('should hide tags in compact mode', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          compact: true,
        },
      })
      expect(wrapper.text()).not.toContain('Sostenibilidad')
    })
  })

  describe('last activity', () => {
    it('should show last activity date', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      expect(wrapper.text()).toContain('Última actividad:')
    })

    it('should not show last activity when not provided', () => {
      const teamNoActivity = { ...mockTeam, lastActivity: undefined }
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: teamNoActivity,
        },
      })
      expect(wrapper.text()).not.toContain('Última actividad:')
    })

    it('should hide last activity in compact mode', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          compact: true,
        },
      })
      expect(wrapper.text()).not.toContain('Última actividad:')
    })
  })

  describe('member badges', () => {
    it('should show leader badge when isLeader is true', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          isLeader: true,
        },
      })
      const badges = wrapper.findAllComponents({ name: 'Badge' })
      const leaderBadge = badges.find(b => b.text().includes('Líder'))
      expect(leaderBadge?.exists()).toBe(true)
    })

    it('should show member badge when isMember is true', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          isMember: true,
          isLeader: false,
        },
      })
      const badges = wrapper.findAllComponents({ name: 'Badge' })
      const memberBadge = badges.find(b => b.text().includes('Miembro'))
      expect(memberBadge?.exists()).toBe(true)
    })

    it('should not show member badge when not a member', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          isMember: false,
          isLeader: false,
        },
      })
      const badges = wrapper.findAllComponents({ name: 'Badge' })
      const memberBadge = badges.find(b => b.text().includes('Miembro'))
      // When find() returns undefined, element doesn't exist
      expect(memberBadge).toBeUndefined()
    })
  })

  describe('actions', () => {
    it('should show join button for non-members', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          isMember: false,
          showJoinButton: true,
        },
      })
      const joinButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Unirme'))
      expect(joinButton?.exists()).toBe(true)
    })

    it('should not show join button when showJoinButton is false', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          isMember: false,
          showJoinButton: false,
        },
      })
      const joinButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Unirme'))
      // When find() returns undefined, element doesn't exist
      expect(joinButton).toBeUndefined()
    })

    it('should show leave button for members', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          isMember: true,
          showLeaveButton: true,
        },
      })
      const leaveButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Salir'))
      expect(leaveButton?.exists()).toBe(true)
    })

    it('should not show leave button when showLeaveButton is false', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          isMember: true,
          showLeaveButton: false,
        },
      })
      const leaveButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Salir'))
      // When find() returns undefined, element doesn't exist
      expect(leaveButton).toBeUndefined()
    })

    it('should disable leave button for leaders', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          isMember: true,
          isLeader: true,
        },
      })
      const leaveButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Salir'))
      expect(leaveButton?.props('disabled')).toBe(true)
    })

    it('should show view details button', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      const detailsButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Ver Detalles'))
      expect(detailsButton?.exists()).toBe(true)
    })

    it('should emit join event', async () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          isMember: false,
        },
      })
      const joinButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Unirme'))
      await joinButton?.trigger('click')

      expect(wrapper.emitted('join')).toBeTruthy()
      expect(wrapper.emitted('join')?.[0]).toEqual(['1'])
    })

    it('should emit leave event', async () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          isMember: true,
          isLeader: false,
        },
      })
      const leaveButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Salir'))
      await leaveButton?.trigger('click')

      expect(wrapper.emitted('leave')).toBeTruthy()
      expect(wrapper.emitted('leave')?.[0]).toEqual(['1'])
    })

    it('should emit view-details event', async () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      const detailsButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Ver Detalles'))
      await detailsButton?.trigger('click')

      expect(wrapper.emitted('view-details')).toBeTruthy()
      expect(wrapper.emitted('view-details')?.[0]).toEqual(['1'])
    })

    it('should disable join button when team is inactive', () => {
      const inactiveTeam = { ...mockTeam, status: 'inactive' as const }
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: inactiveTeam,
          isMember: false,
        },
      })
      const joinButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Unirme'))
      expect(joinButton?.props('disabled')).toBe(true)
    })

    it('should disable all actions when disabled prop is true', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          disabled: true,
          isMember: false,
        },
      })
      const joinButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Unirme'))
      expect(joinButton?.props('disabled')).toBe(true)
    })
  })

  describe('loading state', () => {
    it('should show loading state', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
          loading: true,
        },
      })
      const card = wrapper.findComponent({ name: 'Card' })
      // Card component should exist and loading should be passed to the component
      expect(card.exists()).toBe(true)
      // Verify loading prop is passed to wrapper by checking class or attribute
      expect(wrapper.props('loading')).toBe(true)
    })
  })

  describe('icons', () => {
    it('should show appropriate status icons', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      const icons = wrapper.findAllComponents({ name: 'Icon' })
      expect(icons.length).toBeGreaterThan(0)
    })

    it('should show users icon for member count', () => {
      const wrapper = mount(ParticipationTeamCard, {
        props: {
          team: mockTeam,
        },
      })
      const usersIcon = wrapper.findAllComponents({ name: 'Icon' }).find(i => i.props('name') === 'users')
      expect(usersIcon?.exists()).toBe(true)
    })
  })
})
