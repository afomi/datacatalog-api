module DataCatalog

  class Categories < Base
    include Resource
    
    model Category

    # == Permissions

    roles Roles
    permission :read   => :basic
    permission :modify => :curator

    # == Properties

    property :name

    property :source_ids do |category|
      category.categorizations.map do |categorization|
        categorization.source.id
      end
    end

  end
  
  Categories.build

end
