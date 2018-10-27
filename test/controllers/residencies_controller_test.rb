require 'test_helper'

describe ResidenciesController do
  before do
    @resident = users(:resident)
    @residency = residencies(:valid_residency)
  end

  describe 'when signed in' do
    it "should get index" do
      sign_in @resident
      get :index
      assert_response :success
      assert assigns(:residencies), Residency.all
    end

    it "should get new" do
      sign_in @resident
      get :new
      assert_response :success
    end

    it "should create residency" do
      sign_in @resident
      assert_difference('Residency.count') do
        post :create, residency: { name: 'Created Residency' }
      end

      assert_redirected_to residency_path(assigns(:residency))
    end

    it "should show residency" do
      sign_in @resident
      get :show, id: @residency
      assert_response :success
    end

    it "should get edit" do
      sign_in @resident
      assert_raises ActionController::UrlGenerationError do
        get :edit, id: @residency
      end
      assert_response :success
    end

    it "should not update residency" do
      sign_in @resident
      assert_raises ActionController::UrlGenerationError do
        put :update, id: @residency, residency: { name: 'Updated Residency' }
      end
      assert_raises ActionController::UrlGenerationError do
        patch :update, id: @residency, residency: { name: 'Updated Residency' }
      end
    end

    it "should not destroy residency" do
      sign_in @resident
      assert_raises ActionController::UrlGenerationError do
        delete :destroy, id: @residency
      end
    end
  end

  describe 'when signed out' do
    it "should not get index" do
      get :index
      assert_redirected_to new_user_session_path
    end

    it "should not show residency" do
      get :show, id: @residency
      assert_redirected_to new_user_session_path
    end

    it "should not get new" do
      get :new
      assert_redirected_to new_user_session_path
    end

    it "should not create residency" do
      assert_no_difference('Residency.count') do
        post :create, residency: { name: 'Created Residency' }
      end

      assert_redirected_to new_user_session_path
    end

    it "should not edit residency" do
      assert_raises ActionController::UrlGenerationError do
        get :edit, id: @residency
      end
    end

    it "should not update residency" do
      assert_raises ActionController::UrlGenerationError do
        put :update, id: @residency, residency: { name: 'Updated Residency' }
      end
      assert_raises ActionController::UrlGenerationError do
        patch :update, id: @residency, residency: { name: 'Updated Residency' }
      end
    end

    it "should not destroy residency" do
      assert_raises ActionController::UrlGenerationError do
        delete :destroy, id: @residency
      end
    end
  end
end
