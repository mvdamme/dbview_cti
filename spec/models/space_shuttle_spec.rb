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
    }.to raise_error(ActiveRecord::InvalidForeignKey)
  end
  
  it "stores attributes that were added to ascendant classes after initial creation of the tables" do
    shuttle = SpaceShuttle.create(:name => 'Discovery', :reliability => 100)
    expect(shuttle.convert_to(:space_ship).reliability).to eq 100
  end
  
  context 'associations' do
    before :each do
      # create dummy space ships to make sure the shuttle we'll create has a different database id than
      # its associated spaceship
      (1..2).map { SpaceShip.create(:name => 'test') }
      @shuttle = SpaceShuttle.create(:name => 'Discovery', :reliability => 100)
      expect(@shuttle.id).not_to eq @shuttle.convert_to(:space_ship).id
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
      expect(@shuttle.launch_ids.sort).to eq [ launch1.id, launch2.id ]
      launch3.save!
      @shuttle.launch_ids = [ launch1.id, launch3.id ]
      expect(@shuttle.launch_ids.sort).to eq [ launch1.id, launch3.id ]
      # test build functionality for adding to existing collection
      expect {
        @shuttle.launches.build(:date => Date.yesterday)
        @shuttle.save!
      }.to change(Launch, :count).by(1)
      expect(@shuttle.launches.order(:id).last.date).to eq Date.yesterday
      # test build functionality for new collection
      @shuttle.launches.clear
      expect(@shuttle.launch_ids).to eq []
      expect {
        @shuttle.name = 'Shuttle'
        @shuttle.launches.build(:date => Date.yesterday)
        @shuttle.save!
      }.to change(Launch, :count).by(1)
      expect(@shuttle.name).to eq 'Shuttle'
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
      expect(shuttle.name).to eq 'Shuttle'
      # test adding onto existing collection
      expect {
        shuttle.launches.build(:date => Date.today)
        shuttle.save!
      }.to change(Launch, :count).by(1)
      expect(shuttle.launches.order(:id).last.date).to eq Date.today
    end
  
    it "supports assignment on the 'remote' side of a has_many association" do
      launch = Launch.new(:date => Date.today)
      expect {
        launch.space_ship = @shuttle
        launch.save!
      }.to change(Launch, :count).by(1)
      expect( @shuttle.convert_to(:space_ship).id ).to eq( launch.space_ship_id )
      launch.destroy
      launch = Launch.new(:date => Date.today)
      expect {
        launch.space_ship = @shuttle.convert_to(:vehicle)
        launch.save!
      }.to change(Launch, :count).by(1)
      launch = Launch.new(:date => Date.today)
      # also test nil assignment
      expect {
        launch.space_ship = nil
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
      expect(@shuttle.launches.order(:date).map(&:date)).to eq [ Date.yesterday, Date.today ]
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
      expect(shuttle.launches.order(:date).map(&:date)).to eq [ Date.yesterday, Date.today ]
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
      expect(@shuttle.experiment_ids.sort).to eq [ experiment1.id, experiment2.id ]
      experiment3.save!
      @shuttle.experiment_ids = [ experiment1.id, experiment3.id ]
      expect(@shuttle.experiment_ids.sort).to eq [ experiment1.id, experiment3.id ]
      expect(Experiment.last.space_ships.first.specialize.id).to eq @shuttle.id
      # test build functionality for adding to existing collection
      expect {
        @shuttle.experiments.build(:name => 'Superconductivity')
        @shuttle.save!
      }.to change(Experiment, :count).by(1)
      expect(@shuttle.experiments.order(:id).last.name).to eq 'Superconductivity'
      # test build functionality for new collection
      @shuttle.experiments.clear
      expect(@shuttle.experiment_ids).to eq []
      expect {
        @shuttle.name = 'Shuttle'
        @shuttle.experiments.build(:name => 'Failed experiment')
        @shuttle.save!
      }.to change(Experiment, :count).by(1)
      expect(@shuttle.experiments.first.name).to eq 'Failed experiment'
      expect(@shuttle.name).to eq 'Shuttle'
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
      expect(shuttle.name).to eq 'Shuttle'
      expect(shuttle.experiments.order(:name).map(&:name)).to eq ['Exp1', 'Exp2']
      # test adding onto existing collection (new object)
      expect {
        shuttle.experiments.build(:name => 'Exp3')
        shuttle.save!
      }.to change(Experiment, :count).by(1)
      expect(shuttle.experiments.order(:name).map(&:name)).to eq ['Exp1', 'Exp2', 'Exp3']
    end
  
    it "supports operations on the 'remote' side of a has_many :through association" do
      experiment = Experiment.new(:name => 'Zero-gravity')
      shuttle2 = SpaceShuttle.create(:name => 'Endeavour', :reliability => 100)
      expect(shuttle2.id).not_to eq shuttle2.convert_to(:space_ship).id
      expect {
        experiment.space_ships = [@shuttle, shuttle2]
        experiment.save!
      }.to change(ExperimentSpaceShipPerformance, :count).by(2)
      expect( experiment.space_ships.order(:id).map(&:id) ).to eq( [ @shuttle.convert_to(:space_ship).id, shuttle2.convert_to(:space_ship).id ] )
      ExperimentSpaceShipPerformance.all.map(&:destroy)
      expect {
        experiment.space_ships << @shuttle
        experiment.save!
      }.to change(ExperimentSpaceShipPerformance, :count).by(1)
      expect {
        experiment.space_ships.delete(@shuttle)
      }.to change(ExperimentSpaceShipPerformance, :count).by(-1)
      # make sure nil assignments raise activerecord exceptions and not exceptions in dbview_cti code
      expect {
        experiment.space_ships = [ nil ]
        experiment.save!
      }.to raise_error(ActiveRecord::AssociationTypeMismatch)
      expect {
        experiment.space_ships << nil
        experiment.save!
      }.to raise_error(ActiveRecord::AssociationTypeMismatch)
      expect {
        experiment.space_ships.delete(nil)
      }.to raise_error(ActiveRecord::AssociationTypeMismatch)
    end
    
    it "supports accepts_nested_attributes for has_many :through associations defined in ascendant classes" do
      expect {
        @shuttle.experiments_attributes = [
          {:name => 'Exp1'}, {:name => 'Exp2'}
        ]
        @shuttle.save!
      }.to change(Experiment, :count).by(2)
      expect(@shuttle.experiments.order(:name).map(&:name)).to eq [ 'Exp1', 'Exp2' ]
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
      expect(shuttle.experiments.order(:name).map(&:name)).to eq [ 'Exp1', 'Exp2' ]
    end
    
    it "can use has_one associations defined in ascendant classes" do
      captain = Captain.new(:name => 'Armstrong')
      expect {
        @shuttle.captain = captain
        @shuttle.save!
      }.to change(Captain, :count).by(1)
      @shuttle.reload
      expect(@shuttle.captain.id).to eq captain.id
      @shuttle.captain.destroy
      expect {
        @shuttle.create_captain(:name => 'Glenn')
      }.to change(Captain, :count).by(1)
      expect(@shuttle.captain.space_ship_id).to eq @shuttle.convert_to(:space_ship).id
      Captain.all.map(&:destroy)
      # test build for existing object
      expect {
        cap = @shuttle.build_captain(:name => 'Aldrinn')
        @shuttle.save!
      }.to change(Captain, :count).by(1)
      expect(@shuttle.captain.space_ship_id).to eq @shuttle.convert_to(:space_ship).id
      # test build for new object
      shuttle = SpaceShuttle.new(:name => 'Endeavour', :reliability => 100)
      expect {
        expect {
          shuttle.name = 'Shuttle'
          cap = shuttle.build_captain(:name => 'Aldrinn')
          shuttle.save!
        }.to change(Captain, :count).by(1)
      }.to change(SpaceShuttle, :count).by(1)
      expect(shuttle.name).to eq 'Shuttle'
      expect(shuttle.captain.space_ship_id).to eq shuttle.convert_to(:space_ship).id
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
      # also test nil assignment
      captain = Captain.new(:name => 'Armstrong')
      expect {
        captain.space_ship = nil
        captain.save!
      }.to change(Captain, :count).by(1)
    end
    
    it "supports accepts_nested_attributes for has_one associations defined in ascendant classes" do
      expect {
        @shuttle.captain_attributes = {:name => 'Haddock'}
        @shuttle.save!
      }.to change(Captain, :count).by(1)
      expect(@shuttle.captain.name).to eq 'Haddock'
      # do the same for a new object
      shuttle = SpaceShuttle.new(:name => 'Endeavour', :reliability => 100)
      expect {
        expect {
          shuttle.captain_attributes = {:name => 'Haddock'}
          shuttle.save!
        }.to change(Captain, :count).by(1)
      }.to change(SpaceShuttle, :count).by(1)
      expect(shuttle.captain.name).to eq 'Haddock'
    end
    
    it "can use has_and_belongs_to_many associations defined in ascendant classes" do
      astronaut1 = Astronaut.new(:name => 'Armstrong')
      astronaut2 = Astronaut.new(:name => 'Glenn')
      astronaut3 = Astronaut.new(:name => 'Gagarin')
      expect {
        @shuttle.astronauts << astronaut1
        @shuttle.save!
      }.to change(Astronaut, :count).by(1)
      expect(@shuttle.astronauts.first.name).to eq astronaut1.name
      expect {
        @shuttle.astronauts = [ astronaut1, astronaut2 ]
        @shuttle.save!
      }.to change(Astronaut, :count).by(1)
      expect(@shuttle.astronaut_ids.sort).to eq [ astronaut1.id, astronaut2.id ]
      astronaut3.save!
      @shuttle.astronaut_ids = [ astronaut1.id, astronaut3.id ]
      expect(@shuttle.astronaut_ids.sort).to eq [ astronaut1.id, astronaut3.id ]
      # test build functionality for adding to existing collection
      expect {
        @shuttle.astronauts.build(:name => 'astro1')
        @shuttle.save!
      }.to change(Astronaut, :count).by(1)
      expect(@shuttle.astronauts.order(:id).last.name).to eq 'astro1'
      # test build functionality for new collection
      @shuttle.astronauts.clear
      expect(@shuttle.astronaut_ids).to eq []
      expect {
        @shuttle.name = 'Shuttle'
        @shuttle.astronauts.build(:name => 'astro2')
        @shuttle.save!
      }.to change(Astronaut, :count).by(1)
      expect(@shuttle.astronauts.first.name).to eq 'astro2'
      expect(@shuttle.name).to eq 'Shuttle'
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
      expect(shuttle.name).to eq 'Shuttle'
      expect(shuttle.astronauts.order(:name).map(&:name)).to eq ['Astro1', 'Astro2']
      # test adding onto existing collection (new object)
      expect {
        shuttle.astronauts.build(:name => 'Astro3')
        shuttle.save!
      }.to change(Astronaut, :count).by(1)
      expect(shuttle.astronauts.order(:name).map(&:name)).to eq ['Astro1', 'Astro2', 'Astro3']
    end

    it "supports operations on the 'remote' side of a has_and_belongs_to_many association" do
      astronaut = Astronaut.new(:name => 'Armstrong')
      shuttle2 = SpaceShuttle.create(:name => 'Endeavour', :reliability => 100)
      expect(shuttle2.id).not_to eq shuttle2.convert_to(:space_ship).id
      query = 'SELECT COUNT(*) FROM astronauts_space_ships'
      expect(ActiveRecord::Base.connection().execute(query)[0]['count'].to_i).to be_zero
      astronaut.space_ships = [@shuttle, shuttle2]
      astronaut.save!
      expect(ActiveRecord::Base.connection().execute(query)[0]['count'].to_i).to eq 2
      astronaut.space_ships.delete(@shuttle, shuttle2)
      expect(ActiveRecord::Base.connection().execute(query)[0]['count'].to_i).to be_zero
      astronaut.space_ships << @shuttle
      astronaut.save!
      expect(ActiveRecord::Base.connection().execute(query)[0]['count'].to_i).to eq 1
      astronaut.space_ships.destroy(@shuttle)
      expect(ActiveRecord::Base.connection().execute(query)[0]['count'].to_i).to be_zero
      # make sure nil assignments raise activerecord exceptions and not exceptions in dbview_cti code
      expect {
        astronaut.space_ships = [nil]
        astronaut.save!
      }.to raise_error(ActiveRecord::AssociationTypeMismatch)
      expect {
        astronaut.space_ships << nil
        astronaut.save!
      }.to raise_error(ActiveRecord::AssociationTypeMismatch)
      expect {
        astronaut.space_ships.destroy(nil)
      }.to raise_error(ActiveRecord::AssociationTypeMismatch)
    end

    it "supports accepts_nested_attributes for has_and_belongs_to_many associations defined in ascendant classes" do
      expect {
        @shuttle.astronauts_attributes = [
          {:name => 'Astro1'}, {:name => 'Astro2'}
        ]
        @shuttle.save!
      }.to change(Astronaut, :count).by(2)
      expect(@shuttle.astronauts.order(:name).map(&:name)).to eq [ 'Astro1', 'Astro2' ]
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
      expect(shuttle.astronauts.order(:name).map(&:name)).to eq [ 'Astro1', 'Astro2' ]
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
    
    it "association logic also works for associations with non-standard names" do
      # check has_many side
      shuttle2 = SpaceShuttle.create(:name => 'Endeavour', :reliability => 100)
      @shuttle.upgraded_to << shuttle2
      @shuttle.save!
      shuttle2.reload
      expect(shuttle2.upgraded_from.specialize.id).to eq @shuttle.id
      # check belongs_to side
      shuttle3 = SpaceShuttle.create(:name => 'Endeavour', :reliability => 100)
      @shuttle.upgraded_from = shuttle3
      @shuttle.save!
      @shuttle.reload
      expect(@shuttle.upgraded_from.specialize.id).to eq shuttle3.id
    end

  end

end
