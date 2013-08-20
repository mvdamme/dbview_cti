module DBViewCTI
  module Names
      
    def self.view_name(klass)
      self.table_name(klass) + '_view'
    end

    def self.table_name(klass)
      ActiveSupport::Inflector.tableize( self.class_name(klass) )
    end
    
    def self.foreign_key(klass)
      ActiveSupport::Inflector.foreign_key( self.class_name(klass) )
    end
    
    def self.class_name(klass)
      klass.is_a?(String) ? klass : klass.name
    end

    def self.trigger_name(klass)
      self.table_name(klass) + '_trig'
    end

    def self.trigger_function_name(klass)
      self.table_name(klass) + '_trgfunc'
    end

    def self.table_to_class_name(table_name)
      ActiveSupport::Inflector.classify( table_name )
    end

  end
end
