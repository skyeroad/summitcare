# A human-readable copy of the patient's records (Solution 18).
class RecordExportPdf
  def initialize(patient) = @patient = patient

  def render
    patient = @patient
    pdf = Prawn::Document.new(page_size: "LETTER", info: { Title: "SummitCare records" })
    pdf.text "SummitCare: Copy of Your Health Records", size: 18, style: :bold
    pdf.text "Generated #{Time.current.to_date.iso8601}", size: 9
    pdf.move_down 12

    section(pdf, "Demographics") do
      pdf.text "#{patient.full_name} (MRN #{patient.mrn})"
      pdf.text "Date of birth: #{patient.date_of_birth&.iso8601}"
      pdf.text [patient.address_line1, patient.city, patient.state, patient.postal_code].compact.join(", ")
    end
    section(pdf, "Lab results") do
      patient.lab_results.order(:resulted_at).each do |lab|
        pdf.text "#{lab.resulted_at.to_date}  #{lab.test_name}: #{lab.value} #{lab.unit} (ref #{lab.reference_range})"
        pdf.text("  Note: #{lab.notes}", size: 9) if lab.notes.present?
        amendments(pdf, lab)
      end
    end
    section(pdf, "Visits") do
      patient.appointments.order(:starts_at).each do |appt|
        pdf.text "#{appt.starts_at.to_date}  #{appt.status.humanize}: #{appt.reason}"
        amendments(pdf, appt)
      end
    end
    section(pdf, "Documents") do
      patient.documents.order(:created_at).each do |doc|
        pdf.text "#{doc.created_at.to_date}  #{doc.kind.humanize}: #{doc.title}"
        amendments(pdf, doc)
      end
    end
    pdf.render
  end

  private

  def section(pdf, title)
    pdf.text title, size: 14, style: :bold
    pdf.move_down 4
    yield
    pdf.move_down 12
  end

  def amendments(pdf, record)
    record.amendment_materials.each do |material|
      pdf.text "  #{material.kind.humanize} (#{material.created_at.to_date}): #{material.body}", size: 9
    end
  end
end
