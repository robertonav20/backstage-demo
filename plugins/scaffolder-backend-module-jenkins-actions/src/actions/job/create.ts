import { createTemplateAction } from '@backstage/plugin-scaffolder-node';
import Jenkins from 'jenkins';
import { buildCreateJobXml } from './template';

export function createJob(jenkins: Jenkins) {
  return createTemplateAction<{
    jobName: string;
    repoUrl: string;
    branch: string;
    gitlabCredentials: string;
  }>({
    id: 'jenkins:job:create',
    description: 'Create a job jenkins given a name and gitlab repo',
    schema: {
      input: {
        type: 'object',
        required: ['jobName', 'repoUrl'],
        properties: {
          jobName: {
            title: 'Jenkins job name',
            description: 'This is the name jenkins job',
            type: 'string',
          },
          repoUrl: {
            title: 'Gitlab repo',
            description: 'This is the name gitlab repo',
            type: 'string',
          },
          branch: {
            title: 'Gitlab branch regex',
            type: 'string',
          },
          gitlabCredentials: {
            title: 'Gitlab credentials Id',
            type: 'string',
          },
        },
      },
    },
    async handler(ctx) {
      ctx.logger.info(
        `Creating jenkins job ${ctx.input.jobName} for repr ${ctx.input.repoUrl}`,
      );

      const branch = ctx.input.branch !== null
        && ctx.input.branch !== undefined
        && ctx.input.branch !== '' ? ctx.input.branch : '*/main';
      const gitlabCredentials = ctx.input.gitlabCredentials !== null
        && ctx.input.gitlabCredentials !== undefined
        && ctx.input.gitlabCredentials !== '' ? ctx.input.gitlabCredentials : 'backstage';

      try {
        const xml = buildCreateJobXml(ctx.input.repoUrl, branch, gitlabCredentials);

        console.log("Trying to create job jenkins with this xml", xml);

        await jenkins.job.create(ctx.input.jobName, xml);
        console.log('Job created successfully!');
      } catch (err) {
        console.error('Error creating job please check');
      }
    },
  });
}
