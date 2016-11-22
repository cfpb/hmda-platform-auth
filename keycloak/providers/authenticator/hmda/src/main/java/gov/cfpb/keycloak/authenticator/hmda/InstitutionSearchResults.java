package gov.cfpb.keycloak.authenticator.hmda;

import java.util.List;


public class InstitutionSearchResults {

    private List<Institution> results;

    public InstitutionSearchResults() {
    }

    public List<Institution> getResults() {
        return results;
    }

    public void setResults(List<Institution> results) {
        this.results = results;
    }

    @Override
    public String toString() {
        return "InstitutionSearchResults{" +
                "results=" + results +
                '}';
    }
}
