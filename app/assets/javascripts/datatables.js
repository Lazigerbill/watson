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

		var table = $("#allEntries").DataTable({
			// "serverSide": true,
			// "ajax": "/entries.json",
			// "processing": true
			"order": [[ 2, 'asc' ], [ 4, 'asc' ]],
			"columnDefs": [
	                { "orderable": false, "targets": [0, 8]}
	                ]
		});

    //var allPages = table.fnGetNodes();
    $('#select_all').on('click', function(){
      // Check/uncheck all checkboxes in the table
      var rows = table.rows({ 'search': 'applied' }).nodes();
      $('input[type="checkbox"]', rows).prop('checked', this.checked);
    });
});
