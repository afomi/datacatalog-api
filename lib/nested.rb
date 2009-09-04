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
          @parent_document = parent_model.find_by_id(parent_id)
          error 404, [].to_json unless @parent_document
          @child_documents = @parent_document.send(association)
          @child_documents.to_json
        end

        get "/:parent_id/#{child_name}/:child_id" do
          parent_id = params.delete("parent_id")
          permission_check :basic, level, parent_id
          child_id = params.delete("child_id")
          @parent_document = parent_model.find_by_id(parent_id)
          error 404, [].to_json unless @parent_document
          @child_document = @parent_document.send(association).find { |x| x.id == child_id }
          error 404, [].to_json unless @child_document
          @child_document.to_json
        end

        post "/:parent_id/#{child_name}" do
          parent_id = params.delete("parent_id")
          permission_check :curator, level, parent_id
          @parent_document = parent_model.find_by_id(parent_id)
          error 404, [].to_json unless @parent_document
          validate_before_save params, child_model, read_only_attributes
          callback callbacks[:before_save]
          callback callbacks[:before_create]
          @child_document = child_model.new(params)
          @parent_document.send(association) << @child_document
          error 500, [].to_json unless @parent_document.save
          callback callbacks[:after_create]
          callback callbacks[:after_save]
          response.status = 201
          response.headers['Location'] = full_uri(
            "/#{parent_name}/#{parent_id}/#{child_name}/#{@child_document.id}"
          )
          @child_document.to_json
        end

        put "/:parent_id/#{child_name}/:child_id" do
          parent_id = params.delete("parent_id")
          permission_check :curator, level, parent_id
          child_id = params.delete("child_id")
          @parent_document = parent_model.find_by_id(parent_id)
          error 404, [].to_json unless @parent_document
          validate_before_save params, child_model, read_only_attributes
          callback callbacks[:before_save]
          callback callbacks[:before_update]
          @child_document = @parent_document.send(association).find { |x| x.id == child_id }
          error 404, [].to_json unless @child_document
          child_index = @parent_document.send(association).index(@child_document)
          @child_document.attributes = params
          @parent_document.send(association)[child_index] = @child_document
          error 500, [].to_json unless @parent_document.save
          callback callbacks[:after_update]
          callback callbacks[:after_save]
          @child_document.to_json
        end

        delete "/:parent_id/#{child_name}/:child_id" do
          parent_id = params.delete("parent_id")
          permission_check :curator, level, parent_id
          child_id = params.delete("child_id")
          @parent_document = parent_model.find_by_id(parent_id)
          error 404, [].to_json unless @parent_document
          @child_document = @parent_document.send(association).find { |x| x.id == child_id }
          error 404, [].to_json unless @child_document
          callback callbacks[:before_destroy]
          @parent_document.send(association).delete(@child_document)
          callback callbacks[:after_destroy]
          error 500, [].to_json unless @parent_document.save
          { "id" => child_id }.to_json
        end
      end
    end

  end
  
end
