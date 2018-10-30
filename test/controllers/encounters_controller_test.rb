require 'test_helper'

class EncountersControllerTest < ActionController::TestCase

  # was the web request successful?
  # was the user redirected to the right page?
  # was the user successfully authenticated?
  # was the correct object stored in the response template?
  # was the appropriate message displayed to the user in the view?

  setup do
    @resident = users(:resident)
    @admin = users(:admin)
    @admin_resident = users(:admin_resident)
    @encounter = @resident.encounters.first

    @encounter_types = [
      "adult_ed",
      "adult_icu",
      "adult_inpatient",
      "adult_inpatient surgery",
      "continuity_external",
      "continuity_inpatient",
      "pediatric_ed",
      "pediatric_inpatient",
      "pediatric_newborn",
      "adult_inpatient",
    ]

    @encounter_types_in_db = [
      "adult ed",
      "adult icu",
      "adult inpatient",
      "adult inpatient surgery",
      "continuity external",
      "continuity inpatient",
      "pediatric ed",
      "pediatric inpatient",
      "pediatric newborn",
      "adult inpatient",
    ]
  end

  test "As a visitor, I cannot visit the encounters index" do
    get :index
    assert_nil assigns(:encounters)
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "As a resident, I can view only my encounters at the encounters index" do
    sign_in @resident
    get :index
    assert_response :success
    assert_equal assigns(:encounters).count, @resident.encounters.count
    assert_equal assigns(:encounters), @resident.encounters.order(encountered_on: :desc)
    assert_template :index
  end

  test "As a resident, when I visit the encounters index, encounters are reverse sorted by encountered_on" do
    sign_in @resident
    get :index
    assert_equal assigns(:encounters).pluck(:encountered_on), @resident.encounters.pluck(:encountered_on).sort.reverse
    assert_template :index
  end

  test "As an admin_resident, I can view my encounters and my residents' encounters at the encounters index" do
    sign_in @admin_resident
    get :index
    assert_response :success

    assert_equal(
      # Expect the count of the assigned encounters
      assigns(:encounters).count,
      # Equals the sum of the counts of both the admin_resident's encounters plus all encounters of residents invited by the admin_resident
      (@admin_resident.encounters + users(:resident_invited_by_admin_resident).encounters).flatten.count
    )
    assert_equal(
      # Expect the user_id of the encoutners
      assigns(:encounters).flatten.map(&:user_id).uniq,
      # Equals those of the admin_resident and their residents
      [users(:resident_invited_by_admin_resident).id, @admin_resident.id]
    )
  end

  test "As an admin_resident, when I visit the encounters index, encounters are reverse sorted by encountered_on" do
    sign_in @admin_resident
    get :index
    assert_response :success

    admin_resident_enconters = @admin_resident.encounters.order(encountered_on: :desc).pluck(:encountered_on)
    resident_encounters = users(:resident_invited_by_admin_resident).encounters.order(encountered_on: :desc).pluck(:encountered_on)

    assert_equal(
      # Compare the length the expected encounters
      [admin_resident_enconters, resident_encounters].flatten.length,
      # ... to the actual assigned encounters' length
      assigns(:encounters).length
    )

    assert_equal(
      # Compare the encountered_on timestamps of the expected encounters
      [admin_resident_enconters, resident_encounters].flatten,
      # ... to the actual assigned encounters' encountered_on timestamps.
      assigns(:encounters).map(&:encountered_on)
    )
    assert_template :index
  end

  test "As an unrecognized role, I can view no encounters at the encounters index" do
    unrecognized_resident = User.create!(@resident.attributes.merge({
      id: nil,
      role: 'unrecognized',
      email: 'unrecognized@example.com',
      password: 'password',
      tos_accepted: '1'
    }))
    sign_in unrecognized_resident
    get :index
    assert_response :success
    assert_equal assigns(:encounters).count, 0
    assert_equal assigns(:encounters), Encounter.none
    assert_template :index
  end

  test "As an admin, I can view all of my invited residents' encounters at the encounters index" do
    sign_in @admin
    get :index
    assert_response :success
    expected_encounters = []
    @admin.invitations.each do |invitation|
      expected_encounters += invitation.encounters
    end
    assert_equal assigns(:encounters).length, expected_encounters.length
    assert_equal assigns(:encounters).pluck(:id).sort, expected_encounters.map(&:id).sort
    assert_template :index
  end

  test "As an admin, when I visit the encounters index, encounters are reverse sorted by encountered_on" do
    sign_in @admin
    get :index
    assert_equal(
      assigns(:encounters).pluck(:encountered_on),
      assigns(:encounters).sort_by(&:encountered_on).reverse.map(&:encountered_on)
    )
  end

  test "As a resident, when I download the encounters summary xml, encounters are assigned" do
    sign_in @admin
    get :summary, format: :xls
    assert_not_nil assigns(:encounters)
    assert_not_nil assigns(:grouped_encounters)
  end

  test "As an admin_resident, when I download the encounters summary xml, encounters are assigned" do
    sign_in @admin_resident
    get :summary, format: :xls
    assert_not_nil assigns(:encounters)
    assert_not_nil assigns(:grouped_encounters)
  end

  test "As an admin, when I download the encounters summary xml, encounters are assigned" do
    sign_in @admin
    get :summary, format: :xls
    assert_not_nil assigns(:encounters)
    assert_not_nil assigns(:grouped_encounters)
  end

  test "As a resident, when I visit the encounters summary page, encounter_types are grouped by user_id and encounter_type" do
    sign_in @resident
    get :summary

    # The grouped keys should looks somethign like this result:
    # assigns(:grouped_encounters).keys #=> [ [486791686, "adult_ed"], ..., [494457361, "adult_inpatient"] ]

    assigns(:grouped_encounters).keys.map { |key|
      user_id, encounter_type = key.first, key.second
      assert_kind_of User, User.find(user_id), 'Each key should include a user_id!'
      assert encounter_type.in?(@encounter_types_in_db), 'Each key should include an encounter_type!'
    }
  end

  test "As an admin_resident, when I visit the encounters summary page, encounter_types are grouped by user_id and encounter_type" do
    sign_in @admin_resident
    get :summary

    # The grouped keys should looks somethign like this result:
    # assigns(:grouped_encounters).keys #=> [ [486791686, "adult_ed"], ..., [494457361, "adult_inpatient"] ]

    assigns(:grouped_encounters).keys.map { |key|
      user_id, encounter_type = key.first, key.second
      assert_kind_of User, User.find(user_id), 'Each key should include a user_id!'
      assert encounter_type.in?(@encounter_types_in_db), 'Each key should include an encounter_type!'
    }
  end

  test "As an admin, when I visit the encounters summary page, encounter_types are grouped by user_id and encounter_type" do
    sign_in @admin
    get :summary

    # The grouped keys should looks somethign like this result:
    # assigns(:grouped_encounters).keys #=> [ [486791686, "adult_ed"], ..., [494457361, "adult_inpatient"] ]

    assigns(:grouped_encounters).keys.map { |key|
      user_id, encounter_type = key.first, key.second
      assert_kind_of User, User.find(user_id), 'Each key should include a user_id!'
      assert encounter_type.in?(@encounter_types_in_db), 'Each key should include an encounter_type!'
    }
  end

  test "As a resident, when I visit the encounters summary page, only my encounters are queried" do
    sign_in @resident
    get :summary
    current_user = @resident

    assert_equal current_user.residency.name, 'Test Residency'
    assert_equal assigns(:encounters).length, 54
    assert_equal assigns(:encounters).map { |encounter| encounter.user.residency.name }.uniq, ['Test Residency']
    assert_equal assigns(:encounters), current_user.encounters.order(encountered_on: :desc)
  end

  test "As an admin, when I visit the encounters summary page, only my residency's encounters are queried" do
    sign_in @admin
    get :summary

    current_user = @admin

    assert_equal current_user.residency.name, 'Test Residency'

    encounters_for_admin = Encounter.includes(:user).
      where('users.invited_by_id = ?', current_user.id).
      references(:users).
      order(encountered_on: :desc).
      order('users.name ASC')

    assert_equal assigns(:encounters).length, 99
    assert_equal assigns(:encounters).map { |encounter| encounter.user.residency.name }.uniq, ['Test Residency']
    assert_equal assigns(:encounters), encounters_for_admin
  end


  test "As an admin_resident, when I visit the encounters summary page, my encounters and residency's encounters are queried" do
    sign_in @admin_resident
    get :summary

    current_user = @admin_resident

    assert_equal current_user.residency.name, 'Test Residency'

    encounters_for_admin_resident = [
      Encounter.includes(:user).
        where('users.invited_by_id = ?', current_user.id).
        references(:users).
        order(encountered_on: :desc).
        order('users.name ASC'),
      current_user.encounters.order(encountered_on: :desc)
    ].flatten
    assert_equal assigns(:encounters).length, 90
    assert_equal assigns(:encounters).map { |encounter| encounter.user.residency.name }.uniq, ['Test Residency']
    assert_equal assigns(:encounters), encounters_for_admin_resident
  end

  test "As a visitor, I cannot visit the new encounter form" do
    get :new
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "As I resident, I can visit the new encounter page" do
    sign_in @resident
    get :new
    assert_response :success
    assert_template :new
  end

  test "As an admin, I can visit the new encounter page" do
    sign_in @admin
    get :new
    assert_response :success
    assert_template :new
  end

  test "As a visitor, I cannot create an encounter" do
    assert_no_difference('Encounter.count') do
      post :create, encounter: { encounter_types: { adult_inpatient: 1, adult_ed: 2 } }
    end
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "As a resident, I can create an encounter" do
    sign_in @resident
    assert_difference('Encounter.count', 3) do
      post :create, encounter_types: { adult_inpatient: 1, adult_ed: 2 }, encountered_on: Time.now.to_date
    end
    assert_response :redirect
    assert_redirected_to encounters_path
  end

  test "As a resident, when encountered_on date is missing, the encounters are not created" do
    sign_in @resident
    assert_no_difference('Encounter.count') do
      assert_raises ActionController::ParameterMissing do
        post :create, encounter_types: { adult_inpatient: 1, adult_ed: 2 }, encountered_on: nil
      end
    end
  end

  test "As a resident, when encounter_types is missing, the encounters are not created" do
    sign_in @resident
    assert_no_difference('Encounter.count') do
      assert_raises ActionController::ParameterMissing do
        post :create, encounter_types: { }, encountered_on: Time.now.to_date
      end
    end
  end

  test "As a resident, when encounter_types with all 0 values are submitted, the user sees an alert" do
    sign_in @resident
    assert_no_difference('Encounter.count') do
      post(:create, encounter_types: {
        adult_inpatient: '0',
        adult_ed: '0',
        adult_icu: '0',
        adult_inpatient_surgery: '0',
        pediatric_inpatient: '0',
        pediatric_newborn: '0',
        pediatric_ed: '0',
        continuity_inpatient: '0',
        continuity_external: '0'
      }, encountered_on: Time.now.to_date)
    end
    assert_equal flash.alert, "You did not count your encounters!"
    assert_nil flash.instance_variable_get :@now
  end

  test "As an admin, I cannot create an encounter" do
    sign_in @admin
    assert_no_difference('Encounter.count') do
      post :create, encounter_types: { adult_inpatient: 1, adult_ed: 2 }, encountered_on: Time.now.to_date
    end
    assert_response :redirect

    assert_redirected_to encounters_path
  end

  test "As a visitor, I cannot view an encounter" do
    get :show, id: @encounter
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "As a resident, I can view one of my encounters" do
    sign_in @resident
    get :show, id: @encounter
    assert_response :success
    assert_template :show
  end

  test "As a resident, I cannot view an encounter that is not mine" do
    sign_in @resident
    get :show, id: users(:resident_1).encounters.first
    assert_response :redirect
    assert_redirected_to encounters_path
  end

  test "As an admin, I cannot view single encounters" do
    sign_in @admin
    get :show, id: @encounter
    assert_response :redirect
    assert_redirected_to encounters_path
  end

  test "As a visitor, I cannot edit encounters" do
    assert_raises ActionController::UrlGenerationError do
      get :edit, id: @encounter
    end
  end

  test "As a resident, I cannot edit encounters" do
    sign_in @resident
    assert_raises ActionController::UrlGenerationError do
      get :edit, id: @encounter
    end
  end

  test "As an admin, I cannot edit encounters" do
    sign_in @admin
    assert_raises ActionController::UrlGenerationError do
      get :edit, id: @encounter
    end
    assert_raises ActionController::UrlGenerationError do
      get :edit, id: @admin.invitations.first.encounters.first
    end
  end

  test "As a visitor, I cannot update encounters" do
    assert_raises ActionController::UrlGenerationError do
      put :update, id: @encounter
    end
  end

  test "As a resident, I cannot update encounters" do
    sign_in @resident
    assert_raises ActionController::UrlGenerationError do
      put :update, id: @encounter
    end
  end

  test "As an admin, I cannot update encounters" do
    sign_in @admin
    assert_raises ActionController::UrlGenerationError do
      put :update, id: @encounter
    end
    assert_raises ActionController::UrlGenerationError do
      put :update, id: @admin.invitations.first.encounters.first
    end
  end

  test "As a visitor, I cannot destroy encounters" do
    assert_no_difference('Encounter.count') do
      delete :destroy, id: @encounter
    end

    assert_redirected_to new_user_session_path
  end

  test "As a resident, I cannot destroy encounters that are not mine" do
    sign_in @resident
    assert_no_difference('Encounter.count') do
      delete :destroy, id: users(:resident_1).encounters.first
    end
    assert_response :redirect
    assert_redirected_to encounters_path
  end

  test "As a resident, I can destroy my own encounters" do
    sign_in @resident
    assert_difference('Encounter.count', -1) do
      delete :destroy, id: @encounter
    end
    assert_response :redirect
    assert_redirected_to encounters_path
  end

  test "As an admin, I cannot destroy encounters" do
    sign_in @admin
    assert_no_difference('Encounter.count') do
      delete :destroy, id: users(:resident_1).encounters.first
    end
    assert_response :redirect
    assert_redirected_to encounters_path
  end
end
