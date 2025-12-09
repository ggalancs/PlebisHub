/**
 * Lazy Loading Configuration
 *
 * Defines which components should be lazy loaded to improve initial page load
 * Uses Vue 3's defineAsyncComponent for code splitting
 */

import { defineAsyncComponent, type Component } from 'vue'

/**
 * Loading component shown while lazy component loads
 */
const LoadingComponent: Component = {
  template: `
    <div class="flex items-center justify-center min-h-[200px]">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
    </div>
  `,
}

/**
 * Error component shown if lazy load fails
 */
const ErrorComponent: Component = {
  template: `
    <div class="flex items-center justify-center min-h-[200px] text-error">
      <p>Error al cargar el componente. Por favor, recarga la página.</p>
    </div>
  `,
}

/**
 * Configuration for lazy loading options
 */
interface LazyLoadOptions {
  delay?: number // Delay before showing loading component (ms)
  timeout?: number // Timeout before showing error (ms)
  showLoading?: boolean // Show loading component
  showError?: boolean // Show error component
}

const defaultOptions: LazyLoadOptions = {
  delay: 200,
  timeout: 30000,
  showLoading: true,
  showError: true,
}

/**
 * Helper to create a lazy-loaded component with options
 */
export function lazyLoad(
  loader: () => Promise<Component>,
  options: LazyLoadOptions = {}
) {
  const opts = { ...defaultOptions, ...options }

  return defineAsyncComponent({
    loader,
    loadingComponent: opts.showLoading ? LoadingComponent : undefined,
    errorComponent: opts.showError ? ErrorComponent : undefined,
    delay: opts.delay,
    timeout: opts.timeout,
  })
}

/**
 * Lazy-loaded organism components
 * These are heavy components that should be code-split
 */
export const LazyOrganisms = {
  // Proposal components
  ProposalForm: lazyLoad(() => import('@/components/organisms/ProposalForm.vue')),
  ProposalCard: lazyLoad(() => import('@/components/organisms/ProposalCard.vue')),
  ProposalsList: lazyLoad(() => import('@/components/organisms/ProposalsList.vue')),

  // Microcredit components
  MicrocreditForm: lazyLoad(() => import('@/components/organisms/MicrocreditForm.vue')),
  MicrocreditCard: lazyLoad(() => import('@/components/organisms/MicrocreditCard.vue')),
  MicrocreditStats: lazyLoad(() => import('@/components/organisms/MicrocreditStats.vue')),

  // Collaboration components
  CollaborationForm: lazyLoad(() => import('@/components/organisms/CollaborationForm.vue')),
  CollaborationSummary: lazyLoad(() => import('@/components/organisms/CollaborationSummary.vue')),
  CollaborationStats: lazyLoad(() => import('@/components/organisms/CollaborationStats.vue')),

  // Verification components
  VerificationSteps: lazyLoad(() => import('@/components/organisms/VerificationSteps.vue')),
  SMSValidator: lazyLoad(() => import('@/components/organisms/SMSValidator.vue')),
  VerificationStatus: lazyLoad(() => import('@/components/organisms/VerificationStatus.vue')),

  // Participation components
  ParticipationForm: lazyLoad(() => import('@/components/organisms/ParticipationForm.vue')),
  // ParticipationCard: lazyLoad(() => import('@/components/organisms/ParticipationCard.vue')), // TODO: Create component

  // Voting components
  VotingWidget: lazyLoad(() => import('@/components/organisms/VotingWidget.vue')),
  VoteButton: lazyLoad(() => import('@/components/organisms/VoteButton.vue')),
  VoteStatistics: lazyLoad(() => import('@/components/organisms/VoteStatistics.vue')),

  // Content components
  ContentEditor: lazyLoad(() => import('@/components/organisms/ContentEditor.vue')),
  CommentsSection: lazyLoad(() => import('@/components/organisms/CommentsSection.vue')),

  // User components
  // UserProfile: lazyLoad(() => import('@/components/organisms/UserProfile.vue')), // TODO: Create component
}

/**
 * Preload a component
 * Useful for prefetching components that will be needed soon
 */
export function preloadComponent(loader: () => Promise<Component>): void {
  // Start loading the component
  loader().catch(err => {
    console.warn('Failed to preload component:', err)
  })
}

/**
 * Preload multiple components
 */
export function preloadComponents(loaders: Array<() => Promise<Component>>): void {
  loaders.forEach(loader => preloadComponent(loader))
}

/**
 * Route-based lazy loading helpers
 */
// TODO: Enable lazy pages once they are created
// export const LazyPages = {
//   // Dashboard and main pages
//   Dashboard: lazyLoad(() => import('@/pages/Dashboard.vue'), { delay: 0 }),
//   ProposalsPage: lazyLoad(() => import('@/pages/ProposalsPage.vue')),
//   MicrocreditPage: lazyLoad(() => import('@/pages/MicrocreditPage.vue')),
//   CollaborationsPage: lazyLoad(() => import('@/pages/CollaborationsPage.vue')),
//
//   // User pages
//   ProfilePage: lazyLoad(() => import('@/pages/ProfilePage.vue')),
//   SettingsPage: lazyLoad(() => import('@/pages/SettingsPage.vue')),
//   VerificationPage: lazyLoad(() => import('@/pages/VerificationPage.vue')),
//
//   // Admin pages
//   AdminDashboard: lazyLoad(() => import('@/pages/admin/Dashboard.vue')),
//   AdminUsers: lazyLoad(() => import('@/pages/admin/Users.vue')),
//   AdminReports: lazyLoad(() => import('@/pages/admin/Reports.vue')),
// }

/**
 * Usage example in router:
 *
 * import { LazyPages } from '@/config/lazy-loading'
 *
 * const routes = [
 *   {
 *     path: '/proposals',
 *     component: LazyPages.ProposalsPage
 *   }
 * ]
 */

/**
 * Usage example in component:
 *
 * <script setup lang="ts">
 * import { LazyOrganisms } from '@/config/lazy-loading'
 * </script>
 *
 * <template>
 *   <LazyOrganisms.ProposalForm />
 * </template>
 */
