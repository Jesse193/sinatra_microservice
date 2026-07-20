require "spec_helper"

RSpec.describe "Search", type: :feature do
  let!(:markets) { create_list(:market, 7) }

  it "searches for markets by address" do
    visit "/"

    click_button "Accept"

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

    expect(page).to have_content("501 Foster Street, Durham, North Carolina 27701")
    expect(page).to have_content("Get directions")
  end
end