require 'test_helper'

class EncountersTest < ActionDispatch::IntegrationTest

  setup do
    @admin = users(:admin)
    @admin_resident = users(:admin_resident)
    @resident = users(:resident)
  end

  test "Visit the summary page as an admin" do
    sign_in_as({ email: @admin.email, password: 'password'})
    get '/encounters/summary'
    assert_response :success
    assert_equal ["All", "Residents", "", "Summary"], css_select('.header_title').map { |e| e.text.strip }

    assert_select "table" do
      assert_select "tr.lineitem", 18
      assert_equal(
        [Array.new(9).map { "Jane Intern" }, Array.new(9).map { "Resident_1 Example" }].flatten!,
        css_select("tr.lineitem td:first-child").map(&:text)
      )
    end
  end

  test "Visit the summary page as an admin_resident" do
    sign_in_as({ email: @admin_resident.email, password: 'password'})
    get '/encounters/summary'
    assert_response :success
    assert_equal ["All", "Residents", "", "Summary"], css_select('.header_title').map { |e| e.text.strip }

    assert_select "table" do
      assert_select "tr.lineitem", 18
      assert_equal(
        [Array.new(9).map { "Resident_Invited_By_Admin_Resident Example" }, Array.new(9).map { "Jane Admin_Resident" }].flatten!,
        css_select("tr.lineitem td:first-child").map(&:text)
      )
    end
  end

  test "Visit the summary page as an resident" do
    sign_in_as({ email: @resident.email, password: 'password'})
    get '/encounters/summary'
    assert_response :success
    assert_equal ["Jane", "Intern's", "", "Summary"], css_select('.header_title').map { |e| e.text.strip }

    assert_select "table" do
      assert_select "tr.lineitem", 9
      assert_select '.lineitem td:first-child', 'adult ed'
      assert_select '.lineitem td:first-child', 'adult icu'
      assert_select '.lineitem td:first-child', 'adult inpatient'
      assert_select '.lineitem td:first-child', 'adult inpatient surgery'
      assert_select '.lineitem td:first-child', 'continuity external'
      assert_select '.lineitem td:first-child', 'continuity inpatient'
      assert_select '.lineitem td:first-child', 'pediatric ed'
      assert_select '.lineitem td:first-child', 'pediatric inpatient'
      assert_select '.lineitem td:first-child', 'pediatric newborn'
    end
  end
end
