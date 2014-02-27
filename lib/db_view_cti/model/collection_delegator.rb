require 'delegate'

module DBViewCTI
  module Model

    class CollectionDelegator < SimpleDelegator
      def initialize(object, target_class_name)
        super(object)
        @target_class_name = target_class_name
      end
      
      def <<(object, *args, &block)
        __getobj__.send('<<', object.try(:convert_to, @target_class_name), *args, &block)
      end

      def []=(*args, &block)
        object = args.last.convert_to(@target_class_name)
        __getobj__.send('[]=', *(args[0..-2]), object, &block)
      end

      def delete(*args, &block)
        objects = args.map do |obj|
          obj.respond_to?(:convert_to) ? obj.convert_to(@target_class_name) : obj
        end
        __getobj__.send('delete', *objects, &block)
      end

      def destroy(*args, &block)
        objects = args.map do |obj|
          obj.respond_to?(:convert_to) ? obj.convert_to(@target_class_name) : obj
        end
        __getobj__.send('delete', *objects, &block)
      end

    end

  end
end
