# Since the gem provides model methods these tests serve as a kind of 'integration tests' for the gem
require 'spec_helper'

describe SpaceShuttle do
  
  it "raises exception on external foreign key violation caused by destroy" do
    # test that foreign key contraints to tables outside of the CTI hierarchy
    # prevent destroy
    shuttle = SpaceShuttle.create(:name => 'Discovery')
    rocket_engine = RocketEngine.create(:name => 'Booster', 
                                        :space_ship_id => shuttle.convert_to(:space_ship).id)
    expect {
      shuttle.destroy
    }.to raise_error
  end
  
  it "stores attributes that were added to ascendant classes after initial creation of the tables" do
    shuttle = SpaceShuttle.create(:name => 'Discovery', :reliability => 100)
    shuttle.convert_to(:space_ship).reliability.should eq 100
  end
  
end
