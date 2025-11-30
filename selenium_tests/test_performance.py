"""
Performance Tests - Test page load times and performance issues
"""
import pytest
from selenium.webdriver.common.by import By
from conftest import report_issue
import time
import requests


class TestPerformance:
    """Test page performance metrics"""

    def test_page_load_time_home(self, driver, base_url, issues_collector):
        """Test home page load time"""
        url = f"{base_url}/es"

        try:
            start_time = time.time()
            driver.get(url)

            # Wait for page to be complete
            driver.execute_script("return document.readyState") == "complete"
            load_time = time.time() - start_time

            if load_time > 10:
                report_issue(
                    issues_collector, "HIGH", "Slow page load: Home",
                    "Performance", url, "Performance Issue",
                    f"Home page took {load_time:.2f} seconds to load"
                )
            elif load_time > 5:
                report_issue(
                    issues_collector, "MEDIUM", "Moderate page load time: Home",
                    "Performance", url, "Performance Issue",
                    f"Home page took {load_time:.2f} seconds to load"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Page load time test failed",
                "Performance", url, "Test Error",
                str(e)
            )

    def test_page_load_time_collaboration(self, driver, base_url, issues_collector):
        """Test collaboration page load time"""
        url = f"{base_url}/es/colabora"

        try:
            start_time = time.time()
            driver.get(url)
            driver.execute_script("return document.readyState") == "complete"
            load_time = time.time() - start_time

            if load_time > 10:
                report_issue(
                    issues_collector, "HIGH", "Slow page load: Collaboration",
                    "Performance", url, "Performance Issue",
                    f"Collaboration page took {load_time:.2f} seconds to load"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Collaboration load time test failed",
                "Performance", url, "Test Error",
                str(e)
            )

    def test_page_load_time_login(self, driver, base_url, issues_collector):
        """Test login page load time"""
        url = f"{base_url}/es/users/sign_in"

        try:
            start_time = time.time()
            driver.get(url)
            driver.execute_script("return document.readyState") == "complete"
            load_time = time.time() - start_time

            if load_time > 10:
                report_issue(
                    issues_collector, "HIGH", "Slow page load: Login",
                    "Performance", url, "Performance Issue",
                    f"Login page took {load_time:.2f} seconds to load"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Login load time test failed",
                "Performance", url, "Test Error",
                str(e)
            )

    def test_api_response_time(self, base_url, issues_collector):
        """Test API/AJAX endpoint response times"""
        endpoints = [
            "/health",
            "/es",
            "/es/colabora",
        ]

        for endpoint in endpoints:
            url = f"{base_url}{endpoint}"
            try:
                start_time = time.time()
                response = requests.get(url, timeout=30)
                response_time = time.time() - start_time

                if response_time > 5:
                    report_issue(
                        issues_collector, "HIGH", f"Slow response: {endpoint}",
                        "Performance", url, "Performance Issue",
                        f"Endpoint took {response_time:.2f} seconds"
                    )
                elif response_time > 2:
                    report_issue(
                        issues_collector, "MEDIUM", f"Moderate response time: {endpoint}",
                        "Performance", url, "Performance Issue",
                        f"Endpoint took {response_time:.2f} seconds"
                    )

            except requests.Timeout:
                report_issue(
                    issues_collector, "CRITICAL", f"Timeout: {endpoint}",
                    "Performance", url, "Performance Issue",
                    "Request timed out after 30 seconds"
                )
            except Exception as e:
                report_issue(
                    issues_collector, "MEDIUM", f"Response time test failed: {endpoint}",
                    "Performance", url, "Test Error",
                    str(e)
                )

    def test_asset_loading(self, driver, base_url, issues_collector):
        """Test that assets (CSS, JS) load correctly"""
        url = f"{base_url}/es"
        driver.get(url)
        time.sleep(3)

        try:
            # Check for CSS load failures
            css_links = driver.find_elements(By.CSS_SELECTOR, "link[rel='stylesheet']")
            for css in css_links:
                href = css.get_attribute("href")
                if href:
                    try:
                        response = requests.head(href, timeout=10)
                        if response.status_code >= 400:
                            report_issue(
                                issues_collector, "HIGH", "CSS file not loading",
                                "Performance", href, "Asset Error",
                                f"CSS file returns {response.status_code}"
                            )
                    except Exception:
                        pass

            # Check for JS load failures
            js_scripts = driver.find_elements(By.CSS_SELECTOR, "script[src]")
            for script in js_scripts:
                src = script.get_attribute("src")
                if src:
                    try:
                        response = requests.head(src, timeout=10)
                        if response.status_code >= 400:
                            report_issue(
                                issues_collector, "HIGH", "JavaScript file not loading",
                                "Performance", src, "Asset Error",
                                f"JS file returns {response.status_code}"
                            )
                    except Exception:
                        pass

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Asset loading test failed",
                "Performance", url, "Test Error",
                str(e)
            )

    def test_image_loading(self, driver, base_url, issues_collector):
        """Test that images load correctly"""
        url = f"{base_url}/es"
        driver.get(url)
        time.sleep(3)

        try:
            images = driver.find_elements(By.TAG_NAME, "img")

            broken_images = []
            for img in images:
                src = img.get_attribute("src")
                if src:
                    # Check if image is naturally loaded
                    natural_width = driver.execute_script("return arguments[0].naturalWidth", img)
                    if natural_width == 0:
                        broken_images.append(src)

            if broken_images:
                report_issue(
                    issues_collector, "MEDIUM", "Broken images on page",
                    "Performance", url, "Asset Error",
                    f"{len(broken_images)} broken images found"
                )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Image loading test failed",
                "Performance", url, "Test Error",
                str(e)
            )

    def test_console_errors(self, driver, base_url, issues_collector):
        """Check for JavaScript console errors"""
        url = f"{base_url}/es"
        driver.get(url)
        time.sleep(3)

        try:
            logs = driver.get_log("browser")
            severe_errors = [log for log in logs if log.get("level") == "SEVERE"]

            if severe_errors:
                error_messages = [log.get("message", "Unknown error") for log in severe_errors[:5]]
                report_issue(
                    issues_collector, "MEDIUM", "JavaScript console errors",
                    "Performance", url, "JavaScript Error",
                    f"Console errors: {'; '.join(error_messages)}"
                )

        except Exception as e:
            # Browser logs might not be available in all configurations
            pass

    def test_large_dom_size(self, driver, base_url, issues_collector):
        """Test for excessively large DOM"""
        url = f"{base_url}/es"
        driver.get(url)
        time.sleep(2)

        try:
            dom_element_count = driver.execute_script("return document.getElementsByTagName('*').length")

            if dom_element_count > 3000:
                report_issue(
                    issues_collector, "MEDIUM", "Large DOM size",
                    "Performance", url, "Performance Issue",
                    f"DOM has {dom_element_count} elements (recommended < 1500)"
                )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "DOM size test failed",
                "Performance", url, "Test Error",
                str(e)
            )

    def test_lazy_loading(self, driver, base_url, issues_collector):
        """Check if images use lazy loading"""
        url = f"{base_url}/es"
        driver.get(url)
        time.sleep(2)

        try:
            images = driver.find_elements(By.TAG_NAME, "img")

            if len(images) > 10:
                lazy_images = [img for img in images if img.get_attribute("loading") == "lazy"]

                if len(lazy_images) == 0:
                    report_issue(
                        issues_collector, "LOW", "No lazy-loaded images",
                        "Performance", url, "Performance Issue",
                        f"Page has {len(images)} images but none use lazy loading"
                    )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Lazy loading test failed",
                "Performance", url, "Test Error",
                str(e)
            )

    def test_gzip_compression(self, base_url, issues_collector):
        """Test if server uses gzip compression"""
        url = f"{base_url}/es"

        try:
            headers = {"Accept-Encoding": "gzip, deflate"}
            response = requests.get(url, headers=headers, timeout=10)

            content_encoding = response.headers.get("Content-Encoding", "")

            if "gzip" not in content_encoding and "deflate" not in content_encoding:
                report_issue(
                    issues_collector, "LOW", "No compression",
                    "Performance", url, "Performance Issue",
                    "Server does not use gzip/deflate compression"
                )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Compression test failed",
                "Performance", url, "Test Error",
                str(e)
            )

    def test_cache_headers(self, base_url, issues_collector):
        """Test if static assets have cache headers"""
        url = f"{base_url}/es"

        try:
            response = requests.get(url, timeout=10)
            cache_control = response.headers.get("Cache-Control", "")

            # This is informational - not necessarily an issue
            if "no-cache" in cache_control or "no-store" in cache_control:
                pass  # Expected for HTML pages

        except Exception as e:
            pass  # Cache headers test is informational

