package gov.cfpb.keycloak.authenticator.hmda;

import org.jboss.logging.Logger;

import javax.net.ssl.*;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.MediaType;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.HashSet;
import java.util.Set;


public class InstitutionSearchHmdaApiImpl implements InstitutionService {

    private static final Logger logger = Logger.getLogger(InstitutionSearchHmdaApiImpl.class);

    private WebTarget apiClient;

    public InstitutionSearchHmdaApiImpl(String apiUri, Boolean validateSsl) {
        this.apiClient = buildClient(apiUri, validateSsl);
    }

    private WebTarget buildClient(String apiUri, Boolean validateSsl) {
        ClientBuilder apiClientBuilder = ClientBuilder.newBuilder();

        // Special handling for dealing with untrusted HTTPS calls
        if(!validateSsl) {
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
            } catch (NoSuchAlgorithmException |KeyManagementException ex) {
                throw new RuntimeException(ex);
            }

            logger.warn("SSL validation is disabled.  This should not be enabled in a production environemnt.");
        }

        apiClient = apiClientBuilder.build()
                .register(InstitutionSearchResultsReader.class)
                .target(apiUri)
                .path("institutions");

        return apiClient;
    }

    @Override
    public Set<Institution> findInstitutionsByDomain(String domain) {
        WebTarget target = apiClient.queryParam("domain", domain);
        InstitutionSearchResults results = target.request(MediaType.APPLICATION_JSON_TYPE).get(InstitutionSearchResults.class);

        return new HashSet<>(results.getResults());
    }

}
