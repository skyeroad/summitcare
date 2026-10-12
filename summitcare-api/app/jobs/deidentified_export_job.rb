class DeidentifiedExportJob < ApplicationJob
  def perform
    safe_harbor = Deidentify::SafeHarbor.new
    Analytics::LabObservation.transaction do
      Analytics::LabObservation.delete_all
      LabResult.includes(:patient).find_in_batches(batch_size: 1_000) do |batch|
        Analytics::LabObservation.insert_all!(batch.map { |lab| safe_harbor.lab_observation(lab) })
      end
    end
  end
end
