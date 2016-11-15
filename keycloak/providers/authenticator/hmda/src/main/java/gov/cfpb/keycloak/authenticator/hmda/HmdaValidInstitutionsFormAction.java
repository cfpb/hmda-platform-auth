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

import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.MultivaluedMap;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;


public class HmdaValidInstitutionsFormAction implements FormAction, FormActionFactory, ConfiguredProvider {

    public static final String PROVIDER_ID = "registration-institution-action";
    public static final String FIELD_INSTITUTIONS = "user.attributes.institutions";
    private static final Logger logger = Logger.getLogger(HmdaValidInstitutionsFormAction.class);

    // FIXME: Replace hard-coded URI with envvar
    private WebTarget apiClient = ClientBuilder.newClient().register(
            InstitutionSearchResultsReader.class
    ).target("http://institution_search:5000").path("institutions");

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
            // FIXME: Make these errors consistent with Keycloak's own errors
            errors.add(new FormMessage(FIELD_INSTITUTIONS, "Institution(s) not set"));
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
                errors.add(new FormMessage(RegistrationPage.FIELD_EMAIL, "Email domain '" + domain + "' not in CFPB whitelist"));
                context.validationError(formData, errors);
                context.error(Errors.INVALID_REGISTRATION);
                return;
            }

            for (String instId : instIds) {

                Institution inst = getInstitution(instId);
                ;

                if (inst == null) {
                    errors.add(new FormMessage(FIELD_INSTITUTIONS, "No institution found with ID " + instId));
                }

                if (!domainInsts.contains(inst)) {
                    errors.add(new FormMessage(
                            FIELD_INSTITUTIONS,
                            "Institution \"" + inst.getName() + "\" not associated with email domain \"" + domain + "\""));
                }
            }

            if (!errors.isEmpty()) {
                context.validationError(formData, errors);
                context.error(Errors.INVALID_REGISTRATION);
                return;
            }

            context.success();
        } catch (Exception e) {
            String message = "Error occurred while validating institution(s) against \"" + domain + "\" domain";
            logger.error(message, e);
            errors.add(new FormMessage(FIELD_INSTITUTIONS, message));
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
        // FIXME: We could check to make sure it is the "hmda" realm?
        return true;
    }

    @Override
    public void setRequiredActions(KeycloakSession session, RealmModel realm, UserModel user) {
        // FIXME: Anything we should do with this?
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
        // FIXME: What does this do?
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


    // ConfiguredProvider methods

}
