"""
Pytest configuration and fixtures for Selenium tests
"""
import pytest
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
import shutil
import json
import os
from datetime import datetime

# Base URL for the application
BASE_URL = os.environ.get("BASE_URL", "http://localhost:3000")

# Test user credentials
TEST_USER = {
    "email": "test@example.com",
    "password": "password123"
}

ADMIN_USER = {
    "email": "admin@example.com",
    "password": "password123"
}

# Store for test results and issues
test_issues = []


@pytest.fixture(scope="function")
def driver():
    """Create a Chrome WebDriver instance for each test"""
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--window-size=1920,1080")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--lang=es")

    # Use system chromedriver from Homebrew
    chromedriver_path = shutil.which("chromedriver") or "/opt/homebrew/bin/chromedriver"
    service = Service(chromedriver_path)
    driver = webdriver.Chrome(service=service, options=chrome_options)
    driver.implicitly_wait(10)

    yield driver

    try:
        driver.quit()
    except Exception:
        pass  # Ignore errors during cleanup


@pytest.fixture
def base_url():
    """Return the base URL for the application"""
    return BASE_URL


@pytest.fixture
def test_user():
    """Return test user credentials"""
    return TEST_USER


@pytest.fixture
def admin_user():
    """Return admin user credentials"""
    return ADMIN_USER


@pytest.fixture
def issues_collector():
    """Collector for issues found during testing"""
    return test_issues


def pytest_sessionfinish(session, exitstatus):
    """Generate issues report after all tests complete"""
    if test_issues:
        report_path = os.path.join(os.path.dirname(__file__), "ISSUES_REPORT.md")
        with open(report_path, "w") as f:
            f.write("# PlebisHub Application Issues Report\n\n")
            f.write(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            f.write(f"**Total Issues Found:** {len(test_issues)}\n\n")
            f.write("---\n\n")

            # Group by severity
            critical = [i for i in test_issues if i.get("severity") == "CRITICAL"]
            high = [i for i in test_issues if i.get("severity") == "HIGH"]
            medium = [i for i in test_issues if i.get("severity") == "MEDIUM"]
            low = [i for i in test_issues if i.get("severity") == "LOW"]

            if critical:
                f.write("## CRITICAL Issues\n\n")
                for issue in critical:
                    write_issue(f, issue)

            if high:
                f.write("## HIGH Priority Issues\n\n")
                for issue in high:
                    write_issue(f, issue)

            if medium:
                f.write("## MEDIUM Priority Issues\n\n")
                for issue in medium:
                    write_issue(f, issue)

            if low:
                f.write("## LOW Priority Issues\n\n")
                for issue in low:
                    write_issue(f, issue)


def write_issue(f, issue):
    """Write a single issue to the report"""
    f.write(f"### {issue.get('title', 'Unknown Issue')}\n\n")
    f.write(f"- **Page:** {issue.get('page', 'N/A')}\n")
    f.write(f"- **URL:** {issue.get('url', 'N/A')}\n")
    f.write(f"- **Type:** {issue.get('type', 'N/A')}\n")
    f.write(f"- **Description:** {issue.get('description', 'N/A')}\n")
    if issue.get("error_message"):
        f.write(f"- **Error Message:** `{issue.get('error_message')}`\n")
    if issue.get("expected"):
        f.write(f"- **Expected:** {issue.get('expected')}\n")
    if issue.get("actual"):
        f.write(f"- **Actual:** {issue.get('actual')}\n")
    if issue.get("screenshot"):
        f.write(f"- **Screenshot:** {issue.get('screenshot')}\n")
    f.write("\n")


def report_issue(issues_list, severity, title, page, url, issue_type, description,
                 error_message=None, expected=None, actual=None, screenshot=None):
    """Helper function to report an issue"""
    issues_list.append({
        "severity": severity,
        "title": title,
        "page": page,
        "url": url,
        "type": issue_type,
        "description": description,
        "error_message": error_message,
        "expected": expected,
        "actual": actual,
        "screenshot": screenshot,
        "timestamp": datetime.now().isoformat()
    })
