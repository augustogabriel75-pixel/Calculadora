import com.android.apksig.ApkSigner;
import com.android.apksig.ApkVerifier;
import java.io.File;
import java.io.FileInputStream;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.cert.X509Certificate;
import java.util.Collections;

/** Uso: java -cp apksig.jar Sign.java <keystore.p12> <senha> <alias> <entrada.apk> <saida.apk> */
public class Sign {
    public static void main(String[] a) throws Exception {
        char[] pass = a[1].toCharArray();
        KeyStore ks = KeyStore.getInstance("PKCS12");
        try (FileInputStream in = new FileInputStream(a[0])) { ks.load(in, pass); }
        PrivateKey key = (PrivateKey) ks.getKey(a[2], pass);
        X509Certificate cert = (X509Certificate) ks.getCertificate(a[2]);
        ApkSigner.SignerConfig signer = new ApkSigner.SignerConfig.Builder(
                "vetclin", key, Collections.singletonList(cert)).build();
        File out = new File(a[4]);
        new ApkSigner.Builder(Collections.singletonList(signer))
                .setInputApk(new File(a[3])).setOutputApk(out)
                .setMinSdkVersion(24).setV1SigningEnabled(false).setV2SigningEnabled(true)
                .build().sign();
        ApkVerifier.Result r = new ApkVerifier.Builder(out).build().verify();
        System.out.println("assinatura válida=" + r.isVerified() + " v1=" + r.isVerifiedUsingV1Scheme()
                + " v2=" + r.isVerifiedUsingV2Scheme());
        if (!r.isVerified()) { System.out.println(r.getErrors()); System.exit(1); }
    }
}
