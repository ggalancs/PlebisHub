<script setup lang="ts">
import { ref, computed } from 'vue'
import DOMPurify from 'dompurify'
import Card from '@/components/molecules/Card.vue'
import Icon from '@/components/atoms/Icon.vue'

export type ViewMode = 'desktop' | 'tablet' | 'mobile'
export type ContentType = 'markdown' | 'html' | 'text'

interface Props {
  /** Content to preview */
  content: string
  /** Content type */
  contentType?: ContentType
  /** Current view mode */
  viewMode?: ViewMode
  /** Show device frame */
  showFrame?: boolean
  /** Show view mode selector */
  showSelector?: boolean
  /** Custom title */
  title?: string
  /** Loading state */
  loading?: boolean
}

interface Emits {
  (e: 'view-mode-change', mode: ViewMode): void
}

const props = withDefaults(defineProps<Props>(), {
  contentType: 'markdown',
  viewMode: 'desktop',
  showFrame: true,
  showSelector: true,
  title: 'Vista Previa',
  loading: false,
})

const emit = defineEmits<Emits>()

// Current view mode
const currentViewMode = ref(props.viewMode)

// View mode options
const viewModes = [
  { id: 'desktop', label: 'Escritorio', icon: 'monitor', width: '100%' },
  { id: 'tablet', label: 'Tablet', icon: 'tablet', width: '768px' },
  { id: 'mobile', label: 'Móvil', icon: 'smartphone', width: '375px' },
]

// Current width
const currentWidth = computed(() => {
  const mode = viewModes.find((m) => m.id === currentViewMode.value)
  return mode?.width || '100%'
})

// Render markdown to HTML
const renderMarkdown = (text: string): string => {
  let html = text

  // Code blocks
  html = html.replace(/```(\w+)?\n([\s\S]*?)```/g, (match, lang, code) => {
    return `<pre class="code-block"><code class="language-${lang || 'plaintext'}">${code.trim()}</code></pre>`
  })

  // Headers
  html = html.replace(/^### (.*$)/gim, '<h3 class="text-lg font-bold mt-4 mb-2">$1</h3>')
  html = html.replace(/^## (.*$)/gim, '<h2 class="text-xl font-bold mt-4 mb-2">$1</h2>')
  html = html.replace(/^# (.*$)/gim, '<h1 class="text-2xl font-bold mt-4 mb-2">$1</h1>')

  // Bold
  html = html.replace(/\*\*(.+?)\*\*/g, '<strong class="font-bold">$1</strong>')

  // Italic
  html = html.replace(/_(.+?)_/g, '<em class="italic">$1</em>')

  // Links
  html = html.replace(
    /\[(.+?)\]\((.+?)\)/g,
    '<a href="$2" class="text-primary hover:underline" target="_blank" rel="noopener">$1</a>'
  )

  // Images
  html = html.replace(
    /!\[(.+?)\]\((.+?)\)/g,
    '<img src="$2" alt="$1" class="max-w-full h-auto rounded my-4" />'
  )

  // Code inline
  html = html.replace(/`(.+?)`/g, '<code class="inline-code">$1</code>')

  // Lists (unordered)
  html = html.replace(/^\* (.+)$/gim, '<li class="list-item">$1</li>')
  html = html.replace(/^\- (.+)$/gim, '<li class="list-item">$1</li>')
  html = html.replace(/(<li class="list-item">.*<\/li>)/s, '<ul class="list">$1</ul>')

  // Lists (ordered)
  html = html.replace(/^\d+\. (.+)$/gim, '<li class="list-item">$1</li>')

  // Blockquotes
  html = html.replace(/^> (.+)$/gim, '<blockquote class="blockquote">$1</blockquote>')

  // Horizontal rule
  html = html.replace(/^---$/gim, '<hr class="hr" />')

  // Paragraphs (simple implementation)
  html = html.split('\n\n').map((para) => {
    // Skip if already wrapped in tag
    if (para.trim().startsWith('<')) return para
    return `<p class="paragraph">${para}</p>`
  }).join('\n')

  // Line breaks
  html = html.replace(/\n/g, '<br />')

  return html
}

// Rendered content with XSS protection
const renderedContent = computed(() => {
  let rawHtml = ''

  if (props.contentType === 'markdown') {
    rawHtml = renderMarkdown(props.content)
  } else if (props.contentType === 'html') {
    rawHtml = props.content
  } else {
    // Plain text - escape HTML and preserve formatting
    return props.content
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/\n/g, '<br />')
  }

  // Security: Sanitize HTML to prevent XSS attacks
  return DOMPurify.sanitize(rawHtml, {
    ALLOWED_TAGS: [
      'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
      'p', 'br', 'strong', 'em', 'u', 's',
      'a', 'img',
      'ul', 'ol', 'li',
      'blockquote', 'code', 'pre',
      'table', 'thead', 'tbody', 'tr', 'th', 'td',
      'div', 'span', 'hr'
    ],
    ALLOWED_ATTR: ['href', 'src', 'alt', 'class', 'target', 'rel'],
    ALLOW_DATA_ATTR: false,
  })
})

// Change view mode
const handleViewModeChange = (mode: ViewMode) => {
  currentViewMode.value = mode
  emit('view-mode-change', mode)
}
</script>

<template>
  <Card :loading="loading" class="content-preview">
    <template #header>
      <div class="flex items-center justify-between">
        <h3 class="text-lg font-semibold">{{ title }}</h3>

        <!-- View Mode Selector -->
        <div v-if="showSelector" class="flex gap-1 bg-gray-100 dark:bg-gray-800 rounded p-1">
          <button
            v-for="mode in viewModes"
            :key="mode.id"
            :class="[
              'px-3 py-1 text-xs rounded transition-colors flex items-center gap-1',
              currentViewMode === mode.id
                ? 'bg-white dark:bg-gray-700 text-primary font-semibold'
                : 'text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200',
            ]"
            @click="handleViewModeChange(mode.id as ViewMode)"
          >
            <Icon :name="mode.icon" class="w-4 h-4" />
            <span class="hidden sm:inline">{{ mode.label }}</span>
          </button>
        </div>
      </div>
    </template>

    <!-- Preview Container -->
    <div class="content-preview__container">
      <!-- Device Frame -->
      <div
        v-if="showFrame"
        class="content-preview__frame"
        :style="{ maxWidth: currentWidth }"
      >
        <div class="content-preview__frame-header">
          <div class="flex items-center gap-2">
            <div class="w-3 h-3 rounded-full bg-red-500"></div>
            <div class="w-3 h-3 rounded-full bg-yellow-500"></div>
            <div class="w-3 h-3 rounded-full bg-green-500"></div>
          </div>
          <div class="flex-1 mx-4">
            <div class="bg-gray-200 dark:bg-gray-700 rounded px-3 py-1 text-xs text-gray-500 text-center">
              {{ currentViewMode === 'desktop' ? '1920x1080' : currentViewMode === 'tablet' ? '768x1024' : '375x667' }}
            </div>
          </div>
          <Icon name="more-vertical" class="w-4 h-4 text-gray-400" />
        </div>

        <!-- Content Area -->
        <div class="content-preview__content">
          <div
            class="prose prose-sm dark:prose-invert max-w-none"
            v-html="renderedContent"
          />
        </div>
      </div>

      <!-- No Frame -->
      <div
        v-else
        class="content-preview__no-frame"
        :style="{ maxWidth: currentWidth }"
      >
        <div
          class="prose prose-sm dark:prose-invert max-w-none"
          v-html="renderedContent"
        />
      </div>
    </div>

    <!-- Empty State -->
    <div
      v-if="!content"
      class="content-preview__empty"
    >
      <Icon name="eye-off" class="w-12 h-12 text-gray-300 dark:text-gray-700 mb-3" />
      <p class="text-gray-500 dark:text-gray-400">
        No hay contenido para previsualizar
      </p>
    </div>
  </Card>
</template>

<style scoped>
.content-preview {
  /* Container styles */
}

.content-preview__container {
  @apply flex justify-center py-6;
  min-height: 400px;
}

.content-preview__frame {
  @apply w-full mx-auto border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden bg-white dark:bg-gray-900 shadow-lg;
  transition: max-width 0.3s ease;
}

.content-preview__frame-header {
  @apply flex items-center justify-between px-4 py-3 bg-gray-100 dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700;
}

.content-preview__content {
  @apply p-6 overflow-y-auto bg-white dark:bg-gray-900;
  max-height: 600px;
}

.content-preview__no-frame {
  @apply w-full mx-auto p-6;
  transition: max-width 0.3s ease;
}

.content-preview__empty {
  @apply flex flex-col items-center justify-center py-16;
}

/* Prose Styles */
:deep(.prose) {
  @apply text-gray-900 dark:text-gray-100;
}

:deep(.prose h1),
:deep(.prose h2),
:deep(.prose h3) {
  @apply text-gray-900 dark:text-white;
}

:deep(.prose strong) {
  @apply text-gray-900 dark:text-white;
}

:deep(.prose a) {
  @apply text-primary no-underline hover:underline;
}

:deep(.prose code) {
  @apply text-primary;
}

:deep(.code-block) {
  @apply bg-gray-100 dark:bg-gray-800 p-4 rounded-lg overflow-x-auto my-4;
}

:deep(.code-block code) {
  @apply text-sm font-mono text-gray-800 dark:text-gray-200;
}

:deep(.inline-code) {
  @apply bg-gray-100 dark:bg-gray-800 px-1.5 py-0.5 rounded text-sm font-mono text-primary;
}

:deep(.list) {
  @apply list-disc list-inside my-4 space-y-1;
}

:deep(.list-item) {
  @apply text-gray-700 dark:text-gray-300;
}

:deep(.blockquote) {
  @apply border-l-4 border-primary pl-4 py-2 my-4 italic text-gray-600 dark:text-gray-400;
}

:deep(.hr) {
  @apply my-6 border-t border-gray-300 dark:border-gray-700;
}

:deep(.paragraph) {
  @apply my-3 text-gray-700 dark:text-gray-300 leading-relaxed;
}
</style>
