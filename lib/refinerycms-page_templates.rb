require 'refinerycms-base'

module Refinery
  module PageTemplates
    class Engine < Rails::Engine
      
      config.before_initialize do
        require 'extensions/has_page_templates'
        require 'extensions/pages_controller_extensions'
      end
      
      initializer "static assets" do |app|
        app.middleware.insert_after ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
      end
      
      config.to_prepare do
        Page.module_eval do
          belongs_to  :page_template, :foreign_key => :page_template_path
          before_save :auto_select_template, :should_apply_template?
          after_save  :apply_template, :update_snippets
          attr_accessible :page_template_path, :lock_page_template
        end
        Page.send :include, Extensions::HasPageTemplates
      end
      
      refinery.after_inclusion do 
        ::PagesController.send :include, Extensions::PagesController
      end
      
      config.after_initialize do
        Refinery::Plugin.register do |plugin|
          plugin.name = "page_templates"
          plugin.pathname = root
          plugin.activity = {
            :class => PageTemplate,
            :title => 'name',
            :url_prefix => ""
          }
        end
      end

    end # Engine
  end # PageTemplates
end # Refinery