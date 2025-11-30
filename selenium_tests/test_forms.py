"""
Form Tests - Test form submissions and validations
"""
import pytest
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import Select
from conftest import report_issue
import time
import random
import string


class TestForms:
    """Test form submissions and validations"""

    def generate_random_email(self):
        """Generate a random email for testing"""
        random_str = ''.join(random.choices(string.ascii_lowercase + string.digits, k=10))
        return f"test_{random_str}@example.com"

    def test_registration_form_validation(self, driver, base_url, issues_collector):
        """Test registration form validation errors"""
        url = f"{base_url}/es/users/sign_up"
        driver.get(url)
        time.sleep(2)

        try:
            # Try to submit empty form
            submit_button = driver.find_elements(By.NAME, "commit")
            if submit_button:
                submit_button[0].click()
                time.sleep(2)

                # Check for validation errors (not 500)
                if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                    report_issue(
                        issues_collector, "HIGH", "500 Error on empty registration form",
                        "Registration Form", url, "Validation Error",
                        "Server error instead of validation message for empty form"
                    )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Registration validation test failed",
                "Registration Form", url, "Test Error",
                str(e)
            )

    def test_registration_form_submission(self, driver, base_url, issues_collector):
        """Test registration form with valid data"""
        url = f"{base_url}/es/users/sign_up"
        driver.get(url)
        time.sleep(2)

        try:
            # Fill in required fields
            fields_to_fill = {
                "user_email": self.generate_random_email(),
                "user_password": "TestPassword123!",
                "user_password_confirmation": "TestPassword123!",
                "user_first_name": "Test",
                "user_last_name": "User",
            }

            for field_id, value in fields_to_fill.items():
                field = driver.find_elements(By.ID, field_id)
                if field:
                    field[0].clear()
                    field[0].send_keys(value)

            # Try to find document fields
            doc_type = driver.find_elements(By.ID, "user_document_type")
            if doc_type:
                try:
                    select = Select(doc_type[0])
                    select.select_by_index(1)
                except Exception:
                    pass

            doc_vatid = driver.find_elements(By.ID, "user_document_vatid")
            if doc_vatid:
                doc_vatid[0].clear()
                doc_vatid[0].send_keys("X1234567L")

            # Submit form
            submit_button = driver.find_elements(By.NAME, "commit")
            if submit_button:
                submit_button[0].click()
                time.sleep(3)

                if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                    report_issue(
                        issues_collector, "CRITICAL", "500 Error on registration submission",
                        "Registration Form", url, "Server Error",
                        "Internal server error on registration form submission"
                    )

        except Exception as e:
            report_issue(
                issues_collector, "HIGH", "Registration submission test failed",
                "Registration Form", url, "Test Error",
                str(e)
            )

    def test_login_form_validation(self, driver, base_url, issues_collector):
        """Test login form validation"""
        url = f"{base_url}/es/users/sign_in"
        driver.get(url)
        time.sleep(2)

        try:
            # Submit empty form
            submit_button = driver.find_elements(By.NAME, "commit")
            if submit_button:
                submit_button[0].click()
                time.sleep(2)

                if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                    report_issue(
                        issues_collector, "HIGH", "500 Error on empty login form",
                        "Login Form", url, "Validation Error",
                        "Server error instead of validation message for empty login"
                    )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Login validation test failed",
                "Login Form", url, "Test Error",
                str(e)
            )

    def test_password_recovery_form(self, driver, base_url, issues_collector):
        """Test password recovery form submission"""
        url = f"{base_url}/es/users/password/new"
        driver.get(url)
        time.sleep(2)

        try:
            email_field = driver.find_elements(By.ID, "user_email")
            if email_field:
                email_field[0].clear()
                email_field[0].send_keys("test@example.com")

                submit_button = driver.find_elements(By.NAME, "commit")
                if submit_button:
                    submit_button[0].click()
                    time.sleep(3)

                    if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                        report_issue(
                            issues_collector, "HIGH", "500 Error on password recovery",
                            "Password Recovery", url, "Server Error",
                            "Internal server error on password recovery form"
                        )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Password recovery test failed",
                "Password Recovery", url, "Test Error",
                str(e)
            )

    def test_collaboration_form_loads(self, driver, base_url, issues_collector):
        """Test collaboration form loads properly"""
        url = f"{base_url}/es/colabora"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on collaboration form",
                    "Collaboration Form", url, "Server Error",
                    "Internal server error on collaboration form page"
                )
                return

            # Check for form elements
            form = driver.find_elements(By.TAG_NAME, "form")
            if not form:
                report_issue(
                    issues_collector, "HIGH", "No form on collaboration page",
                    "Collaboration Form", url, "Missing Element",
                    "Could not find form on collaboration page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Collaboration form test failed",
                "Collaboration Form", url, "Test Error",
                str(e)
            )

    def test_single_collaboration_form(self, driver, base_url, issues_collector):
        """Test single collaboration form"""
        url = f"{base_url}/es/colabora/puntual"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on single collaboration form",
                    "Single Collaboration Form", url, "Server Error",
                    "Internal server error on single collaboration form"
                )
                return

            # Check for amount selection
            amount_inputs = driver.find_elements(By.CSS_SELECTOR, "input[name*='amount'], input[type='radio'][name*='collaboration']")
            if not amount_inputs:
                report_issue(
                    issues_collector, "MEDIUM", "No amount selection on single collaboration",
                    "Single Collaboration Form", url, "Missing Element",
                    "Could not find amount selection options"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Single collaboration form test failed",
                "Single Collaboration Form", url, "Test Error",
                str(e)
            )

    def test_microcredit_form_loads(self, driver, base_url, issues_collector):
        """Test microcredit form loads properly"""
        # First check if there are active microcredits
        url = f"{base_url}/es/microcreditos"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on microcredit page",
                    "Microcredit Form", url, "Server Error",
                    "Internal server error on microcredit page"
                )
                return

            # Look for form or "no active campaigns" message
            forms = driver.find_elements(By.TAG_NAME, "form")
            no_campaigns = "no hay" in driver.page_source.lower() or "no active" in driver.page_source.lower()

            if not forms and not no_campaigns:
                report_issue(
                    issues_collector, "MEDIUM", "Microcredit page missing content",
                    "Microcredit Form", url, "Content Issue",
                    "Neither form nor 'no campaigns' message found"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Microcredit form test failed",
                "Microcredit Form", url, "Test Error",
                str(e)
            )

    def test_contact_form_if_exists(self, driver, base_url, issues_collector):
        """Test contact form if it exists"""
        url = f"{base_url}/es/contacto"
        driver.get(url)
        time.sleep(2)

        try:
            # 404 is acceptable if page doesn't exist
            if "404" in driver.page_source or "not found" in driver.page_source.lower():
                return  # Page doesn't exist, that's OK

            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on contact page",
                    "Contact Form", url, "Server Error",
                    "Internal server error on contact page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Contact form test failed",
                "Contact Form", url, "Test Error",
                str(e)
            )

    def test_profile_update_form(self, driver, base_url, test_user, issues_collector):
        """Test profile update form"""
        # Login first
        login_url = f"{base_url}/es/users/sign_in"
        driver.get(login_url)
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

            # Go to profile edit
            url = f"{base_url}/es/users/edit"
            driver.get(url)
            time.sleep(2)

            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on profile edit page",
                    "Profile Update Form", url, "Server Error",
                    "Internal server error on profile edit page"
                )
                return

            # Check for form
            form = driver.find_elements(By.TAG_NAME, "form")
            if not form:
                report_issue(
                    issues_collector, "HIGH", "No form on profile edit page",
                    "Profile Update Form", url, "Missing Element",
                    "Could not find form on profile edit page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Profile update form test failed",
                "Profile Update Form", f"{base_url}/es/users/edit", "Test Error",
                str(e)
            )

    def test_xss_in_forms(self, driver, base_url, issues_collector):
        """Test for XSS vulnerabilities in forms"""
        url = f"{base_url}/es/users/sign_in"
        driver.get(url)
        time.sleep(2)

        xss_payload = "<script>alert('XSS')</script>"

        try:
            email_field = driver.find_elements(By.ID, "user_email")
            if email_field:
                email_field[0].clear()
                email_field[0].send_keys(xss_payload)

                password_field = driver.find_element(By.ID, "user_password")
                password_field.clear()
                password_field.send_keys("test")

                submit_button = driver.find_element(By.NAME, "commit")
                submit_button.click()
                time.sleep(2)

                # Check if script tag is rendered as-is (XSS vulnerability)
                if "<script>alert('XSS')</script>" in driver.page_source:
                    report_issue(
                        issues_collector, "CRITICAL", "Potential XSS vulnerability",
                        "Login Form", url, "Security Issue",
                        "Script tag not properly escaped in form input"
                    )

                if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                    report_issue(
                        issues_collector, "MEDIUM", "500 Error on XSS test input",
                        "Login Form", url, "Server Error",
                        "Server error when processing special characters in form"
                    )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "XSS test failed",
                "Login Form", url, "Test Error",
                str(e)
            )

    def test_sql_injection_protection(self, driver, base_url, issues_collector):
        """Test for SQL injection protection"""
        url = f"{base_url}/es/users/sign_in"
        driver.get(url)
        time.sleep(2)

        sql_payload = "' OR '1'='1"

        try:
            email_field = driver.find_elements(By.ID, "user_email")
            if email_field:
                email_field[0].clear()
                email_field[0].send_keys(sql_payload)

                password_field = driver.find_element(By.ID, "user_password")
                password_field.clear()
                password_field.send_keys(sql_payload)

                submit_button = driver.find_element(By.NAME, "commit")
                submit_button.click()
                time.sleep(2)

                # Check for database errors (SQL injection might cause these)
                page_source = driver.page_source.lower()
                sql_errors = ["sql", "syntax error", "postgresql", "pg::", "activerecord"]
                for error in sql_errors:
                    if error in page_source:
                        report_issue(
                            issues_collector, "CRITICAL", "Potential SQL injection vulnerability",
                            "Login Form", url, "Security Issue",
                            f"Database error exposed: '{error}' found in response"
                        )
                        break

                if "500" in driver.page_source and any(e in page_source for e in sql_errors):
                    report_issue(
                        issues_collector, "HIGH", "SQL error exposed on injection attempt",
                        "Login Form", url, "Security Issue",
                        "Server error with database info on SQL injection attempt"
                    )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "SQL injection test failed",
                "Login Form", url, "Test Error",
                str(e)
            )

