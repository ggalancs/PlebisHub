"""
Edge Cases Tests - Test unusual inputs and error scenarios
"""
import pytest
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from conftest import report_issue
import time


class TestEdgeCases:
    """Test edge cases and unusual scenarios"""

    def test_empty_parameters(self, driver, base_url, issues_collector):
        """Test pages with empty/missing parameters"""
        urls_with_params = [
            f"{base_url}/es/microcreditos/",
            f"{base_url}/es/votos//",
            f"{base_url}/es/propuestas/",
        ]

        for url in urls_with_params:
            driver.get(url)
            time.sleep(2)

            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 on empty parameter",
                    "Edge Cases", url, "Server Error",
                    f"Server error when accessing URL with empty parameter"
                )

    def test_nonexistent_ids(self, driver, base_url, issues_collector):
        """Test accessing resources with non-existent IDs"""
        urls = [
            f"{base_url}/es/microcreditos/999999999",
            f"{base_url}/es/propuestas/999999999",
            f"{base_url}/es/votos/999999999",
        ]

        for url in urls:
            driver.get(url)
            time.sleep(2)

            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 on non-existent ID",
                    "Edge Cases", url, "Server Error",
                    "Server error instead of 404 for non-existent resource"
                )

    def test_invalid_id_formats(self, driver, base_url, issues_collector):
        """Test accessing resources with invalid ID formats"""
        invalid_ids = ["abc", "-1", "1.5", "null", "undefined", "' OR 1=1 --"]

        for invalid_id in invalid_ids:
            url = f"{base_url}/es/microcreditos/{invalid_id}"
            driver.get(url)
            time.sleep(2)

            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                page_source = driver.page_source.lower()
                # Check if database errors are exposed
                if "activerecord" in page_source or "postgresql" in page_source:
                    report_issue(
                        issues_collector, "CRITICAL", "Database error exposed",
                        "Edge Cases", url, "Security Issue",
                        f"Database error exposed with invalid ID: {invalid_id}"
                    )
                else:
                    report_issue(
                        issues_collector, "MEDIUM", "500 on invalid ID format",
                        "Edge Cases", url, "Server Error",
                        f"Server error with invalid ID format: {invalid_id}"
                    )

    def test_very_long_urls(self, driver, base_url, issues_collector):
        """Test handling of very long URLs"""
        long_path = "a" * 5000
        url = f"{base_url}/es/{long_path}"

        try:
            driver.get(url)
            time.sleep(2)

            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "MEDIUM", "500 on very long URL",
                    "Edge Cases", url[:100] + "...", "Server Error",
                    "Server error on URL with 5000+ characters"
                )

        except Exception as e:
            # Very long URLs might cause browser/network issues
            pass

    def test_special_characters_in_url(self, driver, base_url, issues_collector):
        """Test special characters in URL paths"""
        special_paths = [
            "test<script>alert('xss')</script>",
            "test%00null",
            "test/../../../etc/passwd",
            "test%2F..%2F..%2Fetc%2Fpasswd",
        ]

        for path in special_paths:
            url = f"{base_url}/es/{path}"

            try:
                driver.get(url)
                time.sleep(2)

                if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                    report_issue(
                        issues_collector, "MEDIUM", "500 on special characters in URL",
                        "Edge Cases", url, "Server Error",
                        f"Server error with special characters: {path[:50]}"
                    )

                # Check for path traversal
                page_source = driver.page_source.lower()
                if "root:" in page_source or "/etc/passwd" in page_source:
                    report_issue(
                        issues_collector, "CRITICAL", "Path traversal vulnerability",
                        "Edge Cases", url, "Security Issue",
                        "Path traversal attack successful"
                    )

            except Exception:
                pass

    def test_unicode_in_forms(self, driver, base_url, issues_collector):
        """Test Unicode characters in form inputs"""
        url = f"{base_url}/es/users/sign_in"
        driver.get(url)
        time.sleep(2)

        unicode_tests = [
            ("Japanese", "テスト@example.com"),
            ("Arabic", "اختبار@example.com"),
            ("Emoji", "test😀@example.com"),
            ("RTL", "מבחן@example.com"),
        ]

        try:
            for test_name, email in unicode_tests:
                email_field = driver.find_element(By.ID, "user_email")
                email_field.clear()
                email_field.send_keys(email)

                password_field = driver.find_element(By.ID, "user_password")
                password_field.clear()
                password_field.send_keys("testpassword")

                submit_button = driver.find_element(By.NAME, "commit")
                submit_button.click()
                time.sleep(2)

                if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                    report_issue(
                        issues_collector, "MEDIUM", f"500 on {test_name} Unicode",
                        "Edge Cases", url, "Server Error",
                        f"Server error when using {test_name} characters in form"
                    )

                # Go back to login page for next test
                driver.get(url)
                time.sleep(1)

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Unicode form test failed",
                "Edge Cases", url, "Test Error",
                str(e)
            )

    def test_concurrent_form_submissions(self, driver, base_url, issues_collector):
        """Test rapid consecutive form submissions"""
        url = f"{base_url}/es/users/sign_in"
        driver.get(url)
        time.sleep(2)

        try:
            email_field = driver.find_element(By.ID, "user_email")
            email_field.send_keys("test@example.com")

            password_field = driver.find_element(By.ID, "user_password")
            password_field.send_keys("wrongpassword")

            submit_button = driver.find_element(By.NAME, "commit")

            # Rapid clicks
            for _ in range(5):
                try:
                    submit_button.click()
                except Exception:
                    pass

            time.sleep(3)

            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "MEDIUM", "500 on rapid form submission",
                    "Edge Cases", url, "Server Error",
                    "Server error on rapid consecutive form submissions"
                )

        except Exception as e:
            pass  # Rapid clicking might cause expected errors

    def test_session_timeout_behavior(self, driver, base_url, test_user, issues_collector):
        """Test behavior when session expires"""
        # Login first
        login_url = f"{base_url}/es/users/sign_in"
        driver.get(login_url)
        time.sleep(2)

        try:
            email_field = WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.ID, "user_email"))
            )
            email_field.send_keys(test_user["email"])

            password_field = driver.find_element(By.ID, "user_password")
            password_field.send_keys(test_user["password"])

            submit_button = driver.find_element(By.NAME, "commit")
            submit_button.click()
            time.sleep(3)

            # Clear cookies to simulate session expiry
            driver.delete_all_cookies()

            # Try to access protected page
            protected_url = f"{base_url}/es/users/edit"
            driver.get(protected_url)
            time.sleep(2)

            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 on expired session",
                    "Edge Cases", protected_url, "Server Error",
                    "Server error instead of redirect on expired session"
                )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Session timeout test failed",
                "Edge Cases", base_url, "Test Error",
                str(e)
            )

    def test_direct_action_urls(self, driver, base_url, issues_collector):
        """Test direct access to action URLs"""
        action_urls = [
            f"{base_url}/es/users/sign_out",
            f"{base_url}/users/confirmation",
            f"{base_url}/users/unlock",
        ]

        for url in action_urls:
            driver.get(url)
            time.sleep(2)

            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "MEDIUM", "500 on direct action URL",
                    "Edge Cases", url, "Server Error",
                    "Server error when accessing action URL directly"
                )

    def test_double_encoding(self, driver, base_url, issues_collector):
        """Test double URL encoding handling"""
        # Double encoded ../ = %252e%252e%252f
        encoded_paths = [
            "%252e%252e%252f",
            "%2525252e%2525252e%2525252f",
        ]

        for path in encoded_paths:
            url = f"{base_url}/es/{path}"

            try:
                driver.get(url)
                time.sleep(2)

                if "500" in driver.page_source:
                    report_issue(
                        issues_collector, "MEDIUM", "500 on double-encoded URL",
                        "Edge Cases", url, "Server Error",
                        "Server error on double URL encoding"
                    )

            except Exception:
                pass

    def test_null_byte_injection(self, driver, base_url, issues_collector):
        """Test null byte injection handling"""
        url = f"{base_url}/es/test%00.html"

        try:
            driver.get(url)
            time.sleep(2)

            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "MEDIUM", "500 on null byte in URL",
                    "Edge Cases", url, "Server Error",
                    "Server error with null byte in URL"
                )

        except Exception:
            pass

    def test_http_method_override(self, driver, base_url, issues_collector):
        """Test HTTP method override handling via _method parameter"""
        # This is more of an API test but can be done via form
        url = f"{base_url}/es/users/sign_in"
        driver.get(url)
        time.sleep(2)

        try:
            # Try to inject _method parameter
            email_field = driver.find_element(By.ID, "user_email")
            email_field.send_keys("test@example.com")

            # Execute JavaScript to add hidden _method field
            driver.execute_script("""
                var form = document.querySelector('form');
                if (form) {
                    var input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = '_method';
                    input.value = 'DELETE';
                    form.appendChild(input);
                }
            """)

            submit_button = driver.find_element(By.NAME, "commit")
            submit_button.click()
            time.sleep(2)

            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "MEDIUM", "500 on method override injection",
                    "Edge Cases", url, "Server Error",
                    "Server error when _method parameter is injected"
                )

        except Exception as e:
            pass

    def test_missing_required_cookies(self, driver, base_url, issues_collector):
        """Test behavior without cookies"""
        url = f"{base_url}/es"

        # Delete all cookies
        driver.delete_all_cookies()

        try:
            driver.get(url)
            time.sleep(2)

            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 without cookies",
                    "Edge Cases", url, "Server Error",
                    "Server error when cookies are disabled/missing"
                )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Cookie test failed",
                "Edge Cases", url, "Test Error",
                str(e)
            )

