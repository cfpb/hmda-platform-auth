/* eslint-env browser, jquery */
/* global HMDA, initRules */
!(function() {
  //Given a list of institutions, create units of html for each of them
  function buildList(institutions) {
    var html = createInstitutions(institutions)
    $('#institutions').html(html)

    addInstitutionsToInput()
  }

  //Given a list of institutions, return an html list of description lists for each
  function createInstitutions(institutions) {
    var labelContent = 'Select your institution'
    if(institutions.length > 1) {
      labelContent = 'Select all available institutions you wish to file for. You may select more than one.'
    }
    var html = '<label>' + labelContent + '</label><ul class="usa-unstyled-list">'

    for (var i = 0; i < institutions.length; i++) {
      html =
        html +
        '<li>' +
        '<input class="institutionsCheck" type="checkbox" id="' +
        institutions[i].id +
        '" name="institutions" value="' +
        institutions[i].id +
        '">' +
        '<label for="' +
        institutions[i].id +
        '">' +
        '<strong>' +
        institutions[i].name +
        '</strong>' +
        createExternalIdHTML(institutions[i].externalIds) +
        '</label></li>'
    }
    html = html + '</ul></fieldset>'

    return html
  }

  //Create description list from a list of ids
  function createExternalIdHTML(externalIds) {
    var html = ''
    if (externalIds.length > 0) {
      html = '<dl class="usa-text-small">'
      for (var i = 0; i < externalIds.length; i++) {
        html += '<dt>' + externalIds[i].externalIdType.name + ': </dt>'
        html += '<dd>' + externalIds[i].value + '</dd>'
      }
      html += '</dl>'
    }

    return html
  }

  //Get checked institutions' values and add them to a hidden input field to be submitted
  function addInstitutionsToInput() {
    var listOfInstitutions = []
    // add to the user.attributes.institutions input
    $('.institutionsCheck').each(function(index) {
      if ($(this).prop('checked')) {
        listOfInstitutions.push($(this).val())
      }
    })
    $('#user\\.attributes\\.institutions').val(listOfInstitutions.join(','))
  }

  //AJAX call to get data, calls buildList with returned institutions
  function getInstitutions(domain) {
    $.ajax({
      url: HMDA.institutionSearchUri,
      statusCode: {
        404: function() {
          $('#institutions').html(
            '<span class="hmda-error-message">' +
              "Sorry, we couldn't find that email domain. For help getting registered, please contact " +
              getEmailLink() +
              ' and provide your institution name plus one other identifier (RSSD, tax ID, NMLS ID, etc).</span>'
          )
        }
      },
      data: { domain: domain },
      beforeSend: function() {
        $('#institutions').html(
          '<div class="LoadingIconWrapper">' +
            '<img src="' +
            HMDA.resources +
            '/img/LoadingIcon.png" class="LoadingIcon" alt="Loading"></img>' +
            '</div>'
        )
      }
    })
      .done(function(data, status, xhr) {
        buildList(data.institutions)
      })
      .fail(function(request, status, error) {
        $('#institutions').html(
          '<span class="hmda-error-message">Sorry, something went wrong. Please contact ' +
            getEmailLink() +
            ' for help getting registered <strong>or</strong> try again in a few minutes.</span>'
        )
      })
  }

  //email parsing util
  function emailToDomain(email) {
    return email.split('@', 2)[1]
  }

  //build email links from values provided at build time
  function getEmailLink() {
    return (
      '<a href="mailto:' +
      HMDA.supportEmailTo +
      '?subject=' +
      HMDA.supportEmailSubject +
      '">' +
      HMDA.supportEmailTo +
      '</a>'
    )
  }

  //Make a debounced version of the getInstitutions API call, passing in the desired delay
  function makeDebouncer(delay) {
    var timeout
    return function(domain) {
      clearTimeout(timeout)
      timeout = setTimeout(function() {
        getInstitutions(domain)
      }, delay)
    }
  }

  var debounceRequest = makeDebouncer(300)

  $(document).ready(function() {
    var email = $('#email')
    var emailExp = /[a-zA-Z0-9!#$%&'*+/=?^_`{|}~.-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-]+/
    var lastEmail = null

    //Process email and make debounced request when typing in email field
    email.on('blur keyup', function(e) {
      var emailVal = email.val().trim()
      if (emailVal === lastEmail) return
      else lastEmail = emailVal

      // keycode (tab key) used to not warn when first tabbing into the email field
      if ((emailVal === '' || emailVal === null) && e.keyCode !== 9) {
        $('#institutions').html('')
      } else {
        // e.keyCode will be 'undefined' on tab key
        // don't make the API call on tab keyup
        var domain = emailToDomain(emailVal)
        if (
          (emailExp.test(emailVal) && e.keyCode) ||
          (e.type === 'blur' && domain !== '')
        ) {
          debounceRequest(domain)
        }
      }
    })

    //Save institution to input when clicked
    $('#institutions').on('click', '.institutionsCheck', addInstitutionsToInput)
    var loading = $('#submit-loader')
    var form = $('#kc-register-form')

    form.on('submit', function(e) {
      loading.css('display', 'block')
    })

    initRules()
  })
})()
