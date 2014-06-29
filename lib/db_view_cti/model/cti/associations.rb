module DBViewCTI
  module Model
    module CTI
      module Associations
        extend ActiveSupport::Concern

        included do
          # for associations:
          alias_method_chain :association, :cti
          # save callbacks (necessary for saving associations)
          after_save :cti_save_associations
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
          return nil if !self.class.reflect_on_all_associations.map(&:name).include?(association_name.to_sym) # necessary since rails 4.1.2
          proxy_name = self.class.cti_association_proxy_name(association_name)
          proxy = instance_variable_get(proxy_name)
          if !proxy && !self.class.cti_has_association?(association_name)
            # As of Rails 4.1, Rails apparently adds an has_many association (with class name starting with HABTM_) for each
            # has_and_belongs_to_many association. We return nil in that case.
            reflection = self.class.reflect_on_all_associations(:has_many).select { |a| a.name == association_name }.first
            return nil if reflection && reflection.klass.name[0..5] == 'HABTM_'
            instance_variable_set(proxy_name, 
                                  ModelDelegator.new(self, self.class.cti_association_proxies[proxy_name]))
            proxy = instance_variable_get(proxy_name)
          end
          proxy
        end
  
        module ClassMethods
          
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
                if cti_reciprocal_association_present_for?( association, :belongs_to )
                  remote_association = cti_reciprocal_association_for( association, :belongs_to )
                  remote_class = cti_association_name_to_class_name( association ).constantize
                  cti_redefine_remote_belongs_to_association(remote_class, remote_association.name.to_sym)
                  @cti_redefined_remote_associations[association_type] << association
                end
              end
            end
            # redefine remote has_many and has_and_belongs_to_many associations
            [:has_many, :has_and_belongs_to_many].each do |association_type|
              @cti_associations[association_type].each do |association|
                next if @cti_redefined_remote_associations[association_type].include?( association )
                if cti_reciprocal_association_present_for?( association, association_type)
                  remote_association = cti_reciprocal_association_for( association, association_type )
                  remote_class = cti_association_name_to_class_name( association ).constantize
                  cti_redefine_remote_to_many_association(remote_class, remote_association.name.to_sym)
                  @cti_redefined_remote_associations[association_type] << association
                end
              end
            end
          end

          # Gets reciprocal association of type 'type' for the given association.
          # (example: if a has_many association has a corresponding belongs_to  in the remote class).
          # Normally, the method checks if the remote association refers to this class, but it is possible to
          # pass in 'class_name' to check different classes
          def cti_reciprocal_association_for(association, type, class_name = nil)
            class_name ||= self.name
            remote_class = cti_association_name_to_class_name( association, class_name ).constantize
            remote_associations = remote_class.reflect_on_all_associations( type ).select { |a| a.class_name == class_name }
            remote_associations.first
          end

          # Check if a reciprocal association of type 'type' is present for the given association.
          # (example: check if a has_many association has a corresponding belongs_to  in the remote class).
          # Normally, the method checks if the remote association refers to this class, but it is possible to
          # pass in 'class_name' to check different classes
          def cti_reciprocal_association_present_for?(association, type, class_name = nil)
            !cti_reciprocal_association_for(association, type, class_name).nil?
          end

          # converts e.g. :space_ships to SpaceShip
          # Normally operates on associations of this class, but it is possible to
          # pass in 'class_name' if 'association_name' is an association on a different classes
          def cti_association_name_to_class_name(association_name, class_name = nil)
            klass = self
            klass = class_name.constantize if class_name
            klass.reflect_on_all_associations.select { |a| a.name == association_name }.first.class_name
          end

          def cti_redefine_remote_belongs_to_association(remote_class, remote_association)
            remote_class.class_eval <<-eos, __FILE__, __LINE__+1
              def #{remote_association}=(object, *args, &block)
                super( object.try(:convert_to, '#{self.name}'), *args, &block )
              end
            eos
          end
  
          def cti_redefine_remote_to_many_association(remote_class, remote_association)
            remote_class.class_eval <<-eos, __FILE__, __LINE__+1
              def #{remote_association}=(objects, *args, &block)
                super( objects.map { |o| o.try(:convert_to, '#{self.name}') }, *args, &block)
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
end