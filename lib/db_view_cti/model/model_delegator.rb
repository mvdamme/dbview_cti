require 'delegate'

module DBViewCTI
  module Model
    
    class ModelDelegator < SimpleDelegator
      
      attr_reader :cti_target_class

      def initialize(object, target_class)
        @cti_object = object
        @cti_converted_object = object.convert_to(target_class)
        if !@cti_converted_object
          @cti_converted_object = target_class.constantize.new
          @cti_is_new = true
        end
        disable_validations
        @cti_target_class = target_class
        super( @cti_converted_object )
      end
      
      def cti_is_new?
        @cti_is_new
      end
      
      def save(*args, &block)
        return super unless cti_is_new?
        # special case for new objects, we need to manually set the id and trick the object
        # to think it was already persisted, so we get an update instead of an insert
        new_id = @cti_object.convert_to( @cti_target_class ).id
        self.id = new_id
        force_persisted_state
        self.created_at = @cti_object.created_at
        self.updated_at = @cti_object.updated_at
        retval = !!super
        # throw away just saved object and convert from scratch
        @cti_converted_object = @cti_object.convert_to( @cti_target_class )
        disable_validations
        __setobj__(@cti_converted_object)
        return retval
      end
      
      private
      
        module DisableValidator
          def validate_each(record, *args)
            return if record.respond_to?(:cti_disable_validations) && record.cti_disable_validations
            super
          end
          
          if Rails::VERSION::MAJOR == 3
            def validate(record, *args)
              return if record.respond_to?(:cti_disable_validations) && record.cti_disable_validations
              super
            end
          end
        end
        
        def disable_validations(object = nil)
          object ||= @cti_converted_object
          object.cti_disable_validations = true
          object._validators.values.flatten.each do |validator|
            validator.extend( DisableValidator )
          end
        end
        
        module ForcePersistedState
          def persisted?
            true
          end
          
          def new_record?
            false
          end
        end
      
        def force_persisted_state(object = nil)
          object ||= @cti_converted_object
          object.extend( ForcePersistedState )
        end

    end
    
  end
end
