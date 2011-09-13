require 'refinerycms-base'

module Refinery
  module PageTemplates

    class << self
      attr_accessor :root
      def root
        @root ||= Pathname.new(File.expand_path('../../', __FILE__))
      end
    end

    class Engine < Rails::Engine
      initializer "static assets" do |app|
        app.middleware.insert_after ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
      end
      refinery.after_inclusion do 
        Page.send :belongs_to_page_template
      end
      config.after_initialize do
        Refinery::Plugin.register do |plugin|
          plugin.name = "page_templates"
          plugin.pathname = root
          plugin.activity = {
            :class => PageTemplate,
            :title => 'name'
          }
        end
      end
    end
  end
end
module Refinery
  module PageTemplates
    module Extension
      
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def belongs_to_page_template
          belongs_to :page_template, :foreign_key => :page_template_path
        end
      end
    end
  end
end
ActiveRecord::Base.send(:include, Refinery::PageTemplates::Extension)