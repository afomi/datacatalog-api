module DataCatalog
  
  module Roles
    include SinatraResource::Roles
  
    role :anonymous
    role :basic   => :anonymous
    role :owner   => :basic
    role :curator => :basic
    role :admin   => [:owner, :curator]
  end

end
