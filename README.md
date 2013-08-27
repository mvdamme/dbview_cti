# dbview_cti
[![Build Status](https://travis-ci.org/mvdamme/dbview_cti.png)](https://travis-ci.org/mvdamme/dbview_cti)

This gem implements [Class Table Inheritance](http://martinfowler.com/eaaCatalog/classTableInheritance.html) (CTI) 
for Rails, as an alternative to Single Table Inheritance (STI). The implementation is based on database views.

Currently, only PostgreSQL (version >= 9.1) is supported. The gem works for both Rails 3.2 and Rails 4 apps.

## Installation

Add the following to your Gemfile:

```ruby
gem 'dbview_cti'
```

## Example

Suppose we would like to have the following class hierarchy: a Vehicle superclass, its subclass MotorVehicle, and Car and MotorCycle wich are subclasses of MotorVehicle:
 
```ruby
class Vehicle < ActiveRecord::Base
end

class MotorVehicle < Vehicle
end

class Car < MotorVehicle
end

class MotorCycle < MotorVehicle
end
```

With Class Table Inheritance, we use a separate database table for each class. Each table only stores the attributes that are specific to that class.
dbview_cti uses database views to combine attributes from several tables in the hierarchy in an almost transparent way, so the resulting objects behave like
normal ActiveRecord models (with a few exceptions).

In order to do this dbview_cti has to know all descendants of a class, so we modify our class definitions:

```ruby
class Vehicle < ActiveRecord::Base
  cti_base_class
end

class MotorVehicle < Vehicle
  cti_derived_class
end

class Car < MotorVehicle
  cti_derived_class
end

class MotorCycle < MotorVehicle
  cti_derived_class
end
```

In the base class in the hierarchy (Vehicle in this case), we add a call to `cti_base_class`, in all derived classes we add `cti_derived_class`. 
It is important to add these before running any migrations for the models, otherwise the database views won't be generated correctly (it is always possible to have them
regenerated, see further).

Now it's time to create the database tables (and views) using Rails migrations. The table for the base class is created using a standard migration, e.g.   

```ruby
class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles do |t|
      t.string  :name
      t.integer :mass

      t.timestamps
    end
  end
end
```

For the derived classes, we use `cti_create_view(class_name)`, a method that dbview_cti adds to migrations: 

```ruby
class CreateMotorVehicles < ActiveRecord::Migration
  def change
    create_table :motor_vehicles do |t|
      t.references :vehicle
      t.string  :fuel
      t.integer :number_of_wheels

      t.timestamps
    end
    
    cti_create_view('MotorVehicle')
  end
end
```

There are two things to note in this migration:

1. The table references the table used for the parent class (vehicles in this case)
2. We call `cti_create_view(class_name)` to create the necessary database view and triggers, and to tell ActiveRecord to use the database view instead of the motor_vehicles table.

The migrations for Car and MotorCycle are very similar (i.e. they reference the parent table and call cti_create_view):

```ruby
class CreateCars < ActiveRecord::Migration
  def change
    create_table :cars do |t|
      t.references :motor_vehicle
      t.boolean :stick_shift
      t.boolean :convertible

      t.timestamps
    end
    
    cti_create_view('Car')
  end
end

class CreateMotorCycles < ActiveRecord::Migration
  def change
    create_table :motor_cycles do |t|
      t.references :motor_vehicle
      t.boolean :offroad

      t.timestamps
    end
    
    cti_create_view('MotorCycle')
  end
end
```

After running `rake db:migrate` we can now use our new models, e.g. in the rails console:

    1.9.3-p448 :001 > c = Car.new
     => #<Car id: nil, name: nil, mass: nil, fuel: nil, number_of_wheels: nil, stick_shift: nil, convertible: nil, created_at: nil, updated_at: nil> 
    1.9.3-p448 :003 > c.name = 'Audi'
     => "Audi" 
    1.9.3-p448 :004 > c.stick_shift = true
     => true 
    1.9.3-p448 :005 > c.save!
     => true 

Note that Car has all attributes of the vehicles, motor_vehicles and cars tables combined. When saving, the attributes are stored in their corresponding tables.

## API

### Models

dbview_cti adds two class methods to ActiveRecord::Base:

* `cti_base_class`, which should be included in the class definition of the base class of the hierarchy.
* `cti_derived_class`, which should be included in the class definition of every other class in the hierarchy.

When either `cti_base_class` or `cti_derived_class` are used in the definition of a model, the model is equipped with the following instance methods:

* `convert_to(class_name)`. Use this to convert an object to another class. Both `convert_to('MotorVehicle')` and `convert_to(:motor_vehicle)` are ok. Example: 

        1.9.3-p448 :003 > c = Car.create(:name => 'Audi')
         => #<Car id: 2, name: "Audi", mass: nil, fuel: nil, number_of_wheels: nil, stick_shift: nil, convertible: nil, created_at: "2013-08-20 01:17:07", updated_at: "2013-08-20 01:17:07"> 
        1.9.3-p448 :004 > v = c.convert_to(:vehicle)
         => #<Vehicle id: 3, name: "Audi", mass: nil, created_at: "2013-08-20 01:17:07", updated_at: "2013-08-20 01:17:07"> 
        1.9.3-p448 :005 > v.convert_to(:car)  # convert back to Car
         => #<Car id: 2, name: "Audi", mass: nil, fuel: nil, number_of_wheels: nil, stick_shift: nil, convertible: nil, created_at: "2013-08-20 01:17:07", updated_at: "2013-08-20 01:17:07"> 
        1.9.3-p448 :009 > v.convert_to(:motor_cycle)  # since v is a car we cannot convert it to a MotorCycle
         => nil 

* `specialize` converts an object to its 'true' (i.e. most specialized or most derived) class. Example:

        1.9.3-p448 :010 > c = Car.create(:name => 'Volvo')
         => #<Car id: 4, name: "Volvo", mass: nil, fuel: nil, number_of_wheels: nil, stick_shift: nil, convertible: nil, created_at: "2013-08-20 01:27:26", updated_at: "2013-08-20 01:27:26"> 
        1.9.3-p448 :011 > mv = MotorVehicle.create(:name => 'Trike')
         => #<MotorVehicle id: 5, name: "Trike", mass: nil, fuel: nil, number_of_wheels: nil, created_at: "2013-08-20 01:28:06", updated_at: "2013-08-20 01:28:06"> 
        1.9.3-p448 :012 > c.convert_to(:vehicle).specialize
         => #<Car id: 4, name: "Volvo", mass: nil, fuel: nil, number_of_wheels: nil, stick_shift: nil, convertible: nil, created_at: "2013-08-20 01:27:26", updated_at: "2013-08-20 01:27:26"> 
        1.9.3-p448 :013 > mv.convert_to(:vehicle).specialize
         => #<MotorVehicle id: 5, name: "Trike", mass: nil, fuel: nil, number_of_wheels: nil, created_at: "2013-08-20 01:28:06", updated_at: "2013-08-20 01:28:06"> 

* `type` returns the 'true' (i.e. most specialized) class of an object (the class that the object is converted to when calling `specialize`).

### Migrations

dbview_cti adds two methods to migrations:

* `cti_create_view(class_name)`
* `cti_drop_view(class_name)`

See the example migrations above about how to use `cti_create_view`. `cti_drop_view` can be used to drop a view created by `cti_create_view`
(e.g. in the `down` method of a migration.)

It is also possible to recreate the database views (and triggers). This is necessary when you want to change one of the tables in the hierarchy, 
since then the views of all subclasses have to be recreated. dbview_cti provides the `cti_recreate_views_after_change_to(class_name)` method 
(to be used with a block) to do this:

```ruby
class AddReliabilityToMotorVehicles < ActiveRecord::Migration
  def up
    cti_recreate_views_after_change_to('MotorVehicle') do
      add_column(:motor_vehicles, :reliability, :integer)
    end
  end
  
  def down
    cti_recreate_views_after_change_to('MotorVehicle') do
      remove_column(:motor_vehicles, :reliability)
    end
  end
end
```

The `change` syntax is not (yet?) supported for recreating database views.

## Notes

* Using dbview_cti doesn't interfere with foreign key constraints. In fact, I recommend adding foreign key constraints
between the tables in a CTI hierarchy (e.g. using [foreigner](https://github.com/matthuhiggins/foreigner)).
* Take care when using database id's. Since the data for a Car object is spread over several tables, 
the id of a Car instance will generally be different than the id of the MotorVehicle instance you get when you 
convert the Car instance to a MotorVehicle.
* The gem intercepts calls to destroy to make sure all rows in all tables are removed. This is not the case for 
delete_all, however, so avoid using delete_all for classes in the CTI hierarchy.
