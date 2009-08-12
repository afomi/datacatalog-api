module ModelHelpers

  def create_normal_user
    key = ApiKey.new(:api_key => "normal-000c52cd9e3e746a36d098181c15ff66d")
    User.create({
      :api_keys  => [key],
      :name      => "Normal User",
      :email     => "normal.user@inter.net",
      :admin     => false
    })
  end

  def create_admin_user
    key = ApiKey.new(:api_key => "admin-360d4f2e3582b6b87595fbebc0315764a6")
    User.create({
      :api_keys  => [key],
      :name      => "Admin User",
      :email     => "admin.user@inter.net",
      :admin     => true
    })
  end
  
end
