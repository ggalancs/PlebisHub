"""
Accessibility Tests - Basic accessibility checks
"""
import pytest
from selenium.webdriver.common.by import By
from conftest import report_issue
import time


class TestAccessibility:
    """Test basic accessibility features"""

    def test_images_have_alt_text(self, driver, base_url, issues_collector):
        """Test that images have alt text"""
        url = f"{base_url}/es"
        driver.get(url)
        time.sleep(2)

        try:
            images = driver.find_elements(By.TAG_NAME, "img")

            images_without_alt = []
            for img in images:
                alt = img.get_attribute("alt")
                src = img.get_attribute("src")
                if not alt or alt.strip() == "":
                    images_without_alt.append(src)

            if images_without_alt:
                report_issue(
                    issues_collector, "MEDIUM", "Images missing alt text",
                    "Accessibility", url, "Accessibility Issue",
                    f"{len(images_without_alt)} images without alt text"
                )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Alt text test failed",
                "Accessibility", url, "Test Error",
                str(e)
            )

    def test_form_labels(self, driver, base_url, issues_collector):
        """Test that form inputs have associated labels"""
        url = f"{base_url}/es/users/sign_up"
        driver.get(url)
        time.sleep(2)

        try:
            inputs = driver.find_elements(By.CSS_SELECTOR, "input[type='text'], input[type='email'], input[type='password'], input[type='tel'], textarea, select")

            unlabeled_inputs = []
            for inp in inputs:
                input_id = inp.get_attribute("id")
                if input_id:
                    label = driver.find_elements(By.CSS_SELECTOR, f"label[for='{input_id}']")
                    aria_label = inp.get_attribute("aria-label")
                    aria_labelledby = inp.get_attribute("aria-labelledby")

                    if not label and not aria_label and not aria_labelledby:
                        unlabeled_inputs.append(input_id)

            if unlabeled_inputs:
                report_issue(
                    issues_collector, "MEDIUM", "Form inputs missing labels",
                    "Accessibility", url, "Accessibility Issue",
                    f"Inputs without labels: {', '.join(unlabeled_inputs[:5])}"
                )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Form labels test failed",
                "Accessibility", url, "Test Error",
                str(e)
            )

    def test_heading_hierarchy(self, driver, base_url, issues_collector):
        """Test heading hierarchy (h1, h2, h3, etc.)"""
        url = f"{base_url}/es"
        driver.get(url)
        time.sleep(2)

        try:
            # Check for h1
            h1_tags = driver.find_elements(By.TAG_NAME, "h1")
            if len(h1_tags) == 0:
                report_issue(
                    issues_collector, "MEDIUM", "No h1 tag on page",
                    "Accessibility", url, "Accessibility Issue",
                    "Page missing main heading (h1)"
                )
            elif len(h1_tags) > 1:
                report_issue(
                    issues_collector, "LOW", "Multiple h1 tags on page",
                    "Accessibility", url, "Accessibility Issue",
                    f"Page has {len(h1_tags)} h1 tags, should have only one"
                )

            # Check heading hierarchy
            headings = driver.find_elements(By.CSS_SELECTOR, "h1, h2, h3, h4, h5, h6")
            if headings:
                levels = []
                for h in headings:
                    level = int(h.tag_name[1])
                    levels.append(level)

                # Check for skipped levels
                for i in range(1, len(levels)):
                    if levels[i] > levels[i-1] + 1:
                        report_issue(
                            issues_collector, "LOW", "Skipped heading level",
                            "Accessibility", url, "Accessibility Issue",
                            f"Heading jumps from h{levels[i-1]} to h{levels[i]}"
                        )
                        break

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Heading hierarchy test failed",
                "Accessibility", url, "Test Error",
                str(e)
            )

    def test_link_text_descriptive(self, driver, base_url, issues_collector):
        """Test that links have descriptive text"""
        url = f"{base_url}/es"
        driver.get(url)
        time.sleep(2)

        try:
            links = driver.find_elements(By.TAG_NAME, "a")

            vague_link_texts = ["click here", "here", "read more", "more", "link"]
            vague_links = []

            for link in links:
                text = link.text.strip().lower()
                if text in vague_link_texts:
                    href = link.get_attribute("href")
                    vague_links.append((text, href))

            if vague_links:
                report_issue(
                    issues_collector, "LOW", "Links with vague text",
                    "Accessibility", url, "Accessibility Issue",
                    f"{len(vague_links)} links with non-descriptive text"
                )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Link text test failed",
                "Accessibility", url, "Test Error",
                str(e)
            )

    def test_color_contrast_basic(self, driver, base_url, issues_collector):
        """Basic check for very light text (potential contrast issues)"""
        url = f"{base_url}/es"
        driver.get(url)
        time.sleep(2)

        try:
            # This is a basic check - full contrast testing requires specialized tools
            elements = driver.find_elements(By.CSS_SELECTOR, "p, span, a, li, h1, h2, h3, h4")

            light_text_count = 0
            for elem in elements[:50]:  # Check first 50 elements
                color = elem.value_of_css_property("color")
                if color:
                    # Very basic check for near-white colors
                    if "rgba(255, 255, 255" in color or "rgb(255, 255, 255" in color:
                        bg_color = elem.value_of_css_property("background-color")
                        if "rgba(255, 255, 255" in bg_color or "transparent" in bg_color:
                            light_text_count += 1

            if light_text_count > 5:
                report_issue(
                    issues_collector, "LOW", "Potential contrast issues",
                    "Accessibility", url, "Accessibility Issue",
                    f"Found {light_text_count} elements with potential contrast issues"
                )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Color contrast test failed",
                "Accessibility", url, "Test Error",
                str(e)
            )

    def test_focus_indicators(self, driver, base_url, issues_collector):
        """Test that interactive elements have focus indicators"""
        url = f"{base_url}/es"
        driver.get(url)
        time.sleep(2)

        try:
            # Find focusable elements
            focusable = driver.find_elements(By.CSS_SELECTOR, "a, button, input, select, textarea")

            elements_without_focus = 0
            for elem in focusable[:10]:  # Test first 10 elements
                try:
                    # Get outline before focus
                    elem.send_keys("")  # Focus the element

                    outline = elem.value_of_css_property("outline")
                    box_shadow = elem.value_of_css_property("box-shadow")
                    border = elem.value_of_css_property("border")

                    # Very basic check - element should have some visual change on focus
                    if outline == "none" and box_shadow == "none":
                        elements_without_focus += 1
                except Exception:
                    pass

            if elements_without_focus > 5:
                report_issue(
                    issues_collector, "LOW", "Elements may lack focus indicators",
                    "Accessibility", url, "Accessibility Issue",
                    f"{elements_without_focus} interactive elements may lack visible focus"
                )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Focus indicator test failed",
                "Accessibility", url, "Test Error",
                str(e)
            )

    def test_skip_navigation_link(self, driver, base_url, issues_collector):
        """Test for skip navigation link"""
        url = f"{base_url}/es"
        driver.get(url)
        time.sleep(2)

        try:
            skip_links = driver.find_elements(By.CSS_SELECTOR, "a[href='#main'], a[href='#content'], .skip-link, .skip-nav")

            if not skip_links:
                report_issue(
                    issues_collector, "LOW", "No skip navigation link",
                    "Accessibility", url, "Accessibility Issue",
                    "Page lacks skip navigation link for keyboard users"
                )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "Skip navigation test failed",
                "Accessibility", url, "Test Error",
                str(e)
            )

    def test_language_attribute(self, driver, base_url, issues_collector):
        """Test that HTML has language attribute"""
        test_urls = [
            (f"{base_url}/es", "es"),
            (f"{base_url}/ca", "ca"),
            (f"{base_url}/eu", "eu"),
        ]

        for url, expected_lang in test_urls:
            driver.get(url)
            time.sleep(2)

            try:
                html = driver.find_element(By.TAG_NAME, "html")
                lang = html.get_attribute("lang")

                if not lang:
                    report_issue(
                        issues_collector, "MEDIUM", "Missing lang attribute",
                        "Accessibility", url, "Accessibility Issue",
                        "HTML element missing lang attribute"
                    )
                elif not lang.startswith(expected_lang):
                    report_issue(
                        issues_collector, "LOW", "Incorrect lang attribute",
                        "Accessibility", url, "Accessibility Issue",
                        f"Expected lang='{expected_lang}', got '{lang}'"
                    )

            except Exception as e:
                report_issue(
                    issues_collector, "LOW", "Language attribute test failed",
                    "Accessibility", url, "Test Error",
                    str(e)
                )

    def test_aria_roles(self, driver, base_url, issues_collector):
        """Test proper use of ARIA roles"""
        url = f"{base_url}/es"
        driver.get(url)
        time.sleep(2)

        try:
            # Check for main landmark
            main = driver.find_elements(By.CSS_SELECTOR, "main, [role='main']")
            if not main:
                report_issue(
                    issues_collector, "LOW", "No main landmark",
                    "Accessibility", url, "Accessibility Issue",
                    "Page lacks main landmark for screen readers"
                )

            # Check for nav landmark
            nav = driver.find_elements(By.CSS_SELECTOR, "nav, [role='navigation']")
            if not nav:
                report_issue(
                    issues_collector, "LOW", "No navigation landmark",
                    "Accessibility", url, "Accessibility Issue",
                    "Page lacks navigation landmark"
                )

        except Exception as e:
            report_issue(
                issues_collector, "LOW", "ARIA roles test failed",
                "Accessibility", url, "Test Error",
                str(e)
            )

