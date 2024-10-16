import { coreServices, createBackendModule } from '@backstage/backend-plugin-api';
import { scaffolderActionsExtensionPoint } from '@backstage/plugin-scaffolder-node/alpha';
import { createJob } from "./actions/job/create";
import { buildJenkinsClient, JenkinsConfig } from "./config";

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
        config: coreServices.rootConfig,
        logger: coreServices.logger
      },
      async init({ config, logger, scaffolderActions }) {
        scaffolderActions.addActions(createJob(buildJenkinsClient(JenkinsConfig.fromConfig(config))));
        logger.info("Jenkins actions module started successfully")
      }
    });
  },
})
