import { coreServices, createBackendModule } from '@backstage/backend-plugin-api';
import { scaffolderActionsExtensionPoint } from '@backstage/plugin-scaffolder-node/alpha';
import { buildJob } from './actions/job/build';
import { copyJob } from './actions/job/copy';
import { createJob } from "./actions/job/create";
import { destroyJob } from './actions/job/destroy';
import { disableJob } from './actions/job/disable';
import { enableJob } from './actions/job/enable';
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
        const jenkinsClient = buildJenkinsClient(JenkinsConfig.fromConfig(config));

        scaffolderActions.addActions(createJob(jenkinsClient));
        scaffolderActions.addActions(copyJob(jenkinsClient));
        scaffolderActions.addActions(buildJob(jenkinsClient));
        scaffolderActions.addActions(enableJob(jenkinsClient));
        scaffolderActions.addActions(disableJob(jenkinsClient));
        scaffolderActions.addActions(destroyJob(jenkinsClient));

        logger.info("Jenkins actions module started successfully")
      }
    });
  },
})
