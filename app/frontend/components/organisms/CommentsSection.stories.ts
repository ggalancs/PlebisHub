import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import CommentsSection from './CommentsSection.vue'
import type { Comment } from './CommentsSection.vue'

const generateComment = (id: number, overrides: Partial<Comment> = {}): Comment => ({
  id,
  author: {
    id: id,
    name: `Usuario ${id}`,
    avatar: `https://i.pravatar.cc/150?img=${id}`,
  },
  content: `Este es el comentario número ${id}. Lorem ipsum dolor sit amet, consectetur adipiscing elit.`,
  createdAt: new Date(Date.now() - Math.random() * 7 * 24 * 60 * 60 * 1000),
  votes: Math.floor(Math.random() * 20),
  hasVoted: false,
  replyCount: 0,
  isEdited: false,
  canEdit: false,
  canDelete: false,
  ...overrides,
})

const mockComments: Comment[] = [
  generateComment(1, {
    content: 'Esta propuesta es excelente. Definitivamente tiene mi apoyo.',
    votes: 15,
  }),
  generateComment(2, {
    content: '¿Alguien ha considerado el impacto ambiental de esta propuesta?',
    votes: 8,
    replyCount: 2,
    replies: [
      generateComment(3, {
        content: 'Buen punto. Creo que debería incluirse un estudio de impacto ambiental.',
        votes: 5,
      }),
      generateComment(4, {
        content: 'Estoy de acuerdo. La sostenibilidad debería ser prioritaria.',
        votes: 3,
      }),
    ],
  }),
  generateComment(5, {
    content: 'Me parece que los costos estimados están subestimados.',
    votes: 12,
    hasVoted: true,
  }),
]

const meta = {
  title: 'Organisms/CommentsSection',
  component: CommentsSection,
  tags: ['autodocs'],
  argTypes: {
    isAuthenticated: {
      control: 'boolean',
    },
    loading: {
      control: 'boolean',
    },
    submitting: {
      control: 'boolean',
    },
    allowReplies: {
      control: 'boolean',
    },
    sortable: {
      control: 'boolean',
    },
    showCount: {
      control: 'boolean',
    },
    maxNestingLevel: {
      control: 'number',
    },
  },
} satisfies Meta<typeof CommentsSection>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    comments: mockComments,
    itemId: 1,
  },
}

export const Authenticated: Story = {
  args: {
    comments: mockComments,
    itemId: 1,
    isAuthenticated: true,
  },
}

export const Empty: Story = {
  args: {
    comments: [],
    itemId: 1,
    isAuthenticated: true,
  },
}

export const EmptyUnauthenticated: Story = {
  args: {
    comments: [],
    itemId: 1,
    isAuthenticated: false,
  },
}

export const Loading: Story = {
  args: {
    comments: mockComments,
    itemId: 1,
    loading: true,
  },
}

export const WithManyComments: Story = {
  args: {
    comments: Array.from({ length: 10 }, (_, i) => generateComment(i + 1)),
    itemId: 1,
    isAuthenticated: true,
  },
}

export const WithNestedReplies: Story = {
  args: {
    comments: [
      generateComment(1, {
        content: 'Comentario principal con respuestas anidadas',
        replyCount: 2,
        replies: [
          generateComment(2, {
            content: 'Primera respuesta',
            replyCount: 1,
            replies: [
              generateComment(3, {
                content: 'Respuesta a la primera respuesta',
                replyCount: 1,
                replies: [
                  generateComment(4, {
                    content: 'Respuesta de nivel 3',
                  }),
                ],
              }),
            ],
          }),
          generateComment(5, {
            content: 'Segunda respuesta al comentario principal',
          }),
        ],
      }),
    ],
    itemId: 1,
    isAuthenticated: true,
  },
}

export const WithEditableComments: Story = {
  args: {
    comments: [
      generateComment(1, {
        content: 'Este comentario puede ser editado y eliminado',
        canEdit: true,
        canDelete: true,
      }),
      generateComment(2, {
        content: 'Este comentario solo puede ser editado',
        canEdit: true,
        canDelete: false,
      }),
      generateComment(3, {
        content: 'Este comentario no puede ser modificado',
        canEdit: false,
        canDelete: false,
      }),
    ],
    itemId: 1,
    isAuthenticated: true,
  },
}

export const WithEditedComments: Story = {
  args: {
    comments: [
      generateComment(1, {
        content: 'Este comentario ha sido editado',
        isEdited: true,
      }),
      generateComment(2, {
        content: 'Este comentario no ha sido editado',
        isEdited: false,
      }),
    ],
    itemId: 1,
    isAuthenticated: true,
  },
}

export const WithVotedComments: Story = {
  args: {
    comments: [
      generateComment(1, {
        content: 'Ya has votado por este comentario',
        votes: 15,
        hasVoted: true,
      }),
      generateComment(2, {
        content: 'No has votado por este comentario',
        votes: 8,
        hasVoted: false,
      }),
    ],
    itemId: 1,
    isAuthenticated: true,
  },
}

export const WithHighVotes: Story = {
  args: {
    comments: [
      generateComment(1, {
        content: 'Comentario muy popular',
        votes: 156,
      }),
      generateComment(2, {
        content: 'Otro comentario popular',
        votes: 89,
      }),
      generateComment(3, {
        content: 'Comentario con pocos votos',
        votes: 3,
      }),
    ],
    itemId: 1,
    isAuthenticated: true,
  },
}

export const NoRepliesAllowed: Story = {
  args: {
    comments: mockComments,
    itemId: 1,
    isAuthenticated: true,
    allowReplies: false,
  },
}

export const MaxNestingLevel2: Story = {
  args: {
    comments: [
      generateComment(1, {
        content: 'Nivel 0',
        replyCount: 1,
        replies: [
          generateComment(2, {
            content: 'Nivel 1 - Puedo responder',
            replyCount: 1,
            replies: [
              generateComment(3, {
                content: 'Nivel 2 - Ya no puedo responder (max nivel alcanzado)',
              }),
            ],
          }),
        ],
      }),
    ],
    itemId: 1,
    isAuthenticated: true,
    maxNestingLevel: 2,
  },
}

export const NoSorting: Story = {
  args: {
    comments: mockComments,
    itemId: 1,
    isAuthenticated: true,
    sortable: false,
  },
}

export const NoCommentCount: Story = {
  args: {
    comments: mockComments,
    itemId: 1,
    isAuthenticated: true,
    showCount: false,
  },
}

export const CustomValidation: Story = {
  args: {
    comments: [],
    itemId: 1,
    isAuthenticated: true,
    minLength: 20,
    maxLength: 200,
    placeholder: 'Escribe un comentario de al menos 20 caracteres...',
  },
}

export const Interactive: Story = {
  render: (args) => ({
    components: { CommentsSection },
    setup() {
      const comments = ref<Comment[]>([
        generateComment(1, {
          content: 'Este es el primer comentario',
          votes: 5,
          canEdit: true,
          canDelete: true,
        }),
        generateComment(2, {
          content: 'Este es el segundo comentario',
          votes: 3,
          replyCount: 0,
          replies: [],
        }),
      ])
      const submitting = ref(false)
      let nextId = 3

      const handleSubmit = async (data: { content: string; parentId?: number | string }) => {
        console.log('Submitting comment:', data)
        submitting.value = true

        await new Promise((resolve) => setTimeout(resolve, 1000))

        const newComment = generateComment(nextId++, {
          content: data.content,
          createdAt: new Date(),
          canEdit: true,
          canDelete: true,
        })

        if (data.parentId) {
          // Add as reply
          const addReply = (commentsList: Comment[]): boolean => {
            for (const comment of commentsList) {
              if (comment.id === data.parentId) {
                if (!comment.replies) comment.replies = []
                comment.replies.push(newComment)
                comment.replyCount++
                return true
              }
              if (comment.replies && addReply(comment.replies)) {
                return true
              }
            }
            return false
          }
          addReply(comments.value)
        } else {
          // Add as top-level comment
          comments.value.unshift(newComment)
        }

        submitting.value = false
      }

      const handleEdit = (commentId: number | string, content: string) => {
        console.log('Editing comment:', commentId, content)
        const editComment = (commentsList: Comment[]): boolean => {
          for (const comment of commentsList) {
            if (comment.id === commentId) {
              comment.content = content
              comment.isEdited = true
              return true
            }
            if (comment.replies && editComment(comment.replies)) {
              return true
            }
          }
          return false
        }
        editComment(comments.value)
      }

      const handleDelete = (commentId: number | string) => {
        console.log('Deleting comment:', commentId)
        const deleteComment = (commentsList: Comment[], parentList?: Comment[]): boolean => {
          for (let i = 0; i < commentsList.length; i++) {
            if (commentsList[i].id === commentId) {
              commentsList.splice(i, 1)
              return true
            }
            if (commentsList[i].replies && deleteComment(commentsList[i].replies!, commentsList)) {
              if (commentsList[i].replies!.length === 0) {
                commentsList[i].replyCount = 0
              }
              return true
            }
          }
          return false
        }
        deleteComment(comments.value)
      }

      const handleVote = (commentId: number | string) => {
        console.log('Voting on comment:', commentId)
        const voteComment = (commentsList: Comment[]): boolean => {
          for (const comment of commentsList) {
            if (comment.id === commentId) {
              if (!comment.hasVoted) {
                comment.votes++
                comment.hasVoted = true
              }
              return true
            }
            if (comment.replies && voteComment(comment.replies)) {
              return true
            }
          }
          return false
        }
        voteComment(comments.value)
      }

      const handleSort = (sortBy: string) => {
        console.log('Sorting by:', sortBy)
      }

      const handleLoginRequired = () => {
        alert('Necesitas iniciar sesión para realizar esta acción')
      }

      return {
        comments,
        submitting,
        handleSubmit,
        handleEdit,
        handleDelete,
        handleVote,
        handleSort,
        handleLoginRequired,
      }
    },
    template: `
      <div class="p-6 max-w-4xl mx-auto">
        <h2 class="text-2xl font-bold mb-4">Sección de Comentarios Interactiva</h2>
        <p class="text-sm text-gray-600 mb-6">
          Prueba todas las funcionalidades: comentar, responder, editar, eliminar y votar.
        </p>
        <CommentsSection
          :comments="comments"
          :item-id="1"
          :is-authenticated="true"
          :submitting="submitting"
          @submit="handleSubmit"
          @edit="handleEdit"
          @delete="handleDelete"
          @vote="handleVote"
          @sort="handleSort"
          @login-required="handleLoginRequired"
        />
      </div>
    `,
  }),
  args: {},
}

export const InteractiveUnauthenticated: Story = {
  render: (args) => ({
    components: { CommentsSection },
    setup() {
      const comments = ref<Comment[]>([
        generateComment(1, {
          content: 'Comentario visible sin autenticación',
          votes: 5,
        }),
        generateComment(2, {
          content: 'Otro comentario que puedes ver',
          votes: 3,
        }),
      ])

      const handleLoginRequired = () => {
        alert('Debes iniciar sesión para comentar, responder o votar')
      }

      return {
        comments,
        handleLoginRequired,
      }
    },
    template: `
      <div class="p-6 max-w-4xl mx-auto">
        <h2 class="text-2xl font-bold mb-4">Usuario No Autenticado</h2>
        <p class="text-sm text-gray-600 mb-6">
          Puedes ver los comentarios, pero necesitas iniciar sesión para participar.
        </p>
        <CommentsSection
          :comments="comments"
          :item-id="1"
          :is-authenticated="false"
          @login-required="handleLoginRequired"
        />
      </div>
    `,
  }),
  args: {},
}

export const RealWorldExample: Story = {
  render: (args) => ({
    components: { CommentsSection },
    setup() {
      const comments = ref<Comment[]>([
        generateComment(1, {
          author: { id: 1, name: 'María González', avatar: 'https://i.pravatar.cc/150?img=5' },
          content:
            'Me parece una propuesta muy interesante. Sin embargo, me gustaría saber más sobre los plazos de implementación y el presupuesto estimado.',
          votes: 23,
          createdAt: new Date(Date.now() - 2 * 60 * 60 * 1000), // 2 hours ago
          replyCount: 2,
          replies: [
            generateComment(2, {
              author: { id: 2, name: 'Juan Ramírez', avatar: 'https://i.pravatar.cc/150?img=12' },
              content:
                'Excelente pregunta, María. Según el documento, el plazo es de 18 meses y el presupuesto es de 2.5 millones.',
              votes: 15,
              createdAt: new Date(Date.now() - 1.5 * 60 * 60 * 1000),
              canEdit: true,
              canDelete: true,
            }),
            generateComment(3, {
              author: { id: 1, name: 'María González', avatar: 'https://i.pravatar.cc/150?img=5' },
              content: '¡Gracias por la información, Juan! Eso clarifica mis dudas.',
              votes: 8,
              createdAt: new Date(Date.now() - 1 * 60 * 60 * 1000),
            }),
          ],
        }),
        generateComment(4, {
          author: { id: 3, name: 'Carlos Pérez', avatar: 'https://i.pravatar.cc/150?img=33' },
          content:
            '¿Se ha considerado el impacto en el tráfico durante la fase de construcción? Vivo en la zona y me preocupa este aspecto.',
          votes: 18,
          createdAt: new Date(Date.now() - 5 * 60 * 60 * 1000), // 5 hours ago
          hasVoted: true,
        }),
        generateComment(5, {
          author: { id: 4, name: 'Ana Martínez', avatar: 'https://i.pravatar.cc/150?img=26' },
          content:
            'Apoyo totalmente esta iniciativa. Es exactamente lo que nuestra comunidad necesita. +1',
          votes: 31,
          createdAt: new Date(Date.now() - 24 * 60 * 60 * 1000), // 1 day ago
          isEdited: true,
        }),
      ])

      return { comments }
    },
    template: `
      <div class="p-6 max-w-4xl mx-auto bg-gray-50 min-h-screen">
        <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
          <h1 class="text-3xl font-bold mb-2">Propuesta de Mejora del Transporte Público</h1>
          <p class="text-gray-600 mb-4">
            Implementación de carriles exclusivos para autobuses y modernización de la flota.
          </p>
          <div class="flex items-center space-x-4 text-sm text-gray-500">
            <span>👍 567 apoyos</span>
            <span>🔥 12,345 puntos</span>
            <span>📅 Finaliza en 45 días</span>
          </div>
        </div>

        <div class="bg-white rounded-lg shadow-sm p-6">
          <CommentsSection
            :comments="comments"
            :item-id="1"
            :is-authenticated="true"
          />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const MobileView: Story = {
  render: (args) => ({
    components: { CommentsSection },
    setup() {
      return { comments: mockComments }
    },
    template: `
      <div class="max-w-md mx-auto p-4">
        <CommentsSection
          :comments="comments"
          :item-id="1"
          :is-authenticated="true"
        />
      </div>
    `,
  }),
  args: {},
}

export const LongComments: Story = {
  args: {
    comments: [
      generateComment(1, {
        content: `Esta es una propuesta muy interesante que merece un análisis detallado.

En primer lugar, me gustaría destacar los aspectos positivos: la iniciativa aborda un problema real que afecta a nuestra comunidad, tiene un enfoque sostenible y parece contar con el respaldo de expertos en la materia.

Sin embargo, también tengo algunas preocupaciones:

1. El presupuesto propuesto parece optimista. ¿Se han considerado todos los costos indirectos?
2. Los plazos de implementación son ambiciosos. ¿Hay un plan de contingencia?
3. Faltan detalles sobre cómo se medirá el éxito de la propuesta.

En conclusión, apoyo la idea en general, pero me gustaría ver una versión revisada que aborde estos puntos.`,
        votes: 42,
      }),
    ],
    itemId: 1,
    isAuthenticated: true,
  },
}

export const DifferentTimestamps: Story = {
  args: {
    comments: [
      generateComment(1, {
        content: 'Hace un momento',
        createdAt: new Date(Date.now() - 30000), // 30 seconds ago
      }),
      generateComment(2, {
        content: 'Hace 5 minutos',
        createdAt: new Date(Date.now() - 5 * 60 * 1000),
      }),
      generateComment(3, {
        content: 'Hace 2 horas',
        createdAt: new Date(Date.now() - 2 * 60 * 60 * 1000),
      }),
      generateComment(4, {
        content: 'Hace 3 días',
        createdAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
      }),
      generateComment(5, {
        content: 'Hace 10 días (fecha completa)',
        createdAt: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000),
      }),
    ],
    itemId: 1,
    isAuthenticated: true,
  },
}
