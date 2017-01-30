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
        <input type="text" id="firstName" class="${properties.kcInputClass!}" name="firstName" value="${(register.formData.firstName!'')?html}" />

        <label for="lastName">${msg("lastName")}</label>
        <input type="text" id="lastName" name="lastName" value="${(register.formData.lastName!'')?html}" />

        <label for="email">${msg("email")}</label>
        <input type="text" id="email" name="email" value="${(register.formData.email!'')?html}" />

        <label for="user.attributes.institutions">Institutions</label>
        <input id="user.attributes.institutions" name="user.attributes.institutions"/>

        <#if passwordRequired>
          <label for="password">${msg("password")}</label>
          <input type="password" id="password" name="password" />

          <label for="password-confirm">${msg("passwordConfirm")}</label>
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

function emailToDomain(email) {
  return email.split("@", 2)[1];
}

function getFormEmail() {
  return $("#email").val().trim().toLowerCase();
}

function genExternalIdsHtml(institution) {
  var externalIds = institution.externalIds;
  var externalIdsHtml = "";
  externalIds.forEach(function(externalId){
    var idName = externalId.name;
    var idValue = externalId.value;
    externalIdsHtml = externalIdsHtml + '    <p><strong>' + idName + '</strong> ' + idValue  + '</p>';
  });

  return externalIdsHtml;
}

$(document).ready(function() {
  $("#user\\.attributes\\.institutions").select2({
    placeholder: "Start typing to select institution(s)",
    //minimumInputLength: 3,
    multiple: true,
    allowClear: true,
    width: "450px",
    dropdownCssClass: "bigdrop",
    ajax: {
      url: institutionSearchUri,
      data: function(term, page) {
        // Search based on "email" form field
        var domain = emailToDomain($("#email").val());
        return { domain: domain }
      },
      results: function(data, page) {
        return {
          // Each result MUST have an `id` attribute
          results: data.results
        }
      }
    },
    escapeMarkup: function(markup) {
      return markup;
    },
    formatSelection: function(institution) {
      return  institution.name + ' (' + institution.id + ')';
    },
    formatResult: function(institution) {
      return '<div class="usa-grid-full">' +
             '  <h4>' + institution.name + '</h4>' +
             '  <div class="usa-width-one-half usa-text-small">' +
             '    <p><strong>Domain:</strong> ' + institution.domains +
             '  </div>' +
             '  <div class="usa-width-one-half usa-text-small">' +
             genExternalIdsHtml(institution) +
             '  </div>' +
             '</div>'
    }
  });
});
</script>
