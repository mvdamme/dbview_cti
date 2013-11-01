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
      (1..2).map { SpaceShip.create(:name => 'test') }
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
      # test build functionality for adding to existing collection
      expect {
        @shuttle.launches.build(:date => Date.yesterday)
        @shuttle.save!
      }.to change(Launch, :count).by(1)
      @shuttle.launches.order(:id).last.date.should eq Date.yesterday
      # test build functionality for new collection
      @shuttle.launches.clear
      @shuttle.launch_ids.should eq []
      expect {
        @shuttle.name = 'Shuttle'
        @shuttle.launches.build(:date => Date.yesterday)
        @shuttle.save!
      }.to change(Launch, :count).by(1)
      @shuttle.name.should eq 'Shuttle'
      # test build functionality for new collection and new object
      shuttle = SpaceShuttle.new(:name => 'Endeavour', :reliability => 100)
      expect {
        expect {
          shuttle.name = 'Shuttle'
          shuttle.launches.build(:date => Date.yesterday)
          shuttle.launches.build(:date => Date.tomorrow)
          shuttle.save!
        }.to change(Launch, :count).by(2)
      }.to change(SpaceShuttle, :count).by(1)
      shuttle.reload
      shuttle.name.should eq 'Shuttle'
      # test adding onto existing collection
      expect {
        shuttle.launches.build(:date => Date.today)
        shuttle.save!
      }.to change(Launch, :count).by(1)
      shuttle.launches.order(:id).last.date.should eq Date.today
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

    it "supports accepts_nested_attributes for has_many associations defined in ascendant classes" do
      expect {
        @shuttle.launches_attributes = [
          {:date => Date.today }, {:date => Date.yesterday }
        ]
        @shuttle.save!
      }.to change(Launch, :count).by(2)
      @shuttle.launches.order(:date).map(&:date).should eq [ Date.yesterday, Date.today ]
      # do the same for a new object
      shuttle = SpaceShuttle.new(:name => 'Endeavour', :reliability => 100)
      expect {
        expect {
          shuttle.launches_attributes = [
            {:date => Date.today }, {:date => Date.yesterday }
          ]
          shuttle.save!
        }.to change(Launch, :count).by(2)
      }.to change(SpaceShuttle, :count).by(1)
      shuttle.launches.order(:date).map(&:date).should eq [ Date.yesterday, Date.today ]
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
      # test build functionality for adding to existing collection
      expect {
        @shuttle.experiments.build(:name => 'Superconductivity')
        @shuttle.save!
      }.to change(Experiment, :count).by(1)
      @shuttle.experiments.order(:id).last.name.should eq 'Superconductivity'
      # test build functionality for new collection
      @shuttle.experiments.clear
      @shuttle.experiment_ids.should eq []
      expect {
        @shuttle.name = 'Shuttle'
        @shuttle.experiments.build(:name => 'Failed experiment')
        @shuttle.save!
      }.to change(Experiment, :count).by(1)
      @shuttle.experiments.first.name.should eq 'Failed experiment'
      @shuttle.name.should eq 'Shuttle'
      # test build functionality for new collection and new object
      shuttle = SpaceShuttle.new(:name => 'Endeavour', :reliability => 100)
      expect {
        expect {
          shuttle.name = 'Shuttle'
          shuttle.experiments.build(:name => 'Exp1')
          shuttle.experiments.build(:name => 'Exp2')
          shuttle.save!
        }.to change(Experiment, :count).by(2)
      }.to change(SpaceShuttle, :count).by(1)
      shuttle.reload
      shuttle.name.should eq 'Shuttle'
      shuttle.experiments.order(:name).map(&:name).should eq ['Exp1', 'Exp2']
      # test adding onto existing collection (new object)
      expect {
        shuttle.experiments.build(:name => 'Exp3')
        shuttle.save!
      }.to change(Experiment, :count).by(1)
      shuttle.experiments.order(:name).map(&:name).should eq ['Exp1', 'Exp2', 'Exp3']
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
    
    it "supports accepts_nested_attributes for has_many :through associations defined in ascendant classes" do
      expect {
        @shuttle.experiments_attributes = [
          {:name => 'Exp1'}, {:name => 'Exp2'}
        ]
        @shuttle.save!
      }.to change(Experiment, :count).by(2)
      @shuttle.experiments.order(:name).map(&:name).should eq [ 'Exp1', 'Exp2' ]
      # do the same for a new object
      shuttle = SpaceShuttle.new(:name => 'Endeavour', :reliability => 100)
      expect {
        expect {
          shuttle.experiments_attributes = [
            {:name => 'Exp1'}, {:name => 'Exp2'}
          ]
          shuttle.save!
        }.to change(Experiment, :count).by(2)
      }.to change(SpaceShuttle, :count).by(1)
      shuttle.experiments.order(:name).map(&:name).should eq [ 'Exp1', 'Exp2' ]
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
      Captain.all.map(&:destroy)
      # test build for existing object
      expect {
        cap = @shuttle.build_captain(:name => 'Aldrinn')
        @shuttle.save!
      }.to change(Captain, :count).by(1)
      @shuttle.captain.space_ship_id.should eq @shuttle.convert_to(:space_ship).id
      # test build for new object
      shuttle = SpaceShuttle.new(:name => 'Endeavour', :reliability => 100)
      expect {
        expect {
          shuttle.name = 'Shuttle'
          cap = shuttle.build_captain(:name => 'Aldrinn')
          shuttle.save!
        }.to change(Captain, :count).by(1)
      }.to change(SpaceShuttle, :count).by(1)
      shuttle.name.should eq 'Shuttle'
      shuttle.captain.space_ship_id.should eq shuttle.convert_to(:space_ship).id
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
    
    it "supports accepts_nested_attributes for has_one associations defined in ascendant classes" do
      expect {
        @shuttle.captain_attributes = {:name => 'Haddock'}
        @shuttle.save!
      }.to change(Captain, :count).by(1)
      @shuttle.captain.name.should eq 'Haddock'
      # do the same for a new object
      shuttle = SpaceShuttle.new(:name => 'Endeavour', :reliability => 100)
      expect {
        expect {
          shuttle.captain_attributes = {:name => 'Haddock'}
          shuttle.save!
        }.to change(Captain, :count).by(1)
      }.to change(SpaceShuttle, :count).by(1)
      shuttle.captain.name.should eq 'Haddock'
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
      # test build functionality for adding to existing collection
      expect {
        @shuttle.astronauts.build(:name => 'astro1')
        @shuttle.save!
      }.to change(Astronaut, :count).by(1)
      @shuttle.astronauts.order(:id).last.name.should eq 'astro1'
      # test build functionality for new collection
      @shuttle.astronauts.clear
      @shuttle.astronaut_ids.should eq []
      expect {
        @shuttle.name = 'Shuttle'
        @shuttle.astronauts.build(:name => 'astro2')
        @shuttle.save!
      }.to change(Astronaut, :count).by(1)
      @shuttle.astronauts.first.name.should eq 'astro2'
      @shuttle.name.should eq 'Shuttle'
      # test build functionality for new collection and new object
      shuttle = SpaceShuttle.new(:name => 'Endeavour', :reliability => 100)
      expect {
        expect {
          shuttle.name = 'Shuttle'
          shuttle.astronauts.build(:name => 'Astro1')
          shuttle.astronauts.build(:name => 'Astro2')
          shuttle.save!
        }.to change(Astronaut, :count).by(2)
      }.to change(SpaceShuttle, :count).by(1)
      shuttle.reload
      shuttle.name.should eq 'Shuttle'
      shuttle.astronauts.order(:name).map(&:name).should eq ['Astro1', 'Astro2']
      # test adding onto existing collection (new object)
      expect {
        shuttle.astronauts.build(:name => 'Astro3')
        shuttle.save!
      }.to change(Astronaut, :count).by(1)
      shuttle.astronauts.order(:name).map(&:name).should eq ['Astro1', 'Astro2', 'Astro3']
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

    it "supports accepts_nested_attributes for has_and_belongs_to_many associations defined in ascendant classes" do
      expect {
        @shuttle.astronauts_attributes = [
          {:name => 'Astro1'}, {:name => 'Astro2'}
        ]
        @shuttle.save!
      }.to change(Astronaut, :count).by(2)
      @shuttle.astronauts.order(:name).map(&:name).should eq [ 'Astro1', 'Astro2' ]
      # do the same for a new object
      shuttle = SpaceShuttle.new(:name => 'Endeavour', :reliability => 100)
      expect {
        expect {
          shuttle.astronauts_attributes = [
            {:name => 'Astro1'}, {:name => 'Astro2'}
          ]
          shuttle.save!
        }.to change(Astronaut, :count).by(2)
      }.to change(SpaceShuttle, :count).by(1)
      shuttle.astronauts.order(:name).map(&:name).should eq [ 'Astro1', 'Astro2' ]
    end
        
    it "doesn't choke on belongs_to associations" do
      @shuttle.category # should not raise exception
    end    
    
    it "doesn't save in case of validation errors in associations defined in ascendant classes" do
      expect {
        @shuttle.launches.build
        @shuttle.save!
      }.to raise_exception(ActiveRecord::RecordInvalid)
      # same with new object
      shuttle = SpaceShuttle.new(:name => 'Endeavour', :reliability => 100)
      expect {
        shuttle.launches.build
        shuttle.save!
      }.to raise_exception(ActiveRecord::RecordInvalid)
    end

    it "doesn't choke on non-association related validations in association proxies" do
      @shuttle.update_attribute(:name, nil)
      expect {
        @shuttle.save!
      }.to raise_exception(ActiveRecord::RecordInvalid)
      expect {
        @shuttle.name = 'Name'
        @shuttle.launches.build(:date => Date.today)
        @shuttle.save!
      }.to change(Launch, :count).by(1)
      # similar for new object
      shuttle = SpaceShuttle.new
      expect {
        shuttle.launches.build(:date => Date.today)
        shuttle.save!
      }.to raise_exception(ActiveRecord::RecordInvalid)
      expect {
        expect {
          shuttle.name = 'Name'
          shuttle.save!
        }.to change(Launch, :count).by(1)
      }.to change(SpaceShuttle, :count).by(1)
    end
    
  end

end
