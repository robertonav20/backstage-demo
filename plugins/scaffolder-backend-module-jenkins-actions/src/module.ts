import { createBackendModule, coreServices } from '@backstage/backend-plugin-api';
import { scaffolderActionsExtensionPoint } from '@backstage/plugin-scaffolder-node/alpha';
import { createJob } from "./actions/job/create";

import Jenkins from "jenkins";

/**
 * A backend module that registers the action into the scaffolder
 */
export const scaffolderBackendModuleJenkinsActions = createBackendModule({
  pluginId: 'scaffolder',
  moduleId: 'scaffolder-backend-module-jenkins-actions',
  register({ registerInit }) {
    registerInit({
      deps: {
        scaffolderActions: scaffolderActionsExtensionPoint,
        config: coreServices.rootConfig
      },
      async init({ config, scaffolderActions }) {
        const jenkinsConfig = config.getConfig('jenkins');

        if (jenkinsConfig === null || !jenkinsConfig.has('hostname') || !jenkinsConfig.has('port')
          || !jenkinsConfig.has('username') || !jenkinsConfig.has('apiKey')) {
          throw new Error("Jenkins configuration is invalid please check");
        }

        const hostname = jenkinsConfig.getString('hostname')
        const port = jenkinsConfig.getString('port')
        const username = jenkinsConfig.getString('username')
        const apiKey = jenkinsConfig.getString('apiKey')

        const jenkinsClient = new Jenkins({
          baseUrl: `http://${username}:${apiKey}@${hostname}:${port}`,
        });

        console.log("Jenkins actions module started successfully")
        scaffolderActions.addActions(createJob(jenkinsClient));
      }
    });
  },
})
