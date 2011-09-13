module NavigationHelpers
  module Refinery
    module PageTemplates
      def path_to(page_name)
        case page_name
        when /the list of page_templates/
          admin_page_templates_path

         when /the new page_template form/
          new_admin_page_template_path
        else
          nil
        end
      end
    end
  end
end
