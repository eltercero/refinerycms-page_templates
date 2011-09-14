require 'find'

namespace :refinery do

  namespace :page_templates do

    # call this task by running: rake refinery:page_templates:refresh
    desc "Refresh available page templates. It does so by removing all 
    PageTemplate instances and re-creating them using the YAML files found in 
    app/views/pages"
    task :refresh => :environment do
      puts "\n1. Destroy every PageTemplate instance:"
      PageTemplate.all.each do |t| 
        t.destroy
        print "."
      end
      print "[DONE]\n"
      puts "\n2.Find yml/html pairs and inject them in the DB as PageTemplate instances:"
      pages_views_path = "#{RAILS_ROOT}/app/views/pages"
      Find.find(pages_views_path) do |path|
        if File.extname(path) == ".yml"
          template = PageTemplate.new(YAML::load_file(path))
          template.path = path.sub("#{pages_views_path}/", "")
          template.path.chomp!(File.extname(path))
          if template.save
            puts "[OK] #{template.path}"
          elsif template.errors
            errmsg = "[ERROR] #{template.path}: "
            errmsg << template.errors.map{|k,v| "#{k} #{v}" }.join(', ')
            puts errmsg
          end
        end
      end
      # Autoselect template if needed and re-apply templates
      puts "\n3. Auto-select (if not locked) and re-apply templates on every Page instance:"
      Page.all.each do |page| 
        if page.save
          print "."
        else
          print "x"
        end
      end
      print "[DONE]\n\n"
    end
  end
end