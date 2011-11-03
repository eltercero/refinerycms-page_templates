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

      puts "\n2.Find yml/html pairs and inject them in the DB as PageTemplate instances:\n\n"
      pages_views_path = "#{RAILS_ROOT}/app/views/pages"
      unless File.directory? pages_views_path
        puts "[ERROR] #{pages_views_path} doesn't exist."
        next
      end
      Find.find(pages_views_path) do |full_path|
        if File.extname(full_path) == ".yml"
          template_path = full_path.sub("#{pages_views_path}/", "")
          template_path.chomp!(File.extname(full_path))
          print "\s\s#{template_path}".ljust(60,".")
          template = PageTemplate.new(YAML::load_file(full_path))
          template.path = template_path
          if template.save
            print "[OK]\n"
          elsif template.errors
            print "[ERROR]\n"
            puts template.errors.map{|k,v| "\s\s#{k} #{v}" }.join(', ')
            print "\n"
          end
        end
      end

      puts "\n3. Auto-select (if not locked) and re-apply templates on every Page instance:"
      updated_pages = []
      Page.all.each do |page|
        # Maybe this page's template has been destroyed and no new template
        # has been created with the same path. In that case, back to automatic
        # template selection
        if page.page_template.nil?
          page.lock_page_template = false
          if page.save && page.apply_template(true)
            print "."
            updated_pages << "* #{page.title}"
          else
            print "x"
          end
        else
          print '-'
        end
      end
      print "[DONE]\n\n"
      print "I've updated the following pages:\n"
      print updated_pages.join('\n')
      print "\n"
    end
  end
end