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
        Page.send :has_page_template
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
        def has_page_template
          belongs_to :page_template, :foreign_key => :page_template_path
          after_save :update_page_parts
          include Refinery::PageTemplates::Extension::InstanceMethods
          if ActiveModel::MassAssignmentSecurity::WhiteList === active_authorizer
            attr_accessible :page_template_path
          else
            #to prevent a future call to attr_accessible
            self._accessible_attributes = accessible_attributes + [:page_template_path]
          end          
        end
      end
      module InstanceMethods
        def update_page_parts
          # Proceed only if there's a template defined
          return if page_template.nil?
          # Remove all parts which are empty and are not defined in the current template
          parts.each do |part|
            unless page_template.page_parts.map{ |p| p['title'] }.include?(part.title)
              if part.body.empty?
                part.destroy
              end
            end
          end
          # Make sure the page has all parts defined in the template
          page_template.page_parts.each do |part|
            unless parts.map{ |p| p.title }.include?(part['title'])
              parts.create(:title => part['title'])
            end
          end
        end
      end
    end
  end
end
ActiveRecord::Base.send(:include, Refinery::PageTemplates::Extension)