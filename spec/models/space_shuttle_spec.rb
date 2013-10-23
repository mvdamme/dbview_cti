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
  
  context 'associations' do
    before :each do
      # create dummy space ships to make sure the shuttle we'll create has a different database id than
      # its associated spaceship
      (1..2).map { SpaceShip.create }
      @shuttle = SpaceShuttle.create(:name => 'Discovery', :reliability => 100)
      @shuttle.id.should_not eq @shuttle.convert_to(:space_ship).id
    end
    
    it "can use has_many associations defined in ascendant classes" do
      launch1 = Launch.new(:date => Date.today)
      launch2 = Launch.new(:date => Date.tomorrow)
      launch3 = Launch.new(:date => Date.tomorrow)
      expect {
        @shuttle.launches << launch1
        @shuttle.save!
      }.to change(Launch, :count).by(1)
      expect {
        @shuttle.launches = [ launch1, launch2 ]
        @shuttle.save!
      }.to change(Launch, :count).by(1)
      @shuttle.launch_ids.sort.should eq [ launch1.id, launch2.id ]
      launch3.save!
      @shuttle.launch_ids = [ launch1.id, launch3.id ]
      @shuttle.launch_ids.sort.should eq [ launch1.id, launch3.id ]
    end
  
    it "supports assignment on the 'remote' side of a has_many association" do
      launch = Launch.new(:date => Date.today)
      expect {
        launch.space_ship = @shuttle
        launch.save!
      }.to change(Launch, :count).by(1)
      launch.destroy
      launch = Launch.new(:date => Date.today)
      expect {
        launch.space_ship = @shuttle.convert_to(:vehicle)
        launch.save!
      }.to change(Launch, :count).by(1)
    end
    
    it "can use has_many :through associations defined in ascendant classes" do
      experiment1 = Experiment.new(:name => 'Zero-gravity')
      experiment2 = Experiment.new(:name => 'Physics 101')
      experiment3 = Experiment.new(:name => 'Cell growth')
      expect {
        @shuttle.experiments << experiment1
        @shuttle.save!
      }.to change(Experiment, :count).by(1)
      expect {
        @shuttle.experiments = [ experiment1, experiment2 ]
        @shuttle.save!
      }.to change(Experiment, :count).by(1)
      @shuttle.experiment_ids.sort.should eq [ experiment1.id, experiment2.id ]
      experiment3.save!
      @shuttle.experiment_ids = [ experiment1.id, experiment3.id ]
      @shuttle.experiment_ids.sort.should eq [ experiment1.id, experiment3.id ]
      Experiment.last.space_ships.first.specialize.id.should eq @shuttle.id
    end
  
    it "supports operations on the 'remote' side of a has_many :through association" do
      experiment = Experiment.new(:name => 'Zero-gravity')
      shuttle2 = SpaceShuttle.create(:name => 'Endeavour', :reliability => 100)
      shuttle2.id.should_not eq shuttle2.convert_to(:space_ship).id
      expect {
        experiment.space_ships = [@shuttle, shuttle2]
        experiment.save!
      }.to change(ExperimentSpaceShipPerformance, :count).by(2)
      ExperimentSpaceShipPerformance.all.map(&:destroy)
      expect {
        experiment.space_ships << @shuttle
        experiment.save!
      }.to change(ExperimentSpaceShipPerformance, :count).by(1)
      expect {
        experiment.space_ships.delete(@shuttle)
      }.to change(ExperimentSpaceShipPerformance, :count).by(-1)
    end
    
    it "can use has_one associations defined in ascendant classes" do
      captain = Captain.new(:name => 'Armstrong')
      expect {
        @shuttle.captain = captain
        @shuttle.save!
      }.to change(Captain, :count).by(1)
      @shuttle.reload
      @shuttle.captain.id.should eq captain.id
      @shuttle.captain.destroy
      expect {
        @shuttle.create_captain(:name => 'Glenn')
      }.to change(Captain, :count).by(1)
      @shuttle.captain.space_ship_id.should eq @shuttle.convert_to(:space_ship).id
      expect {
        cap = @shuttle.build_captain(:name => 'Aldrinn')
        cap.save!
      }.to change(Captain, :count).by(1)
      @shuttle.captain.space_ship_id.should eq @shuttle.convert_to(:space_ship).id
    end
  
    it "supports operations on the 'remote' side of a has_one association" do
      captain = Captain.new(:name => 'Armstrong')
      expect {
        captain.space_ship = @shuttle
        captain.save!
      }.to change(Captain, :count).by(1)
      captain.destroy
      captain = Captain.new(:name => 'Armstrong')
      expect {
        captain.space_ship = @shuttle.convert_to(:vehicle)
        captain.save!
      }.to change(Captain, :count).by(1)
    end
    
    it "can use has_and_belongs_to_many associations defined in ascendant classes" do
      astronaut1 = Astronaut.new(:name => 'Armstrong')
      astronaut2 = Astronaut.new(:name => 'Glenn')
      astronaut3 = Astronaut.new(:name => 'Gagarin')
      expect {
        @shuttle.astronauts << astronaut1
        @shuttle.save!
      }.to change(Astronaut, :count).by(1)
      @shuttle.astronauts.first.name.should eq astronaut1.name
      expect {
        @shuttle.astronauts = [ astronaut1, astronaut2 ]
        @shuttle.save!
      }.to change(Astronaut, :count).by(1)
      @shuttle.astronaut_ids.sort.should eq [ astronaut1.id, astronaut2.id ]
      astronaut3.save!
      @shuttle.astronaut_ids = [ astronaut1.id, astronaut3.id ]
      @shuttle.astronaut_ids.sort.should eq [ astronaut1.id, astronaut3.id ]
    end

    it "supports operations on the 'remote' side of a has_and_belongs_to_many association" do
      astronaut = Astronaut.new(:name => 'Armstrong')
      shuttle2 = SpaceShuttle.create(:name => 'Endeavour', :reliability => 100)
      shuttle2.id.should_not eq shuttle2.convert_to(:space_ship).id
      query = 'SELECT COUNT(*) FROM astronauts_space_ships'
      ActiveRecord::Base.connection().execute(query)[0]['count'].to_i.should be_zero
      astronaut.space_ships = [@shuttle, shuttle2]
      astronaut.save!
      ActiveRecord::Base.connection().execute(query)[0]['count'].to_i.should eq 2
      astronaut.space_ships.delete(@shuttle, shuttle2)
      ActiveRecord::Base.connection().execute(query)[0]['count'].to_i.should be_zero
      astronaut.space_ships << @shuttle
      astronaut.save!
      ActiveRecord::Base.connection().execute(query)[0]['count'].to_i.should eq 1
      astronaut.space_ships.destroy(@shuttle)
      ActiveRecord::Base.connection().execute(query)[0]['count'].to_i.should be_zero
    end
    
  end

end
