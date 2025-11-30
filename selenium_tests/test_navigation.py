"""
Navigation Tests - Test site navigation and links
"""
import pytest
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from conftest import report_issue
import time
import requests


class TestNavigation:
    """Test navigation and links throughout the site"""

    def test_main_navigation_links(self, driver, base_url, issues_collector):
        """Test main navigation links work"""
        url = f"{base_url}/es"
        driver.get(url)
        time.sleep(2)

        try:
            # Find all navigation links
            nav_links = driver.find_elements(By.CSS_SELECTOR, "nav a, .navbar a, .nav a, header a")

            broken_links = []
            for link in nav_links[:20]:  # Test first 20 links
                href = link.get_attribute("href")
                if href and href.startswith(("http", "/")):
                    try:
                        if href.startswith("/"):
                            href = f"{base_url}{href}"
                        response = requests.head(href, timeout=10, allow_redirects=True)
                        if response.status_code >= 400:
                            broken_links.append((href, response.status_code))
                    except requests.RequestException:
                        pass

            if broken_links:
                for href, status in broken_links:
                    report_issue(
                        issues_collector, "MEDIUM", f"Broken navigation link: {status}",
                        "Main Navigation", href, "Broken Link",
                        f"Navigation link returns {status}"
                    )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Navigation links test failed",
                "Main Navigation", url, "Test Error",
                str(e)
            )

    def test_footer_links(self, driver, base_url, issues_collector):
        """Test footer links work"""
        url = f"{base_url}/es"
        driver.get(url)
        time.sleep(2)

        try:
            footer_links = driver.find_elements(By.CSS_SELECTOR, "footer a")

            broken_links = []
            for link in footer_links[:15]:  # Test first 15 footer links
                href = link.get_attribute("href")
                if href and href.startswith(("http", "/")):
                    try:
                        if href.startswith("/"):
                            href = f"{base_url}{href}"
                        response = requests.head(href, timeout=10, allow_redirects=True)
                        if response.status_code >= 400:
                            broken_links.append((href, response.status_code))
                    except requests.RequestException:
                        pass

            if broken_links:
                for href, status in broken_links:
                    report_issue(
                        issues_collector, "LOW", f"Broken footer link: {status}",
                        "Footer", href, "Broken Link",
                        f"Footer link returns {status}"
                    )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Footer links test failed",
                "Footer", url, "Test Error",
                str(e)
            )

    def test_breadcrumb_navigation(self, driver, base_url, issues_collector):
        """Test breadcrumb navigation if present"""
        # Test on a page likely to have breadcrumbs
        url = f"{base_url}/es/colabora"
        driver.get(url)
        time.sleep(2)

        try:
            breadcrumbs = driver.find_elements(By.CSS_SELECTOR, ".breadcrumb a, nav[aria-label='breadcrumb'] a")

            if breadcrumbs:
                for crumb in breadcrumbs:
                    href = crumb.get_attribute("href")
                    if href:
                        try:
                            response = requests.head(href, timeout=10, allow_redirects=True)
                            if response.status_code >= 500:
                                report_issue(
                                    issues_collector, "MEDIUM", "Breadcrumb link returns 500",
                                    "Breadcrumb Navigation", href, "Server Error",
                                    f"Breadcrumb link returns {response.status_code}"
                                )
                        except requests.RequestException:
                            pass

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Breadcrumb navigation test failed",
                "Breadcrumb Navigation", url, "Test Error",
                str(e)
            )

    def test_language_switcher(self, driver, base_url, issues_collector):
        """Test language switcher works"""
        url = f"{base_url}/es"
        driver.get(url)
        time.sleep(2)

        try:
            # Find language switcher links
            lang_links = driver.find_elements(By.CSS_SELECTOR, "a[href*='/ca'], a[href*='/eu'], a[href*='/en']")

            for link in lang_links[:4]:  # Test language links
                href = link.get_attribute("href")
                if href:
                    driver.get(href)
                    time.sleep(2)

                    if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                        report_issue(
                            issues_collector, "HIGH", "500 Error on language switch",
                            "Language Switcher", href, "Server Error",
                            f"Error when switching to language: {href}"
                        )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Language switcher test failed",
                "Language Switcher", url, "Test Error",
                str(e)
            )

    def test_mobile_menu(self, driver, base_url, issues_collector):
        """Test mobile menu functionality"""
        url = f"{base_url}/es"

        try:
            # Set mobile viewport
            driver.set_window_size(375, 812)
            driver.get(url)
            time.sleep(2)

            # Look for mobile menu toggle
            menu_toggle = driver.find_elements(By.CSS_SELECTOR, ".navbar-toggle, .navbar-toggler, [data-toggle='collapse'], button[aria-label*='menu']")

            if menu_toggle and menu_toggle[0].is_displayed():
                menu_toggle[0].click()
                time.sleep(1)

                # Check if menu expanded
                mobile_menu = driver.find_elements(By.CSS_SELECTOR, ".navbar-collapse.in, .navbar-collapse.show, .mobile-menu.open")
                if not mobile_menu:
                    report_issue(
                        issues_collector, "MEDIUM", "Mobile menu not expanding",
                        "Mobile Navigation", url, "UI Issue",
                        "Mobile menu toggle clicked but menu not visible"
                    )

            # Reset viewport
            driver.set_window_size(1920, 1080)

        except Exception as e:
            driver.set_window_size(1920, 1080)
            report_issue(
                issues_collector, "LOW", "Mobile menu test failed",
                "Mobile Navigation", url, "Test Error",
                str(e)
            )

    def test_back_button_behavior(self, driver, base_url, issues_collector):
        """Test back button works correctly"""
        try:
            # Navigate through pages
            driver.get(f"{base_url}/es")
            time.sleep(2)
            first_url = driver.current_url

            driver.get(f"{base_url}/es/colabora")
            time.sleep(2)

            # Go back
            driver.back()
            time.sleep(2)

            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "MEDIUM", "500 Error on back navigation",
                    "Back Navigation", driver.current_url, "Server Error",
                    "Error when using browser back button"
                )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Back button test failed",
                "Back Navigation", base_url, "Test Error",
                str(e)
            )

    def test_pagination_if_present(self, driver, base_url, issues_collector):
        """Test pagination links if present"""
        # Test on pages likely to have pagination
        test_urls = [
            f"{base_url}/es/propuestas",
            f"{base_url}/es/noticias",
        ]

        for url in test_urls:
            driver.get(url)
            time.sleep(2)

            try:
                if "500" in driver.page_source:
                    continue

                # Find pagination
                pagination = driver.find_elements(By.CSS_SELECTOR, ".pagination a, nav[aria-label='pagination'] a, .page-link")

                for page_link in pagination[:5]:  # Test first 5 pagination links
                    href = page_link.get_attribute("href")
                    if href:
                        driver.get(href)
                        time.sleep(2)

                        if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                            report_issue(
                                issues_collector, "MEDIUM", "500 Error on pagination",
                                "Pagination", href, "Server Error",
                                f"Error when navigating to page: {href}"
                            )

            except Exception as e:
                report_issue(
                    issues_collector, "LOW", "Pagination test failed",
                    "Pagination", url, "Test Error",
                    str(e)
                )

    def test_anchor_links(self, driver, base_url, issues_collector):
        """Test anchor links work correctly"""
        url = f"{base_url}/es"
        driver.get(url)
        time.sleep(2)

        try:
            # Find anchor links
            anchor_links = driver.find_elements(By.CSS_SELECTOR, "a[href*='#']")

            for link in anchor_links[:10]:  # Test first 10 anchor links
                href = link.get_attribute("href")
                if href and "#" in href:
                    anchor = href.split("#")[-1]
                    if anchor:
                        # Check if target element exists
                        target = driver.find_elements(By.ID, anchor)
                        if not target:
                            target = driver.find_elements(By.CSS_SELECTOR, f"[name='{anchor}']")

                        # Only report if anchor seems intentional (not just "#")
                        if not target and anchor and anchor != "":
                            report_issue(
                                issues_collector, "LOW", f"Anchor target not found: #{anchor}",
                                "Anchor Links", url, "Missing Element",
                                f"Anchor link points to #{anchor} but element not found"
                            )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Anchor links test failed",
                "Anchor Links", url, "Test Error",
                str(e)
            )

    def test_external_links(self, driver, base_url, issues_collector):
        """Test external links have proper attributes"""
        url = f"{base_url}/es"
        driver.get(url)
        time.sleep(2)

        try:
            # Find external links
            external_links = driver.find_elements(By.CSS_SELECTOR, "a[href^='http']:not([href*='localhost'])")

            for link in external_links[:10]:
                href = link.get_attribute("href")
                target = link.get_attribute("target")
                rel = link.get_attribute("rel")

                # External links should ideally open in new tab
                if target != "_blank":
                    report_issue(
                        issues_collector, "LOW", "External link opens in same tab",
                        "External Links", url, "UX Issue",
                        f"External link {href} opens in same tab"
                    )

                # Security: external links should have rel="noopener"
                if target == "_blank" and (not rel or "noopener" not in rel):
                    report_issue(
                        issues_collector, "LOW", "External link missing rel=noopener",
                        "External Links", url, "Security Issue",
                        f"External link {href} with target=_blank missing rel=noopener"
                    )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "External links test failed",
                "External Links", url, "Test Error",
                str(e)
            )

