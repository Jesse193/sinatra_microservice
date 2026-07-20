require "spec_helper"

RSpec.describe "Login", type: :feature do
  let!(:users) { create_list(:user, 5) }

  it "logs in via the React UI" do
    visit "/"

    click_button "Accept"

    fill_in "email", with: users[0].email
    fill_in "password", with: users[0].password

    click_button "Login"
    expect(page).to have_content("Welcome")
  end

  it "rejects invalid login credentials" do
    visit "/"

    click_button "Accept"

    fill_in "email", with: users[0].email
    fill_in "password", with: "wrongpassword"

    click_button "Login"
    expect(page).to have_content("Invalid email or password")
  end

  it "logs out via the React UI" do
    visit "/"

    click_button "Accept"

    fill_in "email", with: users[0].email
    fill_in "password", with: users[0].password

    click_button "Login"
    expect(page).to have_content("Welcome")

    click_button "Logout"
    expect(page).to have_content("Login")
  end
end