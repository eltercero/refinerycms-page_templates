module Extensions
  module HasPageTemplates

    # Find the most suitable template based on this page 
    # and its ancestor's slugs and assign it automatically
    def auto_select_template
      # Don't do anything if Page has a valid PageTemplate
      # and it's locked (because it was selected manually)
      unless defined?self.page_template_path &&
          self.page_template_path.present? &&
          PageTemplate.find(self.page_template_path).present? &&
          self.lock_page_template
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

    # We should re-apply the template to the page
    # if a new template has been selected
    def should_apply_template?
      return true if self.id.nil?
      return false unless defined?(self.page_template_path)
      past_self = Page.find(self.id)
      new_template_selected = (past_self.page_template_path != self.page_template_path)
      return new_template_selected
    end

    # Re-apply template
    def apply_template
      return unless @should_apply_template
      # If this Page instance has a PageTemplate and the template has a 
      # page_parts sceheme, use those parts here. Otherwise, use default
      # parts from Settings.
      if page_template.present? and page_template.page_parts.present?
        template_parts = page_template.page_parts
      else
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

  end
end