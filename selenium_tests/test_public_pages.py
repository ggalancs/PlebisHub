"""
Public Pages Tests - Pages accessible without authentication
"""
import pytest
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from conftest import report_issue
import time
import requests


class TestPublicPages:
    """Test public pages accessibility and functionality"""

    def test_health_endpoint(self, base_url, issues_collector):
        """Test health check endpoint"""
        url = f"{base_url}/health"
        try:
            response = requests.get(url, timeout=10)
            if response.status_code != 200:
                report_issue(
                    issues_collector, "CRITICAL", "Health endpoint not responding",
                    "Health Check", url, "Server Error",
                    f"Health endpoint returned status {response.status_code}"
                )
        except Exception as e:
            report_issue(
                issues_collector, "CRITICAL", "Health endpoint unreachable",
                "Health Check", url, "Connection Error",
                str(e)
            )

    def test_root_redirect(self, driver, base_url, issues_collector):
        """Test root URL redirects correctly"""
        driver.get(base_url)
        time.sleep(2)

        try:
            current_url = driver.current_url
            # Should redirect to /es or /en or locale-prefixed URL
            if not any(locale in current_url for locale in ["/es", "/en", "/ca", "/eu"]):
                report_issue(
                    issues_collector, "MEDIUM", "Root redirect not working",
                    "Root URL", base_url, "Redirect Issue",
                    f"Expected redirect to locale URL, got: {current_url}"
                )

            # Check for errors
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "CRITICAL", "500 Error on root URL",
                    "Root URL", base_url, "Server Error",
                    "Internal server error on root URL"
                )

        except Exception as e:
            report_issue(
                issues_collector, "HIGH", "Root URL test failed",
                "Root URL", base_url, "Test Error",
                str(e)
            )

    def test_spanish_locale(self, driver, base_url, issues_collector):
        """Test Spanish locale loads correctly"""
        url = f"{base_url}/es"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source:
                report_issue(
                    issues_collector, "CRITICAL", "500 Error on Spanish locale",
                    "Spanish Home", url, "Server Error",
                    "Internal server error on Spanish locale"
                )
                return

            # Check page loaded properly
            page_source = driver.page_source.lower()
            if "error" in driver.title.lower() and "exception" in page_source:
                report_issue(
                    issues_collector, "HIGH", "Error on Spanish locale page",
                    "Spanish Home", url, "Page Error",
                    "Error detected in page content"
                )

        except Exception as e:
            report_issue(
                issues_collector, "HIGH", "Spanish locale test failed",
                "Spanish Home", url, "Test Error",
                str(e)
            )

    def test_catalan_locale(self, driver, base_url, issues_collector):
        """Test Catalan locale loads correctly"""
        url = f"{base_url}/ca"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Catalan locale",
                    "Catalan Home", url, "Server Error",
                    "Internal server error on Catalan locale"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Catalan locale test failed",
                "Catalan Home", url, "Test Error",
                str(e)
            )

    def test_basque_locale(self, driver, base_url, issues_collector):
        """Test Basque locale loads correctly"""
        url = f"{base_url}/eu"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Basque locale",
                    "Basque Home", url, "Server Error",
                    "Internal server error on Basque locale"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Basque locale test failed",
                "Basque Home", url, "Test Error",
                str(e)
            )

    def test_404_page(self, driver, base_url, issues_collector):
        """Test 404 error page displays correctly"""
        url = f"{base_url}/es/nonexistent-page-12345"
        driver.get(url)
        time.sleep(2)

        try:
            # Should show 404, not 500
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error instead of 404",
                    "404 Page", url, "Error Handling",
                    "Non-existent page shows 500 error instead of 404"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "404 page test failed",
                "404 Page", url, "Test Error",
                str(e)
            )

    def test_collaboration_page(self, driver, base_url, issues_collector):
        """Test collaboration (donation) page loads"""
        url = f"{base_url}/es/colabora"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Collaboration Page",
                    "Collaboration Page", url, "Server Error",
                    "Internal server error on collaboration page"
                )
                return

            # Check for form elements
            page_source = driver.page_source
            if "error" in driver.title.lower():
                report_issue(
                    issues_collector, "HIGH", "Error on Collaboration Page",
                    "Collaboration Page", url, "Page Error",
                    "Error detected in collaboration page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Collaboration page test failed",
                "Collaboration Page", url, "Test Error",
                str(e)
            )

    def test_single_collaboration_page(self, driver, base_url, issues_collector):
        """Test single collaboration page loads"""
        url = f"{base_url}/es/colabora/puntual"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Single Collaboration Page",
                    "Single Collaboration", url, "Server Error",
                    "Internal server error on single collaboration page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Single collaboration page test failed",
                "Single Collaboration", url, "Test Error",
                str(e)
            )

    def test_microcredit_page(self, driver, base_url, issues_collector):
        """Test microcredit page loads"""
        url = f"{base_url}/es/microcreditos"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Microcredit Page",
                    "Microcredit Page", url, "Server Error",
                    "Internal server error on microcredit page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Microcredit page test failed",
                "Microcredit Page", url, "Test Error",
                str(e)
            )

    def test_impulsa_page(self, driver, base_url, issues_collector):
        """Test Impulsa page loads"""
        url = f"{base_url}/es/impulsa"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Impulsa Page",
                    "Impulsa Page", url, "Server Error",
                    "Internal server error on impulsa page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Impulsa page test failed",
                "Impulsa Page", url, "Test Error",
                str(e)
            )

    def test_audio_captcha_endpoint(self, driver, base_url, issues_collector):
        """Test audio captcha endpoint"""
        url = f"{base_url}/es/audio_captcha"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source:
                report_issue(
                    issues_collector, "MEDIUM", "500 Error on Audio Captcha",
                    "Audio Captcha", url, "Server Error",
                    "Internal server error on audio captcha endpoint"
                )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Audio captcha test failed",
                "Audio Captcha", url, "Test Error",
                str(e)
            )
