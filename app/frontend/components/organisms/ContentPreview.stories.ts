import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import ContentPreview from './ContentPreview.vue'

const sampleMarkdown = `# Mi Artículo de Blog

## Introducción

Este es un artículo de **ejemplo** que muestra cómo se vería el contenido _renderizado_.

## Características Principales

- Soporte para **Markdown**
- Vista previa en tiempo real
- Múltiples dispositivos

### Código de Ejemplo

\`\`\`javascript
const greeting = "Hola Mundo";
console.log(greeting);
\`\`\`

Código inline: \`const x = 42;\`

## Enlaces e Imágenes

Visita [nuestro sitio web](https://example.com) para más información.

![Imagen de ejemplo](https://via.placeholder.com/600x300)

## Citas

> "El código limpio siempre parece como si fue escrito por alguien a quien le importa." - Robert C. Martin

## Lista Numerada

1. Primer elemento
2. Segundo elemento
3. Tercer elemento

---

Gracias por leer!
`

const articleContent = `# El Futuro del Desarrollo Web

## Una Mirada a las Tecnologías Emergentes

El desarrollo web está evolucionando rápidamente. En este artículo, exploramos las **tecnologías más prometedoras** para los próximos años.

### 1. Web Components

Los Web Components permiten crear _componentes reutilizables_ sin frameworks.

\`\`\`html
<custom-button label="Click me"></custom-button>
\`\`\`

### 2. Edge Computing

El procesamiento en el borde reduce la latencia y mejora el rendimiento.

> "Edge computing acerca los datos a donde se necesitan"

### 3. WebAssembly

Permite ejecutar código de alto rendimiento en el navegador:

- C++
- Rust
- Go

Más información en [WebAssembly.org](https://webassembly.org)

![WebAssembly Logo](https://via.placeholder.com/400x200?text=WebAssembly)

---

**Conclusión**: El futuro es brillante para los desarrolladores web.
`

const meta = {
  title: 'Organisms/ContentPreview',
  component: ContentPreview,
  tags: ['autodocs'],
  argTypes: {
    contentType: {
      control: 'select',
      options: ['markdown', 'html', 'text'],
    },
    viewMode: {
      control: 'select',
      options: ['desktop', 'tablet', 'mobile'],
    },
    showFrame: {
      control: 'boolean',
    },
    showSelector: {
      control: 'boolean',
    },
    loading: {
      control: 'boolean',
    },
  },
} satisfies Meta<typeof ContentPreview>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    content: sampleMarkdown,
  },
}

export const DesktopView: Story = {
  args: {
    content: sampleMarkdown,
    viewMode: 'desktop',
  },
}

export const TabletView: Story = {
  args: {
    content: sampleMarkdown,
    viewMode: 'tablet',
  },
}

export const MobileView: Story = {
  args: {
    content: sampleMarkdown,
    viewMode: 'mobile',
  },
}

export const NoFrame: Story = {
  args: {
    content: sampleMarkdown,
    showFrame: false,
  },
}

export const NoSelector: Story = {
  args: {
    content: sampleMarkdown,
    showSelector: false,
  },
}

export const HTMLContent: Story = {
  args: {
    content: '<h1>HTML Content</h1><p>This is <strong>HTML</strong> content.</p>',
    contentType: 'html',
  },
}

export const PlainText: Story = {
  args: {
    content: 'This is plain text content.\n\nIt preserves line breaks\nbut does not render HTML or Markdown.',
    contentType: 'text',
  },
}

export const Empty: Story = {
  args: {
    content: '',
  },
}

export const Loading: Story = {
  args: {
    content: sampleMarkdown,
    loading: true,
  },
}

export const LongArticle: Story = {
  args: {
    content: articleContent,
  },
}

export const Interactive: Story = {
  render: (args) => ({
    components: { ContentPreview },
    setup() {
      const content = ref(sampleMarkdown)
      const viewMode = ref<'desktop' | 'tablet' | 'mobile'>('desktop')

      const handleViewModeChange = (mode: 'desktop' | 'tablet' | 'mobile') => {
        viewMode.value = mode
        console.log('View mode changed to:', mode)
      }

      return {
        content,
        viewMode,
        handleViewModeChange,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Vista Previa Interactiva</h2>
        <p class="text-sm text-gray-600 mb-6">
          Cambia entre los diferentes modos de vista para ver cómo se adapta el contenido.
        </p>
        <ContentPreview
          :content="content"
          :view-mode="viewMode"
          @view-mode-change="handleViewModeChange"
        />
        <div class="mt-4 p-3 bg-gray-50 rounded text-sm">
          Modo actual: <strong>{{ viewMode }}</strong>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const WithEditor: Story = {
  render: (args) => ({
    components: { ContentPreview },
    setup() {
      const content = ref('# Mi Documento\n\nEscribe algo aquí...')

      return { content }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Editor con Vista Previa</h2>
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- Editor -->
          <div>
            <label class="block text-sm font-medium mb-2">Editor</label>
            <textarea
              v-model="content"
              class="w-full h-96 p-4 border border-gray-300 rounded-lg font-mono text-sm resize-none focus:outline-none focus:ring-2 focus:ring-primary"
              placeholder="Escribe markdown aquí..."
            />
          </div>

          <!-- Preview -->
          <div>
            <label class="block text-sm font-medium mb-2">Vista Previa</label>
            <ContentPreview
              :content="content"
              :show-selector="true"
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const BlogPostPreview: Story = {
  render: (args) => ({
    components: { ContentPreview },
    setup() {
      const post = ref({
        title: 'Las 10 Mejores Prácticas de Vue 3',
        author: 'Juan Desarrollador',
        date: '15 de Noviembre, 2025',
        content: articleContent,
      })

      return { post }
    },
    template: `
      <div class="p-6 max-w-6xl mx-auto">
        <div class="mb-6">
          <h1 class="text-3xl font-bold mb-2">{{ post.title }}</h1>
          <p class="text-sm text-gray-600">
            Por {{ post.author }} • {{ post.date }}
          </p>
        </div>
        <ContentPreview
          :content="post.content"
          title="Vista Previa del Artículo"
        />
      </div>
    `,
  }),
  args: {},
}

export const DocumentationPreview: Story = {
  args: {
    content: `# API Documentation

## Authentication

All API requests require authentication via API key.

### Headers

\`\`\`
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json
\`\`\`

## Endpoints

### GET /api/users

Returns a list of users.

**Query Parameters:**
- \`page\` (integer): Page number
- \`limit\` (integer): Items per page

**Response:**

\`\`\`json
{
  "users": [],
  "total": 100
}
\`\`\`

### POST /api/users

Creates a new user.

> **Note:** Email must be unique.

**Request Body:**

\`\`\`json
{
  "name": "John Doe",
  "email": "john@example.com"
}
\`\`\`

---

For more information, visit our [documentation portal](https://docs.example.com).
`,
    title: 'API Documentation Preview',
  },
}

export const AllDeviceSizes: Story = {
  render: (args) => ({
    components: { ContentPreview },
    setup() {
      const content = ref('# Responsive Preview\n\nThis content adapts to different screen sizes.')

      return { content }
    },
    template: `
      <div class="p-6 space-y-6">
        <div>
          <h3 class="text-lg font-semibold mb-3">Desktop (1920px)</h3>
          <ContentPreview
            :content="content"
            view-mode="desktop"
            :show-selector="false"
          />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-3">Tablet (768px)</h3>
          <ContentPreview
            :content="content"
            view-mode="tablet"
            :show-selector="false"
          />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-3">Mobile (375px)</h3>
          <ContentPreview
            :content="content"
            view-mode="mobile"
            :show-selector="false"
          />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const CodeHeavy: Story = {
  args: {
    content: `# Code Examples

## JavaScript

\`\`\`javascript
function fibonacci(n) {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

console.log(fibonacci(10));
\`\`\`

## Python

\`\`\`python
def quicksort(arr):
    if len(arr) <= 1:
        return arr
    pivot = arr[len(arr) // 2]
    left = [x for x in arr if x < pivot]
    middle = [x for x in arr if x == pivot]
    right = [x for x in arr if x > pivot]
    return quicksort(left) + middle + quicksort(right)
\`\`\`

## CSS

\`\`\`css
.container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1rem;
}
\`\`\`
`,
    title: 'Code Examples Preview',
  },
}
