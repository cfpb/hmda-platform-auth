var keycloak = Keycloak({
    url: 'http://192.168.99.100/auth',
    realm: 'hmda',
    clientId: 'hmda-apis'
})

$(document).ready(function() {

    keycloak.init({
        flow: 'implicit',
        checkLoginIframe: false
    }).success(function(authenticated) {
        console.log('Keycloak init successful');
    }).error(function() {
        console.log('ERROR: Could not initialize Keycloak client.');
    })

    if(!keycloak.authenticated) {
        console.log('User not authenticated.')
        $("#login-link").click(forwardToLogin);
    } else {
        console.log('User ' + keycloak.subject + ' is authenticated.')
    
        var idToken = keycloak.idToken;
        var accessToken = keycloak.token;
    
        var idTokenJwt = keycloak.idTokenParsed;
        $("#login-status").text("Welcome back, " + idTokenJwt.given_name + "!");
        $("#oidc-id-token").text(idToken);
        $("#oidc-id-token-jwt").text(JSON.stringify(idTokenJwt, null, '  '));

        var accessTokenJwt = keycloak.tokenParsed;
        $("#oidc-access-token").text(accessToken);
        $("#oidc-access-token-jwt").text(JSON.stringify(accessTokenJwt, null, '  '));
   
        // Set functions for API calls 
        $("#echo-request-button").click(callEchoApi)
    
        $("#inst-list-button").click(getMyInstitutions)
    
        $("#inst-button").click(function(){
            var instId = $("#inst-input").val()
            getInstitution(instId)
        })
    }
});

function forwardToLogin() {
    console.log('Redirect to authorization server...');
    keycloak.login();
    console.log('Redirect to authorization server complete.');
}

function getInstitution(instId) {

    var resource = "/hmda/institutions/v1/institutions/"+instId

    $("#inst-id").text(instId)

    $.ajax({
        url: "https://192.168.99.100/apiman-gateway"+resource,
        method: "GET",
        headers: {
            "Authorization": "Bearer " + keycloak.token
        }
    }).done(function(data, textStatus, jqXHR) {
        console.log("Institution "+instId+" found! :)")
        $("#inst-response").text(JSON.stringify(data, null, '  '))
    }).fail(function(error){
        console.log("Institution "+instId+" NOT found! :(")
        $("#inst-response").text(JSON.stringify(error, null, '  '))
    });
}


function getMyInstitutions() {

    $.ajax({
        url: "https://192.168.99.100/apiman-gateway/hmda/institutions/v1/institutions",
        method: "GET",
        headers: {
            "Authorization": "Bearer " + keycloak.token
        }
    }).done(function(data, textStatus, jqXHR) {
        console.log("Institutions List Success! :)")
        data.forEach(function(inst){
            $("#inst-list-response-table").append(
                "<tr><td>"+inst.id+"</td><td>"+inst.name+"</td><td>"+inst.taxId+"</td></tr>"
            )
        })
        $("#inst-list-response").text(JSON.stringify(data, null, '  '))
    }).fail(function(error){
        console.log("Institutions List Fail! :(")
        $("#inst-list-response").text(JSON.stringify(error, null, '  '))
    });
}

function callEchoApi() {

    $.ajax({
        url: "https://192.168.99.100/apiman-gateway/hmda/echo/v1",
        method: "PUT",
        headers: {
            "Authorization": "Bearer " + keycloak.token
        }
    }).done(function(data, textStatus, jqXHR) {
        console.log("Echo Success! :)")
        $("#echo-response").text(JSON.stringify(data, null, '  '))
    }).fail(function(error){
        console.log("Echo Fail! :(")
        $("#echo-response").text(JSON.stringify(error, null, '  '))
    });
}

