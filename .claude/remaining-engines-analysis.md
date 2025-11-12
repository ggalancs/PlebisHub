# Remaining Engines Analysis - Components Specification

## Overview

Based on analysis of the 5 remaining engines, here's a detailed specification of the Vue components needed for each.

---

## 1. **plebis_participation** - Participation Teams

### Purpose
Manages participation teams/campaign teams where citizens can sign up to actively participate in campaigns.

### Required Components (2-3 components)

#### ParticipationTeamCard
- **Purpose**: Display information about a participation team
- **Features**:
  - Team name and description
  - Member count
  - Join/Leave button
  - Team status (active/inactive)
  - Team location/region
- **Props**: `team`, `userIsMember`, `loading`
- **Events**: `join`, `leave`
- **Similar to**: ProposalCard

#### ParticipationForm
- **Purpose**: Form to express interest in joining participation teams
- **Features**:
  - User contact information
  - Region/location selector
  - Skills/interests checkboxes
  - Availability options
  - Motivation textarea
- **Props**: `initialData`, `regions`
- **Events**: `submit`
- **Similar to**: ProposalForm

---

## 2. **plebis_impulsa** - Project Funding Platform

### Purpose
Platform for submitting and voting on community projects that receive funding from elected officials' salary surplus.

### Required Components (4-5 components)

#### ImpulsaProjectCard
- **Purpose**: Display a project in listings
- **Features**:
  - Project title, description (truncated)
  - Funding amount requested
  - Vote count
  - Project status (submission, evaluation, voting, funded)
  - Category badge
  - Progress indicator
- **Props**: `project`, `compact`
- **Events**: `click`, `vote`
- **Similar to**: ProposalCard

#### ImpulsaProjectForm
- **Purpose**: Multi-step form to submit a project
- **Features**:
  - Step 1: Basic info (title, description, category)
  - Step 2: Funding details (amount, budget breakdown)
  - Step 3: Team info (collaborators, skills needed)
  - Step 4: Timeline and milestones
  - Progress indicator showing current step
  - Save draft functionality
  - File upload for supporting documents
- **Props**: `initialData`, `currentStep`, `edition`
- **Events**: `submit`, `save-draft`, `step-change`
- **Similar to**: ProposalForm + ContentEditor

#### ImpulsaProjectsList
- **Purpose**: Filterable list of projects
- **Features**:
  - Filter by status, category, funding amount
  - Sort by votes, date, funding amount
  - Pagination
  - Search
- **Props**: `projects`, `filters`, `loading`
- **Events**: `filter-change`, `sort-change`
- **Similar to**: ProposalsList

#### ImpulsaProjectSteps
- **Purpose**: Visual stepper showing project submission stages
- **Features**:
  - Step indicators
  - Timeline view
  - Current step highlighting
  - Completion status
- **Props**: `currentStep`, `steps`, `completed`
- **Similar to**: Custom stepper component

#### ImpulsaEditionInfo
- **Purpose**: Display information about current IMPULSA edition
- **Features**:
  - Edition dates (submission, evaluation, voting)
  - Countdown timers
  - Phase indicators
  - Total funding available
  - Number of projects submitted
- **Props**: `edition`, `stats`
- **Similar to**: VoteStatistics

---

## 3. **plebis_verification** - User Verification

### Purpose
Multi-step user identity verification system using SMS and document upload.

### Required Components (3 components)

#### VerificationSteps
- **Purpose**: Multi-step wizard for verification process
- **Features**:
  - Step 1: Document type selection
  - Step 2: Document photo upload
  - Step 3: Phone number entry
  - Step 4: SMS code validation
  - Progress indicator
  - Back/Next navigation
  - Validation on each step
- **Props**: `currentStep`, `userData`
- **Events**: `step-complete`, `verification-complete`
- **Similar to**: Multi-step form pattern

#### SMSValidator
- **Purpose**: SMS code input and validation
- **Features**:
  - Phone number display (masked)
  - Code input (6 digits)
  - Resend code button with countdown
  - Error display
  - Loading states
- **Props**: `phoneNumber`, `loading`
- **Events**: `validate`, `resend`
- **Similar to**: Form input component

#### VerificationStatus
- **Purpose**: Display user's verification status
- **Features**:
  - Status badge (pending, verified, rejected)
  - Verification level indicator
  - Document status
  - Phone verification status
  - Action buttons (re-verify, appeal)
- **Props**: `verification`, `canEdit`
- **Events**: `retry`, `appeal`
- **Similar to**: Status display component

---

## 4. **plebis_microcredit** - Microcredit Management

### Purpose
Platform for managing microcredits/microloans to support the organization.

### Required Components (3-4 components)

#### MicrocreditCard
- **Purpose**: Display microcredit option
- **Features**:
  - Loan amount
  - Return date
  - Interest (if any)
  - Status (available, funded, returned)
  - Progress bar
  - Contribute button
- **Props**: `microcredit`, `userContribution`
- **Events**: `contribute`
- **Similar to**: ProposalCard

#### MicrocreditForm
- **Purpose**: Form to contribute to microcredit
- **Features**:
  - Amount selector
  - Payment method selection
  - Personal information
  - Bank details (IBAN)
  - Terms acceptance
  - Secure payment indicator
- **Props**: `microcredit`, `user`
- **Events**: `submit`
- **Similar to**: ProposalForm

#### MicrocreditList
- **Purpose**: List of available microcredits
- **Features**:
  - Filter by amount, status
  - Sort by date, amount
  - Total contributed display
  - Pagination
- **Props**: `microcredits`, `filters`
- **Events**: `filter-change`
- **Similar to**: ProposalsList

#### MicrocreditStats
- **Purpose**: Display statistics dashboard
- **Features**:
  - Total amount raised
  - Number of contributors
  - Average contribution
  - Funding progress
  - Charts (amount over time, contribution distribution)
- **Props**: `stats`, `loading`
- **Similar to**: VoteStatistics

---

## 5. **plebis_collaborations** - Recurring Collaborations/Donations

### Purpose
Manage recurring financial collaborations (donations) to support the organization.

### Required Components (3 components)

#### CollaborationForm
- **Purpose**: Form to set up recurring donation
- **Features**:
  - Amount selection (preset options + custom)
  - Frequency selector (monthly, quarterly, yearly)
  - Payment method (card, bank transfer, PayPal)
  - Personal information
  - Start date selector
  - Terms and conditions
- **Props**: `amounts`, `frequencies`, `initialData`
- **Events**: `submit`
- **Similar to**: ProposalForm + Payment form

#### CollaborationSummary
- **Purpose**: Display user's active collaborations
- **Features**:
  - List of active collaborations
  - Amount and frequency
  - Next payment date
  - Total contributed
  - Edit/Cancel buttons
  - Payment history
- **Props**: `collaborations`, `user`
- **Events**: `edit`, `cancel`, `view-history`
- **Similar to**: VoteHistory

#### CollaborationStats
- **Purpose**: Admin dashboard showing collaboration statistics
- **Features**:
  - Total monthly income
  - Number of active collaborators
  - Collaboration by frequency chart
  - Evolution over time graph
  - Collaboration by amount chart
  - New vs cancelled this month
- **Props**: `stats`, `dateRange`
- **Similar to**: VoteStatistics

---

## Implementation Priority

### High Priority (Immediate - Session 1-2)
1. **plebis_impulsa** (Most complex, user-facing)
   - ImpulsaProjectCard
   - ImpulsaProjectForm
   - ImpulsaProjectsList

2. **plebis_verification** (Critical for security)
   - VerificationSteps
   - SMSValidator

### Medium Priority (Session 2-3)
3. **plebis_participation**
   - ParticipationTeamCard
   - ParticipationForm

4. **plebis_microcredit**
   - MicrocreditCard
   - MicrocreditForm

### Lower Priority (Session 3 or simplify)
5. **plebis_collaborations** (Can reuse patterns from microcredit)
   - CollaborationForm
   - CollaborationSummary

---

## Estimated Component Count

- **plebis_participation**: 2 components
- **plebis_impulsa**: 5 components
- **plebis_verification**: 3 components
- **plebis_microcredit**: 4 components
- **plebis_collaborations**: 3 components

**Total**: 17 components

**Estimated effort**:
- ~30-40 tests per component = 510-680 tests
- ~10-15 stories per component = 170-255 stories
- ~200-300 lines per component = 3,400-5,100 lines of code

---

## Notes

- Many components can reuse patterns from already-implemented engines (proposals, votes, cms)
- Form components can leverage the `useForm` composable
- List components can leverage the `usePagination` composable
- The patterns are now well-established, making implementation faster
- Consider simplifying or combining some components if time is limited

---

*Document created*: 2025-11-12
*Based on*: Analysis of engines/ directory views and controllers
