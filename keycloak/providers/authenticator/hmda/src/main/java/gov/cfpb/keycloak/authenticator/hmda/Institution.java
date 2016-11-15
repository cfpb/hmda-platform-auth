package gov.cfpb.keycloak.authenticator.hmda;

import java.util.List;
import java.util.Objects;

public class Institution {

    private String id;
    private String name;
    private String regulator;
    private List<String> domain;

    public Institution() {
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getRegulator() {
        return regulator;
    }

    public void setRegulator(String regulator) {
        this.regulator = regulator;
    }

    public List<String> getDomain() {
        return domain;
    }

    public void setDomain(List<String> domain) {
        this.domain = domain;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Institution that = (Institution) o;
        return Objects.equals(id, that.id) &&
                Objects.equals(name, that.name) &&
                Objects.equals(regulator, that.regulator) &&
                Objects.equals(domain, that.domain);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, name, regulator, domain);
    }

    @Override
    public String toString() {
        return "Institution{" +
                "id='" + id + '\'' +
                ", name='" + name + '\'' +
                ", regulator='" + regulator + '\'' +
                ", domain=" + domain +
                '}';
    }
}
