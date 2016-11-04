package gov.cfpb.keycloak.authenticator.hmda;

import java.util.List;
import java.util.Objects;

/**
 * Created by keelerh on 10/21/16.
 */
public class Institution {

    private String id;
    private String fdic_charter;
    private String rssd_id;
    private String name;
    private List<String> domain;

    public Institution() {
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getFdic_charter() {
        return fdic_charter;
    }

    public void setFdic_charter(String fdic_charter) {
        this.fdic_charter = fdic_charter;
    }

    public String getRssd_id() {
        return rssd_id;
    }

    public void setRssd_id(String rssd_id) {
        this.rssd_id = rssd_id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<String> getDomain() {
        return domain;
    }

    public void setDomains(List<String> domain) {
        this.domain = domain;
    }

    @Override
    public String toString() {
        return "Institution{" +
                "id='" + id + '\'' +
                ", fdic_charter='" + fdic_charter + '\'' +
                ", rssd_id='" + rssd_id + '\'' +
                ", name='" + name + '\'' +
                ", domain=" + domain +
                '}';
    }

    //FIXME: Regenerate once id details are hashed out!
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Institution that = (Institution) o;
        return Objects.equals(id, that.id) &&
                Objects.equals(fdic_charter, that.fdic_charter) &&
                Objects.equals(rssd_id, that.rssd_id) &&
                Objects.equals(name, that.name) &&
                Objects.equals(domain, that.domain);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, fdic_charter, rssd_id, name, domain);
    }
}
