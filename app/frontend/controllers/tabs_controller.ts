/**
 * Tabs Controller
 *
 * Stimulus controller for accessible tabbed interfaces.
 * Supports keyboard navigation and ARIA attributes.
 *
 * Usage:
 *   <div data-controller="tabs" data-tabs-active-class="active">
 *     <div role="tablist">
 *       <button data-tabs-target="tab" data-action="click->tabs#select">Tab 1</button>
 *       <button data-tabs-target="tab" data-action="click->tabs#select">Tab 2</button>
 *     </div>
 *     <div data-tabs-target="panel">Panel 1 content</div>
 *     <div data-tabs-target="panel" class="hidden">Panel 2 content</div>
 *   </div>
 */

import { Controller } from '@hotwired/stimulus'

export default class extends Controller<HTMLElement> {
  static override targets = ['tab', 'panel']
  static override values = {
    index: { type: Number, default: 0 },
  }

  declare readonly tabTargets: HTMLElement[]
  declare readonly panelTargets: HTMLElement[]
  declare indexValue: number

  override connect() {
    this.showTab(this.indexValue)
    this.setupKeyboardNav()
  }

  select(event: Event) {
    const tab = event.currentTarget as HTMLElement
    const index = this.tabTargets.indexOf(tab)
    if (index >= 0) {
      this.indexValue = index
      this.showTab(index)
    }
  }

  showTab(index: number) {
    this.tabTargets.forEach((tab, i) => {
      const isActive = i === index
      tab.setAttribute('aria-selected', String(isActive))
      tab.setAttribute('tabindex', isActive ? '0' : '-1')

      if (isActive) {
        tab.classList.add('active', 'border-primary-500', 'text-primary-600')
        tab.classList.remove('border-transparent', 'text-gray-500')
      } else {
        tab.classList.remove('active', 'border-primary-500', 'text-primary-600')
        tab.classList.add('border-transparent', 'text-gray-500')
      }
    })

    this.panelTargets.forEach((panel, i) => {
      panel.classList.toggle('hidden', i !== index)
      panel.setAttribute('aria-hidden', String(i !== index))
    })
  }

  private setupKeyboardNav() {
    this.tabTargets.forEach((tab) => {
      tab.addEventListener('keydown', (event: KeyboardEvent) => {
        const currentIndex = this.tabTargets.indexOf(tab)
        let newIndex = currentIndex

        switch (event.key) {
          case 'ArrowLeft':
            newIndex = currentIndex > 0 ? currentIndex - 1 : this.tabTargets.length - 1
            break
          case 'ArrowRight':
            newIndex = currentIndex < this.tabTargets.length - 1 ? currentIndex + 1 : 0
            break
          case 'Home':
            newIndex = 0
            break
          case 'End':
            newIndex = this.tabTargets.length - 1
            break
          default:
            return
        }

        event.preventDefault()
        this.indexValue = newIndex
        this.showTab(newIndex)
        this.tabTargets[newIndex]?.focus()
      })
    })
  }
}
