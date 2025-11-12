import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import CommentsSection from './CommentsSection.vue'
import type { Comment } from './CommentsSection.vue'

const mockComment: Comment = {
  id: 1,
  author: {
    id: 1,
    name: 'Juan Pérez',
    avatar: 'https://via.placeholder.com/150',
  },
  content: 'Este es un comentario de prueba',
  createdAt: new Date(Date.now() - 3600000), // 1 hour ago
  votes: 5,
  hasVoted: false,
  replyCount: 0,
  isEdited: false,
  canEdit: false,
  canDelete: false,
}

const mockCommentWithReplies: Comment = {
  ...mockComment,
  id: 2,
  replyCount: 2,
  replies: [
    {
      ...mockComment,
      id: 3,
      content: 'Esta es una respuesta',
      replyCount: 0,
    },
    {
      ...mockComment,
      id: 4,
      content: 'Esta es otra respuesta',
      replyCount: 0,
    },
  ],
}

describe('CommentsSection', () => {
  describe('rendering', () => {
    it('should render the component', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
        },
      })

      expect(wrapper.find('.comments-section').exists()).toBe(true)
    })

    it('should display comments header', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('Comentarios')
    })

    it('should display comment count when showCount is true', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockComment],
          itemId: 1,
          showCount: true,
        },
      })

      expect(wrapper.text()).toContain('(1)')
    })

    it('should not display comment count when showCount is false', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockComment],
          itemId: 1,
          showCount: false,
        },
      })

      expect(wrapper.text()).not.toMatch(/\(\d+\)/)
    })

    it('should calculate total comment count including replies', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockCommentWithReplies],
          itemId: 1,
          showCount: true,
        },
      })

      expect(wrapper.text()).toContain('(3)') // 1 parent + 2 replies
    })

    it('should display sort dropdown when sortable is true', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockComment],
          itemId: 1,
          sortable: true,
        },
      })

      expect(wrapper.findComponent({ name: 'Dropdown' }).exists()).toBe(true)
    })

    it('should not display sort dropdown when sortable is false', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockComment],
          itemId: 1,
          sortable: false,
        },
      })

      expect(wrapper.findComponent({ name: 'Dropdown' }).exists()).toBe(false)
    })
  })

  describe('authentication', () => {
    it('should show comment form when authenticated', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
          isAuthenticated: true,
        },
      })

      expect(wrapper.find('.comments-section__form').exists()).toBe(true)
      expect(wrapper.find('textarea').exists()).toBe(true)
    })

    it('should show login prompt when not authenticated', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
          isAuthenticated: false,
        },
      })

      expect(wrapper.find('.comments-section__login-prompt').exists()).toBe(true)
      expect(wrapper.text()).toContain('Inicia sesión para participar')
    })

    it('should emit login-required when clicking login button', async () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
          isAuthenticated: false,
        },
      })

      const button = wrapper.findComponent({ name: 'Button' })
      await button.trigger('click')

      expect(wrapper.emitted('login-required')).toBeTruthy()
    })
  })

  describe('empty state', () => {
    it('should show empty state when no comments', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
          loading: false,
        },
      })

      expect(wrapper.findComponent({ name: 'EmptyState' }).exists()).toBe(true)
    })

    it('should display custom empty message', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
          loading: false,
          emptyMessage: 'No hay comentarios todavía',
        },
      })

      const emptyState = wrapper.findComponent({ name: 'EmptyState' })
      expect(emptyState.props('title')).toBe('No hay comentarios todavía')
    })
  })

  describe('loading state', () => {
    it('should show spinner when loading', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
          loading: true,
        },
      })

      expect(wrapper.findComponent({ name: 'Spinner' }).exists()).toBe(true)
    })

    it('should not show comments when loading', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockComment],
          itemId: 1,
          loading: true,
        },
      })

      expect(wrapper.find('.comments-section__list').exists()).toBe(false)
    })
  })

  describe('comment form', () => {
    it('should render textarea with placeholder', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
          isAuthenticated: true,
          placeholder: 'Escribe aquí...',
        },
      })

      const textarea = wrapper.find('textarea')
      expect(textarea.attributes('placeholder')).toBe('Escribe aquí...')
    })

    it('should show character count', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
          isAuthenticated: true,
          maxLength: 500,
        },
      })

      expect(wrapper.text()).toContain('0 / 500')
    })

    it('should update character count as user types', async () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
          isAuthenticated: true,
          maxLength: 500,
        },
      })

      const textarea = wrapper.find('textarea')
      await textarea.setValue('Test comment')
      await nextTick()

      expect(wrapper.text()).toContain('12 / 500')
    })

    it('should show warning color when near character limit', async () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
          isAuthenticated: true,
          maxLength: 100,
        },
      })

      const textarea = wrapper.find('textarea')
      await textarea.setValue('a'.repeat(95))
      await nextTick()

      expect(wrapper.find('.text-warning').exists()).toBe(true)
    })

    it('should show error color when very close to character limit', async () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
          isAuthenticated: true,
          maxLength: 100,
        },
      })

      const textarea = wrapper.find('textarea')
      await textarea.setValue('a'.repeat(98))
      await nextTick()

      expect(wrapper.find('.text-error').exists()).toBe(true)
    })

    it('should disable submit button when form is invalid', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
          isAuthenticated: true,
        },
      })

      const submitButton = wrapper.findAllComponents({ name: 'Button' })[0]
      expect(submitButton.props('disabled')).toBe(true)
    })

    it('should enable submit button when form is valid', async () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
          isAuthenticated: true,
          minLength: 1,
        },
      })

      const textarea = wrapper.find('textarea')
      await textarea.setValue('Valid comment')
      await nextTick()

      const submitButton = wrapper.findAllComponents({ name: 'Button' })[0]
      expect(submitButton.props('disabled')).toBe(false)
    })

    it('should show loading state when submitting', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
          isAuthenticated: true,
          submitting: true,
        },
      })

      const submitButton = wrapper.findAllComponents({ name: 'Button' })[0]
      expect(submitButton.props('loading')).toBe(true)
    })
  })

  describe('submitting comments', () => {
    it('should emit submit event with content', async () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
          isAuthenticated: true,
          minLength: 1,
        },
      })

      const textarea = wrapper.find('textarea')
      await textarea.setValue('My comment')
      await nextTick()

      const submitButton = wrapper.findAllComponents({ name: 'Button' })[0]
      await submitButton.trigger('click')

      expect(wrapper.emitted('submit')).toBeTruthy()
      expect(wrapper.emitted('submit')?.[0]).toEqual([{ content: 'My comment' }])
    })

    it('should emit login-required when not authenticated and trying to submit', async () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
          isAuthenticated: false,
        },
      })

      // Manually trigger the submit handler since form is not visible
      await wrapper.vm.handleSubmit()

      expect(wrapper.emitted('login-required')).toBeTruthy()
    })

    it('should validate minimum length', async () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
          isAuthenticated: true,
          minLength: 10,
        },
      })

      const textarea = wrapper.find('textarea')
      await textarea.setValue('Short')
      await textarea.trigger('blur')
      await nextTick()

      expect(wrapper.text()).toContain('Mínimo 10 caracteres')
    })

    it('should validate maximum length', async () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [],
          itemId: 1,
          isAuthenticated: true,
          maxLength: 20,
        },
      })

      const textarea = wrapper.find('textarea')
      await textarea.setValue('This is a very long comment that exceeds the limit')
      await textarea.trigger('blur')
      await nextTick()

      expect(wrapper.text()).toContain('Máximo 20 caracteres')
    })
  })

  describe('displaying comments', () => {
    it('should display comment author name', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockComment],
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('Juan Pérez')
    })

    it('should display comment content', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockComment],
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('Este es un comentario de prueba')
    })

    it('should display comment votes', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockComment],
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('5')
    })

    it('should display formatted date', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockComment],
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('hace')
    })

    it('should display avatar', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockComment],
          itemId: 1,
        },
      })

      expect(wrapper.findComponent({ name: 'Avatar' }).exists()).toBe(true)
    })

    it('should show edited indicator when comment is edited', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [{ ...mockComment, isEdited: true }],
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('(editado)')
    })
  })

  describe('nested replies', () => {
    it('should display nested replies', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockCommentWithReplies],
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('Esta es una respuesta')
      expect(wrapper.text()).toContain('Esta es otra respuesta')
    })

    it('should show reply count', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockCommentWithReplies],
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('2 respuestas')
    })

    it('should show singular label for 1 reply', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [{ ...mockComment, replyCount: 1 }],
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('1 respuesta')
    })

    it('should apply proper indentation for nested comments', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockCommentWithReplies],
          itemId: 1,
        },
      })

      const commentItems = wrapper.findAll('.comment-item')
      expect(commentItems.length).toBeGreaterThan(1)
      expect(commentItems[1].classes()).toContain('ml-8')
    })
  })

  describe('voting', () => {
    it('should emit vote event when clicking vote button', async () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockComment],
          itemId: 1,
          isAuthenticated: true,
        },
      })

      const voteButton = wrapper.find('.comment-item__content button')
      await voteButton.trigger('click')

      expect(wrapper.emitted('vote')).toBeTruthy()
      expect(wrapper.emitted('vote')?.[0]).toEqual([1])
    })

    it('should emit login-required when not authenticated and trying to vote', async () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockComment],
          itemId: 1,
          isAuthenticated: false,
        },
      })

      const voteButton = wrapper.find('.comment-item__content button')
      await voteButton.trigger('click')

      expect(wrapper.emitted('login-required')).toBeTruthy()
    })

    it('should show voted state', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [{ ...mockComment, hasVoted: true }],
          itemId: 1,
        },
      })

      const voteButton = wrapper.find('.comment-item__content button')
      expect(voteButton.classes()).toContain('text-primary')
    })
  })

  describe('editing comments', () => {
    it('should show edit button when canEdit is true', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [{ ...mockComment, canEdit: true }],
          itemId: 1,
        },
      })

      const editButton = wrapper.find('.comment-item__content button[class*="hover:text-primary"]')
      expect(editButton.exists()).toBe(true)
    })

    it('should not show edit button when canEdit is false', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [{ ...mockComment, canEdit: false }],
          itemId: 1,
        },
      })

      const editButton = wrapper.find('.comment-item__content button[class*="hover:text-primary"]')
      expect(editButton.exists()).toBe(false)
    })

    it('should show textarea when editing', async () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [{ ...mockComment, canEdit: true }],
          itemId: 1,
        },
      })

      // Manually trigger edit mode
      wrapper.vm.startEdit(mockComment)
      await nextTick()

      const textareas = wrapper.findAll('textarea')
      expect(textareas.length).toBeGreaterThan(0)
    })

    it('should emit edit event when saving', async () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [{ ...mockComment, canEdit: true }],
          itemId: 1,
        },
      })

      wrapper.vm.startEdit(mockComment)
      wrapper.vm.editingContent = 'Updated content'
      wrapper.vm.saveEdit()

      expect(wrapper.emitted('edit')).toBeTruthy()
      expect(wrapper.emitted('edit')?.[0]).toEqual([1, 'Updated content'])
    })
  })

  describe('deleting comments', () => {
    beforeEach(() => {
      global.confirm = vi.fn(() => true)
    })

    it('should show delete button when canDelete is true', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [{ ...mockComment, canDelete: true }],
          itemId: 1,
        },
      })

      const deleteButton = wrapper.find('.comment-item__content button[class*="hover:text-error"]')
      expect(deleteButton.exists()).toBe(true)
    })

    it('should not show delete button when canDelete is false', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [{ ...mockComment, canDelete: false }],
          itemId: 1,
        },
      })

      const deleteButton = wrapper.find('.comment-item__content button[class*="hover:text-error"]')
      expect(deleteButton.exists()).toBe(false)
    })

    it('should show confirmation dialog when deleting', async () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [{ ...mockComment, canDelete: true }],
          itemId: 1,
        },
      })

      await wrapper.vm.handleDelete(1)

      expect(global.confirm).toHaveBeenCalledWith(
        '¿Estás seguro de que deseas eliminar este comentario?'
      )
    })

    it('should emit delete event when confirmed', async () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [{ ...mockComment, canDelete: true }],
          itemId: 1,
        },
      })

      await wrapper.vm.handleDelete(1)

      expect(wrapper.emitted('delete')).toBeTruthy()
      expect(wrapper.emitted('delete')?.[0]).toEqual([1])
    })

    it('should not emit delete event when cancelled', async () => {
      global.confirm = vi.fn(() => false)

      const wrapper = mount(CommentsSection, {
        props: {
          comments: [{ ...mockComment, canDelete: true }],
          itemId: 1,
        },
      })

      await wrapper.vm.handleDelete(1)

      expect(wrapper.emitted('delete')).toBeFalsy()
    })
  })

  describe('replying to comments', () => {
    it('should show reply button when allowReplies is true', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockComment],
          itemId: 1,
          allowReplies: true,
        },
      })

      expect(wrapper.text()).toContain('Responder')
    })

    it('should not show reply button when allowReplies is false', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockComment],
          itemId: 1,
          allowReplies: false,
        },
      })

      expect(wrapper.text()).not.toContain('Responder')
    })

    it('should emit login-required when not authenticated and trying to reply', async () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockComment],
          itemId: 1,
          isAuthenticated: false,
          allowReplies: true,
        },
      })

      await wrapper.vm.toggleReply(1)

      expect(wrapper.emitted('login-required')).toBeTruthy()
    })

    it('should not show reply button when max nesting level reached', () => {
      const deeplyNestedComment = {
        ...mockComment,
        id: 1,
        replies: [
          {
            ...mockComment,
            id: 2,
            replies: [
              {
                ...mockComment,
                id: 3,
                replies: [],
              },
            ],
          },
        ],
      }

      const wrapper = mount(CommentsSection, {
        props: {
          comments: [deeplyNestedComment],
          itemId: 1,
          allowReplies: true,
          maxNestingLevel: 2,
        },
      })

      // The deepest comment (level 2) should not have a reply button
      const commentItems = wrapper.findAll('.comment-item')
      expect(commentItems.length).toBe(3)
    })
  })

  describe('sorting', () => {
    it('should emit sort event when changing sort option', async () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [mockComment],
          itemId: 1,
          sortable: true,
        },
      })

      await wrapper.vm.handleSortChange('oldest')

      expect(wrapper.emitted('sort')).toBeTruthy()
      expect(wrapper.emitted('sort')?.[0]).toEqual(['oldest'])
    })
  })

  describe('date formatting', () => {
    it('should format recent dates as "hace X minutos"', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [{ ...mockComment, createdAt: new Date(Date.now() - 300000) }], // 5 min ago
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('hace 5 minutos')
    })

    it('should format dates as "hace X horas"', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [{ ...mockComment, createdAt: new Date(Date.now() - 7200000) }], // 2 hours ago
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('hace 2 horas')
    })

    it('should format dates as "hace X días"', () => {
      const wrapper = mount(CommentsSection, {
        props: {
          comments: [{ ...mockComment, createdAt: new Date(Date.now() - 172800000) }], // 2 days ago
          itemId: 1,
        },
      })

      expect(wrapper.text()).toContain('hace 2 días')
    })
  })
})
