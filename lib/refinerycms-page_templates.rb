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

    end # Engine
  end # PageTemplates
end # Refinery

module Refinery
  module PageTemplates
    module Extension

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def has_page_template
          belongs_to  :page_template, :foreign_key => :page_template_path
          before_save :auto_select_template, :should_apply_template?
          after_save  :apply_template

          include Refinery::PageTemplates::Extension::InstanceMethods

          if ActiveModel::MassAssignmentSecurity::WhiteList === active_authorizer
            attr_accessible :page_template_path, :lock_page_template
          else
            #to prevent a future call to attr_accessible
            self._accessible_attributes = accessible_attributes + [:page_template_path]
          end
        end

      end # ClassMethods

      module InstanceMethods
        
        # Find the most suitable template based on this page 
        # and its ancestor's slugs and assign it automatically
        def auto_select_template
          # Don't do anything if Page already has a PageTemplate
          # and it's locked (because it was selected manually)
          unless self.page_template_path && self.lock_page_template
            self.page_template_path = self.guess_template_path
          end
        end
        def guess_template_path
          expected_path = [slug.name.gsub("-","_")]
          expected_path << parent.slug.name.gsub("-","_") if parent
          expected_path = expected_path.reverse.join("/")
          if PageTemplate.find_by_path(expected_path)
            return expected_path
          elsif parent
            return parent.guess_template_path
          end
        end

        # Re-apply template if a new template has been selected or the template
        # has been updated since the last saving of this Page
        def should_apply_template?
          past_self = Page.find(self.id)
          new_template_selected = (past_self.page_template_path != self.page_template_path)
          template_has_been_updated = page_template.present? && (page_template.updated_at > past_self.updated_at)
          @should_apply_template = new_template_selected || template_has_been_updated
        end

        def apply_template
          return unless @should_apply_template
          # If this Page instance has a PageTemplate, use the PagePart
          # sceheme defined there. Otherwise, use default parts from Settings.
          if page_template.present?
            logger.debug "\n\napplying template\n\n"
            template_parts = page_template.page_parts
          else
            logger.debug "\n\nusing default parts\n\n"
            template_parts = Page.default_parts
          end
          # Remove all parts which are empty and not defined in the current template
          parts.each do |part|
            unless template_parts.present? && template_parts.map{ |p| p['title'] }.include?(part.title)
              unless part.body.present?
                part.destroy
              else
                part.save
              end
            end
          end unless parts.nil?
          # Make sure the page has all parts defined in the template
          template_parts.each_with_index do |part, index|
            unless parts.present? && parts.map{ |p| p.title }.include?(part['title'])
              parts.create(:title => part['title'], :position => index)
            end
          end unless template_parts.nil?
        end
      
      end # InstanceMethods
    end # Extension
  end # PageTemplates
end # Refinery

ActiveRecord::Base.send(:include, Refinery::PageTemplates::Extension)