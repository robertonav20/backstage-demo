/*
 * Copyright 2023 The Backstage Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { Strategy as GiteaStrategy } from 'passport-gitea';
import {
    createOAuthAuthenticator,
    PassportOAuthAuthenticatorHelper,
    PassportOAuthDoneCallback,
    PassportProfile,
} from '@backstage/plugin-auth-node';

/** @public */
export const giteaAuthenticator = createOAuthAuthenticator({
    defaultProfileTransform:
        PassportOAuthAuthenticatorHelper.defaultProfileTransform,
    scopes: {
        required: ['read:user'],
    },
    initialize({ callbackUrl, config }) {
        const clientId = config.getString('clientId');
        const clientSecret = config.getString('clientSecret');
        const baseUrl =
            config.getOptionalString('audience') || 'https://gitea.com';

        return PassportOAuthAuthenticatorHelper.from(
            new GiteaStrategy(
                {
                    clientID: clientId,
                    clientSecret: clientSecret,
                    callbackURL: callbackUrl,
                    baseURL: baseUrl,
                    authorizationURL: `${baseUrl}/login/oauth/authorize`,
                    tokenURL: `${baseUrl}/login/oauth/access_token`,
                    profileURL: `${baseUrl}/login/oauth/userinfo`,
                },
                (
                    accessToken: string,
                    refreshToken: string,
                    params: any,
                    fullProfile: PassportProfile,
                    done: PassportOAuthDoneCallback,
                ) => {
                    done(
                        undefined,
                        { fullProfile, params, accessToken },
                        { refreshToken },
                    );
                },
            ),
        );
    },

    async start(input, helper) {
        return helper.start(input, {
            accessType: 'offline',
            prompt: 'consent',
        });
    },

    async authenticate(input, helper) {
        return helper.authenticate(input);
    },

    async refresh(input, helper) {
        return helper.refresh(input);
    },
});
