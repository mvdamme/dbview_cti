module DBViewCTI
  module Model
    module CTI
      extend ActiveSupport::Concern
      
      def specialize
        class_name, id = type(true)
        return self if class_name == self.class.name
        class_name.constantize.find(id)
      end
      
      # Return the 'true' (i.e. most specialized) classname of this object
      # When return_id is true, the 'specialized' database id is also returned
      def type(return_id = false)
        query, levels = self.class.cti_outer_join_sql(id)
        result = self.class.connection.execute(query).first
        # replace returned ids with the levels corresponding to their classes
        result_levels = result.inject({}) do |hash, (k,v)|
          hash[k] = levels[k] unless v.nil?
          hash
        end
        # find class with maximum level value
        foreign_key = result_levels.max_by { |k,v| v }.first
        class_name = DBViewCTI::Names.table_to_class_name(foreign_key[0..-4])
        if return_id
          id_ = result[foreign_key].to_i
          [class_name, id_]
        else
          class_name
        end
      end
      
      def convert_to(type)
        return nil unless persisted?
        type_string = type.to_s
        type_string = type_string.camelize if type.is_a?(Symbol)
        return self if type_string == self.class.name
        query = self.class.cti_inner_join_sql(id, type_string)
        # query is nil when we try to cenvert to a descendant class (instead of an ascendant),
        # or when we try to convert to a class outside of the hierarchy
        if query.nil?
          specialized = specialize
          return nil if specialized == self
          return specialized.convert_to(type_string)
        end
        result = self.class.connection.execute(query).first
        id = result[ DBViewCTI::Names.foreign_key(type.to_s) ]
        return nil if id.nil?
        type_string.constantize.find(id.to_i)
      end
      
      # change destroy and delete methods to operate on most specialized object
      included do
        alias_method_chain :destroy, :cti
        alias_method_chain :delete, :cti
        # destroy! seems te be defined in Rails 4
        alias_method_chain :destroy!, :cti if self.method_defined?(:destroy!)

        # for associations:
        alias_method_chain :association, :cti
        # save callbacks (necessary for saving associations)
        after_save :cti_save_associations

        # validations
        validate :cti_validate_associations, :cti_no_disable => true
        attr_accessor :cti_disable_validations
      end
      
      def destroy_with_cti
        specialize.destroy_without_cti
      end
      
      def destroy_with_cti!
        specialize.destroy_without_cti!
      end
      
      def delete_with_cti
        specialize.delete_without_cti
      end
      
      def cti_validate_associations
        return_value = true
        self.class.cti_association_proxies.each_key do |proxy_name|
          proxy = instance_variable_get(proxy_name)
          if proxy && !proxy.valid?
            errors.messages.merge!(proxy.errors.messages)
            return_value = false
          end
        end
        return_value
      end

      def cti_save_associations
        self.class.cti_association_proxies.each_key do |proxy_name|
          proxy = instance_variable_get(proxy_name)
          proxy.save if proxy
        end
        true
      end
      
      def association_with_cti(*args)
        return association_without_cti(*args) unless args.length == 1
        association_name = args[0]
        proxy = cti_association_proxy(association_name)
        proxy ||= self
        proxy.association_without_cti(association_name)
      end
      
      def cti_association_proxy(association_name)
        return nil if self.class.reflect_on_all_associations(:belongs_to).map(&:name).include?(association_name.to_sym)
        proxy_name = self.class.cti_association_proxy_name(association_name)
        proxy = instance_variable_get(proxy_name)
        if !proxy && !self.class.cti_has_association?(association_name)
          instance_variable_set(proxy_name, 
                                ModelDelegator.new(self, self.class.cti_association_proxies[proxy_name]))
          proxy = instance_variable_get(proxy_name)
        end
        proxy
      end

      module ClassMethods
        
        def cti_base_class?
          !!@cti_base_class
        end
  
        def cti_derived_class?
          !!@cti_derived_class
        end
        
        attr_accessor :cti_descendants, :cti_ascendants, :cti_association_proxies
        
        # registers a derived class and its descendants in the current class
        # class_name: name of derived class (the one calling cti_register_descendants on this class)
        # descendants: the descendants of the derived class
        def cti_register_descendants(class_name, descendants = {})
          @cti_descendants ||= {}
          @cti_descendants[class_name] = descendants
          if cti_derived_class?
            # call up the chain. This will also cause the register_ascendants callbacks
            self.superclass.cti_register_descendants(self.name, @cti_descendants)
          end
          # call back to calling class
          @cti_ascendants ||= []
          class_name.constantize.cti_register_ascendants(@cti_ascendants + [ self.name ])
        end
        
        # registers the ascendants of the current class. Called on this class by the parent class.
        # ascendants: array of ascendants. The first element is the highest level class, derived
        # classes follow, the last element is the parent of this class.
        def cti_register_ascendants(ascendants)
          @cti_ascendants = ascendants
        end
        
        # returns a list of all descendants
        def cti_all_descendants
          result = []
          block = Proc.new do |klass, descendants|
            result << klass
            descendants.each(&block)
          end
          @cti_descendants ||= {}
          @cti_descendants.each(&block)
          result
        end
        
        # redefine validate to always add :unless proc so we can disable the validations for an object
        # by setting the cti_disable_validations accessor to true
        def validate(*args, &block)
          # we specifically don't want to disable balidations belonging to associations. Based on the naming
          # rails uses, we return immediately in such cases (there must be a cleaner way to do this...)
          return super if args.first && args.first.to_s =~ /^validate_associated_records_for_/
          # rest of implementation insipred by the validate implementation in rails
          options = args.extract_options!.dup
          return super if options[:cti_no_disable]
          if options.key?(:unless)
            options[:unless] = Array(options[:unless])
            options[:unless].unshift( cti_validation_unless_proc )
          else
            options[:unless] = cti_validation_unless_proc
          end
          args << options
          return super(*args, &block)
        end
        
        def cti_validation_unless_proc
          @cti_validation_unless_proc ||= Proc.new do |object| 
            object.respond_to?(:cti_disable_validations) && object.cti_disable_validations
          end
        end
        
        # redefine association class methods
        [:has_many, :has_and_belongs_to_many, :has_one].each do |name|
          self.class_eval <<-eos, __FILE__, __LINE__+1
            def #{name}(*args, &block)
              cti_initialize_cti_associations
              @cti_associations[:#{name}] << args.first
              super
            end
          eos
        end

        def cti_create_association_proxies
          # create hash with proxy and class names. The proxies themselves will be created
          # by the 'association' instance method when the association is used for the first time.
          @cti_association_proxies ||= {}
          @cti_ascendants.each do |ascendant|
            [:has_many, :has_and_belongs_to_many, :has_one].each do |association_type|
              ascendant.constantize.cti_associations[association_type].each do |association|
                proxy_name = cti_association_proxy_name(association)
                @cti_association_proxies[proxy_name] = ascendant
              end
            end
          end
        end
        
         # fix the 'remote' (i.e. belongs_to) part of any has_one of has_many association in this class
        def cti_redefine_remote_associations
          cti_initialize_cti_associations
          # redefine remote belongs_to associations
          [:has_many, :has_one].each do |association_type|
            @cti_associations[association_type].each do |association|
              next if @cti_redefined_remote_associations[association_type].include?( association )
              remote_class = association.to_s.camelize.singularize.constantize
              remote_associations = remote_class.reflect_on_all_associations(:belongs_to).map(&:name)
              remote_association = self.name.underscore.to_sym
              if remote_associations.include?( remote_association )
                cti_redefine_remote_belongs_to_association(remote_class, remote_association)
                @cti_redefined_remote_associations[association_type] << association
              end
            end
          end
          # redefine remote has_many and has_and_belongs_to_many associations
          [:has_many, :has_and_belongs_to_many].each do |association_type|
            @cti_associations[association_type].each do |association|
              next if @cti_redefined_remote_associations[association_type].include?( association )
              remote_class = association.to_s.camelize.singularize.constantize
              remote_associations = remote_class.reflect_on_all_associations( association_type ).map(&:name)
              remote_association = self.name.underscore.pluralize.to_sym
              if remote_associations.include?( remote_association )
                cti_redefine_remote_to_many_association(remote_class, remote_association)
                @cti_redefined_remote_associations[association_type] << association
              end
            end
          end
        end

        def cti_redefine_remote_belongs_to_association(remote_class, remote_association)
          remote_class.class_eval <<-eos, __FILE__, __LINE__+1
            def #{remote_association}=(object, *args, &block)
              super( object.convert_to('#{self.name}'), *args, &block )
            end
          eos
        end

        def cti_redefine_remote_to_many_association(remote_class, remote_association)
          remote_class.class_eval <<-eos, __FILE__, __LINE__+1
            def #{remote_association}=(objects, *args, &block)
              super( objects.map { |o| o.convert_to('#{self.name}') }, *args, &block)
            end
            def #{remote_association}(*args, &block)
              collection = super
              DBViewCTI::Model::CollectionDelegator.new(collection, '#{self.name}')
            end
          eos
        end
        
        def cti_association_proxy_name(association)
          "@cti_#{association}_association_proxy"
        end

        def cti_associations
          cti_initialize_cti_associations
          @cti_associations
        end
        
        def cti_has_association?(association_name)
          if !@cti_all_associations
            @cti_all_associations = @cti_associations.keys.inject([]) do |result, key|
              result += @cti_associations[key]
              result 
            end
          end
          @cti_all_associations.include?(association_name.to_sym)
        end
        
        include DBViewCTI::SQLGeneration::Model
        
        # this method is only used in testing. It returns the number of rows present in the real database
        # table, not the number of rows present in the view (as returned by count)
        def cti_table_count
          result = connection.execute("SELECT COUNT(*) FROM #{DBViewCTI::Names.table_name(self)};")
          result[0]['count'].to_i
        end
        
        def cti_initialize_cti_associations
          @cti_associations ||= {}
          @cti_redefined_remote_associations ||= {}
          [:has_many, :has_and_belongs_to_many, :has_one].each do |name|
            @cti_associations[name] ||= []
            @cti_redefined_remote_associations[name] ||= []
          end
          @cti_association_proxies ||= {}
        end
        
      end
    end
  end
end
