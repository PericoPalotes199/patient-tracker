// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/

var encounter_types = [];

// TODO: How can this behavior be run on page ready or load instead of
// called by event handler functions below?
function parseEncounterLabels() {
  if (!encounter_types.length) {
    encounter_types = $('.encounter_type_button')
                      .map( function(index, element) { return element.id; } );
  }
}

function setEncounteredOn() {
  var date = $('#date').val();
  $('#encountered_on').val(date);
}

function resetEncounters() {
  parseEncounterLabels();
  for (i = 0; i < encounter_types.length; i++) {
    var encounter_type = encounter_types[i];
    $("#" + encounter_type)
      .html(0)
      .removeClass( "gradient_blue" )
      .addClass( "gradient_light" );
    $('#encounter_types_' + encounter_type).val(0);
    $("#total").html(0);
  }
}

function incrementEncounterType(encounter_type) {
  parseEncounterLabels();
  current_value = parseInt( $('#' + encounter_type).text() );
  current_value++;

  $("#" + encounter_type).html(current_value);
  $('#encounter_types_' + encounter_type).val(current_value);

  $("#" + encounter_type)
    .addClass( "gradient_blue" )
    .removeClass( "gradient_light" );

  calcTotal();
}

function calcTotal() {
  var total = 0;
  for (i = 0; i < encounter_types.length; i++) {
    total += parseInt( $('#encounter_types_' + encounter_types[i]).val() );
  }
  $("#total").html( total );
}
