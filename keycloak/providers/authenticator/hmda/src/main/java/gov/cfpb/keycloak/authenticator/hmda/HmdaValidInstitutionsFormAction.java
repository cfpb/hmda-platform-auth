package gov.cfpb.keycloak.authenticator.hmda;

import org.jboss.logging.Logger;
import org.keycloak.Config;
import org.keycloak.authentication.FormAction;
import org.keycloak.authentication.FormActionFactory;
import org.keycloak.authentication.FormContext;
import org.keycloak.authentication.ValidationContext;
import org.keycloak.authentication.forms.RegistrationPage;
import org.keycloak.events.Errors;
import org.keycloak.forms.login.LoginFormsProvider;
import org.keycloak.models.*;
import org.keycloak.models.utils.FormMessage;
import org.keycloak.provider.ConfiguredProvider;
import org.keycloak.provider.ProviderConfigProperty;
import org.keycloak.services.validation.Validation;

import javax.net.ssl.*;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.MultivaluedMap;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;


public class HmdaValidInstitutionsFormAction implements FormAction, FormActionFactory, ConfiguredProvider {

    public static final String PROVIDER_ID = "registration-institution-action";
    public static final String FIELD_INSTITUTIONS = "user.attributes.institutions";
    public static final String MISSING_INSTITUTION_MESSAGE = "missingInstitutionMessage";
    public static final String INVALID_INSTITUTION_MESSAGE = "invalidInstitutionMessage";
    public static final String UNKNOWN_INSTITUTION_MESSAGE = "unknownInstitutionMessage";
    public static final String UNKNOWN_EMAIL_DOMAIN_MESSAGE = "unknownEmailDomainMessage";
    public static final String INSTITUTION_ERROR_MESSAGE = "institutionErrorMessage";

    private static final WebTarget apiClient;

    private static final Logger logger = Logger.getLogger(HmdaValidInstitutionsFormAction.class);

    static {
        //FIXME: Should probably switch envvar handling to using Keycloak built-in Config features
        String validateSsl = System.getenv("INSTITUTION_SEARCH_VALIDATE_SSL");
        String apiUri = System.getenv("INSTITUTION_SEARCH_URI");

        ClientBuilder apiClientBuilder = ClientBuilder.newBuilder();

        // Special handling for dealing with untrusted HTTPS calls
        if(validateSsl.trim().toUpperCase().equals("OFF")) {
            try {
                TrustManager[] tm = new TrustManager[] {
                    new X509TrustManager() {
                        @Override public void checkClientTrusted(X509Certificate[] x509Certificates, String s) throws CertificateException {}
                        @Override public void checkServerTrusted(X509Certificate[] x509Certificates, String s) throws CertificateException {}
                        @Override public X509Certificate[] getAcceptedIssuers() { return new X509Certificate[0]; }
                    }};

                HostnameVerifier hv = new HostnameVerifier() {
                    @Override public boolean verify(String s, SSLSession sslSession) { return true; }
                };

                SSLContext sslCtx = SSLContext.getInstance("TLS");
                sslCtx.init(null, tm, new SecureRandom());

                apiClientBuilder.sslContext(sslCtx).hostnameVerifier(hv).build();
            } catch (NoSuchAlgorithmException|KeyManagementException ex) {
                throw new RuntimeException(ex);
            }

            logger.warn("SSL validation is disabled.  This should not be enabled in a production environemnt.");
        }

        apiClient = apiClientBuilder.build()
                .register(InstitutionSearchResultsReader.class)
                .target(apiUri)
                .path("institutions");
    }

    private Set<Institution> findInstitutionsByDomain(String domain) {
        WebTarget target = apiClient.queryParam("domain", domain);
        InstitutionSearchResults results = target.request(MediaType.APPLICATION_JSON_TYPE).get(InstitutionSearchResults.class);

        return new HashSet<>(results.getResults());
    }

    private Institution getInstitution(String id) {
        WebTarget target = apiClient.queryParam("id", id);
        InstitutionSearchResults results = target.request(MediaType.APPLICATION_JSON_TYPE).get(InstitutionSearchResults.class);

        // FIXME: This should use a /institutions/{id} endpoint
        List<Institution> insts = results.getResults();

        if (insts.isEmpty())
            // FIXME: Throw exception on inst_not_found?
            return null;
        else
            return insts.get(0);
    }

    @Override
    public void buildPage(FormContext context, LoginFormsProvider form) {
    }

    @Override
    public void validate(ValidationContext context) {

        logger.info("Validating Institutions...");

        String domain = null;

        MultivaluedMap<String, String> formData = context.getHttpRequest().getDecodedFormParameters();
        List<FormMessage> errors = new ArrayList<>();

        logger.info("Form Data: " + formData);

        String instFieldVal = formData.getFirst(FIELD_INSTITUTIONS);
        if (Validation.isBlank(instFieldVal)) {
            errors.add(new FormMessage(FIELD_INSTITUTIONS, MISSING_INSTITUTION_MESSAGE));
            context.validationError(formData, errors);
            context.error(Errors.INVALID_REGISTRATION);

            return;
        }

        try {
            String[] instIds = instFieldVal.split(",");
            String email = formData.getFirst(RegistrationPage.FIELD_EMAIL);
            domain = email.split("@")[1];

            logger.info("Email Domain: " + domain);


            Set<Institution> domainInsts = findInstitutionsByDomain(domain);

            if (domainInsts.isEmpty()) {
                errors.add(new FormMessage(RegistrationPage.FIELD_EMAIL, UNKNOWN_EMAIL_DOMAIN_MESSAGE, domain));
                context.validationError(formData, errors);
                context.error(Errors.INVALID_REGISTRATION);
                return;
            }

            for (String instId : instIds) {
                Institution inst = getInstitution(instId);

                if (inst == null) {
                    errors.add(new FormMessage(FIELD_INSTITUTIONS, UNKNOWN_INSTITUTION_MESSAGE, instId));
                }

                if (!domainInsts.contains(inst)) {
                    errors.add(new FormMessage(FIELD_INSTITUTIONS, INVALID_INSTITUTION_MESSAGE, inst.getName(), domain));
                }
            }

        } catch (Exception e) {
            logger.error("Error occurred while validating institution(s) against \"" + domain + "\" domain", e);
            errors.add(new FormMessage(FIELD_INSTITUTIONS, INSTITUTION_ERROR_MESSAGE, domain));
        }

        if (errors.isEmpty()) {
            context.success();
        } else {
            context.validationError(formData, errors);
            context.error(Errors.INVALID_REGISTRATION);
        }

    }

    @Override
    public void success(FormContext form) {
    }

    @Override
    public boolean requiresUser() {
        return false;
    }

    @Override
    public boolean configuredFor(KeycloakSession session, RealmModel realm, UserModel user) {
        return true;
    }

    @Override
    public void setRequiredActions(KeycloakSession session, RealmModel realm, UserModel user) {
    }

    @Override
    public FormAction create(KeycloakSession keycloakSession) {
        return this;
    }

    @Override
    public void init(Config.Scope scope) {

    }

    @Override
    public void postInit(KeycloakSessionFactory keycloakSessionFactory) {

    }

    @Override
    public void close() {
    }


    // FormActionFactor methods
    @Override
    public String getId() {
        return PROVIDER_ID;
    }

    @Override
    public String getDisplayType() {
        return "Institution Validation";
    }

    @Override
    public String getReferenceCategory() {
        return null;
    }

    @Override
    public boolean isConfigurable() {
        return false;
    }

    @Override
    public AuthenticationExecutionModel.Requirement[] getRequirementChoices() {
        AuthenticationExecutionModel.Requirement[] choices = {
                AuthenticationExecutionModel.Requirement.REQUIRED,
                AuthenticationExecutionModel.Requirement.DISABLED
        };

        return choices;
    }

    @Override
    public boolean isUserSetupAllowed() {
        return false;
    }

    @Override
    public String getHelpText() {
        return "Adds Institution verification per email domain";
    }

    @Override
    public List<ProviderConfigProperty> getConfigProperties() {
        // FIXME: Add Institution API endpoint config
        return null;
    }

}
