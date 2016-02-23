$(document).on('page:load ready', function(){

	$("#allReports").DataTable({
		// "serverSide": true,
		// "ajax": "/entries.json",
		// "processing": true
		"order": [ 3, 'desc' ],
		"columnDefs": [
    { "orderable": false, "targets": 4}
  ],
		"searching": false
		}
	);

		$("#allEntries").DataTable({
			// "serverSide": true,
			// "ajax": "/entries.json",
			// "processing": true
			"order": [[ 2, 'asc' ], [ 4, 'asc' ]],
			"columnDefs": [
	    { "orderable": false, "targets": [0, 8]}
	  ]
			}
		);

});