module DBViewCTI
  module Model
    module CTI
      module AssociationValidations
        extend ActiveSupport::Concern

        included do
          # validations
          validate :cti_validate_associations, :cti_no_disable => true
          attr_accessor :cti_disable_validations
        end
        
        def cti_validate_associations
          return_value = true
          self.class.cti_association_proxies.each_key do |proxy_name|
            proxy = instance_variable_get(proxy_name)
            if proxy && !proxy.valid?
              if Rails::VERSION::MAJOR < 6 || (Rails::VERSION::MAJOR == 6 && Rails::VERSION::MINOR == 0)
                errors.messages.merge!(proxy.errors.messages)
              else
                proxy.errors.each do |error|
                  attribute = error.attribute.to_s.split('.').first.to_sym  # convert attribute name to association name
                  if RUBY_VERSION >= '2.7'
                    errors.add(attribute, error.type, **error.options)
                  else
                    errors.add(attribute, error.type, error.options)
                  end
                end
              end
              return_value = false
            end
          end
          return_value
        end
  
        module ClassMethods

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
          
        end
        
      end
    end
  end
end