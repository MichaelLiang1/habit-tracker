require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new page renders" do
    get new_registration_path
    assert_response :success
  end

  test "create makes a user and logs them in" do
    assert_difference "User.count", 1 do
      post registration_path, params: { user: { email_address: "new@example.com", password: "password123", password_confirmation: "password123", time_zone: "UTC" } }
    end
    assert_redirected_to root_path
  end

  test "create with mismatched passwords fails" do
    assert_no_difference "User.count" do
      post registration_path, params: { user: { email_address: "new@example.com", password: "password123", password_confirmation: "nope", time_zone: "UTC" } }
    end
    assert_response :unprocessable_entity
  end
end
