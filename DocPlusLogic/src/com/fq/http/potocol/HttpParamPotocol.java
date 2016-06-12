package com.fq.http.potocol;

import java.io.File;
import java.io.InputStream;

public interface HttpParamPotocol {

    public void put(String key, String value);

    public void put(String key, File file) ;

    public void put(String key, File file, String contentType);

    public void put(String key, InputStream stream);

    public void put(String key, InputStream stream, String name);
    
    public void put(String key, InputStream stream, String name, String contentType) ;

    public void put(String key, InputStream stream, String name, String contentType, boolean autoClose) ;
    
    public void put(String key, Object value);

    public void put(String key, int value);

    public void put(String key, long value) ;
	
}
