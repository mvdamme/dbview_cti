module DBViewCTI

  class Railtie < Rails::Railtie
    initializer 'dbview_cti.load' do
      ActiveSupport.on_load :active_record do
        DBViewCTI.load
      end
    end
  end

end
