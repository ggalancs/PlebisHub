"""
Authenticated Pages Tests - Pages requiring user login
"""
import pytest
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
from conftest import report_issue
import time


class TestAuthenticatedPages:
    """Test pages that require authentication"""

    def login(self, driver, base_url, user):
        """Helper method to log in a user"""
        url = f"{base_url}/es/users/sign_in"
        driver.get(url)
        time.sleep(2)

        try:
            email_field = WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.ID, "user_email"))
            )
            email_field.clear()
            email_field.send_keys(user["email"])

            password_field = driver.find_element(By.ID, "user_password")
            password_field.clear()
            password_field.send_keys(user["password"])

            submit_button = driver.find_element(By.NAME, "commit")
            submit_button.click()
            time.sleep(3)
            return True
        except Exception:
            return False

    def test_user_profile_page(self, driver, base_url, test_user, issues_collector):
        """Test user profile page loads after login"""
        self.login(driver, base_url, test_user)

        url = f"{base_url}/es/users/edit"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on User Profile Page",
                    "User Profile", url, "Server Error",
                    "Internal server error on user profile page"
                )
                return

            # Check for profile form elements
            if "sign_in" in driver.current_url:
                report_issue(
                    issues_collector, "HIGH", "Redirected to login from profile",
                    "User Profile", url, "Authentication Error",
                    "User was redirected to login page instead of profile"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "User profile test failed",
                "User Profile", url, "Test Error",
                str(e)
            )

    def test_user_dashboard(self, driver, base_url, test_user, issues_collector):
        """Test user dashboard/home after login"""
        self.login(driver, base_url, test_user)
        time.sleep(2)

        try:
            current_url = driver.current_url

            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Dashboard",
                    "Dashboard", current_url, "Server Error",
                    "Internal server error on dashboard after login"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Dashboard test failed",
                "Dashboard", driver.current_url, "Test Error",
                str(e)
            )

    def test_tools_page(self, driver, base_url, test_user, issues_collector):
        """Test tools/herramientas page"""
        self.login(driver, base_url, test_user)

        url = f"{base_url}/es/herramientas"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Tools Page",
                    "Tools Page", url, "Server Error",
                    "Internal server error on tools page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Tools page test failed",
                "Tools Page", url, "Test Error",
                str(e)
            )

    def test_participation_page(self, driver, base_url, test_user, issues_collector):
        """Test participation page"""
        self.login(driver, base_url, test_user)

        url = f"{base_url}/es/participa"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Participation Page",
                    "Participation Page", url, "Server Error",
                    "Internal server error on participation page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Participation page test failed",
                "Participation Page", url, "Test Error",
                str(e)
            )

    def test_proposals_page(self, driver, base_url, test_user, issues_collector):
        """Test proposals page"""
        self.login(driver, base_url, test_user)

        url = f"{base_url}/es/propuestas"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Proposals Page",
                    "Proposals Page", url, "Server Error",
                    "Internal server error on proposals page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Proposals page test failed",
                "Proposals Page", url, "Test Error",
                str(e)
            )

    def test_votes_page(self, driver, base_url, test_user, issues_collector):
        """Test votes/votaciones page"""
        self.login(driver, base_url, test_user)

        url = f"{base_url}/es/votos"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Votes Page",
                    "Votes Page", url, "Server Error",
                    "Internal server error on votes page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Votes page test failed",
                "Votes Page", url, "Test Error",
                str(e)
            )

    def test_militant_page(self, driver, base_url, test_user, issues_collector):
        """Test militant/militante page"""
        self.login(driver, base_url, test_user)

        url = f"{base_url}/es/militante"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Militant Page",
                    "Militant Page", url, "Server Error",
                    "Internal server error on militant page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Militant page test failed",
                "Militant Page", url, "Test Error",
                str(e)
            )

    def test_census_page(self, driver, base_url, test_user, issues_collector):
        """Test census page"""
        self.login(driver, base_url, test_user)

        url = f"{base_url}/es/censo"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Census Page",
                    "Census Page", url, "Server Error",
                    "Internal server error on census page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Census page test failed",
                "Census Page", url, "Test Error",
                str(e)
            )

    def test_collaboration_authenticated(self, driver, base_url, test_user, issues_collector):
        """Test collaboration page when authenticated"""
        self.login(driver, base_url, test_user)

        url = f"{base_url}/es/colabora"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Authenticated Collaboration",
                    "Collaboration Page", url, "Server Error",
                    "Internal server error on collaboration page when authenticated"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Authenticated collaboration test failed",
                "Collaboration Page", url, "Test Error",
                str(e)
            )

    def test_microcredit_authenticated(self, driver, base_url, test_user, issues_collector):
        """Test microcredit page when authenticated"""
        self.login(driver, base_url, test_user)

        url = f"{base_url}/es/microcreditos"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Authenticated Microcredit",
                    "Microcredit Page", url, "Server Error",
                    "Internal server error on microcredit page when authenticated"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Authenticated microcredit test failed",
                "Microcredit Page", url, "Test Error",
                str(e)
            )

    def test_impulsa_authenticated(self, driver, base_url, test_user, issues_collector):
        """Test impulsa page when authenticated"""
        self.login(driver, base_url, test_user)

        url = f"{base_url}/es/impulsa"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Authenticated Impulsa",
                    "Impulsa Page", url, "Server Error",
                    "Internal server error on impulsa page when authenticated"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Authenticated impulsa test failed",
                "Impulsa Page", url, "Test Error",
                str(e)
            )

    def test_user_verification_page(self, driver, base_url, test_user, issues_collector):
        """Test user verification/SMS verification page"""
        self.login(driver, base_url, test_user)

        url = f"{base_url}/es/verificacion"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Verification Page",
                    "Verification Page", url, "Server Error",
                    "Internal server error on verification page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Verification page test failed",
                "Verification Page", url, "Test Error",
                str(e)
            )

