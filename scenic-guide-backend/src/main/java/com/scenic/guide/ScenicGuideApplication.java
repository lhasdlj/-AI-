package com.scenic.guide;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 景区导览服务AI数字人后端启动类
 */
@SpringBootApplication
@MapperScan("com.scenic.guide.mapper")
public class ScenicGuideApplication {

    public static void main(String[] args) {
        SpringApplication.run(ScenicGuideApplication.class, args);
        System.out.println("=================================================");
        System.out.println("景区导览服务AI数字人后端应用启动成功！端口：8080");
        System.out.println("=================================================");
    }
}
