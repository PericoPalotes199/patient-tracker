// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/

var encounter_types = ['adult_inpatient', 'adult_ed', 'adult_icu', 'adult_inpatient_surgery',
                       'pediatric_inpatient', 'pediatric_newborn', 'pediatric_ed',
                       'continuity_inpatient', 'continuity_external'];

function setEncounteredOn() {
  var date = $('#date').val();
  console.log(date);

  $('#encountered_on').val(date);
}

function resetEncounters() {
  for (i = 0; i < encounter_types.length; i++) {
    var encounter_type = encounter_types[i];
    $("#" + encounter_type).html(0);
    $("#" + encounter_type).removeClass( "gradient_blue" );
    $("#" + encounter_type).addClass( "gradient_light" );
    $('#encounter_types_' + encounter_type).val(0);
    $("#total").html(0);
  }
}

function incrementEncounterType(encounter_type) {
  console.log(encounter_type);
  current_value = parseInt( $('#' + encounter_type).text() );
  console.log(current_value);
  current_value++;
  console.log(current_value);

  $("#" + encounter_type).html(current_value);
  $('#encounter_types_' + encounter_type).val(current_value);

  $("#" + encounter_type).addClass( "gradient_blue" );
  $("#" + encounter_type).removeClass( "gradient_light" );
  calcTotal();
}

function calcTotal() {
  var total =  parseInt($('#encounter_types_' + encounter_types[0]).val()) +
               parseInt($('#encounter_types_' + encounter_types[1]).val()) +
               parseInt($('#encounter_types_' + encounter_types[2]).val()) +
               parseInt($('#encounter_types_' + encounter_types[3]).val()) +
               parseInt($('#encounter_types_' + encounter_types[4]).val()) +
               parseInt($('#encounter_types_' + encounter_types[5]).val()) +
               parseInt($('#encounter_types_' + encounter_types[6]).val()) +
               parseInt($('#encounter_types_' + encounter_types[7]).val()) +
               parseInt($('#encounter_types_' + encounter_types[8]).val());
  console.log (total);
  $("#total").html(total);
}
