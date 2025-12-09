/**
 * Clipboard Controller
 *
 * Stimulus controller for copying text to clipboard.
 * Shows feedback on successful copy.
 *
 * Usage:
 *   <button
 *     data-controller="clipboard"
 *     data-clipboard-text-value="Text to copy"
 *     data-action="click->clipboard#copy"
 *   >
 *     Copy
 *   </button>
 *
 * Or copy from an element:
 *   <div data-controller="clipboard">
 *     <input data-clipboard-target="source" value="Text to copy" />
 *     <button data-action="click->clipboard#copy">Copy</button>
 *   </div>
 */

import { Controller } from '@hotwired/stimulus'

export default class extends Controller<HTMLElement> {
  static override targets = ['source']
  static override values = {
    text: String,
    successMessage: { type: String, default: 'Copiado!' },
    successDuration: { type: Number, default: 2000 },
  }

  declare readonly sourceTarget: HTMLInputElement | HTMLTextAreaElement
  declare readonly hasSourceTarget: boolean
  declare textValue: string
  declare successMessageValue: string
  declare successDurationValue: number

  private originalContent: string | null = null

  async copy(event: Event) {
    event.preventDefault()

    const text = this.getTextToCopy()
    if (!text) return

    try {
      await navigator.clipboard.writeText(text)
      this.showSuccess()
    } catch (err) {
      // Fallback for older browsers
      this.fallbackCopy(text)
    }
  }

  private getTextToCopy(): string {
    if (this.textValue) {
      return this.textValue
    }

    if (this.hasSourceTarget) {
      return this.sourceTarget.value
    }

    return ''
  }

  private fallbackCopy(text: string) {
    const textarea = document.createElement('textarea')
    textarea.value = text
    textarea.style.position = 'fixed'
    textarea.style.left = '-9999px'
    document.body.appendChild(textarea)
    textarea.select()

    try {
      document.execCommand('copy')
      this.showSuccess()
    } catch (err) {
      console.error('Failed to copy text:', err)
    }

    document.body.removeChild(textarea)
  }

  private showSuccess() {
    // Store original content
    this.originalContent = this.element.innerHTML

    // Show success message
    const icon = `<svg class="w-4 h-4 inline-block mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
    </svg>`
    this.element.innerHTML = `${icon}${this.successMessageValue}`
    this.element.classList.add('text-green-600')

    // Restore original content after duration
    setTimeout(() => {
      if (this.originalContent !== null) {
        this.element.innerHTML = this.originalContent
        this.element.classList.remove('text-green-600')
        this.originalContent = null
      }
    }, this.successDurationValue)
  }
}
