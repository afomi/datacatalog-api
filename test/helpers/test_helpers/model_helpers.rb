module ModelHelpers
  
  def reset_sources
    Source.destroy_all
  end

  def reset_users
    User.destroy_all
  end
  
  def create_unconfirmed_user
    User.create({
      :api_key   => "unconfirmed-2cd9e3e746a36d098181c15ff66d",
      :name      => "Mr. Unconfirmed",
      :email     => "mr.unconfirmed@inter.net",
      :confirmed => false,
      :admin     => false
    })
  end

  def create_confirmed_user
    @normal = User.create({
      :api_key   => "confirmed-c52cd9e3e746a36d098181c15ff66d",
      :name      => "Dr. Confirmed",
      :email     => "dr.confirmed@inter.net",
      :confirmed => true,
      :admin     => false
    })
  end

  def create_admin_user
    User.create({
      :api_key   => "admin-360d4f2e3582b6b87595fbebc0315764a6",
      :name      => "Admin",
      :email     => "admin@inter.net",
      :confirmed => true,
      :admin     => true
    })
  end
  
end
