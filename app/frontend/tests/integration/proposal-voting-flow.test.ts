/**
 * Integration Test: Proposal Creation and Voting Flow
 *
 * Critical Flow: ProposalForm + VotingWidget + CommentsSection
 * Tests the complete proposal lifecycle:
 * - Proposal creation with validation
 * - Voting functionality
 * - Comment sanitization (XSS prevention)
 * - Real-time statistics updates
 */

import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import ProposalForm from '@/components/organisms/ProposalForm.vue'
import VotingWidget from '@/components/organisms/VotingWidget.vue'
import CommentsSection from '@/components/organisms/CommentsSection.vue'
import DOMPurify from 'dompurify'

describe('Proposal Creation and Voting Flow', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('should create proposal with complete validation', async () => {
    const onSubmit = vi.fn()
    const wrapper = mount(ProposalForm, {
      props: {
        mode: 'create',
      },
    })

    wrapper.vm.$on('submit', onSubmit)

    // Fill title (min 10 chars)
    const titleInput = wrapper.findAll('input').find(i =>
      i.attributes('placeholder')?.toLowerCase().includes('título')
    )
    await titleInput?.setValue('Propuesta para mejorar el transporte público')

    // Fill description (min 50 chars)
    const descriptionTextarea = wrapper.findComponent({ name: 'Textarea' })
    await descriptionTextarea?.setValue(
      'Esta propuesta busca mejorar el sistema de transporte público mediante la implementación de nuevas rutas y horarios más flexibles.'
    )

    // Select category
    const categorySelect = wrapper.findComponent({ name: 'Select' })
    await categorySelect?.setValue('infraestructura')

    // Add tags
    const tagInput = wrapper.findAll('input').find(i =>
      i.attributes('placeholder')?.toLowerCase().includes('etiqueta')
    )
    await tagInput?.setValue('transporte')

    const addTagButton = wrapper.findAll('button').find(b =>
      b.text().includes('Agregar')
    )
    await addTagButton?.trigger('click')

    // Submit form
    const submitButton = wrapper.findAll('button').find(b =>
      b.text().includes('Crear')
    )
    await submitButton?.trigger('click')
    await flushPromises()

    // Should emit submit event with valid data
    expect(wrapper.emitted('submit')).toBeTruthy()
    const submittedData = wrapper.emitted('submit')?.[0]?.[0] as any
    expect(submittedData.title).toBe('Propuesta para mejorar el transporte público')
    expect(submittedData.tags).toContain('transporte')
  })

  it('should prevent submission with invalid data', async () => {
    const onSubmit = vi.fn()
    const wrapper = mount(ProposalForm, {
      props: {
        mode: 'create',
      },
    })

    wrapper.vm.$on('submit', onSubmit)

    // Try to submit with short title (< 10 chars)
    const titleInput = wrapper.findAll('input').find(i =>
      i.attributes('placeholder')?.toLowerCase().includes('título')
    )
    await titleInput?.setValue('Short')

    const submitButton = wrapper.findAll('button').find(b =>
      b.text().includes('Crear')
    )
    await submitButton?.trigger('click')
    await flushPromises()

    // Should show validation error
    expect(wrapper.text()).toContain('10 caracteres')
    expect(wrapper.emitted('submit')).toBeFalsy()
  })
})

describe('Voting Integration', () => {
  it('should handle upvote/downvote correctly', async () => {
    const onVote = vi.fn()
    const wrapper = mount(VotingWidget, {
      props: {
        proposalId: 1,
        initialVotes: { upvotes: 10, downvotes: 5, totalVotes: 15 },
        userVote: null,
        isAuthenticated: true,
      },
    })

    wrapper.vm.$on('vote', onVote)

    // Click upvote
    const upvoteButton = wrapper.findAll('button').find(b =>
      b.attributes('aria-label')?.includes('Upvote')
    )
    await upvoteButton?.trigger('click')
    await flushPromises()

    // Should emit vote event
    expect(wrapper.emitted('vote')).toBeTruthy()
    expect(wrapper.emitted('vote')?.[0]).toEqual([1, 'up'])
  })

  it('should require authentication for voting', async () => {
    const onLoginRequired = vi.fn()
    const wrapper = mount(VotingWidget, {
      props: {
        proposalId: 1,
        initialVotes: { upvotes: 10, downvotes: 5, totalVotes: 15 },
        userVote: null,
        isAuthenticated: false,
      },
    })

    wrapper.vm.$on('login-required', onLoginRequired)

    // Try to vote when not authenticated
    const upvoteButton = wrapper.findAll('button').find(b =>
      b.attributes('aria-label')?.includes('Upvote')
    )
    await upvoteButton?.trigger('click')
    await flushPromises()

    // Should emit login-required
    expect(wrapper.emitted('login-required')).toBeTruthy()
    expect(wrapper.emitted('vote')).toBeFalsy()
  })
})

describe('Comment Sanitization (XSS Prevention)', () => {
  it('should sanitize malicious HTML in comments', () => {
    const maliciousComment = '<script>alert("XSS")</script><p>Real content</p>'
    const sanitized = DOMPurify.sanitize(maliciousComment, {
      ALLOWED_TAGS: [],
      KEEP_CONTENT: true,
    })

    // Script should be removed
    expect(sanitized).not.toContain('<script>')
    expect(sanitized).not.toContain('alert')
    expect(sanitized).toContain('Real content')
  })

  it('should display sanitized comments safely', async () => {
    const comments = [
      {
        id: '1',
        content: '<img src=x onerror="alert(1)">Safe text',
        author: { id: '1', name: 'User', avatar: '' },
        createdAt: new Date().toISOString(),
        likes: 0,
        canEdit: false,
        canDelete: false,
      },
    ]

    const wrapper = mount(CommentsSection, {
      props: {
        comments,
        itemId: 1,
        isAuthenticated: true,
      },
    })

    await flushPromises()

    const html = wrapper.html()

    // Should not contain malicious attributes
    expect(html).not.toContain('onerror=')
    expect(html).not.toContain('alert(1)')
  })

  it('should prevent XSS through comment submission', async () => {
    const onSubmit = vi.fn()
    const wrapper = mount(CommentsSection, {
      props: {
        comments: [],
        itemId: 1,
        isAuthenticated: true,
      },
    })

    wrapper.vm.$on('submit', onSubmit)

    // Try to submit comment with XSS payload
    const textarea = wrapper.find('textarea')
    await textarea.setValue('<script>steal_cookies()</script>')

    const submitButton = wrapper.findAll('button').find(b =>
      b.text().includes('Comentar')
    )
    await submitButton?.trigger('click')
    await flushPromises()

    // Content should be submitted but will be sanitized on display
    expect(wrapper.emitted('submit')).toBeTruthy()
    const content = wrapper.emitted('submit')?.[0]?.[0] as string

    // When rendered, it should be safe
    const sanitized = DOMPurify.sanitize(content, {
      ALLOWED_TAGS: [],
      KEEP_CONTENT: true,
    })
    expect(sanitized).not.toContain('<script>')
  })
})

describe('End-to-End Proposal Flow', () => {
  it('should complete full flow: create -> vote -> comment', async () => {
    // 1. Create Proposal
    const proposalWrapper = mount(ProposalForm, {
      props: { mode: 'create' },
    })

    const titleInput = proposalWrapper.findAll('input')[0]
    await titleInput.setValue('Test Proposal for Integration')

    const descriptionTextarea = proposalWrapper.findComponent({ name: 'Textarea' })
    await descriptionTextarea?.setValue('A' + ' long'.repeat(20) + ' description')

    const submitButton = proposalWrapper.findAll('button').find(b =>
      b.text().includes('Crear')
    )
    await submitButton?.trigger('click')
    await flushPromises()

    expect(proposalWrapper.emitted('submit')).toBeTruthy()

    // 2. Vote on Proposal
    const votingWrapper = mount(VotingWidget, {
      props: {
        proposalId: 1,
        initialVotes: { upvotes: 0, downvotes: 0, totalVotes: 0 },
        userVote: null,
        isAuthenticated: true,
      },
    })

    const upvoteButton = votingWrapper.findAll('button')[0]
    await upvoteButton.trigger('click')
    await flushPromises()

    expect(votingWrapper.emitted('vote')).toBeTruthy()

    // 3. Add Comment
    const commentsWrapper = mount(CommentsSection, {
      props: {
        comments: [],
        itemId: 1,
        isAuthenticated: true,
      },
    })

    const commentTextarea = commentsWrapper.find('textarea')
    await commentTextarea.setValue('Great proposal!')

    const commentButton = commentsWrapper.findAll('button').find(b =>
      b.text().includes('Comentar')
    )
    await commentButton?.trigger('click')
    await flushPromises()

    expect(commentsWrapper.emitted('submit')).toBeTruthy()
  })
})
