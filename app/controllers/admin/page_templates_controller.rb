module Admin
  class PageTemplatesController < Admin::BaseController

    crudify :page_template,
            :title_attribute => 'name', :xhr_paging => true

  end
end
