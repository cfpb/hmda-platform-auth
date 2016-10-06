$(document).ready(function() {

    console.log('CORS Test Starting...')

    $.ajax({
        url: "https://192.168.99.100/apiman-gateway/hmda/echo/cors"//,
//        headers: {
//            "Authorization": "Bearer: " + accessToken
//        }
    }).then(function(data) {
        console.log(JSON.stringify(data, null, '  '))
    });

    console.log('CORS Test Complete')

});
