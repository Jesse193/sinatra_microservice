require "spec_helper"

RSpec.describe "Search", type: :feature do
  let!(:markets) { create_list(:market, 7) }
  let!(:users) { create_list(:user, 5) }

  it "can add favorite markets" do
    visit "/"

    click_button "Accept"

    fill_in "email", with: users[0].email
    fill_in "password", with: users[0].password

    click_button "Login"
    expect(page).to have_content("Welcome")

    click_link "Markets"

    forms = page.all("form")
    address_form = forms[1]
    within(address_form) do
      fill_in "Address Line 1", with: "501 Foster Street"
      fill_in "City", with: "Durham"
      fill_in "State", with: "North Carolina"
      fill_in "Zip Code", with: "27701"
      click_button "Search"
    end

    click_button "Add to Favorites"
    visit "/favorites"

    expect(page).to have_content("Favorites")
    expect(page).to have_content("Remove from Favorites")
  end

  it "doesn't show others favorite markets" do
    visit "/"

    click_button "Accept"

    fill_in "email", with: users[0].email
    fill_in "password", with: users[0].password

    click_button "Login"
    expect(page).to have_content("Welcome")

    click_link "Markets"

    forms = page.all("form")
    address_form = forms[1]
    within(address_form) do
      fill_in "Address Line 1", with: "501 Foster Street"
      fill_in "City", with: "Durham"
      fill_in "State", with: "North Carolina"
      fill_in "Zip Code", with: "27701"
      click_button "Search"
    end

    click_button "Add to Favorites"
    visit "/favorites"

    expect(page).to have_content("Favorites")

    visit "/"
    click_button "Logout"

    visit "/"
    fill_in "email", with: users[1].email
    fill_in "password", with: users[1].password

    click_button "Login"
    expect(page).to have_content("Welcome")

    visit "/favorites"
    expect(page).to have_content("Favorites")
    expect(page).to_not have_content("Remove from Favorites")
  end
end