<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import DOMPurify from 'dompurify'
import Icon from '@/components/atoms/Icon.vue'
import { useDebounce } from '@/composables'

export type EditorMode = 'rich' | 'markdown'
export type EditorView = 'edit' | 'preview' | 'split'

interface Props {
  /** Initial content */
  modelValue: string
  /** Editor mode */
  mode?: EditorMode
  /** Current view mode */
  view?: EditorView
  /** Placeholder text */
  placeholder?: string
  /** Maximum content length */
  maxLength?: number
  /** Minimum content length */
  minLength?: number
  /** Enable auto-save */
  autosave?: boolean
  /** Auto-save delay in ms */
  autosaveDelay?: number
  /** Show word/character count */
  showCount?: boolean
  /** Show toolbar */
  showToolbar?: boolean
  /** Disabled state */
  disabled?: boolean
  /** Read-only mode */
  readonly?: boolean
  /** Height */
  height?: string
}

interface Emits {
  (e: 'update:modelValue', value: string): void
  (e: 'autosave', value: string): void
  (e: 'change', value: string): void
  (e: 'insert-media'): void
}

const props = withDefaults(defineProps<Props>(), {
  mode: 'rich',
  view: 'edit',
  placeholder: 'Escribe tu contenido aquí...',
  maxLength: 10000,
  minLength: 0,
  autosave: false,
  autosaveDelay: 3000,
  showCount: true,
  showToolbar: true,
  disabled: false,
  readonly: false,
  height: '400px',
})

const emit = defineEmits<Emits>()

// Local content state
const content = ref(props.modelValue)
const currentView = ref(props.view)
const editorElement = ref<HTMLTextAreaElement>()

// Debounced content for autosave
const debouncedContent = useDebounce(content, props.autosaveDelay)

// Character and word counts
const characterCount = computed(() => content.value.length)
const wordCount = computed(() => {
  const text = content.value.trim()
  if (text.length === 0) return 0
  return text.split(/\s+/).length
})

// Character count color
const characterCountColor = computed(() => {
  const remaining = props.maxLength - characterCount.value
  if (remaining < 100) return 'text-error'
  if (remaining < 500) return 'text-warning'
  return 'text-gray-500 dark:text-gray-400'
})

// Validation
const isValid = computed(() => {
  return (
    characterCount.value >= props.minLength &&
    characterCount.value <= props.maxLength
  )
})

// Watch for external changes
watch(
  () => props.modelValue,
  (newValue) => {
    if (newValue !== content.value) {
      content.value = newValue
    }
  }
)

// Watch for content changes
watch(content, (newValue) => {
  emit('update:modelValue', newValue)
  emit('change', newValue)
})

// Watch debounced content for autosave
watch(debouncedContent, (newValue) => {
  if (props.autosave && newValue !== props.modelValue) {
    emit('autosave', newValue)
  }
})

// Toolbar actions
const toolbarActions = [
  { id: 'bold', icon: 'bold', label: 'Negrita', markdown: '**texto**' },
  { id: 'italic', icon: 'italic', label: 'Cursiva', markdown: '_texto_' },
  { id: 'heading', icon: 'heading', label: 'Encabezado', markdown: '# ' },
  { id: 'link', icon: 'link', label: 'Enlace', markdown: '[texto](url)' },
  { id: 'image', icon: 'image', label: 'Imagen', markdown: '![alt](url)' },
  { id: 'list', icon: 'list', label: 'Lista', markdown: '- ' },
  { id: 'code', icon: 'code', label: 'Código', markdown: '`código`' },
  { id: 'quote', icon: 'quote', label: 'Cita', markdown: '> ' },
]

// Insert markdown syntax
const insertMarkdown = (syntax: string) => {
  if (!editorElement.value || props.readonly || props.disabled) return

  const textarea = editorElement.value
  const start = textarea.selectionStart
  const end = textarea.selectionEnd
  const selectedText = content.value.substring(start, end)

  // Handle different markdown patterns
  let newText = ''
  let cursorPos = start

  if (syntax.includes('texto')) {
    // Replace 'texto' with selected text or placeholder
    newText = syntax.replace('texto', selectedText || 'texto')
    cursorPos = start + newText.indexOf(selectedText || 'texto')
  } else if (syntax.startsWith('# ') || syntax.startsWith('- ') || syntax.startsWith('> ')) {
    // Line prefix
    newText = syntax + selectedText
    cursorPos = start + syntax.length
  } else if (syntax === '`código`' && selectedText) {
    // Code wrap
    newText = `\`${selectedText}\``
    cursorPos = end + 2
  } else {
    newText = syntax
    cursorPos = start + syntax.length
  }

  content.value = content.value.substring(0, start) + newText + content.value.substring(end)

  // Restore focus and cursor position
  textarea.focus()
  setTimeout(() => {
    textarea.setSelectionRange(cursorPos, cursorPos)
  }, 0)
}

// Render markdown to HTML (basic implementation)
const renderMarkdown = (text: string): string => {
  let html = text

  // Headers
  html = html.replace(/^### (.*$)/gim, '<h3 class="text-lg font-bold mt-4 mb-2">$1</h3>')
  html = html.replace(/^## (.*$)/gim, '<h2 class="text-xl font-bold mt-4 mb-2">$1</h2>')
  html = html.replace(/^# (.*$)/gim, '<h1 class="text-2xl font-bold mt-4 mb-2">$1</h1>')

  // Bold
  html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')

  // Italic
  html = html.replace(/_(.+?)_/g, '<em>$1</em>')

  // Links
  html = html.replace(/\[(.+?)\]\((.+?)\)/g, '<a href="$2" class="text-primary hover:underline">$1</a>')

  // Images
  html = html.replace(/!\[(.+?)\]\((.+?)\)/g, '<img src="$2" alt="$1" class="max-w-full h-auto rounded my-2" />')

  // Code inline
  html = html.replace(/`(.+?)`/g, '<code class="bg-gray-100 dark:bg-gray-800 px-1 rounded">$1</code>')

  // Lists
  html = html.replace(/^\- (.+)$/gim, '<li class="ml-4">$1</li>')

  // Quotes
  html = html.replace(/^> (.+)$/gim, '<blockquote class="border-l-4 border-gray-300 pl-4 italic my-2">$1</blockquote>')

  // Line breaks
  html = html.replace(/\n/g, '<br />')

  return html
}

// Preview HTML with sanitization
const previewHtml = computed(() => {
  let rawHtml = ''

  if (props.mode === 'markdown') {
    rawHtml = renderMarkdown(content.value)
  } else {
    rawHtml = content.value
  }

  // Sanitize HTML to prevent XSS attacks
  return DOMPurify.sanitize(rawHtml, {
    ALLOWED_TAGS: [
      'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
      'p', 'br', 'strong', 'em', 'u', 's',
      'a', 'img',
      'ul', 'ol', 'li',
      'blockquote', 'code', 'pre',
      'table', 'thead', 'tbody', 'tr', 'th', 'td',
      'div', 'span'
    ],
    ALLOWED_ATTR: ['href', 'src', 'alt', 'class', 'target', 'rel'],
    ALLOW_DATA_ATTR: false,
  })
})

// View tabs
const viewTabs = [
  { id: 'edit', label: 'Editar', icon: 'edit' },
  { id: 'preview', label: 'Vista Previa', icon: 'eye' },
  { id: 'split', label: 'Dividido', icon: 'columns' },
]

// Change view
const handleViewChange = (viewId: string) => {
  currentView.value = viewId as EditorView
}

// Handle media insert
const handleInsertMedia = () => {
  emit('insert-media')
}

// Expose methods
defineExpose({
  focus: () => editorElement.value?.focus(),
  insertText: (text: string) => {
    if (editorElement.value) {
      const start = editorElement.value.selectionStart
      content.value = content.value.substring(0, start) + text + content.value.substring(start)
    }
  },
  getContent: () => content.value,
  setContent: (text: string) => {
    content.value = text
  },
})
</script>

<template>
  <div class="content-editor" :style="{ height }">
    <!-- Header -->
    <div class="content-editor__header">
      <div class="flex items-center justify-between mb-3">
        <h3 class="text-sm font-semibold text-gray-700 dark:text-gray-300">Editor de Contenido</h3>
        <div class="flex items-center gap-4">
          <!-- View Switcher -->
          <div class="flex gap-1 bg-gray-100 dark:bg-gray-800 rounded p-1">
            <button
              v-for="tab in viewTabs"
              :key="tab.id"
              :class="[
                'px-3 py-1 text-xs rounded transition-colors',
                currentView === tab.id
                  ? 'bg-white dark:bg-gray-700 text-primary font-semibold'
                  : 'text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200',
              ]"
              @click="handleViewChange(tab.id)"
            >
              <Icon :name="tab.icon" class="w-4 h-4 inline mr-1" />
              {{ tab.label }}
            </button>
          </div>

          <!-- Stats -->
          <div v-if="showCount" class="text-xs text-gray-600 dark:text-gray-400">
            <span class="font-semibold">{{ wordCount }}</span> palabras
            <span class="mx-2">•</span>
            <span :class="characterCountColor">
              {{ characterCount }} / {{ maxLength }}
            </span>
          </div>
        </div>
      </div>

      <!-- Toolbar -->
      <div v-if="showToolbar && currentView !== 'preview'" class="content-editor__toolbar">
        <div class="flex flex-wrap gap-1">
          <button
            v-for="action in toolbarActions"
            :key="action.id"
            :title="action.label"
            :disabled="disabled || readonly"
            class="p-2 rounded hover:bg-gray-100 dark:hover:bg-gray-800 text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white transition-colors disabled:opacity-50"
            @click="action.id === 'image' ? handleInsertMedia() : insertMarkdown(action.markdown)"
          >
            <Icon :name="action.icon" class="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>

    <!-- Editor Content -->
    <div class="content-editor__content">
      <!-- Edit View -->
      <div
        v-if="currentView === 'edit'"
        class="h-full"
      >
        <textarea
          ref="editorElement"
          v-model="content"
          :placeholder="placeholder"
          :disabled="disabled"
          :readonly="readonly"
          :maxlength="maxLength"
          class="content-editor__textarea"
        />
      </div>

      <!-- Preview View -->
      <div
        v-else-if="currentView === 'preview'"
        class="content-editor__preview"
        v-html="previewHtml"
      />

      <!-- Split View -->
      <div
        v-else-if="currentView === 'split'"
        class="content-editor__split"
      >
        <div class="content-editor__split-pane">
          <textarea
            ref="editorElement"
            v-model="content"
            :placeholder="placeholder"
            :disabled="disabled"
            :readonly="readonly"
            :maxlength="maxLength"
            class="content-editor__textarea"
          />
        </div>
        <div class="content-editor__split-divider" />
        <div class="content-editor__split-pane">
          <div class="content-editor__preview" v-html="previewHtml" />
        </div>
      </div>
    </div>

    <!-- Footer -->
    <div class="content-editor__footer">
      <div class="flex items-center justify-between text-xs">
        <div class="text-gray-500 dark:text-gray-400">
          <span v-if="autosave">Guardado automático activado</span>
          <span v-if="!isValid" class="text-error ml-2">
            El contenido debe tener entre {{ minLength }} y {{ maxLength }} caracteres
          </span>
        </div>
        <div class="text-gray-500 dark:text-gray-400">
          {{ mode === 'markdown' ? 'Markdown' : 'Rich Text' }}
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.content-editor {
  @apply flex flex-col border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-900 overflow-hidden;
}

.content-editor__header {
  @apply p-4 border-b border-gray-200 dark:border-gray-800;
}

.content-editor__toolbar {
  @apply pt-3 border-t border-gray-100 dark:border-gray-800;
}

.content-editor__content {
  @apply flex-1 overflow-hidden;
}

.content-editor__textarea {
  @apply w-full h-full p-4 border-0 resize-none focus:outline-none bg-transparent text-gray-900 dark:text-white;
  font-family: 'Menlo', 'Monaco', 'Courier New', monospace;
  font-size: 14px;
  line-height: 1.6;
}

.content-editor__preview {
  @apply w-full h-full p-4 overflow-y-auto prose prose-sm dark:prose-invert max-w-none;
}

.content-editor__split {
  @apply flex h-full;
}

.content-editor__split-pane {
  @apply flex-1 overflow-hidden;
}

.content-editor__split-divider {
  @apply w-px bg-gray-200 dark:bg-gray-800;
}

.content-editor__footer {
  @apply p-3 border-t border-gray-200 dark:border-gray-800 bg-gray-50 dark:bg-gray-800;
}
</style>
