// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on('page:load ready', function(){
	// The following is a test only
	$('#submitButton').click(function(){
	})

	// When radio button is clicked, text area will show corresponding speech of that speaker
	$("input[type='radio'][name='entry[speaker]']").change(function(){
		$('#transBox').val($('#transcript').data('content')[$(this).val()]);
		$('#wcount').html($('#transBox').val().split(' ').length);
	});

});