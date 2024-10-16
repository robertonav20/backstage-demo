import { RootConfigService } from '@backstage/backend-plugin-api';
import Jenkins from 'jenkins';

const JENKINS_CONFIG_KEY: string = 'jenkins';
const BASE_URL_KEY: string = 'baseUrl';
const HEADERS_KEY: string = 'headers';

const HTTP_PREFIX: string = 'http';

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

    constructor(baseUrl: string, headers: Record<string, string> | null) {
        this.baseUrl = baseUrl;
        this.headers = headers;
    }

    static fromConfig(rootConfigService: RootConfigService): JenkinsConfig {
        if (!rootConfigService.has(JENKINS_CONFIG_KEY)) {
            throwError(BASE_URL_KEY, null);
        }

        const config = rootConfigService.getConfig(JENKINS_CONFIG_KEY);
        if (!config.has(BASE_URL_KEY) || !config.getString(BASE_URL_KEY).startsWith(HTTP_PREFIX)) {
            throwError(BASE_URL_KEY, config.getString(BASE_URL_KEY));
        }

        const baseUrl = config.getString(BASE_URL_KEY);

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

        return new JenkinsConfig(baseUrl, headers);
    }
}

export function buildJenkinsClient(config: JenkinsConfig) {
    return new Jenkins({
        baseUrl: config.baseUrl,
        headers: config.headers
    });
}

function throwError(field: string, value: any) {
    throw new Error(`Jenkins configuration of ${field} is invalid, with value ${value}, it must respect structure ${JSON.stringify(jenkinsConfigStructure, null, 2)} please check`);
}