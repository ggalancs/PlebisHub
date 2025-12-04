#!/usr/bin/env python3
"""
Test authenticated pages in PlebisHub
"""
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException
from selenium.webdriver.chrome.options import Options

# Test credentials
EMAIL = "test@example.com"
PASSWORD = "testpassword123"
BASE_URL = "http://localhost:3000"

# Pages to test
AUTHENTICATED_PAGES = [
    "/es",  # authenticated home
    "/es/users/edit",  # profile
    "/es/colabora",  # collaboration (authenticated)
    "/es/microcreditos",  # microcredit (authenticated)
    "/es/impulsa",  # impulsa (authenticated)
    "/es/financiacion",  # funding
    "/es/tools/militant_request",  # militant request
]

ADMIN_PAGES = [
    "/admin",
    "/admin/users",
    "/admin/collaborations",
    "/admin/microcredits",
]

def setup_driver():
    """Setup Chrome driver"""
    chrome_options = Options()
    chrome_options.add_argument('--headless')
    chrome_options.add_argument('--no-sandbox')
    chrome_options.add_argument('--disable-dev-shm-usage')
    chrome_options.add_argument('--disable-gpu')
    return webdriver.Chrome(options=chrome_options)

def login(driver):
    """Login to the application"""
    print(f"Logging in as {EMAIL}...")
    driver.get(f"{BASE_URL}/es/users/sign_in")
    time.sleep(2)

    # Fill in login form
    login_field = driver.find_element(By.ID, "user_login")
    password_field = driver.find_element(By.ID, "user_password")

    login_field.send_keys(EMAIL)
    password_field.send_keys(PASSWORD)

    # Submit form
    submit_button = driver.find_element(By.CSS_SELECTOR, "input[type='submit']")
    submit_button.click()
    time.sleep(3)

    # Check if login was successful
    if "sign_in" in driver.current_url:
        print("ERROR: Login failed!")
        return False

    print("Login successful!")
    return True

def test_page(driver, path):
    """Test a single page"""
    url = f"{BASE_URL}{path}"
    print(f"\nTesting: {url}")

    try:
        driver.get(url)
        time.sleep(2)

        # Check for errors
        page_source = driver.page_source

        if "Action Controller: Exception caught" in page_source:
            print(f"  ❌ ERROR: Exception on page")
            # Try to extract error message
            try:
                error_header = driver.find_element(By.TAG_NAME, "h1")
                print(f"  Error: {error_header.text}")
            except:
                pass

            # Try to extract error details
            try:
                error_code = driver.find_element(By.TAG_NAME, "code")
                print(f"  Details: {error_code.text[:200]}")
            except:
                pass

            return False

        if "NameError" in page_source or "NoMethodError" in page_source or "undefined method" in page_source:
            print(f"  ❌ ERROR: Ruby error on page")
            return False

        # Check if redirected to login
        if "/users/sign_in" in driver.current_url:
            print(f"  ⚠️  WARNING: Redirected to login (authentication required)")
            return True  # Not an error, just needs auth

        # Check page title
        title = driver.title
        print(f"  ✓ Page loaded successfully")
        print(f"  Title: {title}")

        return True

    except TimeoutException:
        print(f"  ❌ ERROR: Page timeout")
        return False
    except Exception as e:
        print(f"  ❌ ERROR: {str(e)}")
        return False

def main():
    """Main test function"""
    driver = setup_driver()

    try:
        # Login first
        if not login(driver):
            print("Login failed, cannot continue")
            return

        # Test authenticated pages
        print("\n" + "="*60)
        print("TESTING AUTHENTICATED PAGES")
        print("="*60)

        results = {}
        for page in AUTHENTICATED_PAGES:
            results[page] = test_page(driver, page)

        # Test admin pages
        print("\n" + "="*60)
        print("TESTING ADMIN PAGES")
        print("="*60)

        for page in ADMIN_PAGES:
            results[page] = test_page(driver, page)

        # Summary
        print("\n" + "="*60)
        print("SUMMARY")
        print("="*60)

        passed = sum(1 for v in results.values() if v)
        failed = sum(1 for v in results.values() if not v)

        print(f"Total pages tested: {len(results)}")
        print(f"Passed: {passed}")
        print(f"Failed: {failed}")

        if failed > 0:
            print("\nFailed pages:")
            for page, result in results.items():
                if not result:
                    print(f"  - {page}")

    finally:
        driver.quit()

if __name__ == "__main__":
    main()
