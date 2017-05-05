<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" class="${properties.kcHtmlClass!}">

<head>
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="robots" content="noindex, nofollow">

    <#if properties.meta?has_content>
        <#list properties.meta?split(' ') as meta>
            <meta name="${meta?split('==')[0]}" content="${meta?split('==')[1]}"/>
        </#list>
    </#if>
    <title><#nested "title"></title>
    <link rel="icon" href="${url.resourcesPath}/img/favicons/favicon.ico" />
    <#if properties.styles?has_content>
        <#list properties.styles?split(' ') as style>
            <link href="${url.resourcesPath}/${style}" rel="stylesheet" />
        </#list>
    </#if>
    <#if properties.scripts?has_content>
        <#list properties.scripts?split(' ') as script>
            <script src="${url.resourcesPath}/${script}" type="text/javascript"></script>
        </#list>
    </#if>
    <#if scripts??>
        <#list scripts as script>
            <script src="${script}" type="text/javascript"></script>
        </#list>
    </#if>
</head>

<body>
  <header class="usa-header usa-header-basic" role="banner">
    <div class="usa-banner">
      <header class="usa-banner-header">
        <div class="usa-grid usa-banner-inner">
          <img src="${url.resourcesPath}/img/favicons/favicon-57.png" alt="U.S. flag" />
          <p>An official website of the United States government</p>
        </div>
      </header>
    </div>
    <div class="usa-nav-container">
      <div class="usa-logo" id="logo">
        <em class="usa-logo-text"><a class="usa-nav-link" title="Home" aria-label="Home" href="${properties.homePageUri!}">HMDA Filing</a></em>
      </div>
      <nav role="navigation" class="Header usa-nav">
        <ul class="usa-nav-primary">
          <li>
            <a class="HomeLink usa-nav-link" href="${properties.homePageUri!}">Home</a>
          </li>
        </ul>
      </nav>
    </div>
  </header>
  <#if realm.internationalizationEnabled>
    <div class="usa-grid">
      <div id="kc-locale" class="${properties.kcLocaleClass!}">
        <div id="kc-locale-wrapper" class="${properties.kcLocaleWrapperClass!}">
          <div class="kc-dropdown" id="kc-locale-dropdown">
            <a href="#" id="kc-current-locale-link">${locale.current}</a>
            <ul>
              <#list locale.supported as l>
                <li class="kc-dropdown-item"><a href="${l.url}">${l.label}</a></li>
              </#list>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </#if>

  <div class="usa-grid usa-grid-small">
    <div id="kc-content">
      <div id="kc-content-wrapper">
        <#if displayMessage && message?has_content>
          <div class="usa-width-one-whole margin-bottom-1">
            <div class="usa-alert usa-alert-${message.type}">
              <div class="usa-alert-body">
                <p class="usa-alert-text">${message.summary}</p>
                <p>For help with account-related issues, please contact
                    <strong><a href="mailto:${properties.supportEmailTo!}?subject=${properties.supportEmailSubject?url('UTF-8')}">${properties.supportEmailTo}</a></strong>.
                </p>
              </div>
            </div>
          </div>
        </#if>

        <div class="usa-width-one-whole">
            <#nested "form">
        </div>

        <#if displayInfo>
          <div class="usa-width-one-whole">
            <#nested "info">
          </div>
        </#if>
      </div>
    </div>
  </div>

  <footer class="usa-footer usa-footer-slim" role="contentinfo">
    <div class="usa-grid usa-footer-return-to-top">
      <a href="#">Return to top</a>
    </div>
    <div class="usa-footer-primary-section">
      <div class="usa-grid-full">
        <nav class="usa-footer-nav usa-width-one-half">
          <ul class="usa-unstyled-list">
            <li class="usa-footer-primary-content">
              <a class="usa-footer-primary-link" href="https://www.ffiec.gov/">
                <img src="${url.resourcesPath}/img/ffiec-logo.png" width="100px"/>
              </a>
            </li>
          </ul>
        </nav>
        <div class="usa-width-one-half">
          <div class="usa-footer-primary-content usa-footer-contact_info">
            <h4>Questions?</h4>
            <a href="mailto:${properties.supportEmailTo!}?subject=${properties.supportEmailSubject?url('UTF-8')}">${properties.supportEmailTo}</a>
          </div>
        </div>
      </div>
    </div>
  </footer>
</body>
</html>
</#macro>
