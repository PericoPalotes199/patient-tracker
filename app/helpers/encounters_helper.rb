module EncountersHelper

  # These methods choose the set of encounter_type that are used to
  # creat the new form's hidden inputs and the value that will be submitted
  # in the hidden inputs.

  # Note: The _encounter_types_ return values can be produced by mapping the
  # _labels_ arrays with `labels.remove(' ').underscore`.

  def encounter_types
    return default_encounters_types unless current_user.has_custom_labels?
    if current_user.has_custom_labels?
      # TODO: these will need to be renamed and categorized/strategized
      custom_encounters_types_1
    end
  end

  def default_encounters_types
    [
      'adult_inpatient',
      'adult_ed',
      'adult_icu',
      'adult_inpatient_surgery',
      'pediatric_inpatient',
      'pediatric_newborn',
      'pediatric_ed',
      'continuity_inpatient',
      'continuity_external'
    ]
  end

  def custom_encounters_types_1
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

  # These methods choose the set of labels to display for the
  # encounters#new view, based on the residency's name (stored in ENV).
  def display_labels
    return default_display_labels unless current_user.has_custom_labels?
    if current_user.has_custom_labels?
      # TODO: these will need to be renamed and categorized/strategized
      custom_display_labels_1
    end
  end

  def default_display_labels
    [
      "Adult Inpatient",
      "Adult ED",
      "Adult ICU",
      "Adult Inpatient Surgery",
      "Pediatric Inpatient",
      "Pediatric Newborn",
      "Pediatric ED",
      "Continuity Inpatient",
      "Continuity External"
    ]
  end

  def custom_display_labels_1
    [
      'Adult Inpatient',
      'Adult ICU',
      'Obstetrics Vaginal Deliveries',
      'OlderAdults Outpatient',
      'Pediatric Outpatient',
      'Pediatric Inpatient',
      'Pediatric Newborn',
      'Pediatric ED',
      'Women’sHealth Outpatient'
    ]
  end
end
