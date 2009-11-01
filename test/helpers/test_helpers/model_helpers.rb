module ModelHelpers

  def create_normal_user
    key = ApiKey.new(
      :api_key  => "normal-000c52cd9e3e746a36d098181c15ff66d",
      :key_type => "primary"
    )
    User.create({
      :api_keys  => [key],
      :name      => "Normal User",
      :email     => "normal.user@inter.net"
    })
  end
  
  def create_another_normal_user
    key = ApiKey.new(
      :api_key  => "normal-400746a36d098181c15c52cd9e3eff66d",
      :key_type => "primary"
    )
    User.create({
      :api_keys  => [key],
      :name      => "Another Normal User",
      :email     => "another.normal.user@inter.net"
    })
  end

  def create_curator_user
    key = ApiKey.new(
      :api_key  => "curator-11112e3582b6b87595fbebc0315764a6",
      :key_type => "primary"
    )
    User.create({
      :api_keys  => [key],
      :name      => "Curator User",
      :email     => "curator.user@inter.net",
      :curator   => true
    })
  end

  def create_admin_user
    key = ApiKey.new(
      :api_key  => "admin-360d4f2e3582b6b87595fbebc0315764a6",
      :key_type => "primary"
    )
    User.create({
      :api_keys  => [key],
      :name      => "Admin User",
      :email     => "admin.user@inter.net",
      :admin     => true
    })
  end
  
  # == Factories
  
  def create_category(custom={})
    create_model!(Category, custom, {
      :source_id   => get_fake_mongo_object_id,
      :category_id => get_fake_mongo_object_id,
    })
  end
  
  def create_categorization(custom={})
    create_model!(Categorization, custom, {
      :source_id   => get_fake_mongo_object_id,
      :category_id => get_fake_mongo_object_id,
    })
  end
  
  def create_comment(custom={})
    required = {
      :text      => "Comment Text",
      :source_id => get_fake_mongo_object_id,
    }
    required[:user_id] = @normal_user.id if @normal_user
    create_model!(Comment, custom, required)
  end
  
  def create_comment_rating(custom={})
    required = {
      :kind      => "comment",
      :value     => 1,
      :source_id => get_fake_mongo_object_id,
    }
    required[:user_id] = @normal_user.id if @normal_user
    create_model!(Rating, custom, required)
  end
  
  def create_document(custom={})
    required = {
      :text      => "Sample Document",
      :source_id => get_fake_mongo_object_id,
    }
    required[:user_id] = @normal_user.id if @normal_user
    create_model!(Document, custom, required)
  end
  
  def create_organization(custom={})
    required = {
      :name     => "Sample Organization",
      :url      => "http://name.org",
      :org_type => "governmental"
    }
    required[:user_id] = @normal_user.id if @normal_user
    create_model!(Organization, custom, required)
  end
  
  def create_note(custom={})
    required = {
      :text      => "Sample Note",
      :source_id => get_fake_mongo_object_id,
    }
    required[:user_id] = @normal_user.id if @normal_user
    create_model!(Note, custom, required)
  end
  
  def create_source(custom={})
    create_model!(Source, custom, {
      :title => "2005-2007 American Community Survey PUMS Housing File",
      :url   => "http://www.data.gov/details/90"
    })
  end
  
  def create_source_rating(custom={})
    required = {
      :kind      => "source",
      :value     => 4,
      :text      => "Rating Text",
      :source_id => get_fake_mongo_object_id,
    }
    required[:user_id] = @normal_user.id if @normal_user
    create_model!(Rating, custom, required)
  end
  
  def create_user_with_primary_key(custom={})
    user = create_user(custom)
    user.add_api_key!(:key_type => "primary")
    user
  end

  def create_user(custom={})
    create_model!(User, custom, {
      :name  => "Data Mangler",
      :email => "data.mangler@inter.net"
    })
  end
  
  def create_tag(custom={})
    create_model!(Tag, custom, {
      :text => "Sample Tag"
    })
  end
  
  # -----

  def new_api_key(custom={})
    new_model!(ApiKey, custom, {
      :api_key  => "",
      :key_type => ""
    })
  end

  def new_category(custom={})
    new_model!(Category, custom, {
      :source_id   => get_fake_mongo_object_id,
      :category_id => get_fake_mongo_object_id,
    })
  end
  
  def new_categorization(custom={})
    new_model!(Categorization, custom, {
      :source_id   => get_fake_mongo_object_id,
      :category_id => get_fake_mongo_object_id,
    })
  end
  
  def new_comment(custom={})
    required = {
      :text      => "Comment Text",
      :source_id => get_fake_mongo_object_id,
    }
    required[:user_id] = @normal_user.id if @normal_user
    new_model!(Comment, custom, required)
  end
  
  def new_comment_rating(custom={})
    required = {
      :kind      => "comment",
      :value     => 1,
      :source_id => get_fake_mongo_object_id,
    }
    required[:user_id] = @normal_user.id if @normal_user
    new_model!(Rating, custom, required)
  end
  
  def new_document(custom={})
    required = {
      :text      => "Sample Document",
      :source_id => get_fake_mongo_object_id,
    }
    required[:user_id] = @normal_user.id if @normal_user
    new_model!(Document, custom, required)
  end

  def new_note(custom={})
    required = {
      :text      => "Sample Note",
      :source_id => get_fake_mongo_object_id,
    }
    required[:user_id] = @normal_user.id if @normal_user
    new_model!(Note, custom, required)
  end

  def new_source(custom={})
    new_model!(Source, custom, {
      :title => "2005-2007 American Community Survey Three-Year PUMS Housing File",
      :url   => "http://www.data.gov/details/90"
    })
  end

  def new_tag(custom={})
    new_model!(Tag, custom, {
      :text => "Sample Tag"
    })
  end
  
  def new_user(custom={})
    new_model!(User, custom, {
      :name  => "Data Mangler",
      :email => "data.mangler@inter.net"
    })
  end

  protected

  def create_model!(klass, custom, required)
    model = klass.create(required.merge(custom))
    unless model.valid?
      raise "Invalid #{klass}: #{model.errors.errors.inspect}"
    end
    model
  end

  def new_model!(klass, custom, required)
    model = klass.new(required.merge(custom))
    unless model.valid?
      raise "Invalid #{klass}: #{model.errors.errors.inspect}"
    end
    model
  end

end
