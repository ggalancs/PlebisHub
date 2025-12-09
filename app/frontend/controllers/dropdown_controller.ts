/**
 * Dropdown Controller
 *
 * Stimulus controller for accessible dropdown menus.
 * Used in header navigation for user menu.
 *
 * Usage:
 *   <div data-controller="dropdown">
 *     <button data-action="click->dropdown#toggle">Menu</button>
 *     <div data-dropdown-target="menu" class="hidden">
 *       <!-- menu items -->
 *     </div>
 *   </div>
 */

import { Controller } from '@hotwired/stimulus'

export default class extends Controller<HTMLElement> {
  static targets = ['menu']

  declare readonly menuTarget: HTMLElement
  declare readonly hasMenuTarget: boolean

  private isOpen = false
  private boundClickOutside: (event: MouseEvent) => void

  connect() {
    this.boundClickOutside = this.clickOutside.bind(this)
  }

  disconnect() {
    document.removeEventListener('click', this.boundClickOutside)
  }

  toggle(event: Event) {
    event.stopPropagation()

    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    if (!this.hasMenuTarget) return

    this.isOpen = true
    this.menuTarget.classList.remove('hidden')
    this.element.querySelector('button')?.setAttribute('aria-expanded', 'true')

    // Close on click outside
    setTimeout(() => {
      document.addEventListener('click', this.boundClickOutside)
    }, 0)

    // Close on escape
    document.addEventListener('keydown', this.handleEscape.bind(this), { once: true })
  }

  close() {
    if (!this.hasMenuTarget) return

    this.isOpen = false
    this.menuTarget.classList.add('hidden')
    this.element.querySelector('button')?.setAttribute('aria-expanded', 'false')

    document.removeEventListener('click', this.boundClickOutside)
  }

  private clickOutside(event: MouseEvent) {
    if (!this.element.contains(event.target as Node)) {
      this.close()
    }
  }

  private handleEscape(event: KeyboardEvent) {
    if (event.key === 'Escape') {
      this.close()
    }
  }
}
