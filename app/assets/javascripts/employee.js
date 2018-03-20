$(document).ready(function(){
	$("#error-message").hide();
	$("#loaderDiv").hide();
	$("#success-message").hide();
	$("#add-employee").on("click", function(){
		let name = $("#name")[0].value;
		let remuneration = $("#remuneration")[0].value;
		if(name && remuneration) {
			$("#loaderDiv").show();
			let data = {
				name: name,
				remuneration: remuneration
			}
			$.ajax({
				type: "POST",
				url: "/employee/new",
				beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
				data: data,
				dataType: "json",
				success: function(data){
					$("#loaderDiv").hide();
					let message = `${name} added to the spreadsheet`;
					$("#success-message").show().fadeOut(3000);
					$("#success-message").find("p").text(message)
					$("#name")[0].value = "";
					$("#remuneration")[0].value = "";
				}
			});
		} else {
			$("#error-message").show();
		}
	})
})