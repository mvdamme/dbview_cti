module DBViewCTI

  def self.load
    ActiveRecord::ConnectionAdapters::AbstractAdapter.module_eval do
      include DBViewCTI::ConnectionAdapters::SchemaStatements
    end

    ActiveRecord::SchemaDumper.class_eval do
      include DBViewCTI::SchemaDumper
    end

    if defined?(ActiveRecord::Migration::CommandRecorder)
      ActiveRecord::Migration::CommandRecorder.class_eval do
        include DBViewCTI::Migration::CommandRecorder
      end
    end

    ActiveRecord::Base.class_eval do
      include DBViewCTI::Model::Extensions
    end
  end

end
