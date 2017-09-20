/* eslint-env browser, jquery */
/* global HMDA */
(function(){

//Given a list of institutions, create units of html for each of them
function buildList(institutions) {
  var html = createInstitutions(institutions);
  $('#institutions').html(html);

  addInstitutionsToInput();
}

//Given a list of institutions, return an html list of description lists for each
function createInstitutions(institutions) {
  var html = '<ul class="usa-unstyled-list">'
  var checked = (institutions.length === 1) ? 'checked' : ''

  for (var i = 0; i < institutions.length; i++) {
    html = html + '<li>'
      + '<input class="institutionsCheck" type="checkbox" id="'
      + institutions[i].id + '" name="institutions" value="'
      + institutions[i].id + '"' + checked + '>'
      + '<label for="' + institutions[i].id + '">'
      + '<strong>' + institutions[i].name + '</strong>'
      + createExternalIdHTML(institutions[i].externalIds)
      + '</label></li>'
  }
  html = html + '</ul></fieldset>'

  return html
}


//Create description list from a list of ids
function createExternalIdHTML(externalIds) {
  var html = '';
  if(externalIds.length > 0) {
    html = '<dl class="usa-text-small">';
    for (var i = 0; i < externalIds.length; i++) {
      html += '<dt>' + externalIds[i].externalIdType.name + ': </dt>';
      html += '<dd>' + externalIds[i].value + '</dd>';
    }
    html += '</dl>';
  }

  return html;
}


//Get checked institutions' values and add them to a hidden input field to be submitted
function addInstitutionsToInput() {
  var listOfInstitutions = [];
  // add to the user.attributes.institutions input
  $('.institutionsCheck').each(function(index){
    if($(this).prop('checked')) {
      listOfInstitutions.push($(this).val())
    }
  })
  $('#user\\.attributes\\.institutions').val(listOfInstitutions.join(','));
}


//AJAX call to get data, calls buildList with returned institutions
function getInstitutions(domain) {
  $.ajax({
    url: HMDA.institutionSearchUri,
    statusCode: {
      404: function() {
        $('#institutions').html(
          '<span class="hmda-error-message">' +
          'Sorry, we couldn\'t find that email domain. Please contact ' +
           getEmailLink() +
          ' for help getting registered.</span>'
        )
      }
    },
    data: { domain: domain },
    beforeSend: function() {
      $('#institutions').html(
        '<div class="LoadingIconWrapper">' +
        '<img src="' + HMDA.resources + '/img/LoadingIcon.png" class="LoadingIcon" alt="Loading"></img>' +
        '</div>');
    }
  })
  .done(function(data, status, xhr) {
    buildList(data.institutions);
  })
  .fail(function(request, status, error) {
    $('#institutions').html(
      '<span class="hmda-error-message">Sorry, something went wrong. Please contact ' +
      getEmailLink() +
      ' for help getting registered <strong>or</strong> try again in a few minutes.</span>'
    )
  });
}


//Password checking function list
var checkFunctions = [
  function atLeastTwelve(val) {
    return val.length > 11
  },

  function hasUppercase(val) {
    return !!val.match(/[A-Z]/)
  },

  function hasLowercase(val) {
    return !!val.match(/[a-z]/)
  },

  function hasNumber(val) {
    return !!val.match(/[0-9]/)
  },

  function hasSpecial(val) {
    return !!val.match(/[^a-zA-Z0-9]/)
  },

  function notUsername(password, username) {
    return password !== username
  }
]


//email parsing util
function emailToDomain(email) {
  return email.split('@', 2)[1];
}


//build email links from values provided at build time
function getEmailLink() {
  return '<a href="mailto:' +
    HMDA.supportEmailTo +
    '?subject=' +
    HMDA.supportEmailSubject +
    '">' +
    HMDA.supportEmailTo +
    '</a>'
}


//Make a debounced version of the getInstitutions API call, passing in the desired delay
function makeDebouncer(delay){
  var timeout
  return function(domain){
    clearTimeout(timeout)
    timeout = setTimeout(function(){getInstitutions(domain)}, delay)
  }
}

var debounceRequest = makeDebouncer(300)

$(document).ready(function() {
  var email = $('#email');
  var password = $('#password');
  var passwordConfirm = $('#password-confirm');
  var validationList = $('#validation_list > li')
  var pwdMatchError = $('#password-confirm-error-message')
  var emailExp = /[a-zA-Z0-9!#$%&'*+/=?^_`{|}~.-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-]+/
  var lastEmail = null


  //Process email and make debounced request when typing in email field
  email.on('blur keyup', function(e) {
    var emailVal = email.val().trim()
    if(emailVal === lastEmail) return
    else lastEmail = emailVal

    // keycode (tab key) used to not warn when first tabbing into the email field
    if((emailVal === '' || emailVal === null) && e.keyCode !== 9) {
      $('#institutions').html(
        '<span class="hmda-error-message">' +
        HMDA.enterEmailMessage +
        '</span>'
      )
    } else {
      // e.keyCode will be 'undefined' on tab key
      // don't make the API call on tab keyup
      var domain = emailToDomain(emailVal)
      if((emailExp.test(emailVal) && e.keyCode) || e.type === 'blur' && domain !== '') {
        debounceRequest(domain)
      }
    }
  })


  //Save institution to input when clicked
  $('#institutions').on('click', '.institutionsCheck', addInstitutionsToInput);


  //Mark password rules as completed when typing and possible adjust password matching error
  password.on('keyup', function(e) {
    validationList.each(function(i, el) {
      if(checkFunctions[i](password.val(), email.val())) {
        el.className = 'complete'
      }else{
        el.className = ''
      }
    })

    var passVal = password.val()
    var confirmVal = passwordConfirm.val()
    if(confirmVal){
      if(passVal !== confirmVal) showMatchingError()
      else hideMatchingError()
    }
  })

  //Display checks for unmet password rules
  password.on('blur', function(e) {
    validationList.each(function(i, el) {
      if(checkFunctions[i](password.val(), email.val())) {
        el.className = 'complete'
      }else{
        el.className = 'missing'
      }
    })
  })


  //show or hide confirm as needed
  //<= ensures it doesn't show too early
  passwordConfirm.on('keyup', function(e) {
    var passVal = password.val()
    var confirmVal = passwordConfirm.val()
    if(passVal === confirmVal) {
      hideMatchingError()
    }else if(passVal.length <= confirmVal.length) {
      showMatchingError()
    }
  })

  //show or hide confirm, on blur will also show errors if confirmation text is shorter than password
  passwordConfirm.on('blur', function(e) {
    if(passwordConfirm.val() === password.val()) {
      hideMatchingError()
    } else {
      showMatchingError()
    }
  })


  //Util for showing error text when password and confirm field don't match
  function showMatchingError() {
    pwdMatchError.css('display', 'block');
    pwdMatchError.prev().css('font-weight', 'bold');
  }


  //Util for hiding error text when password and confirm field match
  function hideMatchingError () {
    pwdMatchError.css('display', 'none');
    pwdMatchError.prev().css('font-weight', 'normal');
  }
})

})()
