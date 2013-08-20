module DBViewCTI
  module Migration
    module CommandRecorder

      def cti_create_view(*args)
        record(:cti_create_view, args)
      end

      def cti_drop_view(*args)
        record(:cti_drop_view, args)
      end

      def invert_cti_create_view(args)
        [:cti_drop_view, args]
      end

    end
  end
end
