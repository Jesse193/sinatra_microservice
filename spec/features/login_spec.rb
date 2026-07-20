require "spec_helper"

RSpec.describe "Login", type: :feature do
  let!(:user) { create(:user) }

  it "logs in via the React UI" do
    visit "/"

    click_button "Accept"

    fill_in "email", with: user.email
    fill_in "password", with: user.password

    click_button "Login"
    expect(page).to have_content("Welcome")
  end
end