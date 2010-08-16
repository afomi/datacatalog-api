module DataCatalog

  class Categorizations < Base
    include Resource

    model Categorization

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :basic
    permission :create => :curator
    permission :update => :curator
    permission :delete => :curator

    # == Properties

    property :source_id
    property :category_id

    property :source do |categorization|
      if categorization.source_id
        if source = categorization.source
          {
            "title"       => source.title,
            "href"        => "/sources/#{source.id}",
            "description" => source.description,
            "slug"        => source.slug,
          }
        end
      end
    end

    property :category do |categorization|
      if categorization.category_id
        if category = categorization.category
          {
            "name" => category.name,
            "href" => "/category/#{category.id}"
          }
        end
      end
    end

  end

  Categorizations.build

end

