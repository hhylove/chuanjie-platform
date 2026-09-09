package com.chuanjie.platform;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/** 创界新后台启动入口（模块化单体）。 */
@SpringBootApplication
public class PlatformServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(PlatformServerApplication.class, args);
    }
}
