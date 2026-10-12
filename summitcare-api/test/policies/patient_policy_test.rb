require "test_helper"

class PatientPolicyTest < ActiveSupport::TestCase
  def resolve(user) = PatientPolicy::Scope.new(user, Patient).resolve

  test "clinicians see only their care team" do
    assert_includes resolve(users(:dr_okafor)), patients(:avery)
    assert_not_includes resolve(users(:dr_okafor)), patients(:riley)
  end

  test "admins and compliance officers see no patients" do
    assert_empty resolve(users(:admin))
    assert_empty resolve(users(:morgan_reyes))
  end

  test "front desk never receives the visit reason" do
    json = AppointmentSerializer.new(appointments(:avery_checkup), viewer: users(:pat_lindqvist)).as_json
    assert_not_includes json.keys, :reason
  end
end
