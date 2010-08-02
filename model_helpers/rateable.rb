module Ratable

  def self.included(other_module)
    other_module.class_eval do
      key :rating_stats, Hash, :default => {
        :total   => 0,
        :count   => 0,
        :average => nil
      }
    end
  end

end
