"""
Authentication Tests - Login, Logout, Registration, Password Recovery
"""
import pytest
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException
from conftest import report_issue
import time


class TestAuthentication:
    """Test authentication flows"""

    def test_login_page_loads(self, driver, base_url, issues_collector):
        """Test that login page loads correctly"""
        url = f"{base_url}/es"
        driver.get(url)
        time.sleep(2)

        try:
            # Check page title
            assert "error" not in driver.title.lower(), "Error page displayed"

            # Check for login form
            email_field = driver.find_elements(By.ID, "user_email")
            password_field = driver.find_elements(By.ID, "user_password")

            if not email_field:
                report_issue(
                    issues_collector, "HIGH", "Login form email field missing",
                    "Login Page", url, "Missing Element",
                    "Email input field not found on login page"
                )

            if not password_field:
                report_issue(
                    issues_collector, "HIGH", "Login form password field missing",
                    "Login Page", url, "Missing Element",
                    "Password input field not found on login page"
                )

            # Check for 500 errors
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "CRITICAL", "500 Error on Login Page",
                    "Login Page", url, "Server Error",
                    "Internal server error displayed on login page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "CRITICAL", "Login page failed to load",
                "Login Page", url, "Page Load Error",
                str(e)
            )

    def test_login_with_valid_credentials(self, driver, base_url, test_user, issues_collector):
        """Test login with valid credentials"""
        url = f"{base_url}/es/users/sign_in"
        driver.get(url)
        time.sleep(2)

        try:
            # Find and fill email
            email_field = WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.ID, "user_email"))
            )
            email_field.clear()
            email_field.send_keys(test_user["email"])

            # Find and fill password
            password_field = driver.find_element(By.ID, "user_password")
            password_field.clear()
            password_field.send_keys(test_user["password"])

            # Submit form
            submit_button = driver.find_element(By.NAME, "commit")
            submit_button.click()
            time.sleep(3)

            # Check if login was successful
            current_url = driver.current_url

            # Check for error messages
            error_messages = driver.find_elements(By.CSS_SELECTOR, ".alert-danger, .alert-error, .error")
            if error_messages:
                for error in error_messages:
                    if error.is_displayed():
                        report_issue(
                            issues_collector, "HIGH", "Login failed with valid credentials",
                            "Login Page", url, "Authentication Error",
                            f"Login failed: {error.text}"
                        )

            # Check for 500 error
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "CRITICAL", "500 Error after login attempt",
                    "Login Page", url, "Server Error",
                    "Internal server error after login attempt"
                )

        except TimeoutException:
            report_issue(
                issues_collector, "HIGH", "Login form elements not found",
                "Login Page", url, "Missing Element",
                "Could not find login form elements within timeout"
            )
        except Exception as e:
            report_issue(
                issues_collector, "HIGH", "Login test failed",
                "Login Page", url, "Test Error",
                str(e)
            )

    def test_login_with_invalid_credentials(self, driver, base_url, issues_collector):
        """Test login with invalid credentials shows appropriate error"""
        url = f"{base_url}/es/users/sign_in"
        driver.get(url)
        time.sleep(2)

        try:
            email_field = WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.ID, "user_email"))
            )
            email_field.clear()
            email_field.send_keys("invalid@example.com")

            password_field = driver.find_element(By.ID, "user_password")
            password_field.clear()
            password_field.send_keys("wrongpassword")

            submit_button = driver.find_element(By.NAME, "commit")
            submit_button.click()
            time.sleep(3)

            # Should show error message, not 500 error
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "CRITICAL", "500 Error on invalid login",
                    "Login Page", url, "Server Error",
                    "Server error instead of friendly error message for invalid login"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Invalid login test failed",
                "Login Page", url, "Test Error",
                str(e)
            )

    def test_registration_page_loads(self, driver, base_url, issues_collector):
        """Test that registration page loads correctly"""
        url = f"{base_url}/es/users/sign_up"
        driver.get(url)
        time.sleep(2)

        try:
            # Check for 500 error
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "CRITICAL", "500 Error on Registration Page",
                    "Registration Page", url, "Server Error",
                    "Internal server error on registration page"
                )
                return

            # Check for registration form elements
            required_fields = ["user_email", "user_password", "user_first_name", "user_last_name"]
            for field_id in required_fields:
                field = driver.find_elements(By.ID, field_id)
                if not field:
                    report_issue(
                        issues_collector, "HIGH", f"Registration field missing: {field_id}",
                        "Registration Page", url, "Missing Element",
                        f"Field {field_id} not found on registration page"
                    )

        except Exception as e:
            report_issue(
                issues_collector, "HIGH", "Registration page test failed",
                "Registration Page", url, "Test Error",
                str(e)
            )

    def test_password_recovery_page_loads(self, driver, base_url, issues_collector):
        """Test that password recovery page loads correctly"""
        url = f"{base_url}/es/users/password/new"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "CRITICAL", "500 Error on Password Recovery Page",
                    "Password Recovery Page", url, "Server Error",
                    "Internal server error on password recovery page"
                )
                return

            # Check for email field
            email_field = driver.find_elements(By.ID, "user_email")
            if not email_field:
                report_issue(
                    issues_collector, "HIGH", "Email field missing on password recovery",
                    "Password Recovery Page", url, "Missing Element",
                    "Email input field not found"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Password recovery page test failed",
                "Password Recovery Page", url, "Test Error",
                str(e)
            )

    def test_logout_functionality(self, driver, base_url, test_user, issues_collector):
        """Test logout functionality after login"""
        # First login
        url = f"{base_url}/es/users/sign_in"
        driver.get(url)
        time.sleep(2)

        try:
            email_field = WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.ID, "user_email"))
            )
            email_field.clear()
            email_field.send_keys(test_user["email"])

            password_field = driver.find_element(By.ID, "user_password")
            password_field.clear()
            password_field.send_keys(test_user["password"])

            submit_button = driver.find_element(By.NAME, "commit")
            submit_button.click()
            time.sleep(3)

            # Try to find logout link
            logout_link = driver.find_elements(By.CSS_SELECTOR, "a[href*='sign_out']")
            if not logout_link:
                report_issue(
                    issues_collector, "MEDIUM", "Logout link not found",
                    "Dashboard", driver.current_url, "Missing Element",
                    "Could not find logout link after successful login"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Logout test failed",
                "Dashboard", driver.current_url, "Test Error",
                str(e)
            )
