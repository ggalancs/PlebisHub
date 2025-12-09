/**
 * Modal Controller
 *
 * Stimulus controller for accessible modal dialogs.
 * Handles focus trap, escape key, backdrop click, and animations.
 *
 * Usage:
 *   <div data-controller="modal">
 *     <button data-action="click->modal#open">Open Modal</button>
 *     <div data-modal-target="backdrop" class="hidden">
 *       <div data-modal-target="dialog" role="dialog" aria-modal="true">
 *         <button data-action="click->modal#close">Close</button>
 *         <!-- modal content -->
 *       </div>
 *     </div>
 *   </div>
 */

import { Controller } from '@hotwired/stimulus'

export default class extends Controller<HTMLElement> {
  static targets = ['backdrop', 'dialog']

  declare readonly backdropTarget: HTMLElement
  declare readonly dialogTarget: HTMLElement
  declare readonly hasBackdropTarget: boolean
  declare readonly hasDialogTarget: boolean

  private isOpen = false
  private previousActiveElement: Element | null = null

  open(event?: Event) {
    event?.preventDefault()

    if (!this.hasBackdropTarget) return

    // Store current focus
    this.previousActiveElement = document.activeElement

    this.isOpen = true
    this.backdropTarget.classList.remove('hidden')

    // Prevent body scroll
    document.body.style.overflow = 'hidden'

    // Focus first focusable element in dialog
    setTimeout(() => {
      const focusable = this.dialogTarget?.querySelector<HTMLElement>(
        'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
      )
      focusable?.focus()
    }, 100)

    // Add escape listener
    document.addEventListener('keydown', this.handleKeydown.bind(this))
  }

  close(event?: Event) {
    event?.preventDefault()

    if (!this.hasBackdropTarget) return

    this.isOpen = false
    this.backdropTarget.classList.add('hidden')

    // Restore body scroll
    document.body.style.overflow = ''

    // Restore focus
    if (this.previousActiveElement instanceof HTMLElement) {
      this.previousActiveElement.focus()
    }

    // Remove escape listener
    document.removeEventListener('keydown', this.handleKeydown.bind(this))
  }

  // Close on backdrop click
  backdropClick(event: MouseEvent) {
    if (event.target === this.backdropTarget) {
      this.close()
    }
  }

  private handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Escape') {
      this.close()
    }

    // Focus trap
    if (event.key === 'Tab' && this.hasDialogTarget) {
      const focusableElements = this.dialogTarget.querySelectorAll<HTMLElement>(
        'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
      )

      const firstElement = focusableElements[0]
      const lastElement = focusableElements[focusableElements.length - 1]

      if (event.shiftKey && document.activeElement === firstElement) {
        event.preventDefault()
        lastElement?.focus()
      } else if (!event.shiftKey && document.activeElement === lastElement) {
        event.preventDefault()
        firstElement?.focus()
      }
    }
  }
}
