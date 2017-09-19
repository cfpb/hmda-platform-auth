<#import "template.ftl" as layout>
<@layout.registrationLayout; section>
  <#if section = "title">
    ${msg("registerWithTitle",(realm.displayName!''))}
  <#elseif section = "header">
    ${msg("registerWithTitleHtml",(realm.displayNameHtml!''))}
  <#elseif section = "form">
    <form id="kc-register-form" class="usa-form" action="${url.registrationAction}" method="post">
      <fieldset>
        <input type="text" readonly value="this is not a login form" style="display: none;">
        <input type="password" readonly value="this is not a login form" style="display: none;">
        <legend class="usa-drop_text">Create an account</legend>
        <span>or <a href="${url.loginUrl}">go back to login</a></span>

        <#if !realm.registrationEmailAsUsername>
          <label for="username" class="${properties.kcLabelClass!}">${msg("username")}</label>
          <input type="text" id="username" class="${properties.kcInputClass!}" name="username" value="${(register.formData.username!'')?html}" />
        </#if>

        <label for="firstName">${msg("firstName")}</label>
        <input type="text" id="firstName" class="${properties.kcInputClass!}" name="firstName" value="${(register.formData.firstName!'')?html}" autofocus />

        <label for="lastName">${msg("lastName")}</label>
        <input type="text" id="lastName" name="lastName" value="${(register.formData.lastName!'')?html}" />

        <label for="email">${msg("email")}</label>
        <span class="usa-form-hint">The provided email address will be used to notify you of any HMDA related technology updates.</span>
        <input type="text" id="email" name="email" value="${(register.formData.email!'')?html}" />

        <label>Select your institutions</label>
        <div id="institutions">
          <span class="usa-input-help-message">${msg("hmdaEnterEmailAddress", (properties.supportEmailTo!''))}</span>
        </div>

        <input id="user.attributes.institutions" name="user.attributes.institutions" class="usa-skipnav" hidden style="display:none;"/>

        <div class="usa-alert usa-alert-info">
          <div class="usa-alert-body">
            <div class="usa-alert-text">
              <p>Passwords must:</p>
              <ul id="validation_list">
                <li data-validator="length"><img src="${url.resourcesPath}/img/correct9.png"></img>Be at least 12 characters</li>
                <li data-validator="uppercase"><img src="${url.resourcesPath}/img/correct9.png"></img>Have at least 1 uppercase character</li>
                <li data-validator="lowercase"><img src="${url.resourcesPath}/img/correct9.png"></img>Have at least 1 lowercase character</li>
                <li data-validator="numerical"><img src="${url.resourcesPath}/img/correct9.png"></img>Have at least 1 numerical character</li>
                <li data-validator="special"><img src="${url.resourcesPath}/img/correct9.png"></img>Have at least 1 special character</li>
                <li data-validator="username"><img src="${url.resourcesPath}/img/correct9.png"></img>Not be the same as your username</li>
              </ul>
            </div>
          </div>
        </div>

        <#if passwordRequired>
          <label for="password">${msg("password")}</label>
          <input type="password" id="password" name="password" />

          <label for="password-confirm">${msg("passwordConfirm")}</label>
          <span class="usa-input-error-message" id="password-confirm-error-message" role="alert">Passwords do not match</span>
          <input type="password" id="password-confirm" name="password-confirm" />
        </#if>

        <#if recaptchaRequired??>
          <div class="g-recaptcha" data-size="compact" data-sitekey="${recaptchaSiteKey}"></div>
        </#if>

        <input name="register" id="kc-register" type="submit" value="${msg("doRegister")}"/>
      </fieldset>

      <p class="usa-text-small">Having trouble? Please contact <a href="mailto:${properties.supportEmailTo!}?subject=${properties.supportEmailSubject!}">${properties.supportEmailTo!}</a></p>
    </form>
  </#if>
</@layout.registrationLayout>

<script>
var institutionSearchUri = "${properties.institutionSearchUri!}/institutions";
var emailExp = new RegExp("[a-zA-Z0-9!#$%&'*+/=?^_`{|}~.-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-]+");

function emailToDomain(email) {
  return email.split("@", 2)[1];
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

function createHTML(institutions) {
  var html = '<ul class="usa-unstyled-list">';
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
  html = html + '</ul></fieldset>';

  return html;
}

function buildList(institutions) {
  var html = createHTML(institutions);
  $('#institutions').html(html);

  addInstitutionsToInput();
}

function getInstitutions(domain) {
  $.ajax({
    url: institutionSearchUri,
    statusCode: {
      404: function() {
        $('#institutions').html(
          '<span class="hmda-error-message">' +
          'Sorry, we couldn\'t find that email domain. Please contact ' +
          '<a href="mailto:${properties.supportEmailTo!}?subject=${properties.supportEmailSubject!}">${properties.supportEmailTo!}</a> ' +
          'for help getting registered.</span>'
        );
      }
    },
    data: { domain: domain },
    beforeSend: function() {
      $('#institutions').html(
        '<div class="LoadingIconWrapper">' +
        '<img src="${url.resourcesPath}/img/LoadingIcon.png" class="LoadingIcon" alt="Loading"></img>' +
        '</div>');
    }
  })
  .done(function(data, status, xhr) {
    buildList(data.institutions);
  })
  .fail(function(request, status, error) {
    $('#institutions').html('<span class="hmda-error-message">Sorry, something went wrong. Please contact <a href="mailto:${properties.supportEmailTo!}?subject=${properties.supportEmailSubject!}">${properties.supportEmailTo!}</a> for help getting registered <strong>or</strong> try again in a few minutes.</span>');
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
      $('#institutions').html('<span class="hmda-error-message">${msg("hmdaEnterEmailAddress", (properties.supportEmailTo!''))}</span>');
    } else {
      // e.keyCode will be 'undefined' on tab key
      // don't make the API call on tab keyup
      var domain = emailToDomain(email.val().trim())
      if((emailExp.test(email.val()) && e.keyCode) || e.type === 'blur' && domain !== '') {
        debounceRequest(domain)
      }
    }
  });

  if(email.val() !== '' && email.val() !== null) {
    getInstitutions(emailToDomain(email.val()));
  }

  // remove whitespace from email to prevent 'invalid email'
  email.on('blur', function(e) {
    email.val($.trim(email.val()))
  })

  $('#institutions').on('click', '.institutionsCheck', addInstitutionsToInput);

  password.on('keyup', function(e) {
    validationList.each(function(i, el) {
      if(checkFunctions[i](password.val(), email.val())) {
        el.className = 'complete'
      }else{
        el.className = ''
      }
    })
  })

  // compare passwords
  // only turn the message off on keyup
  // blur will display it
  passwordConfirm.on('keyup', function(e) {
    if(passwordConfirm.val() === password.val()) {
      $('#password-confirm-error-message').css('display', 'none');
      $('#password-confirm-error-message').prev().css('font-weight', 'normal');
    }
  })

  passwordConfirm.on('blur', function(e) {
    if(passwordConfirm.val() === password.val()) {
      $('#password-confirm-error-message').css('display', 'none');
      $('#password-confirm-error-message').prev().css('font-weight', 'normal');
    } else {
      $('#password-confirm-error-message').css('display', 'block');
      $('#password-confirm-error-message').prev().css('font-weight', 'bold');
    }
  })
});
</script>
