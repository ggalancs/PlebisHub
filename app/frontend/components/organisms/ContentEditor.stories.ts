import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import ContentEditor from './ContentEditor.vue'

const sampleMarkdown = `# Sample Content

This is a **bold** statement and this is _italic_.

## Features

- Easy to use
- Markdown support
- Live preview

### Code Example

\`const greeting = "Hello World";\`

> This is a quote from someone famous.

[Visit our website](https://example.com)

![Sample Image](https://via.placeholder.com/400x200)
`

const meta = {
  title: 'Organisms/ContentEditor',
  component: ContentEditor,
  tags: ['autodocs'],
  argTypes: {
    mode: {
      control: 'select',
      options: ['rich', 'markdown'],
    },
    view: {
      control: 'select',
      options: ['edit', 'preview', 'split'],
    },
    autosave: {
      control: 'boolean',
    },
    showCount: {
      control: 'boolean',
    },
    showToolbar: {
      control: 'boolean',
    },
    disabled: {
      control: 'boolean',
    },
    readonly: {
      control: 'boolean',
    },
  },
} satisfies Meta<typeof ContentEditor>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    modelValue: '',
    placeholder: 'Escribe tu contenido aquí...',
  },
}

export const WithContent: Story = {
  args: {
    modelValue: 'Este es un contenido de ejemplo que ya existe en el editor.',
  },
}

export const MarkdownMode: Story = {
  args: {
    modelValue: sampleMarkdown,
    mode: 'markdown',
  },
}

export const PreviewView: Story = {
  args: {
    modelValue: sampleMarkdown,
    mode: 'markdown',
    view: 'preview',
  },
}

export const SplitView: Story = {
  args: {
    modelValue: sampleMarkdown,
    mode: 'markdown',
    view: 'split',
  },
}

export const WithAutosave: Story = {
  args: {
    modelValue: 'Contenido con guardado automático',
    autosave: true,
    autosaveDelay: 2000,
  },
}

export const NoToolbar: Story = {
  args: {
    modelValue: 'Editor sin barra de herramientas',
    showToolbar: false,
  },
}

export const NoCount: Story = {
  args: {
    modelValue: 'Editor sin contador de palabras',
    showCount: false,
  },
}

export const Disabled: Story = {
  args: {
    modelValue: 'Este editor está deshabilitado',
    disabled: true,
  },
}

export const Readonly: Story = {
  args: {
    modelValue: 'Este editor es de solo lectura',
    readonly: true,
  },
}

export const CustomHeight: Story = {
  args: {
    modelValue: 'Editor con altura personalizada',
    height: '600px',
  },
}

export const WithLengthLimits: Story = {
  args: {
    modelValue: 'Contenido con límites',
    minLength: 10,
    maxLength: 200,
  },
}

export const NearMaxLength: Story = {
  args: {
    modelValue: 'a'.repeat(180),
    maxLength: 200,
    showCount: true,
  },
}

export const Interactive: Story = {
  render: (args) => ({
    components: { ContentEditor },
    setup() {
      const content = ref('# Mi Artículo\n\nEscribe algo aquí...')
      const lastSaved = ref<string | null>(null)

      const handleAutosave = (value: string) => {
        lastSaved.value = new Date().toLocaleTimeString()
        console.log('Autosaved:', value)
      }

      const handleInsertMedia = () => {
        alert('Abrir selector de medios')
      }

      return {
        content,
        lastSaved,
        handleAutosave,
        handleInsertMedia,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Editor Interactivo</h2>
        <p class="text-sm text-gray-600 mb-4">
          Edita el contenido y prueba las diferentes vistas y herramientas.
        </p>
        <ContentEditor
          v-model="content"
          mode="markdown"
          :autosave="true"
          :autosave-delay="3000"
          @autosave="handleAutosave"
          @insert-media="handleInsertMedia"
        />
        <div v-if="lastSaved" class="mt-4 p-3 bg-green-50 border border-green-200 rounded text-sm text-green-700">
          Último guardado: {{ lastSaved }}
        </div>
        <div class="mt-4 p-4 bg-gray-50 rounded">
          <h3 class="font-semibold mb-2">Contenido actual:</h3>
          <pre class="text-xs">{{ content }}</pre>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const BlogPost: Story = {
  render: (args) => ({
    components: { ContentEditor },
    setup() {
      const content = ref(`# Mi Primera Publicación en el Blog

## Introducción

Bienvenidos a mi blog. En esta publicación, compartiré mis pensamientos sobre el desarrollo web moderno.

## Desarrollo Web Moderno

El desarrollo web ha evolucionado significativamente en los últimos años. Algunas tecnologías clave incluyen:

- **Vue 3**: Framework reactivo y moderno
- **TypeScript**: Type-safety para JavaScript
- **Tailwind CSS**: Utility-first CSS framework

### Ejemplo de Código

\`\`\`javascript
const app = createApp({
  setup() {
    const count = ref(0)
    return { count }
  }
})
\`\`\`

## Conclusión

Estas tecnologías hacen que el desarrollo web sea más eficiente y mantenible.

> "El código limpio siempre parece como si fue escrito por alguien a quien le importa." - Robert C. Martin
`)

      return { content }
    },
    template: `
      <div class="p-6 max-w-5xl mx-auto">
        <h2 class="text-2xl font-bold mb-6">Crear Publicación de Blog</h2>
        <ContentEditor
          v-model="content"
          mode="markdown"
          view="split"
          :height="'500px'"
          :max-length="5000"
        />
      </div>
    `,
  }),
  args: {},
}

export const Documentation: Story = {
  render: (args) => ({
    components: { ContentEditor },
    setup() {
      const content = ref(`# Documentación de la API

## Autenticación

Para autenticarte, incluye tu API key en el header:

\`Authorization: Bearer YOUR_API_KEY\`

## Endpoints

### GET /api/users

Obtiene la lista de usuarios.

**Parámetros:**
- \`page\` (opcional): Número de página
- \`limit\` (opcional): Resultados por página

**Respuesta:**

\`\`\`json
{
  "users": [...],
  "total": 100,
  "page": 1
}
\`\`\`

### POST /api/users

Crea un nuevo usuario.

**Body:**

\`\`\`json
{
  "name": "John Doe",
  "email": "john@example.com"
}
\`\`\`

## Códigos de Error

| Código | Descripción |
|--------|-------------|
| 400 | Bad Request |
| 401 | Unauthorized |
| 404 | Not Found |
| 500 | Server Error |
`)

      return { content }
    },
    template: `
      <div class="p-6 max-w-6xl mx-auto">
        <h2 class="text-2xl font-bold mb-6">Editor de Documentación</h2>
        <ContentEditor
          v-model="content"
          mode="markdown"
          view="split"
          :height="'600px'"
          :show-count="true"
        />
      </div>
    `,
  }),
  args: {},
}

export const MinimalEditor: Story = {
  args: {
    modelValue: '',
    showToolbar: false,
    showCount: false,
    height: '200px',
    placeholder: 'Escribe una nota rápida...',
  },
}

export const ArticleEditor: Story = {
  render: (args) => ({
    components: { ContentEditor },
    setup() {
      const title = ref('Título del Artículo')
      const content = ref('Comienza a escribir tu artículo aquí...')
      const tags = ref('vue, typescript, tutorial')

      const handlePublish = () => {
        alert(`Publicando artículo:\nTítulo: ${title.value}\nEtiquetas: ${tags.value}`)
      }

      return {
        title,
        content,
        tags,
        handlePublish,
      }
    },
    template: `
      <div class="p-6 max-w-4xl mx-auto">
        <h2 class="text-2xl font-bold mb-6">Crear Nuevo Artículo</h2>

        <div class="space-y-4 mb-6">
          <div>
            <label class="block text-sm font-medium mb-2">Título</label>
            <input
              v-model="title"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg"
              placeholder="Título del artículo"
            />
          </div>

          <div>
            <label class="block text-sm font-medium mb-2">Contenido</label>
            <ContentEditor
              v-model="content"
              mode="markdown"
              :height="'400px'"
              :max-length="10000"
            />
          </div>

          <div>
            <label class="block text-sm font-medium mb-2">Etiquetas</label>
            <input
              v-model="tags"
              type="text"
              class="w-full px-4 py-2 border border-gray-300 rounded-lg"
              placeholder="Separadas por comas"
            />
          </div>
        </div>

        <div class="flex gap-3">
          <button
            class="px-6 py-2 bg-primary text-white rounded-lg hover:bg-primary-dark"
            @click="handlePublish"
          >
            Publicar
          </button>
          <button class="px-6 py-2 border border-gray-300 rounded-lg hover:bg-gray-50">
            Guardar Borrador
          </button>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const CommentEditor: Story = {
  render: (args) => ({
    components: { ContentEditor },
    setup() {
      const comment = ref('')

      const handleSubmit = () => {
        alert(`Comentario enviado:\n${comment.value}`)
        comment.value = ''
      }

      return {
        comment,
        handleSubmit,
      }
    },
    template: `
      <div class="p-6 max-w-2xl">
        <h3 class="font-semibold mb-3">Añadir Comentario</h3>
        <ContentEditor
          v-model="comment"
          :height="'150px'"
          :max-length="500"
          :show-toolbar="false"
          placeholder="Escribe tu comentario..."
        />
        <div class="mt-3">
          <button
            class="px-4 py-2 bg-primary text-white rounded hover:bg-primary-dark text-sm"
            :disabled="comment.length === 0"
            @click="handleSubmit"
          >
            Enviar Comentario
          </button>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const WithValidation: Story = {
  render: (args) => ({
    components: { ContentEditor },
    setup() {
      const content = ref('Short')
      const isValid = ref(false)

      const checkValidity = (value: string) => {
        isValid.value = value.length >= 50 && value.length <= 500
      }

      return {
        content,
        isValid,
        checkValidity,
      }
    },
    template: `
      <div class="p-6 max-w-3xl">
        <h2 class="text-2xl font-bold mb-4">Editor con Validación</h2>
        <p class="text-sm text-gray-600 mb-4">
          El contenido debe tener entre 50 y 500 caracteres.
        </p>
        <ContentEditor
          v-model="content"
          :min-length="50"
          :max-length="500"
          @change="checkValidity"
        />
        <div class="mt-4 p-3 rounded" :class="isValid ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700'">
          {{ isValid ? '✓ Contenido válido' : '✗ Contenido inválido' }}
        </div>
      </div>
    `,
  }),
  args: {},
}
