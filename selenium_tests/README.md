# PlebisHub Selenium Test Suite

Comprehensive end-to-end testing suite for the PlebisHub Rails application using Selenium WebDriver and pytest.

## Overview

This test suite covers:

- **Public Pages**: Health endpoint, locale pages, collaboration, microcredit, impulsa
- **Authentication**: Login, registration, password recovery, logout
- **Authenticated Pages**: User profile, dashboard, tools, participation, proposals, votes
- **Admin Pages**: Admin dashboard, users, collaborations, votes, proposals, CMS
- **Forms**: Form validation, submission, XSS/SQL injection protection
- **Navigation**: Links, language switcher, mobile menu, pagination
- **Accessibility**: Alt text, labels, heading hierarchy, ARIA roles
- **Performance**: Page load times, asset loading, console errors
- **API Endpoints**: Health check, JSON responses, error handling
- **Edge Cases**: Invalid inputs, special characters, session handling

## Prerequisites

- Python 3.8+
- Chrome browser
- Docker running with PlebisHub application

## Installation

```bash
cd selenium_tests
pip install -r requirements.txt
```

## Test Users

The following test users should exist in the application:

| Email | Password | Role |
|-------|----------|------|
| test@example.com | password123 | Regular User |
| admin@example.com | password123 | Admin |

To create test users, run inside the Docker container:

```bash
docker compose exec app rails runner tmp/create_test_users.rb
```

## Running Tests

### Run all tests

```bash
pytest
```

### Run with HTML report

```bash
pytest --html=report.html --self-contained-html
```

### Run specific test file

```bash
pytest test_public_pages.py
pytest test_authentication.py
pytest test_forms.py
```

### Run specific test class

```bash
pytest test_public_pages.py::TestPublicPages
```

### Run specific test

```bash
pytest test_public_pages.py::TestPublicPages::test_health_endpoint
```

### Run with verbose output

```bash
pytest -v
```

### Run against different URL

```bash
BASE_URL=http://staging.example.com pytest
```

## Output

### Issues Report

After running the tests, an `ISSUES_REPORT.md` file is automatically generated containing all discovered issues organized by severity:

- **CRITICAL**: Server errors (500), security vulnerabilities
- **HIGH**: Major functionality issues, authentication problems
- **MEDIUM**: UI issues, broken links, accessibility problems
- **LOW**: Minor issues, suggestions

### HTML Report

When using `--html=report.html`, a detailed HTML report with test results is generated.

## Test Categories

### test_public_pages.py
Tests for pages accessible without authentication:
- Health endpoint
- Root redirect
- Locale pages (Spanish, Catalan, Basque)
- 404 error handling
- Collaboration pages
- Microcredit pages
- Impulsa pages
- Audio captcha

### test_authentication.py
Tests for authentication flows:
- Login page rendering
- Login with valid credentials
- Login with invalid credentials
- Registration page
- Password recovery
- Logout functionality

### test_authenticated_pages.py
Tests for pages requiring user login:
- User profile
- Dashboard
- Tools page
- Participation
- Proposals
- Votes
- Militant
- Census
- User verification

### test_admin_pages.py
Tests for admin panel pages:
- Admin dashboard
- Users management
- Collaborations
- Microcredits
- Votes
- Proposals
- Impulsa
- Census
- Participation teams
- CMS pages
- Categories
- Notices
- Non-admin access control

### test_forms.py
Tests for form functionality:
- Registration validation
- Login validation
- Password recovery
- Collaboration forms
- Profile update
- XSS protection
- SQL injection protection

### test_navigation.py
Tests for site navigation:
- Main navigation links
- Footer links
- Breadcrumbs
- Language switcher
- Mobile menu
- Back button
- Pagination
- Anchor links
- External links

### test_accessibility.py
Basic accessibility tests:
- Image alt text
- Form labels
- Heading hierarchy
- Link text
- Color contrast
- Focus indicators
- Skip navigation
- Language attributes
- ARIA roles

### test_performance.py
Performance tests:
- Page load times
- API response times
- Asset loading
- Image loading
- Console errors
- DOM size
- Lazy loading
- Gzip compression

### test_api_endpoints.py
API endpoint tests:
- Health check
- JSON responses
- Error handling
- Content types
- Method handling
- Large request handling
- Special character handling
- Rate limiting
- CSRF tokens

### test_edge_cases.py
Edge case tests:
- Empty parameters
- Non-existent IDs
- Invalid ID formats
- Long URLs
- Special characters in URLs
- Unicode in forms
- Session timeout
- Direct action URLs
- Null byte injection

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| BASE_URL | http://localhost:3000 | Application base URL |

### Test User Configuration

Edit `conftest.py` to modify test user credentials:

```python
TEST_USER = {
    "email": "test@example.com",
    "password": "password123"
}

ADMIN_USER = {
    "email": "admin@example.com",
    "password": "password123"
}
```

## Customization

### Adding New Tests

1. Create a new test file `test_<feature>.py`
2. Import required modules and `report_issue` from conftest
3. Create test class with descriptive name
4. Use `report_issue()` to log discovered issues

Example:

```python
from conftest import report_issue

class TestNewFeature:
    def test_something(self, driver, base_url, issues_collector):
        url = f"{base_url}/es/new-feature"
        driver.get(url)

        if "500" in driver.page_source:
            report_issue(
                issues_collector, "HIGH", "500 Error on New Feature",
                "New Feature", url, "Server Error",
                "Internal server error description"
            )
```

### Issue Severity Levels

- **CRITICAL**: Application is unusable or has security vulnerability
- **HIGH**: Major feature is broken
- **MEDIUM**: Feature partially broken or has significant issues
- **LOW**: Minor issue or improvement suggestion

## Troubleshooting

### Chrome driver issues

```bash
# Install/update webdriver-manager
pip install --upgrade webdriver-manager
```

### Connection refused

Ensure the Docker application is running:

```bash
docker compose up -d
curl http://localhost:3000/health
```

### Test users don't exist

Create test users:

```bash
docker compose exec app rails runner tmp/create_test_users.rb
```

## CI/CD Integration

For CI/CD pipelines, use:

```bash
pytest --html=report.html --self-contained-html -v --tb=short
```

Exit codes:
- 0: All tests passed
- 1: Some tests failed
- 2: Test execution error
