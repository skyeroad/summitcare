module Deidentify
  class AggregateReport
    MIN_CELL = 11

    def self.counts_by(*columns, scope: Analytics::LabObservation.all)
      scope.group(*columns).count.transform_values { |n| n < MIN_CELL ? "<#{MIN_CELL}" : n }
    end
  end
end
