module Extensions
  module PagesController
    def self.included(base)
      base.class_eval do

        before_filter :render_filter, :only => [:show]

        protected
     
        def render_filter
          instance_eval do
            def default_render

              template = @page.page_template.present? ? @page.page_template : PageTemplate.find(@page.guess_template_path)
              
              if template.present?
                render_options = {}
                render_options[:template] = "pages/#{template.path}"
                if template.layout.present?
                  render_options[:layout] = template.layout
                end
                logger.debug "[page_templates] Render page using options #{render_options.inspect}"
                render render_options
              end
              
            end # def default_render
          end # instance_eval
        end # def render_filter

      end
    end
  end
end