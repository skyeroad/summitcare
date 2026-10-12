module Analytics
  class Record < ActiveRecord::Base
    self.abstract_class = true
    connects_to database: { writing: :analytics, reading: :analytics }
  end
end
