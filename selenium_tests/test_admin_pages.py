"""
Admin Pages Tests - Pages requiring admin authentication
"""
import pytest
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from conftest import report_issue
import time


class TestAdminPages:
    """Test admin panel pages"""

    def admin_login(self, driver, base_url, admin_user):
        """Helper method to log in as admin"""
        url = f"{base_url}/es/users/sign_in"
        driver.get(url)
        time.sleep(2)

        try:
            email_field = WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.ID, "user_email"))
            )
            email_field.clear()
            email_field.send_keys(admin_user["email"])

            password_field = driver.find_element(By.ID, "user_password")
            password_field.clear()
            password_field.send_keys(admin_user["password"])

            submit_button = driver.find_element(By.NAME, "commit")
            submit_button.click()
            time.sleep(3)
            return True
        except Exception:
            return False

    def test_admin_dashboard(self, driver, base_url, admin_user, issues_collector):
        """Test admin dashboard loads"""
        self.admin_login(driver, base_url, admin_user)

        url = f"{base_url}/admin"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "CRITICAL", "500 Error on Admin Dashboard",
                    "Admin Dashboard", url, "Server Error",
                    "Internal server error on admin dashboard"
                )
                return

            # Check if access denied
            if "403" in driver.page_source or "Forbidden" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "Access Denied to Admin Dashboard",
                    "Admin Dashboard", url, "Authorization Error",
                    "Admin user cannot access admin dashboard"
                )

        except Exception as e:
            report_issue(
                issues_collector, "HIGH", "Admin dashboard test failed",
                "Admin Dashboard", url, "Test Error",
                str(e)
            )

    def test_admin_users_page(self, driver, base_url, admin_user, issues_collector):
        """Test admin users management page"""
        self.admin_login(driver, base_url, admin_user)

        url = f"{base_url}/admin/users"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "CRITICAL", "500 Error on Admin Users Page",
                    "Admin Users", url, "Server Error",
                    "Internal server error on admin users page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "HIGH", "Admin users page test failed",
                "Admin Users", url, "Test Error",
                str(e)
            )

    def test_admin_collaborations_page(self, driver, base_url, admin_user, issues_collector):
        """Test admin collaborations page"""
        self.admin_login(driver, base_url, admin_user)

        url = f"{base_url}/admin/collaborations"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Admin Collaborations",
                    "Admin Collaborations", url, "Server Error",
                    "Internal server error on admin collaborations page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Admin collaborations test failed",
                "Admin Collaborations", url, "Test Error",
                str(e)
            )

    def test_admin_microcredits_page(self, driver, base_url, admin_user, issues_collector):
        """Test admin microcredits page"""
        self.admin_login(driver, base_url, admin_user)

        url = f"{base_url}/admin/microcredits"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Admin Microcredits",
                    "Admin Microcredits", url, "Server Error",
                    "Internal server error on admin microcredits page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Admin microcredits test failed",
                "Admin Microcredits", url, "Test Error",
                str(e)
            )

    def test_admin_votes_page(self, driver, base_url, admin_user, issues_collector):
        """Test admin votes page"""
        self.admin_login(driver, base_url, admin_user)

        url = f"{base_url}/admin/votes"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Admin Votes",
                    "Admin Votes", url, "Server Error",
                    "Internal server error on admin votes page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Admin votes test failed",
                "Admin Votes", url, "Test Error",
                str(e)
            )

    def test_admin_proposals_page(self, driver, base_url, admin_user, issues_collector):
        """Test admin proposals page"""
        self.admin_login(driver, base_url, admin_user)

        url = f"{base_url}/admin/proposals"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Admin Proposals",
                    "Admin Proposals", url, "Server Error",
                    "Internal server error on admin proposals page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Admin proposals test failed",
                "Admin Proposals", url, "Test Error",
                str(e)
            )

    def test_admin_impulsa_page(self, driver, base_url, admin_user, issues_collector):
        """Test admin impulsa page"""
        self.admin_login(driver, base_url, admin_user)

        url = f"{base_url}/admin/impulsa"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Admin Impulsa",
                    "Admin Impulsa", url, "Server Error",
                    "Internal server error on admin impulsa page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Admin impulsa test failed",
                "Admin Impulsa", url, "Test Error",
                str(e)
            )

    def test_admin_census_page(self, driver, base_url, admin_user, issues_collector):
        """Test admin census page"""
        self.admin_login(driver, base_url, admin_user)

        url = f"{base_url}/admin/census"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Admin Census",
                    "Admin Census", url, "Server Error",
                    "Internal server error on admin census page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Admin census test failed",
                "Admin Census", url, "Test Error",
                str(e)
            )

    def test_admin_participation_teams_page(self, driver, base_url, admin_user, issues_collector):
        """Test admin participation teams page"""
        self.admin_login(driver, base_url, admin_user)

        url = f"{base_url}/admin/participation_teams"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Admin Participation Teams",
                    "Admin Participation Teams", url, "Server Error",
                    "Internal server error on admin participation teams page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Admin participation teams test failed",
                "Admin Participation Teams", url, "Test Error",
                str(e)
            )

    def test_admin_pages_cms(self, driver, base_url, admin_user, issues_collector):
        """Test admin CMS pages management"""
        self.admin_login(driver, base_url, admin_user)

        url = f"{base_url}/admin/pages"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Admin CMS Pages",
                    "Admin CMS Pages", url, "Server Error",
                    "Internal server error on admin CMS pages"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Admin CMS pages test failed",
                "Admin CMS Pages", url, "Test Error",
                str(e)
            )

    def test_admin_categories_page(self, driver, base_url, admin_user, issues_collector):
        """Test admin categories page"""
        self.admin_login(driver, base_url, admin_user)

        url = f"{base_url}/admin/categories"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Admin Categories",
                    "Admin Categories", url, "Server Error",
                    "Internal server error on admin categories page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Admin categories test failed",
                "Admin Categories", url, "Test Error",
                str(e)
            )

    def test_admin_notices_page(self, driver, base_url, admin_user, issues_collector):
        """Test admin notices page"""
        self.admin_login(driver, base_url, admin_user)

        url = f"{base_url}/admin/notices"
        driver.get(url)
        time.sleep(2)

        try:
            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on Admin Notices",
                    "Admin Notices", url, "Server Error",
                    "Internal server error on admin notices page"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Admin notices test failed",
                "Admin Notices", url, "Test Error",
                str(e)
            )

    def test_non_admin_access_denied(self, driver, base_url, test_user, issues_collector):
        """Test that non-admin users cannot access admin pages"""
        # Login as regular user
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

            # Try to access admin
            admin_url = f"{base_url}/admin"
            driver.get(admin_url)
            time.sleep(2)

            # Should be denied or redirected
            if "admin" in driver.current_url.lower() and "500" not in driver.page_source:
                # Check if actually showing admin content
                if "dashboard" in driver.page_source.lower() or "users" in driver.page_source.lower():
                    report_issue(
                        issues_collector, "CRITICAL", "Non-admin can access admin area",
                        "Admin Access Control", admin_url, "Security Issue",
                        "Regular user was able to access admin dashboard"
                    )

            if "500" in driver.page_source or "Internal Server Error" in driver.page_source:
                report_issue(
                    issues_collector, "HIGH", "500 Error on admin access denial",
                    "Admin Access Control", admin_url, "Server Error",
                    "Server error instead of proper access denial for non-admin"
                )

        except Exception as e:
            report_issue(
                issues_collector, "MEDIUM", "Admin access control test failed",
                "Admin Access Control", f"{base_url}/admin", "Test Error",
                str(e)
            )

