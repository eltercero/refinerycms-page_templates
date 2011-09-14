require 'find'

namespace :refinery do

  namespace :page_templates do

    # call this task by running: rake refinery:page_templates:refresh
    desc "Refresh available page templates. It does so by removing all 
    PageTemplate instances and re-creating them using the YAML files found in 
    app/views/pages"
    task :refresh => :environment do
      PageTemplate.all.each{ |t| t.destroy }
      pages_views_path = "#{RAILS_ROOT}/app/views/pages/" # leave the trailing slash...
      Find.find(pages_views_path) do |path|
        if File.extname(path) == ".yml"
          template = PageTemplate.new(YAML::load_file(path))
          template.path = path.sub(pages_views_path, "") # ...or this will return /path instead of path
          template.path.chomp!(File.extname(path))
          if template.save
            template.pages.each{ |page| page.save } # Force Page saving to update Page Parts
            puts "[OK] #{template.path}"
          elsif template.errors
            errmsg = "[ERROR] #{template.path}: "
            errmsg << template.errors.map{|k,v| "#{k} #{v}" }.join(', ')
            puts errmsg
          end
        end
      end
    end
  end
end