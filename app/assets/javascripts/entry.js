$(document).on('page:load ready', function(){

	// When radio button is clicked, text area will show corresponding speech of that speaker
	$("input[type='radio'][name='entry[speaker_name]']").change(function(){
		$('.transBox').val($('#transcript').data('content')[$(this).val()]);
		// word count
		$('#wcount').text($('.transBox').val().split(' ').length);
	});

});