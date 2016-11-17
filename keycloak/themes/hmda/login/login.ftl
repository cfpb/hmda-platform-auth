<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=social.displayInfo; section>
    <#if section = "title">
        ${msg("loginTitle",(realm.displayName!''))}
    <#elseif section = "header">
        ${msg("loginTitleHtml",(realm.displayNameHtml!''))}
    <#elseif section = "form">
        <#if realm.password>
            <form id="kc-form-login" class="usa-form" action="${url.loginAction}" method="post">
                <fieldset>
                    <legend class="usa-drop_text">Sign in</legend>
                    <span>or <a href="${url.registrationUrl}">create an account</a></span>

                    <label for="username"><#if !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}<#else>${msg("email")}</#if></label>
                    <#if usernameEditDisabled??>
                        <input id="username" name="username" type="text" autocapitalize="off" autocorrect="off" value="${(login.username!'')?html}" disabled>
                    <#else>
                        <input id="username" name="username" value="${(login.username!'')?html}" type="text" autofocus />
                    </#if>

                    <label for="password">${msg("password")}</label>
                    <input id="password" name="password" type="password" autocomplete="off" />

                    <input name="login" id="kc-login" type="submit" value="${msg("doLogIn")}"/>

                    <#if realm.resetPasswordAllowed>
                        <p><a href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a></p>
                    </#if>
                </fieldset>
            </form>
        </#if>
    </#if>
</@layout.registrationLayout>
