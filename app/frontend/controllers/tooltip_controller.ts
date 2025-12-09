/**
 * Tooltip Controller
 *
 * Stimulus controller for accessible tooltips.
 * Shows on hover/focus, hides on blur/escape.
 *
 * Usage:
 *   <button
 *     data-controller="tooltip"
 *     data-tooltip-content-value="Tooltip text"
 *     data-tooltip-position-value="top"
 *   >
 *     Hover me
 *   </button>
 */

import { Controller } from '@hotwired/stimulus'

export default class extends Controller<HTMLElement> {
  static values = {
    content: String,
    position: { type: String, default: 'top' },
  }

  declare contentValue: string
  declare positionValue: 'top' | 'bottom' | 'left' | 'right'

  private tooltip: HTMLElement | null = null
  private showTimeout: ReturnType<typeof setTimeout> | null = null

  connect() {
    this.element.addEventListener('mouseenter', this.show.bind(this))
    this.element.addEventListener('mouseleave', this.hide.bind(this))
    this.element.addEventListener('focus', this.show.bind(this))
    this.element.addEventListener('blur', this.hide.bind(this))
    this.element.addEventListener('keydown', this.handleKeydown.bind(this))

    // Set aria-describedby for accessibility
    const id = `tooltip-${Math.random().toString(36).substr(2, 9)}`
    this.element.setAttribute('aria-describedby', id)
  }

  disconnect() {
    this.hide()
  }

  show() {
    if (this.tooltip || !this.contentValue) return

    // Delay show for better UX
    this.showTimeout = setTimeout(() => {
      this.createTooltip()
    }, 200)
  }

  hide() {
    if (this.showTimeout) {
      clearTimeout(this.showTimeout)
      this.showTimeout = null
    }

    if (this.tooltip) {
      this.tooltip.remove()
      this.tooltip = null
    }
  }

  private createTooltip() {
    const id = this.element.getAttribute('aria-describedby') || ''

    this.tooltip = document.createElement('div')
    this.tooltip.id = id
    this.tooltip.role = 'tooltip'
    this.tooltip.className = `
      fixed z-50 px-2 py-1 text-xs font-medium text-white bg-gray-900 rounded shadow-lg
      pointer-events-none animate-fade-in max-w-xs
    `.trim()
    this.tooltip.textContent = this.contentValue

    document.body.appendChild(this.tooltip)
    this.position()
  }

  private position() {
    if (!this.tooltip) return

    const rect = this.element.getBoundingClientRect()
    const tooltipRect = this.tooltip.getBoundingClientRect()
    const gap = 8

    let top: number
    let left: number

    switch (this.positionValue) {
      case 'bottom':
        top = rect.bottom + gap
        left = rect.left + (rect.width - tooltipRect.width) / 2
        break
      case 'left':
        top = rect.top + (rect.height - tooltipRect.height) / 2
        left = rect.left - tooltipRect.width - gap
        break
      case 'right':
        top = rect.top + (rect.height - tooltipRect.height) / 2
        left = rect.right + gap
        break
      default: // top
        top = rect.top - tooltipRect.height - gap
        left = rect.left + (rect.width - tooltipRect.width) / 2
    }

    // Keep tooltip in viewport
    left = Math.max(8, Math.min(left, window.innerWidth - tooltipRect.width - 8))
    top = Math.max(8, Math.min(top, window.innerHeight - tooltipRect.height - 8))

    this.tooltip.style.top = `${top}px`
    this.tooltip.style.left = `${left}px`
  }

  private handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Escape') {
      this.hide()
    }
  }
}
