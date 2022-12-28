package de.sebastianthiele.redirect.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.validation.annotation.Validated;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

/**
 * This class are used to read values from configuration file 'application.yml'
 */
@Configuration
@ConfigurationProperties(prefix = "redirect-server")
@Validated
@Getter
@Setter
public class RedirectServerApplicationConfig {
    
    @NotNull
    private String httpHeaderUserAgent;
}
