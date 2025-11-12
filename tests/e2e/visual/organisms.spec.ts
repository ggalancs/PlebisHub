/**
 * Visual Regression Tests for Organism Components
 *
 * Tests visual consistency across:
 * - Different browsers (Chromium, Firefox, WebKit)
 * - Different viewports (Desktop, Mobile)
 * - Different themes (Light, Dark)
 * - Different states (Default, Hover, Active, Disabled)
 */

import { test, expect } from '@playwright/test'

// Base URL for Storybook (adjust if different)
const STORYBOOK_URL = 'http://localhost:6006'

test.describe('Visual Regression - Proposal Components', () => {
  test('ProposalCard - Default State', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-proposalcard--default`)

    // Wait for component to be fully rendered
    await page.waitForSelector('.proposal-card', { state: 'visible' })

    // Take screenshot
    await expect(page).toHaveScreenshot('proposal-card-default.png', {
      fullPage: true,
      animations: 'disabled',
    })
  })

  test('ProposalCard - Hover State', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-proposalcard--default`)
    await page.waitForSelector('.proposal-card')

    const card = page.locator('.proposal-card').first()
    await card.hover()

    await expect(page).toHaveScreenshot('proposal-card-hover.png', {
      animations: 'disabled',
    })
  })

  test('ProposalForm - Empty State', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-proposalform--default`)
    await page.waitForSelector('.proposal-form')

    await expect(page).toHaveScreenshot('proposal-form-empty.png', {
      fullPage: true,
    })
  })

  test('ProposalForm - Validation Errors', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-proposalform--with-errors`)
    await page.waitForSelector('.proposal-form')

    await expect(page).toHaveScreenshot('proposal-form-errors.png', {
      fullPage: true,
    })
  })
})

test.describe('Visual Regression - Voting Components', () => {
  test('VoteButton - Default', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-votebutton--default`)
    await page.waitForSelector('[class*="vote"]')

    await expect(page).toHaveScreenshot('vote-button-default.png')
  })

  test('VoteButton - Upvoted', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-votebutton--upvoted`)
    await page.waitForSelector('[class*="vote"]')

    await expect(page).toHaveScreenshot('vote-button-upvoted.png')
  })

  test('VoteStatistics - With Data', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-votestatistics--with-votes`)
    await page.waitForSelector('[class*="vote-stat"]')

    await expect(page).toHaveScreenshot('vote-statistics.png', {
      fullPage: true,
    })
  })
})

test.describe('Visual Regression - Microcredit Components', () => {
  test('MicrocreditCard - Open Status', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-microcreditcard--default`)
    await page.waitForSelector('.microcredit-card')

    await expect(page).toHaveScreenshot('microcredit-card-open.png')
  })

  test('MicrocreditCard - Funded Status', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-microcreditcard--funded`)
    await page.waitForSelector('.microcredit-card')

    await expect(page).toHaveScreenshot('microcredit-card-funded.png')
  })

  test('MicrocreditForm - Complete', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-microcreditform--with-data`)
    await page.waitForSelector('.microcredit-form')

    await expect(page).toHaveScreenshot('microcredit-form-complete.png', {
      fullPage: true,
    })
  })

  test('MicrocreditStats - Dashboard', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-microcreditstats--default`)
    await page.waitForTimeout(1000) // Wait for animations

    await expect(page).toHaveScreenshot('microcredit-stats.png', {
      fullPage: true,
      animations: 'disabled',
    })
  })
})

test.describe('Visual Regression - Collaboration Components', () => {
  test('CollaborationForm - Empty', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-collaborationform--default`)
    await page.waitForSelector('.collaboration-form')

    await expect(page).toHaveScreenshot('collaboration-form-empty.png', {
      fullPage: true,
    })
  })

  test('CollaborationSummary - Open', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-collaborationsummary--open-status`)
    await page.waitForSelector('.collaboration-summary')

    await expect(page).toHaveScreenshot('collaboration-summary.png', {
      fullPage: true,
    })
  })

  test('CollaborationStats - Dashboard', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-collaborationstats--default`)
    await page.waitForTimeout(1000)

    await expect(page).toHaveScreenshot('collaboration-stats.png', {
      fullPage: true,
      animations: 'disabled',
    })
  })
})

test.describe('Visual Regression - Verification Components', () => {
  test('VerificationSteps - Step 1', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-verificationsteps--step-one`)
    await page.waitForSelector('[class*="verification"]')

    await expect(page).toHaveScreenshot('verification-step-1.png', {
      fullPage: true,
    })
  })

  test('SMSValidator - Pending', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-smsvalidator--pending`)
    await page.waitForSelector('.sms-validator')

    await expect(page).toHaveScreenshot('sms-validator-pending.png')
  })

  test('SMSValidator - Valid', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-smsvalidator--valid`)
    await page.waitForSelector('.sms-validator')

    await expect(page).toHaveScreenshot('sms-validator-valid.png')
  })

  test('VerificationStatus - Verified', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-verificationstatus--verified`)
    await page.waitForSelector('[class*="verification"]')

    await expect(page).toHaveScreenshot('verification-status-verified.png')
  })
})

test.describe('Visual Regression - Dark Mode', () => {
  test.use({ colorScheme: 'dark' })

  test('ProposalCard - Dark Mode', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-proposalcard--default&globals=backgrounds.value:dark`)
    await page.waitForSelector('.proposal-card')

    await expect(page).toHaveScreenshot('proposal-card-dark.png')
  })

  test('MicrocreditForm - Dark Mode', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-microcreditform--default&globals=backgrounds.value:dark`)
    await page.waitForSelector('.microcredit-form')

    await expect(page).toHaveScreenshot('microcredit-form-dark.png', {
      fullPage: true,
    })
  })

  test('CollaborationStats - Dark Mode', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-collaborationstats--default&globals=backgrounds.value:dark`)
    await page.waitForTimeout(1000)

    await expect(page).toHaveScreenshot('collaboration-stats-dark.png', {
      fullPage: true,
      animations: 'disabled',
    })
  })
})

test.describe('Visual Regression - Mobile Views', () => {
  test.use({ viewport: { width: 375, height: 667 } }) // iPhone SE size

  test('ProposalCard - Mobile', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-proposalcard--default`)
    await page.waitForSelector('.proposal-card')

    await expect(page).toHaveScreenshot('proposal-card-mobile.png', {
      fullPage: true,
    })
  })

  test('MicrocreditCard - Mobile', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-microcreditcard--default`)
    await page.waitForSelector('.microcredit-card')

    await expect(page).toHaveScreenshot('microcredit-card-mobile.png', {
      fullPage: true,
    })
  })

  test('CollaborationForm - Mobile', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-collaborationform--default`)
    await page.waitForSelector('.collaboration-form')

    await expect(page).toHaveScreenshot('collaboration-form-mobile.png', {
      fullPage: true,
    })
  })

  test('SMSValidator - Mobile', async ({ page }) => {
    await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-smsvalidator--default`)
    await page.waitForSelector('.sms-validator')

    await expect(page).toHaveScreenshot('sms-validator-mobile.png')
  })
})

test.describe('Visual Regression - Responsive Breakpoints', () => {
  const viewports = [
    { name: 'mobile', width: 375, height: 667 },
    { name: 'tablet', width: 768, height: 1024 },
    { name: 'desktop', width: 1920, height: 1080 },
  ]

  for (const viewport of viewports) {
    test(`CollaborationStats - ${viewport.name}`, async ({ page }) => {
      await page.setViewportSize({ width: viewport.width, height: viewport.height })
      await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-collaborationstats--default`)
      await page.waitForTimeout(1000)

      await expect(page).toHaveScreenshot(`collaboration-stats-${viewport.name}.png`, {
        fullPage: true,
        animations: 'disabled',
      })
    })

    test(`MicrocreditStats - ${viewport.name}`, async ({ page }) => {
      await page.setViewportSize({ width: viewport.width, height: viewport.height })
      await page.goto(`${STORYBOOK_URL}/iframe.html?id=organisms-microcreditstats--default`)
      await page.waitForTimeout(1000)

      await expect(page).toHaveScreenshot(`microcredit-stats-${viewport.name}.png`, {
        fullPage: true,
        animations: 'disabled',
      })
    })
  }
})
