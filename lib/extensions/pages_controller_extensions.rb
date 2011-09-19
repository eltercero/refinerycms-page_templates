module Extensions
  module PagesController
    def self.included(base)
      base.class_eval do

        before_filter :render_filter, :only => [:show]

        protected
     
        def render_filter
          instance_eval do
            def default_render
              unless @page.page_template.nil?
                render_options = {}
                  render_options[:template] = "pages/#{@page.page_template.path}"
                  unless @page.page_template.layout.nil?
                    render_options[:layout] = @page.page_template.layout 
                  end
                render render_options
              end
            end # def default_render
          end # instance_eval
        end # def render_filter

      end
    end
  end
end