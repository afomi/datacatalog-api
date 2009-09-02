module DataCatalog

  class Nested

    # public
    def self.restful_routes(&block)
      @block = block
    end
    
    # protected
    def self.evaluate_restful_routes
      @callbacks = {}
      @block.call
      define_restful_routes
    end

    # public
    def self.name(name)
      @name = name
    end
    
    # public
    def self.association(association)
      @association = association
    end
    
    # public
    def self.model(model, opts)
      @model = model
      @read_only_attributes = opts[:read_only]
    end
    
    # public
    def self.permission(level)
      @permission = level
    end

    # public
    def self.callback(label, &block)
      @callbacks[label] = block
    end
    
    # protected
    def self.parent_resource=(resource)
      @parent_resource = resource
      @parent_model = resource.get_model
      @parent_name = resource.get_name
    end
    
    # protected
    def self.define_restful_routes
      association          = @association
      callbacks            = @callbacks
      child_model          = @model
      child_name           = @name
      level                = @permission
      parent_model         = @parent_model
      parent_name          = @parent_name
      read_only_attributes = @read_only_attributes
      @parent_resource.instance_eval do
        get "/:parent_id/#{child_name}" do
          parent_id = params.delete("parent_id")
          permission_check :basic, level, parent_id
          parent_doc = parent_model.find_by_id(parent_id)
          error 404, [].to_json unless parent_doc
          child_docs = parent_doc.send(association)
          child_docs.to_json
        end

        get "/:parent_id/#{child_name}/:child_id" do
          parent_id = params.delete("parent_id")
          permission_check :basic, level, parent_id
          child_id = params.delete("child_id")
          parent_doc = parent_model.find_by_id(parent_id)
          error 404, [].to_json unless parent_doc
          child_doc = parent_doc.send(association).find { |x| x.id == child_id }
          error 404, [].to_json unless child_doc
          child_doc.to_json
        end

        post "/:parent_id/#{child_name}" do
          parent_id = params.delete("parent_id")
          permission_check :curator, level, parent_id
          parent_doc = parent_model.find_by_id(parent_id)
          error 404, [].to_json unless parent_doc
          validate params, child_model, read_only_attributes
          callback callbacks[:before_create], parent_doc # ***
          child_doc = child_model.new(params)
          parent_doc.send(association) << child_doc
          error 500, [].to_json unless parent_doc.save
          response.status = 201
          response.headers['Location'] = full_uri "/#{parent_name}/#{parent_id}/#{child_name}/#{child_doc.id}"
          child_doc.to_json
        end

        put "/:parent_id/#{child_name}/:child_id" do
          parent_id = params.delete("parent_id")
          permission_check :curator, level, parent_id
          child_id = params.delete("child_id")
          parent_doc = parent_model.find_by_id(parent_id)
          error 404, [].to_json unless parent_doc
          validate params, child_model, read_only_attributes
          callback callbacks[:before_update], parent_doc # ***
          child_doc = parent_doc.send(association).find { |x| x.id == child_id }
          error 404, [].to_json unless child_doc
          child_index = parent_doc.send(association).index(child_doc)
          child_doc.attributes = params
          parent_doc.send(association)[child_index] = child_doc
          error 500, [].to_json unless parent_doc.save
          child_doc.to_json
        end

        delete "/:parent_id/#{child_name}/:child_id" do
          parent_id = params.delete("parent_id")
          permission_check :curator, level, parent_id
          child_id = params.delete("child_id")
          parent_doc = parent_model.find_by_id(parent_id)
          error 404, [].to_json unless parent_doc
          child_doc = parent_doc.send(association).find { |x| x.id == child_id }
          error 404, [].to_json unless child_doc
          callback callbacks[:before_delete], child_doc # ***
          parent_doc.send(association).delete(child_doc)
          error 500, [].to_json unless parent_doc.save
          { "id" => child_id }.to_json
        end
      end
    end

  end
  
end
