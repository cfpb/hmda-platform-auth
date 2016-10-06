$(document).ready(function() {

    $("#login-link").click(forwardToLogin)

    // Restore configuration information
    OIDC.restoreInfo();

    try {
        var idToken = OIDC.getValidIdToken()
        console.log('id_token: ' + idToken)
    } catch(e) {
        console.log('Could not get id_token.  Error: ' + e.message)
    }

    var accessToken = undefined

    try {
        accessToken = OIDC.getAccessToken()
    } catch(e) {
        if (e instanceof OidcException) {
            console.log('Could not get access_token.  Error: ' + e.message)
        }
    }

    if(idToken) {
        idTokenJwt = tokenToJWT(idToken)
        $("#login-status").text("Welcome back, " + idTokenJwt.given_name + "!")
        $("#oidc-id-token").text(idToken)
        $("#oidc-id-token-jwt").text(JSON.stringify(idTokenJwt, null, '  '))
    }

    if(accessToken) {
        accessTokenJwt = tokenToJWT(accessToken)
        $("#oidc-access-token").text(accessToken)
        $("#oidc-access-token-jwt").text(JSON.stringify(accessTokenJwt, null, '  '))
    }

    $("#echo-request-button").click(function(){
        callEchoApi(accessToken)
    })

    $("#inst-list-button").click(function(){
        getMyInstitutions(accessToken)
    })

    $("#inst-button").click(function(){
        var instId = $("#inst-input").val()
        console.log('instId: '+instId)
        getInstitution(accessToken, instId)
    })

});

function getInstitution(accessToken, instId) {

    var resource = "/hmda/institutions/v1/institutions/"+instId

    $("#inst-id").text(instId)

    $.ajax({
        url: "https://192.168.99.100/api"+resource,
        method: "GET",
        headers: {
            "Authorization": "Bearer " + accessToken
        }
    }).done(function(data, textStatus, jqXHR) {
        console.log("Institution "+instId+" found! :)")
        $("#inst-response").text(JSON.stringify(data, null, '  '))
    }).fail(function(error){
        console.log("Institution "+instId+" NOT found! :(")
        $("#inst-response").text(JSON.stringify(error, null, '  '))
    });
}


function getMyInstitutions(accessToken) {

    $.ajax({
        url: "https://192.168.99.100/api/hmda/institutions/v1/institutions",
        method: "GET",
        headers: {
            "Authorization": "Bearer " + accessToken
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

function callEchoApi(accessToken) {

    if(accessToken) {
        $.ajax({
            url: "https://192.168.99.100/echo/v1",
            method: "GET",
            headers: {
                "Authorization": "Bearer " + accessToken
            }
        }).done(function(data, textStatus, jqXHR) {
            console.log("Echo Success! :)")
            $("#echo-response").text(JSON.stringify(data, null, '  '))
        }).fail(function(error){
            console.log("Echo Fail! :(")
            $("#echo-response").text(JSON.stringify(error, null, '  '))
        });
    } else {
        $.ajax({
            url: "https://192.168.99.100/api/echo/v1",
            method: "GET"
        }).done(function(data, textStatus, jqXHR) {
            console.log("Echo Success! :)")
            $("#echo-response").text(JSON.stringify(data, null, '  '))
        }).fail(function(error){
            console.log("Echo Fail! :(")
            $("#echo-response").text(JSON.stringify(error, null, '  '))
        });
    }
}



function tokenToJWT(token) {
    return OIDC.getIdTokenPayload(token)
}

function forwardToLogin() {
    // set client_id and redirect_uri
    var clientInfo = {
        client_id : 'admin-api',
        redirect_uri: 'http://192.168.99.100:7070'
    };
    OIDC.setClientInfo( clientInfo );
    
    // set Identity Provider configuration information using discovery
    var providerInfo = OIDC.discover('https://192.168.99.100:8443/auth/realms/master');
    
    // set Identity Provider configuration
    OIDC.setProviderInfo( providerInfo );
    
    // store configuration for reuse in the callback page
    OIDC.storeInfo(providerInfo, clientInfo);
    
    // Redirect to login
    // login with default scope=openid, response_type=id_token
    //OIDC.login();
    OIDC.login( {
              scope : 'openid profile email',
              response_type : 'id_token token',
              max_age : 60//,
              //claims : {
              //           id_token : ['email', 'phone_number'],
              //           userinfo : ['given_name', 'family_name']
              //         }
             }
    );
}

