package gov.cfpb.keycloak.authenticator.hmda;

import java.util.Set;

/**
 * Created by keelerh on 1/26/17.
 */
public interface InstitutionService {

    public Set<Institution> findInstitutionsByDomain(String domain);

}
