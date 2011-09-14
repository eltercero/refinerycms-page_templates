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

    add_column ::Page.table_name, :page_template_path, :string
    add_column ::Page.table_name, :lock_page_template, :boolean

    add_column ::PagePart.table_name, :legacy, :boolean

  end

  def self.down
    if defined?(UserPlugin)
      UserPlugin.destroy_all({:name => "page_templates"})
    end
    
    remove_column ::Page.table_name, :page_template_path
    remove_column ::Page.table_name, :lock_page_template
    remove_column ::PagePart.table_name, :legacy, :boolean
    drop_table :page_templates
  end

end
