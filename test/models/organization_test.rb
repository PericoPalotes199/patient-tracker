require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase

  def setup
    @residency_organization = organizations(:residency_organization)
    @company_organization = organizations(:company_organization)
  end

  test "each orgaization has a kind attribute" do
    assert_equal 'residency', @residency_organization.kind
    assert_equal 'company', @company_organization.kind
  end
end
