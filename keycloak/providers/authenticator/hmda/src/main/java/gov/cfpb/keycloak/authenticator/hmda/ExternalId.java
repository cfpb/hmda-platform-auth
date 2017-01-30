package gov.cfpb.keycloak.authenticator.hmda;

import java.util.Objects;

/**
 * Created by keelerh on 1/25/17.
 */
public class ExternalId {

    private String name;
    private String value;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    @Override
    public String toString() {
        return "ExternalId{" +
                "name='" + name + '\'' +
                ", value='" + value + '\'' +
                '}';
    }
}
