<script setup lang="ts">
import { ref, computed } from 'vue'
import Button from '@/components/atoms/Button.vue'
import Icon from '@/components/atoms/Icon.vue'
import Avatar from '@/components/atoms/Avatar.vue'
import Dropdown from '@/components/molecules/Dropdown.vue'
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
const replyForms = ref<Record<string, any>>({})
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

  const isValid = await commentForm.validate()
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

  const isValid = await form.validate()
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
const handleSortChange = (sort: string) => {
  emit('sort', sort as SortOption)
}

// Calculate nesting level
const getNestingLevel = (comment: Comment, level = 0): number => {
  if (!comment.replies || comment.replies.length === 0) return level
  return Math.max(...comment.replies.map((reply) => getNestingLevel(reply, level + 1)))
}

// Sanitize content
const sanitizedContent = (content: string) => {
  return DOMPurify.sanitize(content, {
    ALLOWED_TAGS: [],
    KEEP_CONTENT: true
  })
}
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

        <!-- Sort Dropdown -->
        <Dropdown
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
          v-if="commentForm.fieldErrors.content && commentForm.touchedFields.content"
          class="text-sm text-error mt-2"
        >
          {{ commentForm.fieldErrors.content }}
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
        :max-nesting-level="maxNestingLevel"
        :allow-replies="allowReplies"
        :is-authenticated="isAuthenticated"
        :active-reply-id="activeReplyId"
        :editing-comment-id="editingCommentId"
        :editing-content="editingContent"
        :voting-comment-id="votingCommentId"
        :reply-forms="replyForms"
        @toggle-reply="toggleReply"
        @reply-submit="handleReplySubmit"
        @start-edit="startEdit"
        @cancel-edit="cancelEdit"
        @save-edit="saveEdit"
        @delete="handleDelete"
        @vote="handleVote"
      />
    </div>
  </div>
</template>

<!-- Comment Item Component (Recursive) -->
<script lang="ts">
import { defineComponent, type PropType } from 'vue'

export default defineComponent({
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
    maxNestingLevel: {
      type: Number,
      default: 3,
    },
    allowReplies: {
      type: Boolean,
      default: true,
    },
    isAuthenticated: {
      type: Boolean,
      default: false,
    },
    activeReplyId: {
      type: [Number, String, null] as PropType<number | string | null>,
      default: null,
    },
    editingCommentId: {
      type: [Number, String, null] as PropType<number | string | null>,
      default: null,
    },
    editingContent: {
      type: String,
      default: '',
    },
    votingCommentId: {
      type: [Number, String, null] as PropType<number | string | null>,
      default: null,
    },
    replyForms: {
      type: Object as PropType<Record<string, any>>,
      default: () => ({}),
    },
  },
  emits: [
    'toggle-reply',
    'reply-submit',
    'start-edit',
    'cancel-edit',
    'save-edit',
    'delete',
    'vote',
  ],
  setup(props, { emit }) {
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

    const canReply = computed(() => {
      return props.allowReplies && props.level < props.maxNestingLevel
    })

    return {
      formatDate,
      canReply,
    }
  },
})
</script>

<template>
  <div
    class="comment-item"
    :class="{
      'ml-8': level > 0,
      'border-l-2 border-gray-200 dark:border-gray-700 pl-4': level > 0,
    }"
  >
    <div class="comment-item__content bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4">
      <!-- Comment Header -->
      <div class="flex items-start justify-between mb-3">
        <div class="flex items-center space-x-3">
          <Avatar :src="comment.author.avatar" :alt="comment.author.name" size="sm" />
          <div>
            <p class="font-semibold text-sm">{{ comment.author.name }}</p>
            <p class="text-xs text-gray-500 dark:text-gray-400">
              {{ formatDate(comment.createdAt) }}
              <span v-if="comment.isEdited" class="italic">(editado)</span>
            </p>
          </div>
        </div>

        <!-- Actions Menu -->
        <div v-if="comment.canEdit || comment.canDelete" class="flex space-x-2">
          <button
            v-if="comment.canEdit && editingCommentId !== comment.id"
            class="text-xs text-gray-600 dark:text-gray-400 hover:text-primary"
            aria-label="Editar comentario"
            @click="$emit('start-edit', comment)"
          >
            <Icon name="edit" class="w-4 h-4" aria-hidden="true" />
          </button>
          <button
            v-if="comment.canDelete"
            class="text-xs text-gray-600 dark:text-gray-400 hover:text-error"
            aria-label="Eliminar comentario"
            @click="$emit('delete', comment.id)"
          >
            <Icon name="trash" class="w-4 h-4" aria-hidden="true" />
          </button>
        </div>
      </div>

      <!-- Comment Body -->
      <div v-if="editingCommentId === comment.id" class="mb-3">
        <textarea
          v-model="editingContent"
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg resize-none focus:outline-none focus:ring-2 focus:ring-primary dark:bg-gray-700 dark:text-white"
          rows="3"
        />
        <div class="flex space-x-2 mt-2">
          <Button size="sm" variant="primary" @click="$emit('save-edit')">
            Guardar
          </Button>
          <Button size="sm" variant="outline" @click="$emit('cancel-edit')">
            Cancelar
          </Button>
        </div>
      </div>
      <div v-else class="mb-3">
        <p class="text-sm text-gray-700 dark:text-gray-300 whitespace-pre-wrap">
          {{ sanitizedContent(comment.content) }}
        </p>
      </div>

      <!-- Comment Footer -->
      <div class="flex items-center space-x-4">
        <!-- Vote Button -->
        <button
          class="flex items-center space-x-1 text-xs hover:text-primary transition-colors"
          :class="{
            'text-primary': comment.hasVoted,
            'text-gray-600 dark:text-gray-400': !comment.hasVoted,
          }"
          :disabled="votingCommentId === comment.id"
          @click="$emit('vote', comment.id)"
        >
          <Icon :name="comment.hasVoted ? 'thumb-up-filled' : 'thumb-up'" class="w-4 h-4" />
          <span>{{ comment.votes }}</span>
        </button>

        <!-- Reply Button -->
        <button
          v-if="canReply"
          class="flex items-center space-x-1 text-xs text-gray-600 dark:text-gray-400 hover:text-primary transition-colors"
          @click="$emit('toggle-reply', comment.id)"
        >
          <Icon name="reply" class="w-4 h-4" />
          <span>Responder</span>
        </button>

        <!-- Reply Count -->
        <span v-if="comment.replyCount > 0" class="text-xs text-gray-500 dark:text-gray-400">
          {{ comment.replyCount }} {{ comment.replyCount === 1 ? 'respuesta' : 'respuestas' }}
        </span>
      </div>
    </div>

    <!-- Reply Form -->
    <div
      v-if="activeReplyId === comment.id && replyForms[comment.id]"
      class="mt-4 ml-8"
    >
      <div class="bg-gray-50 dark:bg-gray-800 rounded-lg border border-gray-300 dark:border-gray-600 p-4">
        <textarea
          v-model="replyForms[comment.id].values.content"
          placeholder="Escribe tu respuesta..."
          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg resize-none focus:outline-none focus:ring-2 focus:ring-primary dark:bg-gray-700 dark:text-white"
          rows="2"
        />
        <div class="flex space-x-2 mt-2">
          <Button size="sm" variant="primary" @click="$emit('reply-submit', comment.id)">
            Responder
          </Button>
          <Button size="sm" variant="outline" @click="$emit('toggle-reply', comment.id)">
            Cancelar
          </Button>
        </div>
      </div>
    </div>

    <!-- Nested Replies -->
    <div v-if="comment.replies && comment.replies.length > 0" class="mt-4 space-y-4">
      <CommentItem
        v-for="reply in comment.replies"
        :key="reply.id"
        :comment="reply"
        :level="level + 1"
        :max-nesting-level="maxNestingLevel"
        :allow-replies="allowReplies"
        :is-authenticated="isAuthenticated"
        :active-reply-id="activeReplyId"
        :editing-comment-id="editingCommentId"
        :editing-content="editingContent"
        :voting-comment-id="votingCommentId"
        :reply-forms="replyForms"
        @toggle-reply="$emit('toggle-reply', $event)"
        @reply-submit="$emit('reply-submit', $event)"
        @start-edit="$emit('start-edit', $event)"
        @cancel-edit="$emit('cancel-edit')"
        @save-edit="$emit('save-edit')"
        @delete="$emit('delete', $event)"
        @vote="$emit('vote', $event)"
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
