$(function() {
    var emails;
    $("#loaderDiv").hide();
    $("#message").hide();
    $('input, select').on('change', function(event) {
        var $element = $(event.target),
        $container = $element.closest('.example');

        if (!$element.data('tagsinput'))
        return;

        emails = $element.val();
    }).trigger('change');
    $("#add-emails").on("click", function(){
        $("#loaderDiv").show();
        let data = {
            emails: emails
        }
        $.ajax({
            type: "POST",
            url: "/admin/privilege-users",
            beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
            data: data,
            dataType: "json",
            success: function(data){
                $("#loaderDiv").hide();
                let message = `privileged list updated`;
                $("#message").show().fadeOut(5000);
                $("#message").find("p").text(message);
            },
            error: function(data){
                $("#loaderDiv").hide();
            }
        });
    })
});