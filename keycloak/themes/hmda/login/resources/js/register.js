/* eslint-env browser, jquery */
/* global HMDA */
(function(){

var emailExp = /[a-zA-Z0-9!#$%&'*+/=?^_`{|}~.-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-]+/
var pwdMatchError = $('#password-confirm-error-message')

function emailToDomain(email) {
  return email.split('@', 2)[1];
}

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

function createInstitutions(institutions) {
  var html = '<ul class="usa-unstyled-list">'
  var checked = (institutions.length === 1) ? 'checked' : ''

  for (var i = 0; i < institutions.length; i++) {
    //var dataList = getExternalIds(institutions[i].externalIds)
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

function buildList(institutions) {
  var html = createInstitutions(institutions);
  $('#institutions').html(html);

  addInstitutionsToInput();
}

function getEmailLink() {
  return '<a href="mailto:' +
    HMDA.supportEmailTo +
    '?subject=' +
    HMDA.supportEmailSubject +
    '">' +
    HMDA.supportEmailTo +
    '</a>'
}

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

function addInstitutionsToInput() {
  var listOfInstitutions = [];
  // add to the user.attributes.institutions input
  $('.institutionsCheck').each(function(index){
    if($(this).prop('checked')) {
      listOfInstitutions.push($(this).val())
    }
  })
  $("#user\\.attributes\\.institutions").val(listOfInstitutions.join(","));
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

  email.on('blur keyup', function(e) {
    // keycode (tab key) used to not warn when first tabbing into the email field
    if((email.val() === '' || email.val() === null) && e.keyCode !== 9) {
      $('#institutions').html(
        '<span class="hmda-error-message">' +
        HMDA.enterEmailMessage +
        '</span>'
      )
    } else {
      // e.keyCode will be 'undefined' on tab key
      // don't make the API call on tab keyup
      var domain = emailToDomain(email.val().trim())
      if((emailExp.test(email.val()) && e.keyCode) || e.type === 'blur' && domain !== '') {
        debounceRequest(domain)
      }
    }
  })

  if(email.val() !== '' && email.val() !== null) {
    getInstitutions(emailToDomain(email.val()));
  }

  // remove whitespace from email to prevent 'invalid email'
  email.on('blur', function(e) {
    email.val($.trim(email.val()))
  })

  $('#institutions').on('click', '.institutionsCheck', addInstitutionsToInput);

  function hideMatchingError () {
    pwdMatchError.css('display', 'none');
    pwdMatchError.prev().css('font-weight', 'normal');
  }

  function showMatchingError() {
    pwdMatchError.css('display', 'block');
    pwdMatchError.prev().css('font-weight', 'bold');
  }

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

  //display error checks
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

  passwordConfirm.on('blur', function(e) {
    if(passwordConfirm.val() === password.val()) {
      hideMatchingError()
    } else {
      showMatchingError()
    }
  })
})

})()
