/**
 * Mobile Menu Controller
 *
 * Stimulus controller for responsive mobile navigation menu.
 * Handles toggle, body scroll lock, and accessibility.
 *
 * Usage:
 *   <header>
 *     <button data-action="click->mobile-menu#toggle">Menu</button>
 *     <div data-mobile-menu-target="panel" class="hidden">
 *       <!-- mobile menu items -->
 *     </div>
 *   </header>
 */

import { Controller } from '@hotwired/stimulus'

export default class extends Controller<HTMLElement> {
  static targets = ['panel']

  declare readonly panelTarget: HTMLElement
  declare readonly hasPanelTarget: boolean

  private isOpen = false

  toggle() {
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    if (!this.hasPanelTarget) return

    this.isOpen = true
    this.panelTarget.classList.remove('hidden')

    // Update button aria
    const button = this.element.querySelector('[data-action*="mobile-menu#toggle"]')
    button?.setAttribute('aria-expanded', 'true')
    button?.setAttribute('aria-label', 'Cerrar menú')

    // Update icon to X
    const icon = button?.querySelector('svg')
    if (icon) {
      icon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />'
    }

    // Prevent body scroll on mobile
    document.body.style.overflow = 'hidden'

    // Close on escape
    document.addEventListener('keydown', this.handleEscape.bind(this), { once: true })
  }

  close() {
    if (!this.hasPanelTarget) return

    this.isOpen = false
    this.panelTarget.classList.add('hidden')

    // Update button aria
    const button = this.element.querySelector('[data-action*="mobile-menu#toggle"]')
    button?.setAttribute('aria-expanded', 'false')
    button?.setAttribute('aria-label', 'Abrir menú')

    // Update icon to hamburger
    const icon = button?.querySelector('svg')
    if (icon) {
      icon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />'
    }

    // Restore body scroll
    document.body.style.overflow = ''
  }

  private handleEscape(event: KeyboardEvent) {
    if (event.key === 'Escape') {
      this.close()
    }
  }

  // Close menu when clicking a link (for SPA-like behavior)
  closeOnNavigate() {
    this.close()
  }
}
