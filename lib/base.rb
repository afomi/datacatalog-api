module DataCatalog
  
  class Base < Sinatra::Base
    
    before do
      content_type :json
    end
    
    # public
    def self.restful_routes
      @callbacks = {}
      @nested_resources = []
      yield
      define_restful_routes
    end

    # public
    def self.name(string)
      @name = string
    end

    # protected
    def self.get_name
      @name
    end

    # public
    def self.model(constant, opts={})
      @model = constant
      @read_only_attributes = opts[:read_only]
    end
    
    # protected
    def self.get_model
      @model
    end
    
    # public
    def self.callback(symbol, &block)
      @callbacks[symbol] = block
    end

    # public
    def self.nested_resource(klass)
      klass.parent_resource = self
      klass.evaluate_restful_routes
    end
    
    # protected
    def self.define_restful_routes
      callbacks            = @callbacks
      model                = @model
      name                 = @name
      read_only_attributes = @read_only_attributes

      get '/?' do
        require_at_least(:basic)
        @documents = find(params, model)
        @documents.to_json
      end

      get '/:id/?' do |id|
        require_at_least(:basic)
        id = params.delete("id")
        @document = model.find_by_id(id)
        error 404, [].to_json unless @document
        @document.to_json
      end

      post '/?' do
        require_at_least(:curator)
        id = params.delete("id")
        validate_before_create(params, model, read_only_attributes)
        @document = model.find_by_id(id)
        callback callbacks[:before_save]
        callback callbacks[:before_create]
        @document = model.new(params)
        unless @document.valid?
          error 400, { "errors" => @document.errors.errors }.to_json
        end
        @document.save
        callback callbacks[:after_create]
        callback callbacks[:after_save]
        response.status = 201
        response.headers['Location'] = full_uri "/#{name}/#{@document.id}"
        @document.to_json
      end

      put '/:id/?' do
        require_at_least(:curator)
        id = params.delete("id")
        @document = model.find_by_id(id)
        error 404, [].to_json unless @document
        validate_before_update(params, model, read_only_attributes)
        callback callbacks[:before_save]
        callback callbacks[:before_update]
        validate_before_update(params, model, read_only_attributes)
        @document = model.update(id, params)
        unless @document.valid?
          error 400, { "errors" => @document.errors.errors }.to_json
        end
        callback callbacks[:after_update]
        callback callbacks[:after_save]
        @document.to_json
      end

      delete '/:id/?' do
        require_at_least(:curator)
        id = params.delete("id")
        @document = model.find_by_id(id)
        error 404, [].to_json unless @document
        callback callbacks[:before_destroy]
        @document.destroy
        callback callbacks[:after_destroy]
        { "id" => id }.to_json
      end
    end
    
  end
  
end
