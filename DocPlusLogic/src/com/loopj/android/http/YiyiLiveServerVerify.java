package com.loopj.android.http;

import java.io.IOException;
import java.io.InputStream;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;

import javax.net.ssl.SSLException;

import android.util.Log;

/**
 * 
 * 验证服务器的合法性，由于默认的https链接通过代理，万一在手机上装了合法的根证书或者非法人员申请了合法的能够
 * 被手机认证的证书，则可以截取信息。
 * 该类通过验证服务器公钥的签名和正在连接的证数的签名是否一致来确定是否有钓鱼网站或代理服务器的伪装证书存在
 * (一般ssl验证证书的CN，而伪装可以自己创建cn=www.yiyihealth.com)
 * @author johnny_peng
 *
 */
public class YiyiLiveServerVerify {
	
    private static byte[] yiyiCerSiginature;
    
    public static final void setYiyiCerSignature(InputStream is) {
    	if(yiyiCerSiginature == null){
    		try {
    			CertificateFactory cf = CertificateFactory.getInstance("X.509");
        		Certificate c = cf.generateCertificate(is);
        		is.close();
        		yiyiCerSiginature = ((X509Certificate)c).getSignature();
			} catch (Exception e) {
				Log.e("", "", e);
			}
    	}
    }
    
    public static void verifyCertificate(Certificate[] cers) throws CertificateException, IOException{
    	if (yiyiCerSiginature == null) {
			throw new IOException("Handshake failed!");
		}
    	for (int i = 0; i < cers.length; i++) {
			Certificate cer = cers[i];
			if (cer instanceof X509Certificate) {
				X509Certificate cer509 = (X509Certificate) cer;
				//TODO 不能用cer.verify()来认证，可能是由于android需要pkcs8的证书
				byte[] yiyiSignature = yiyiCerSiginature;
				byte[] netSignature = cer509.getSignature();
				if (yiyiSignature.length == netSignature.length) {
					for (int j = 0; j < netSignature.length; j++) {
						if (yiyiSignature[j] != netSignature[j]) {
							throw new SSLException("Handshake failed!");
						}
					}
				} else {
					throw new SSLException("Handshake failed!");
				}
				//上面检查发现能通过，则不再检查父证书, 父证书肯定不同
				break;
			}
		}
    }

}
