module PageStructuredData
  class Engine < ::Rails::Engine
    isolate_namespace PageStructuredData

    config.autoload_paths << File.join(config.root, "app/src")
  end
end
