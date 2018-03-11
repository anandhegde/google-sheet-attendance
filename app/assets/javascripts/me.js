$(document).ready(function(){
	$("#submit").on("click", function(){
		let data = {};
		let attendanceData = {};
		$("tr").each(function(index){
			if(index !== 0){
				let tableCells = $(this).find("td");
				let name = $(tableCells[1]).text();
				let value = $(tableCells[2]).find("input:checked").length;
				attendanceData[name] = value;
			}
		});
		if($(this).text() === "Save"){
			data["type"] = "save";
		} else {
			data["type"] = "update";
		}
		data["data"] = attendanceData;
		console.log(data)
		$.ajax({
			type: "POST",
			url: "/update-work-sheet",
			beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
			data: data,
			dataType: "json",
			success: function(data){
				$("#submit").text("Update")
			}
		});
	})
});