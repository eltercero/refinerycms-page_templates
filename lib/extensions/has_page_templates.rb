module Extensions
  module HasPageTemplates

    # Find the most suitable template based on this page 
    # and its ancestor's slugs and assign it automatically
    def auto_select_template
      # Don't do anything if Page has a valid PageTemplate
      # and it's locked (because it was selected manually)
      if PageTemplate.table_exists?
        unless defined?(self.page_template_path) && # Check PageTemplates migration already ran
            self.page_template_path.present? &&
            PageTemplate.exists?(self.page_template_path) &&
            self.lock_page_template
              self.page_template_path = self.guess_template_path
        end
      end
      return true
    end

    def expected_template_paths
      out = []
      slugs.each do |s|
        if parent.present? && !parent.home?
          parent.expected_template_paths.each do |parent_path|
            out << [parent_path, s.name.gsub("-","_")].compact.flatten.join("/")
          end
        else
          out << s.name.gsub("-","_")
        end
      end
      out += parent.expected_template_paths if parent.present?
      out << parent.page_template_path if parent.present? and parent.page_template_path.present?
      return out
    end

    def guess_template_path
      expected_template_paths.each do |expected_path|
        if PageTemplate.table_exists? && PageTemplate.exists?(expected_path)
          return expected_path
        end
      end
      return nil
    end

    # We should re-apply the template to the page
    # if the page is new or the template has been changed
    def should_apply_template?
      if self.id.nil? # New page
        @should_apply_template = true
      elsif not defined?(self.page_template_path) # PageTemplate migration not ran yet
        @should_apply_template = false
      else # Check if template is different from previous
        past_self = ::Page.find(self.id)
        @should_apply_template = (past_self.page_template_path != self.page_template_path)
        # TODO: What if template path is the same but template has been updated?!
      end
      return true # Note to self: no callbacks should return false, otherwise the record won't be saved
    end

    # Re-apply template
    def apply_template(force=false)
      return unless @should_apply_template || force
      # If this Page instance has a PageTemplate and the template has a 
      # page_parts scheme, use those parts here. Otherwise, use default
      # parts from Settings.
      template_parts = if page_template.present? and page_template.page_parts.present?
        page_template.page_parts
      else
        ::Page.default_parts.map{ |p| { 'title' => p } }
      end
      # Remove all parts which are empty and not defined in the current template      
      parts.each do |part|
        unless template_parts.present? && template_parts.map{ |p| p['title'] }.include?(part.title)
          if part.body.blank?
            part.destroy
          else
            part.save
          end
        end
      end unless parts.nil?
      
      # Make sure the page has all parts defined in the template
      template_parts.each_with_index do |part, index|
                # Skip inheritable parts if this page is using its parent's template
        unless  (parent.present? and page_template == parent.page_template and part['inheritable']) or
                # Skip parts marked as "parents_only" unless this page didn't inherit its template
                (parent.present? and page_template == parent.page_template and part['parents_only']) or
                # Skip if part is only available to some other pages 
                (part['except'].present? and p.to_param =~ Regexp.new(part['except']) ) or
                # Skip if this is not one of the pages for which this part is available exclusively
                (part['only'].present? and not p.to_param =~ Regexp.new(part['only'])) or
                # Skip if this part exists already in this page
                (parts.present? and parts.map{ |p| p.title }.include?(part['title']))
          parts.create(:title => part['title'], :position => index)
        end
      end unless template_parts.nil?

      update_snippets

    end

    def update_snippets
      # Create default snippets on every PagePart
      if defined?(Snippet) and Snippet.table_exists?
        parts.each do |part|
          if (defined?(part.snippets) && part.snippets.present?) or part.snippets.nil? or part.snippets.empty?
            part.snippets.size.times do
              part.snippets << Snippet.create(:snippet_template_path => part.default_snippet_template.path)
            end
          end
        end unless parts.nil?
      end
    end
    
    def inheritable_parts
      logger.debug "inheritable parts for #{self.title}"
      if page_template.page_parts.present?
        page_template.page_parts.select{ |part| part['inheritable'].present? }.map{ |tp| parts.select{ |p| p.title == tp['title'] } }.flatten
      end
    end
    
  end
end