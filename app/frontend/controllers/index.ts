/**
 * Stimulus Controllers Index
 *
 * Register all Stimulus controllers here for automatic loading.
 */

import { Application } from '@hotwired/stimulus'

// Import controllers
import DropdownController from './dropdown_controller'
import MobileMenuController from './mobile_menu_controller'
import ModalController from './modal_controller'
import TabsController from './tabs_controller'
import TooltipController from './tooltip_controller'
import ClipboardController from './clipboard_controller'

// Start Stimulus application
const application = Application.start()

// Configure Stimulus development experience
application.debug = import.meta.env.DEV

// Register controllers
application.register('dropdown', DropdownController)
application.register('mobile-menu', MobileMenuController)
application.register('modal', ModalController)
application.register('tabs', TabsController)
application.register('tooltip', TooltipController)
application.register('clipboard', ClipboardController)

export { application }
