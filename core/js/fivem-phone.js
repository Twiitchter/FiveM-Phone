
$(document).ready(function () {
    var resizeDelay = 200;
    var doResize = true;
    var resizer = function () {
        if (doResize) {

            // Working on cross page scale..

            doResize = false;
        }
    };
    var resizerInterval = setInterval(resizer, resizeDelay);
    resizer();

    $(window).resize(function () {
        doResize = true;
        console.log("Phone.Scaled");
    });
});

$(window).on("load", function () {
    console.log("Phone.Loaded");
});

$(function () {
    $("#Unlock").click(function () {
        $("#OSLock").css({ "z-index": "-40" });
    });
});

$(function () {
    $("#OSBotA").click(function () {
        console.log("Phone.Reload");
        document.location.reload();
    });
});

$(function () {
    $("#OSBotB").click(function () {
        console.log("Phone.Home");
        $('#UseFrame').attr("src", "html/home.html");
    });
});

//-----------------------------------------------------------------------------------

// Below is the controls for FiveM 

//-----------------------------------------------------------------------------------

$(function () {
    function display(bool) {
        if (bool) {
            $("#Page").show();
        } else {
            $("#Page").hide();
        }
    }

    display(true)

    window.addEventListener('message', function(event) {
        var item = event.data;
        if (item.type === "ui") {
            if (item.status == true) {
                display(true)
            } else {
                display(false)
            }
        }
    })
	
    // if the person uses the escape key, it will exit the resource
    document.onkeyup = function (data) {
        if (data.which == 27) {
            $.post('http://fivem-phone/exit', JSON.stringify({}));
            return
        } else if (data.which == 8) {
            $.post('http://fivem-phone/exit', JSON.stringify({}));
            return
        }
    };
})

//-----------------------------------------------------------------------------------
