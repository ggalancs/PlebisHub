"""
API Endpoint Tests - Test API responses and error handling
"""
import pytest
import requests
from conftest import report_issue
import json


class TestAPIEndpoints:
    """Test API endpoints"""

    def test_health_endpoint(self, base_url, issues_collector):
        """Test health check endpoint"""
        url = f"{base_url}/health"

        try:
            response = requests.get(url, timeout=10)

            if response.status_code != 200:
                report_issue(
                    issues_collector, "CRITICAL", "Health endpoint failing",
                    "API", url, "Server Error",
                    f"Health endpoint returns {response.status_code}"
                )

        except requests.Timeout:
            report_issue(
                issues_collector, "CRITICAL", "Health endpoint timeout",
                "API", url, "Server Error",
                "Health endpoint timed out"
            )
        except Exception as e:
            report_issue(
                issues_collector, "CRITICAL", "Health endpoint unreachable",
                "API", url, "Server Error",
                str(e)
            )

    def test_json_api_responses(self, base_url, issues_collector):
        """Test JSON API endpoints if they exist"""
        json_endpoints = [
            "/api/v1/status",
            "/api/status",
            "/status.json",
        ]

        for endpoint in json_endpoints:
            url = f"{base_url}{endpoint}"
            try:
                response = requests.get(url, timeout=10, headers={"Accept": "application/json"})

                if response.status_code == 200:
                    try:
                        response.json()
                    except json.JSONDecodeError:
                        report_issue(
                            issues_collector, "MEDIUM", f"Invalid JSON response: {endpoint}",
                            "API", url, "Response Error",
                            "Endpoint returns 200 but body is not valid JSON"
                        )

                elif response.status_code >= 500:
                    report_issue(
                        issues_collector, "HIGH", f"API Server Error: {endpoint}",
                        "API", url, "Server Error",
                        f"Endpoint returns {response.status_code}"
                    )

            except requests.Timeout:
                report_issue(
                    issues_collector, "MEDIUM", f"API Timeout: {endpoint}",
                    "API", url, "Timeout",
                    "API request timed out"
                )
            except Exception:
                pass  # Endpoint might not exist

    def test_cors_headers(self, base_url, issues_collector):
        """Test CORS headers on API endpoints"""
        url = f"{base_url}/health"

        try:
            response = requests.options(url, timeout=10, headers={
                "Origin": "http://example.com",
                "Access-Control-Request-Method": "GET"
            })

            # Note: CORS might be intentionally restrictive
            # This is informational, not necessarily an issue

        except Exception:
            pass

    def test_error_response_format(self, base_url, issues_collector):
        """Test that error responses are properly formatted"""
        # Test 404 response
        url = f"{base_url}/api/nonexistent/endpoint/12345"

        try:
            response = requests.get(url, timeout=10, headers={"Accept": "application/json"})

            if response.status_code >= 500:
                report_issue(
                    issues_collector, "HIGH", "API returns 500 for missing endpoint",
                    "API", url, "Server Error",
                    "Missing API endpoint causes server error instead of 404"
                )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Error response test failed",
                "API", url, "Test Error",
                str(e)
            )

    def test_authentication_api(self, base_url, issues_collector):
        """Test authentication API endpoints"""
        url = f"{base_url}/users/sign_in"

        try:
            # Test with JSON content type
            response = requests.post(url, json={
                "user": {
                    "email": "test@example.com",
                    "password": "wrongpassword"
                }
            }, timeout=10, headers={
                "Content-Type": "application/json",
                "Accept": "application/json"
            })

            if response.status_code >= 500:
                report_issue(
                    issues_collector, "HIGH", "Auth API server error",
                    "API", url, "Server Error",
                    f"Authentication endpoint returns {response.status_code}"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Auth API test failed",
                "API", url, "Test Error",
                str(e)
            )

    def test_content_type_headers(self, base_url, issues_collector):
        """Test that responses have proper content-type headers"""
        endpoints = [
            ("/es", "text/html"),
            ("/health", None),  # Could be JSON or text
        ]

        for endpoint, expected_type in endpoints:
            url = f"{base_url}{endpoint}"
            try:
                response = requests.get(url, timeout=10)
                content_type = response.headers.get("Content-Type", "")

                if expected_type and expected_type not in content_type:
                    report_issue(
                        issues_collector, "LOW", f"Unexpected content type: {endpoint}",
                        "API", url, "Response Error",
                        f"Expected {expected_type}, got {content_type}"
                    )

            except Exception:
                pass

    def test_method_not_allowed(self, base_url, issues_collector):
        """Test that invalid HTTP methods return proper error"""
        url = f"{base_url}/es"

        try:
            response = requests.delete(url, timeout=10)

            if response.status_code >= 500:
                report_issue(
                    issues_collector, "MEDIUM", "DELETE method causes server error",
                    "API", url, "Server Error",
                    f"DELETE on page returns {response.status_code} instead of 405"
                )

        except Exception:
            pass

    def test_large_request_handling(self, base_url, issues_collector):
        """Test handling of large requests"""
        url = f"{base_url}/es/users/sign_in"

        try:
            # Send a large payload
            large_payload = {"email": "a" * 10000, "password": "b" * 10000}

            response = requests.post(url, data=large_payload, timeout=30)

            if response.status_code >= 500:
                report_issue(
                    issues_collector, "MEDIUM", "Server error on large request",
                    "API", url, "Server Error",
                    f"Large payload causes {response.status_code} error"
                )

        except requests.Timeout:
            report_issue(
                issues_collector, "MEDIUM", "Timeout on large request",
                "API", url, "Performance Issue",
                "Server times out when processing large request"
            )
        except Exception:
            pass

    def test_special_characters_handling(self, base_url, issues_collector):
        """Test handling of special characters in requests"""
        special_chars = [
            ("unicode", "test@例え.com"),
            ("sql", "'; DROP TABLE users; --"),
            ("html", "<script>alert('xss')</script>"),
            ("null", "\x00\x00"),
        ]

        url = f"{base_url}/es/users/sign_in"

        for char_type, test_value in special_chars:
            try:
                response = requests.post(url, data={
                    "user[email]": test_value,
                    "user[password]": "test"
                }, timeout=10)

                if response.status_code >= 500:
                    report_issue(
                        issues_collector, "HIGH", f"Server error on {char_type} characters",
                        "API", url, "Server Error",
                        f"Special characters ({char_type}) cause {response.status_code} error"
                    )

            except Exception:
                pass

    def test_rate_limiting(self, base_url, issues_collector):
        """Test if rate limiting is in place"""
        url = f"{base_url}/es/users/sign_in"

        try:
            # Make multiple rapid requests
            for i in range(20):
                response = requests.post(url, data={
                    "user[email]": "test@example.com",
                    "user[password]": "wrongpassword"
                }, timeout=5)

                if response.status_code == 429:
                    # Rate limiting is working
                    return

                if response.status_code >= 500:
                    report_issue(
                        issues_collector, "HIGH", "Server error under rapid requests",
                        "API", url, "Server Error",
                        f"Server returns {response.status_code} after {i+1} rapid requests"
                    )
                    return

            # Note: Lack of rate limiting is informational
            # Some applications may not need it depending on context

        except Exception:
            pass

    def test_csrf_token_presence(self, driver, base_url, issues_collector):
        """Test that forms have CSRF tokens"""
        from selenium.webdriver.common.by import By

        url = f"{base_url}/es/users/sign_in"
        driver.get(url)

        try:
            csrf_token = driver.find_elements(By.CSS_SELECTOR, "input[name='authenticity_token'], meta[name='csrf-token']")

            if not csrf_token:
                report_issue(
                    issues_collector, "HIGH", "Missing CSRF token",
                    "Security", url, "Security Issue",
                    "Form is missing CSRF protection token"
                )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "CSRF token test failed",
                "Security", url, "Test Error",
                str(e)
            )

