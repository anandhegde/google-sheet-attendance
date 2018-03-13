$(document).ready(function(){
	$("#loaderDiv").hide();
	$("#submit").on("click", function(){
		$("#loaderDiv").show();
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
		$.ajax({
			type: "POST",
			url: "/update-work-sheet",
			beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
			data: data,
			dataType: "json",
			success: function(data){
				$("#loaderDiv").hide();
				$("#submit").text("Update");
			}
		});
	})
	$(".delete").on("click", function(event){
		let target = event.target;
		let grandParent = $(target).parent().parent();
		let index = grandParent.find(".index").text();
		let name = grandParent.find(".name").text();
		if (window.confirm(`Are you sure to want to delete ${name}?`)) {
			let data = {};
	        data["rowNumber"] = parseInt(index) + 1;
	        data["name"] = name;
	        $("#loaderDiv").show();
			$.ajax({
				type: "POST",
				url: "/delete-employee",
				beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
				data: data,
				dataType: "json",
				success: function(data){
					$("#loaderDiv").hide();
					window.location = "/me";
				}
			});
	    }
	})
});