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

  # def create_example_source
  #   
  # end
  
end
