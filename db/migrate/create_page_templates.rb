class CreatePageTemplates < ActiveRecord::Migration

  def self.up
    create_table :page_templates, :id => false, :primary_key => 'path' do |t|
      t.string :name
      t.string :description
      t.string :path, :null => false
      t.integer :position
      t.string :layout
      t.text :page_parts
      t.timestamps
    end
    
    add_index :page_templates, :path

    add_column :pages, :page_template_path, :string

    load(Rails.root.join('db', 'seeds', 'page_templates.rb'))
  end

  def self.down
    if defined?(UserPlugin)
      UserPlugin.destroy_all({:name => "page_templates"})
    end
    
    remove_column :pages, :page_template_path

    drop_table :page_templates
  end

end
