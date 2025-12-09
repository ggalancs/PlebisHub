<script setup lang="ts">
import { ref, computed, h, defineComponent, type PropType, type VNode } from 'vue'
import Button from '@/components/atoms/Button.vue'
import Icon from '@/components/atoms/Icon.vue'
import Avatar from '@/components/atoms/Avatar.vue'
import Select from '@/components/atoms/Select.vue'
import EmptyState from '@/components/molecules/EmptyState.vue'
import Spinner from '@/components/atoms/Spinner.vue'
import { useForm, validators } from '@/composables'
import DOMPurify from 'dompurify'

export interface Comment {
  id: number | string
  author: {
    id: number | string
    name: string
    avatar?: string
  }
  content: string
  createdAt: Date | string
  updatedAt?: Date | string
  votes: number
  hasVoted: boolean
  replies?: Comment[]
  replyCount: number
  isEdited: boolean
  canEdit: boolean
  canDelete: boolean
}

export type SortOption = 'newest' | 'oldest' | 'most-voted'

interface Props {
  /** Comments list */
  comments: Comment[]
  /** Proposal/item ID */
  itemId: number | string
  /** User is authenticated */
  isAuthenticated?: boolean
  /** Loading comments */
  loading?: boolean
  /** Submitting new comment */
  submitting?: boolean
  /** Allow nested replies */
  allowReplies?: boolean
  /** Maximum nesting level */
  maxNestingLevel?: number
  /** Show sort options */
  sortable?: boolean
  /** Current sort option */
  sortBy?: SortOption
  /** Placeholder for comment input */
  placeholder?: string
  /** Minimum comment length */
  minLength?: number
  /** Maximum comment length */
  maxLength?: number
  /** Show comment count */
  showCount?: boolean
  /** Custom empty message */
  emptyMessage?: string
}

interface Emits {
  (e: 'submit', data: { content: string; parentId?: number | string }): void
  (e: 'edit', commentId: number | string, content: string): void
  (e: 'delete', commentId: number | string): void
  (e: 'vote', commentId: number | string): void
  (e: 'sort', sortBy: SortOption): void
  (e: 'login-required'): void
}

const props = withDefaults(defineProps<Props>(), {
  isAuthenticated: false,
  loading: false,
  submitting: false,
  allowReplies: true,
  maxNestingLevel: 3,
  sortable: true,
  sortBy: 'newest',
  placeholder: 'Escribe tu comentario...',
  minLength: 1,
  maxLength: 1000,
  showCount: true,
  emptyMessage: 'Sé el primero en comentar',
})

const emit = defineEmits<Emits>()

// Form for new comment
const commentForm = useForm(
  { content: '' },
  {
    content: [
      validators.required('El comentario es obligatorio'),
      validators.minLength(props.minLength, `Mínimo ${props.minLength} caracteres`),
      validators.maxLength(props.maxLength, `Máximo ${props.maxLength} caracteres`),
    ],
  }
)

// Reply forms (for nested replies)
const replyForms = ref<Record<string, ReturnType<typeof useForm<{ content: string }>>>>({})
const activeReplyId = ref<number | string | null>(null)
const editingCommentId = ref<number | string | null>(null)
const editingContent = ref('')
const votingCommentId = ref<number | string | null>(null)

// Sort options
const sortOptions = [
  { value: 'newest', label: 'Más recientes' },
  { value: 'oldest', label: 'Más antiguos' },
  { value: 'most-voted', label: 'Más votados' },
]

// Character count for main comment
const characterCount = computed(() => commentForm.values.content.length)

// Character count color
const characterCountColor = computed(() => {
  const remaining = props.maxLength - characterCount.value
  if (remaining < 50) return 'text-error'
  if (remaining < 100) return 'text-warning'
  return 'text-gray-500'
})

// Total comment count (including replies)
const totalCommentCount = computed(() => {
  const countReplies = (comment: Comment): number => {
    let count = 1
    if (comment.replies && comment.replies.length > 0) {
      count += comment.replies.reduce((acc, reply) => acc + countReplies(reply), 0)
    }
    return count
  }

  return props.comments.reduce((acc, comment) => acc + countReplies(comment), 0)
})

// Format date
const formatDate = (date: Date | string): string => {
  const d = typeof date === 'string' ? new Date(date) : date
  const now = new Date()
  const diff = now.getTime() - d.getTime()
  const seconds = Math.floor(diff / 1000)
  const minutes = Math.floor(seconds / 60)
  const hours = Math.floor(minutes / 60)
  const days = Math.floor(hours / 24)

  if (days > 7) {
    return d.toLocaleDateString()
  } else if (days > 0) {
    return `hace ${days} ${days === 1 ? 'día' : 'días'}`
  } else if (hours > 0) {
    return `hace ${hours} ${hours === 1 ? 'hora' : 'horas'}`
  } else if (minutes > 0) {
    return `hace ${minutes} ${minutes === 1 ? 'minuto' : 'minutos'}`
  } else {
    return 'hace un momento'
  }
}

// Submit new comment
const handleSubmit = async () => {
  if (!props.isAuthenticated) {
    emit('login-required')
    return
  }

  const isValid = await commentForm.validateForm()
  if (!isValid) return

  emit('submit', { content: commentForm.values.content })
  commentForm.resetForm()
}

// Toggle reply form
const toggleReply = (commentId: number | string) => {
  if (activeReplyId.value === commentId) {
    activeReplyId.value = null
  } else {
    if (!props.isAuthenticated) {
      emit('login-required')
      return
    }
    activeReplyId.value = commentId
    if (!replyForms.value[commentId]) {
      replyForms.value[commentId] = useForm(
        { content: '' },
        {
          content: [
            validators.required('La respuesta es obligatoria'),
            validators.minLength(props.minLength, `Mínimo ${props.minLength} caracteres`),
            validators.maxLength(props.maxLength, `Máximo ${props.maxLength} caracteres`),
          ],
        }
      )
    }
  }
}

// Submit reply
const handleReplySubmit = async (parentId: number | string) => {
  const form = replyForms.value[parentId]
  if (!form) return

  const isValid = await form.validateForm()
  if (!isValid) return

  emit('submit', { content: form.values.content, parentId })
  form.resetForm()
  activeReplyId.value = null
}

// Start editing
const startEdit = (comment: Comment) => {
  editingCommentId.value = comment.id
  editingContent.value = comment.content
}

// Cancel editing
const cancelEdit = () => {
  editingCommentId.value = null
  editingContent.value = ''
}

// Save edit
const saveEdit = () => {
  if (!editingCommentId.value) return
  emit('edit', editingCommentId.value, editingContent.value)
  cancelEdit()
}

// Delete comment
const handleDelete = (commentId: number | string) => {
  if (confirm('¿Estás seguro de que deseas eliminar este comentario?')) {
    emit('delete', commentId)
  }
}

// Vote on comment
const handleVote = async (commentId: number | string) => {
  if (!props.isAuthenticated) {
    emit('login-required')
    return
  }
  votingCommentId.value = commentId
  emit('vote', commentId)
  setTimeout(() => {
    votingCommentId.value = null
  }, 500)
}

// Handle sort change
const handleSortChange = (sort: string | number) => {
  emit('sort', sort as SortOption)
}

// Sanitize content
const sanitizeContent = (content: string) => {
  return DOMPurify.sanitize(content, {
    ALLOWED_TAGS: [],
    KEEP_CONTENT: true
  })
}

// CommentItem component defined using render function for recursion
const CommentItem = defineComponent({
  name: 'CommentItem',
  props: {
    comment: {
      type: Object as PropType<Comment>,
      required: true,
    },
    level: {
      type: Number,
      default: 0,
    },
  },
  setup(itemProps) {
    const canReply = computed(() => {
      return props.allowReplies && itemProps.level < props.maxNestingLevel
    })

    return () => {
      const comment = itemProps.comment
      const level = itemProps.level

      // Build the comment content
      const children: VNode[] = []

      // Comment card
      const commentCard = h('div', {
        class: 'comment-item__content bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4'
      }, [
        // Header
        h('div', { class: 'flex items-start justify-between mb-3' }, [
          h('div', { class: 'flex items-center space-x-3' }, [
            h(Avatar, { src: comment.author.avatar, alt: comment.author.name, size: 'sm' }),
            h('div', {}, [
              h('p', { class: 'font-semibold text-sm' }, comment.author.name),
              h('p', { class: 'text-xs text-gray-500 dark:text-gray-400' }, [
                formatDate(comment.createdAt),
                comment.isEdited ? h('span', { class: 'italic' }, ' (editado)') : null
              ])
            ])
          ]),
          // Actions
          (comment.canEdit || comment.canDelete) ? h('div', { class: 'flex space-x-2' }, [
            comment.canEdit && editingCommentId.value !== comment.id
              ? h('button', {
                  class: 'text-xs text-gray-600 dark:text-gray-400 hover:text-primary',
                  'aria-label': 'Editar comentario',
                  onClick: () => startEdit(comment)
                }, [h(Icon, { name: 'edit', class: 'w-4 h-4' })])
              : null,
            comment.canDelete
              ? h('button', {
                  class: 'text-xs text-gray-600 dark:text-gray-400 hover:text-error',
                  'aria-label': 'Eliminar comentario',
                  onClick: () => handleDelete(comment.id)
                }, [h(Icon, { name: 'trash', class: 'w-4 h-4' })])
              : null
          ]) : null
        ]),

        // Body (editing or display)
        editingCommentId.value === comment.id
          ? h('div', { class: 'mb-3' }, [
              h('textarea', {
                value: editingContent.value,
                onInput: (e: Event) => { editingContent.value = (e.target as HTMLTextAreaElement).value },
                class: 'w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg resize-none focus:outline-none focus:ring-2 focus:ring-primary dark:bg-gray-700 dark:text-white',
                rows: 3
              }),
              h('div', { class: 'flex space-x-2 mt-2' }, [
                h(Button, { size: 'sm', variant: 'primary', onClick: saveEdit }, () => 'Guardar'),
                h(Button, { size: 'sm', variant: 'outline', onClick: cancelEdit }, () => 'Cancelar')
              ])
            ])
          : h('div', { class: 'mb-3' }, [
              h('p', {
                class: 'text-sm text-gray-700 dark:text-gray-300 whitespace-pre-wrap'
              }, sanitizeContent(comment.content))
            ]),

        // Footer
        h('div', { class: 'flex items-center space-x-4' }, [
          // Vote button
          h('button', {
            class: [
              'flex items-center space-x-1 text-xs hover:text-primary transition-colors',
              comment.hasVoted ? 'text-primary' : 'text-gray-600 dark:text-gray-400'
            ],
            disabled: votingCommentId.value === comment.id,
            onClick: () => handleVote(comment.id)
          }, [
            h(Icon, { name: comment.hasVoted ? 'thumb-up-filled' : 'thumb-up', class: 'w-4 h-4' }),
            h('span', {}, String(comment.votes))
          ]),
          // Reply button
          canReply.value
            ? h('button', {
                class: 'flex items-center space-x-1 text-xs text-gray-600 dark:text-gray-400 hover:text-primary transition-colors',
                onClick: () => toggleReply(comment.id)
              }, [
                h(Icon, { name: 'reply', class: 'w-4 h-4' }),
                h('span', {}, 'Responder')
              ])
            : null,
          // Reply count
          comment.replyCount > 0
            ? h('span', { class: 'text-xs text-gray-500 dark:text-gray-400' },
                `${comment.replyCount} ${comment.replyCount === 1 ? 'respuesta' : 'respuestas'}`)
            : null
        ])
      ])

      children.push(commentCard)

      // Reply form
      if (activeReplyId.value === comment.id && replyForms.value[comment.id]) {
        const replyForm = replyForms.value[comment.id]
        children.push(
          h('div', { class: 'mt-4 ml-8' }, [
            h('div', { class: 'bg-gray-50 dark:bg-gray-800 rounded-lg border border-gray-300 dark:border-gray-600 p-4' }, [
              h('textarea', {
                value: replyForm.values.content,
                onInput: (e: Event) => { replyForm.values.content = (e.target as HTMLTextAreaElement).value },
                placeholder: 'Escribe tu respuesta...',
                class: 'w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg resize-none focus:outline-none focus:ring-2 focus:ring-primary dark:bg-gray-700 dark:text-white',
                rows: 2
              }),
              h('div', { class: 'flex space-x-2 mt-2' }, [
                h(Button, { size: 'sm', variant: 'primary', onClick: () => handleReplySubmit(comment.id) }, () => 'Responder'),
                h(Button, { size: 'sm', variant: 'outline', onClick: () => toggleReply(comment.id) }, () => 'Cancelar')
              ])
            ])
          ])
        )
      }

      // Nested replies
      if (comment.replies && comment.replies.length > 0) {
        children.push(
          h('div', { class: 'mt-4 space-y-4' },
            comment.replies.map(reply =>
              h(CommentItem, { key: reply.id, comment: reply, level: level + 1 })
            )
          )
        )
      }

      return h('div', {
        class: [
          'comment-item',
          level > 0 ? 'ml-8 border-l-2 border-gray-200 dark:border-gray-700 pl-4' : ''
        ]
      }, children)
    }
  }
})
</script>

<template>
  <div class="comments-section">
    <!-- Header -->
    <div class="comments-section__header mb-6">
      <div class="flex items-center justify-between">
        <h3 class="text-xl font-bold">
          Comentarios
          <span v-if="showCount" class="text-gray-500 font-normal text-base ml-2">
            ({{ totalCommentCount }})
          </span>
        </h3>

        <!-- Sort Select -->
        <Select
          v-if="sortable && comments.length > 0"
          :options="sortOptions"
          :model-value="sortBy"
          class="w-48"
          @update:model-value="handleSortChange"
        />
      </div>
    </div>

    <!-- New Comment Form -->
    <div v-if="isAuthenticated" class="comments-section__form mb-8">
      <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-300 dark:border-gray-600 p-4">
        <textarea
          v-model="commentForm.values.content"
          :placeholder="placeholder"
          :disabled="submitting"
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg resize-none focus:outline-none focus:ring-2 focus:ring-primary dark:bg-gray-700 dark:text-white"
          rows="3"
          @blur="commentForm.validateField('content')"
        />

        <!-- Character Count -->
        <div class="flex items-center justify-between mt-2">
          <span :class="['text-xs', characterCountColor]">
            {{ characterCount }} / {{ maxLength }}
          </span>

          <Button
            variant="primary"
            size="sm"
            :disabled="!commentForm.isValid.value || submitting"
            :loading="submitting"
            @click="handleSubmit"
          >
            <template #icon>
              <Icon name="send" />
            </template>
            Comentar
          </Button>
        </div>

        <!-- Validation Error -->
        <p
          v-if="commentForm.errors.value.content && commentForm.touched.content"
          class="text-sm text-error mt-2"
        >
          {{ commentForm.errors.value.content }}
        </p>
      </div>
    </div>

    <!-- Login Prompt -->
    <div v-else class="comments-section__login-prompt mb-8">
      <div class="bg-gray-50 dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6 text-center">
        <Icon name="lock" class="w-12 h-12 mx-auto mb-3 text-gray-400" />
        <p class="text-gray-600 dark:text-gray-400 mb-4">
          Inicia sesión para participar en la conversación
        </p>
        <Button variant="primary" @click="emit('login-required')">
          Iniciar Sesión
        </Button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center py-12">
      <Spinner size="lg" />
    </div>

    <!-- Empty State -->
    <EmptyState
      v-else-if="comments.length === 0"
      :title="emptyMessage"
      description="Comparte tu opinión y comienza la conversación"
      icon="message"
    />

    <!-- Comments List -->
    <div v-else class="comments-section__list space-y-6">
      <CommentItem
        v-for="comment in comments"
        :key="comment.id"
        :comment="comment"
        :level="0"
      />
    </div>
  </div>
</template>

<style scoped>
.comments-section {
  /* Container styles */
}

.comment-item {
  /* Comment item styles */
}

/* Smooth transitions */
.comment-item__content {
  transition: all 0.2s ease;
}

.comment-item__content:hover {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}
</style>
