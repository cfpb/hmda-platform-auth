<#import "template.ftl" as layout>
<@layout.registrationLayout; section>
    <#if section = "title">
        ${msg("registerWithTitle",(realm.displayName!''))}
    <#elseif section = "header">
        ${msg("registerWithTitleHtml",(realm.displayNameHtml!''))}
    <#elseif section = "form">
        <form id="kc-register-form" class="${properties.kcFormClass!}" action="${url.registrationAction}" method="post">
          <input type="text" readonly value="this is not a login form" style="display: none;">
          <input type="password" readonly value="this is not a login form" style="display: none;">

          <#if !realm.registrationEmailAsUsername>
            <div class="${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('username',properties.kcFormGroupErrorClass!)}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="username" class="${properties.kcLabelClass!}">${msg("username")}</label>
                </div>
                <div class="${properties.kcInputWrapperClass!}">
                    <input type="text" id="username" class="${properties.kcInputClass!}" name="username" value="${(register.formData.username!'')?html}" />
                </div>
            </div>
          </#if>
            <div class="${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('firstName',properties.kcFormGroupErrorClass!)}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="firstName" class="${properties.kcLabelClass!}">${msg("firstName")}</label>
                </div>
                <div class="${properties.kcInputWrapperClass!}">
                    <input type="text" id="firstName" class="${properties.kcInputClass!}" name="firstName" value="${(register.formData.firstName!'')?html}" />
                </div>
            </div>

            <div class="${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('lastName',properties.kcFormGroupErrorClass!)}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="lastName" class="${properties.kcLabelClass!}">${msg("lastName")}</label>
                </div>
                <div class="${properties.kcInputWrapperClass!}">
                    <input type="text" id="lastName" class="${properties.kcInputClass!}" name="lastName" value="${(register.formData.lastName!'')?html}" />
                </div>
            </div>

            <div class="${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('email',properties.kcFormGroupErrorClass!)}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="email" class="${properties.kcLabelClass!}">${msg("email")}</label>
                </div>
                <div class="${properties.kcInputWrapperClass!}">
                    <input type="text" id="email" class="${properties.kcInputClass!}" name="email" value="${(register.formData.email!'')?html}" />
                </div>
            </div>

            <div class="${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('institutions',properties.kcFormGroupErrorClass!)}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="user.attributes.institutions" class="${properties.kcLabelClass!}">Institutions</label>
                </div>
                <div class="${properties.kcInputWrapperClass!}">
                    <input id="user.attributes.institutions" name="user.attributes.institutions"/>
                </div>
            </div>

            <#if passwordRequired>
            <div class="${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('password',properties.kcFormGroupErrorClass!)}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="password" class="${properties.kcLabelClass!}">${msg("password")}</label>
                </div>
                <div class="${properties.kcInputWrapperClass!}">
                    <input type="password" id="password" class="${properties.kcInputClass!}" name="password" />
                </div>
            </div>

            <div class="${properties.kcFormGroupClass!} ${messagesPerField.printIfExists('password-confirm',properties.kcFormGroupErrorClass!)}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="password-confirm" class="${properties.kcLabelClass!}">${msg("passwordConfirm")}</label>
                </div>
                <div class="${properties.kcInputWrapperClass!}">
                    <input type="password" id="password-confirm" class="${properties.kcInputClass!}" name="password-confirm" />
                </div>
            </div>
            </#if>

            <#if recaptchaRequired??>
            <div class="form-group">
                <div class="${properties.kcInputWrapperClass!}">
                    <div class="g-recaptcha" data-size="compact" data-sitekey="${recaptchaSiteKey}"></div>
                </div>
            </div>
            </#if>

            <div class="${properties.kcFormGroupClass!}">
                <div id="kc-form-options" class="${properties.kcFormOptionsClass!}">
                    <div class="${properties.kcFormOptionsWrapperClass!}">
                        <span><a href="${url.loginUrl}">${msg("backToLogin")}</a></span>
                    </div>
                </div>

                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                    <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("doRegister")}"/>
                </div>
            </div>
        </form>
    </#if>
    <script>

        function emailToDomain(email) {
            return email.split("@", 2)[1];
        }

        function getFormEmail() {
            return $("#email").val().trim().toLowerCase();
        }

        function isValidDomain(email, domain) {
            return emailToDomain(email) === domain;
        }

        function getStatusIcon(email, domain) {
            var statusIcon = '';
            if(isValidDomain(email, domain))
                statusIcon =  '<i style="color:#20aa3f;" class="fa fa-check-circle" aria-hidden="true"></i>';
            else
                statusIcon =  '<i style="color:#ff9e1b;" class="fa fa-warning" aria-hidden="true"></i>';

            return statusIcon;
        }

        $(document).ready(function() {
            $("#user\\.attributes\\.institutions").select2({
                placeholder: "Select Institution(s)",
                minimumInputLength: 3,
                multiple: true,
                allowClear: true,
                width: "600px",
                dropdownCssClass: "bigdrop",
                ajax: {
                    url: "https://192.168.99.100:9443/institutions",
                    data: function(term, page) {
                        // Search based on user input
                        return { search: term }

                        // Search based on "email" form field
                        //var domain = emailToDomain($("#email").val());
                        //return { domain: domain }
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
                    return  institution.name + ' (' + institution.id + ') ' + getStatusIcon(getFormEmail(), institution.domain[0]);
                },
                formatResult: function(institution) {
                    //console.log(institution)

                    return '<div class="container-fluid">' +
                           '  <div class="row">' +
                           '    <div styles="vertical-align:middle;" class="col-md-1">' +
                           '      <h1>' + getStatusIcon(getFormEmail(), institution.domain[0]) + '</h1>' +
                           '    </div>' +
                           '    <div class="col-md-11">' +
                           '      <div class="row">' +

                           '        <div class="col-md-6">' +
                           '          <div class="row">' +
                           '            <div class="col-md-12">' +
                           '              <h4>' + institution.name + '</h4>' +
                           '            </div>' +
                           '          </div>' +

                           '          <div class="row">' +
                           '            <div class="col-md-4">' +
                           '               <i class="fa fa-gavel" aria-hidden="true"></i> ' + institution.regulator +
                           '            </div>' +
                           '            <div class="col-md-8">' +
                           '               <i class="fa fa-envelope" aria-hidden="true"></i> ' + institution.domain[0] +
                           '            </div>' +
                           '          </div>' +

                           '        </div>' +

                           '        <div class="col-md-6">' +
                           '          <div class="row"><strong>Respondent ID:</strong> ' + institution.id + '</div>' +
                           '          <div class="row"><strong>EIN:</strong> 12-3456789</div>' +
                           '          <div class="row"><strong>FDIC Charter:</strong> 999999</div>' +
                           '          </div>' +
                           '        </div>' +

                           '      </div>' +
                           '    </div>' +
                           '  </div>' +
                           '</div>' 
                }
            });
        });
    </script>
</@layout.registrationLayout>
