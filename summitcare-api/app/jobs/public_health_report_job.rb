class PublicHealthReportJob < ApplicationJob
  def perform(lab_result)
    StatePublicHealthClient.new.submit_lab_report(lab_result)
    Disclosure.record!(
      patient: lab_result.patient,
      recipient_name: "State Department of Health, Epidemiology Division",
      recipient_address: StatePublicHealthClient::RECIPIENT_ADDRESS,
      purpose: "public_health",
      description: "Reportable lab result: #{lab_result.test_name}, " \
                   "resulted #{lab_result.resulted_at.to_date}",
      subject: lab_result
    )
  end
end
