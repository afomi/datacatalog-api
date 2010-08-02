module DataCatalog

  class Importers < Base
    include Resource

    model Importer

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :basic
    permission :create => :curator
    permission :update => :curator
    permission :delete => :curator

    # == Properties

    property :name

    property :imports do |importer|
      importer.imports.map do |import|
        {
          "status"      => import.status,
          "started_at"  => import.started_at,
          "finished_at" => import.finished_at,
        }
      end
    end

    # == Callbacks
  end

  Importers.build

end
