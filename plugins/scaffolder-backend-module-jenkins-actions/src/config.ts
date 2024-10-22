import { RootConfigService } from '@backstage/backend-plugin-api';
import Jenkins from 'jenkins';

const JENKINS_CONFIG_KEY: string = 'jenkins';
const BASE_URL_KEY: string = 'baseUrl';
const HEADERS_KEY: string = 'headers';
const USERNAME: string = 'username';
const PASSWORD: string = 'password';
const CRUMB_ISSUER_ENABLED: string = 'crumbIssuerEnabled';

const HTTP_PREFIX: string = 'http://';
const HTTP_PROTOCOL: string = 'http://';
const HTTPS_PROTOCOL: string = 'https://';

export const jenkinsConfigStructure = {
    baseUrl: 'string',
    headers: 'Record<string, string> | null'
};

export class JenkinsConfig {
    /**
    * Must be something like http://hostname:port, https://hostname:port or https://hostname
    */
    baseUrl: string;

    // Optional Keys
    headers: Record<string, string> | null = null;
    crumbIssuerEnabled: boolean | null = null;

    constructor(baseUrl: string, headers: Record<string, string> | null, crumbIssuerEnabled: boolean | null) {
        this.baseUrl = baseUrl;
        this.headers = headers;
        this.crumbIssuerEnabled = crumbIssuerEnabled;
    }

    static fromConfig(rootConfigService: RootConfigService): JenkinsConfig {
        if (!rootConfigService.has(JENKINS_CONFIG_KEY)) {
            throwError(BASE_URL_KEY, null);
        }

        const config = rootConfigService.getConfig(JENKINS_CONFIG_KEY);
        if (!config.has(BASE_URL_KEY) || !config.getString(BASE_URL_KEY).startsWith(HTTP_PREFIX)) {
            throwError(BASE_URL_KEY, config.getString(BASE_URL_KEY));
        }

        let baseUrl = config.getString(BASE_URL_KEY);

        if (config.has(USERNAME) && config.has(PASSWORD)) {
            if (baseUrl.startsWith(HTTP_PROTOCOL)) {
                baseUrl = baseUrl.replace(HTTP_PROTOCOL, HTTP_PROTOCOL
                    .concat(config.getString(USERNAME))
                    .concat(":")
                    .concat(config.getString(PASSWORD))
                    .concat("@"))
            } else {
                baseUrl = baseUrl.replace(HTTPS_PROTOCOL, HTTPS_PROTOCOL
                    .concat(config.getString(USERNAME))
                    .concat(":")
                    .concat(config.getString(PASSWORD))
                    .concat("@"))
            }
        }

        const headers = config.getOptionalConfig(HEADERS_KEY)?.keys().reduce(
            (acc, key) => {
                const value = config.getOptionalString(`${key}`);
                if (value) {
                    acc[key] = value;
                }
                return acc;
            },
            {} as Record<string, string>
        ) || null;

        const crumbIssuerEnabled = config.getOptionalBoolean(CRUMB_ISSUER_ENABLED) || true;

        return new JenkinsConfig(baseUrl, headers, crumbIssuerEnabled);
    }
}

export function buildJenkinsClient(config: JenkinsConfig) {
    return new Jenkins({
        baseUrl: config.baseUrl,
        headers: config.headers,
        crumbIssuer: config.crumbIssuerEnabled ? config.crumbIssuerEnabled : false
    });
}

function throwError(field: string, value: any) {
    throw new Error(`Jenkins configuration of ${field} is invalid, with value ${value}, it must respect structure ${JSON.stringify(jenkinsConfigStructure, null, 2)} please check`);
}