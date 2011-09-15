# Page Templates engine for Refinery CMS.


## About

**This is a work in progress.**

Page Templates allows you to... er, assign a template to your pages.

A template stores the following information: 
  
  * A path to a **template** file (```.erb``` or ```.haml```) and a **layout**
    to be used when rendering a page.
  * A set of **page parts** to be used in the page.
  * A **description**, for identification purposes.

This engine is intended to work together with ```refinerycms-content_blocks```
(also w.i.p., not public yet) to allow for complex content modularization 
and customization, but it should be perfectly usable by itself.


## Requirements

  * Refinery 1.0.8


## Installation

Add this to your Gemfile:

    gem 'haml'
    gem 'refinerycms-page_templates', :path => 'vendor/plugins'

Then:

    $ cd vendor/engines
    $ git clone git@github.com:rilla/refinerycms-page_templates.git
    $ bundle install
    $ rails g refinerycms_page_templates
    $ rake db:migrate

Make sure that you have an ```app/views/pages``` directory in your application 
root directory, or create it if you don't.

The engine is ready, but now you have to create some templates. Go ahead:


## Creating templates

You need two files for each template:

  * A configuration file (```.yml```)
  * The template itself (a ```.html.erb``` or ```.html.haml``` file)

Both files must be placed in ```#{RAILS_ROOT}/app/views/pages```, and you can group 
them in folders for better organization. You should end up with something like this:

    app/views/pages/
    ├── corporate
    │   ├── contact.html.haml
    │   ├── contact.yml
    │   ├── job_inquiries.html.haml
    │   └── job_inquiries.yml
    ├── corporate.html.haml
    ├── corporate.yml
    ├── home.html.haml
    └── home.yml


### YAML file

Write your YAMLs like this:

**app/views/pages/corporate.yaml**:

```yaml
description: Generic template for Corporate section
layout: pages
page_parts:
- {:title => Head }
- {:title => Main contents }
- {:title => Sidebar }
```

### Haml or Erb file

A regular Refinery template. You can render the contents of your page parts like this:

```ruby
@page.content_for(:main_contents).html_safe
```


## Template injection

Now you have to make Refinery aware of your new templates. Execute:

    rake refinery:page_templates:refresh

**IMPORTANT: You must execute this task every single time you make changes to your 
templates.**

### What's happening here?

The rake task performs the following operations:
    
  1. Destroy every ```PageTemplate``` instance that exists in the database.
  2. Find ```.yml``` files in ```#{RAILS_ROOT}/app/views/pages``` and create
     a ```PageTemplate``` instance for each of them, but only if a ```.erb``` 
     or ```.haml``` file with the same name is found within the same 
     directory. Otherwise an error will be shown.
  3. Go through each ```Page``` instance and:
    * If needed, auto-select a template based on the ```slug.name``` of the 
      page and/or its ancestor pages. See ```Template assignment > Automatic
      template assignment``` section in this document for more details.
    * Apply or re-apply the template configuration, i.e. create and/or remove 
      ```parts``` as needed to fit the template specification. See 
      ```Automatic page part handling``` in this document for more details.

Note that the relations between ```Page``` and ```PageTemplate``` instances
will be preserved regardless the rake task destroying every ```PageTemplate```, 
as long as the new PageTemplate preserves its original path. 

So in step 3, any Page with a template_path referencing a non-existent
PageTemplate will be assigned a new template automatically (See 
```Template assignment > Automatic template assignment``` to know more).


## See the available templates and its associations

There's a new ```Page Templates``` tab in Refinery CMS where you'll find a
list of the templates that exist in the database and the pages that have been
associated to them (both automatically or manually).

You can check this list after running the rake task to make sure everything 
went as expected.


## Template assignment

Now that all your templates are in the database you'll want to know how to
associate Pages and Templates. Well, the good news is that this should already
have happened via **automatic template assignment**:

### Automatic template assignment

Everytime a Page is saved (or for every single page when the ```refinery:page_templates:refresh```
task is ran), the following conditions wil be checked:

  * Does it have a template associated?
  * Was that template assigned manually by a user through the CMS?

If any of these conditions evaluate to false, the system will auto-assign a 
template for the page, and it will follow these criteria: 
  
  1. Start checking if a valid template exists with the path 
     ```parent1/parent2/.../page```, where 
      ````ruby
      page = page.slug.name.gsub("-", "_")
      ``` 
      and ```parent1/parent2/...``` represents the ancestors (parent pages) 
      chain. If a template is found, use it.
     
  2. Climb up the ancestors chain until a valid template is found.
  3. If no template is found, default to nil and let Refinery use its own 
     templates.

I'll try to illustrate it with some examples. We'll use this template tree:

    app/views/pages/
    ├── corporate
    │   ├── contact.html.haml
    │   ├── contact.yml
    │   ├── job_inquiries.html.haml
    │   └── job_inquiries.yml
    ├── corporate.html.haml
    ├── corporate.yml
    ├── home.html.haml
    └── home.yml

After injecting the templates in the database with 
```rake refinery:page_templates:refresh```, we 
can try this in the console:

```ruby
page1 = Page.create :title => "Wadus"
page1.guess_template_path
=> nil

page2 = Page.create :title => "Corporate"
page2.guess_template_path
=> "corporate"

page1.parent = page2
page1.guess_template_path
=> "corporate"

page3 = Page.create :title => "Job Inquiries"
page3.guess_template_path
=> nil

page3.parent = page2
page3.guess_template_path
=> "corporate/job_inquiries"
```

### Manual template assignment

If you need to, you can manually edit the template for each page. You'll find 
a select box in the Advanced Options section of the page edition form.

When a template is selected by hand for a page, that page/template association
becomes locked and the system won't try to auto-assign a template to this page
again, until:

  * The user selects the Automatic Selection in the Template select box
  * The assigned template is deleted or moved to another path


## Automatic page part handling

Page parts are added and removed as needed whenever a Page is saved to fit the
page_parts section of its template's configuration.

However, only empty parts will be removed. That way no content is lost.

If a template is defined with no page_parts, pages assigned to that template 
will use the default page parts from Settings.

## TODO

* Integrate with permissions to enable/disable manual template management
* Refactor Extensions (they're a horrible mess right now)
* Try to find a way to ovoid overriding ```PagesController``` 
  and ```_form_advanced_options.html.erb```
* Write tests
* Build as gem


## How to build this engine as a gem

    cd vendor/engines/page_templates
    gem build refinerycms-page_templates.gemspec
    gem install refinerycms-page_templates.gem
    
    # Sign up for a http://rubygems.org/ account and publish the gem
    gem push refinerycms-page_templates.gem