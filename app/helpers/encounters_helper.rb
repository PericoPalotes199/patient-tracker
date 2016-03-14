module EncountersHelper

  # These methods return the set of encounter_types that are used to
  # create the new form's hidden inputs and the values that will be submitted
  # in the hidden inputs.

  def encounter_types
    current_user.encounter_types
  end

  def labels
    current_user.labels
  end

end
