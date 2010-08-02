module DataCatalog

  class Catalogs < Base
    include Resource

    model Catalog

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :basic
    permission :create => :curator
    permission :update => :curator
    permission :delete => :curator

    # == Properties

    property :title
    property :url

    property :sources do |catalog|
      catalog.sources.map do |source|
        {
          "href"  => "/sources/#{source.id}",
          "title" => source.title,
          "url"   => source.url,
        }
      end
    end

    # == Callbacks

  end

  Catalogs.build

end
