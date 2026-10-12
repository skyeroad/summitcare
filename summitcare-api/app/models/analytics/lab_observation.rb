# De-identified lab observations in the separate analytics database (Solution 22).
module Analytics
  class LabObservation < Record
    self.table_name = "lab_observations"
  end
end
