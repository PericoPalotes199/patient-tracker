module EncountersHelper

  # These methods choose the set of encounter_type that are used to
  # creat the new form's hidden inputs and the value that will be submitted
  # in the hidden inputs.

  # These methods choose the set of labels to display for the
  # encounters#new view, based on the Residency.
  def encounter_types
    return default_encounter_types unless current_user.has_custom_encounter_types?
    if current_user.has_custom_encounter_types?
      # TODO: strategy for per-residency sets of encounter_types
      custom_encounter_types
    end
  end

  def default_encounter_types
    Encounter.default_encounter_types
  end

  def custom_encounter_types
    [
      'adult_inpatient',
      'adult_icu',
      'obstetrics_vaginal_deliveries',
      'older_adults_outpatient',
      'pediatric_outpatient',
      'pediatric_inpatient',
      'pediatric_newborn',
      'pediatric_ed',
      'women’s_health_outpatient'
    ]
  end
end
