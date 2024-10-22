import { createTemplateAction } from '@backstage/plugin-scaffolder-node';
import Jenkins from 'jenkins';
import { buildCreateJobXml, buildCreatePipelineXml } from './template';

export function createJob(jenkins: Jenkins) {
  return createTemplateAction<{
    jobName: string;
    jobType: string;
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
            description: 'Name of jenkins item',
            type: 'string',
          },
          jobType: {
            title: 'Jenkins job type',
            description: 'Type of jenkins item',
            type: 'string',
            pattern: '(job|pipeline)',
          },
          gitlabCredentials: {
            title: 'Gitlab credentials Id',
            type: 'string',
          },
          repoUrl: {
            title: 'Gitlab repo',
            description: 'Gitlab repo bind to jenkins item',
            type: 'string',
          },
          branch: {
            title: 'Gitlab branch regex',
            type: 'string',
          }
        },
      },
    },
    async handler(ctx) {
      ctx.logger.info(
        `Creating jenkins job ${ctx.input.jobName} with type ${ctx.input.jobType} for repo ${ctx.input.repoUrl}`,
      );

      const branch = ctx.input.branch !== null
        && ctx.input.branch !== undefined
        && ctx.input.branch !== '' ? ctx.input.branch : '*/main';
      const gitlabCredentials = ctx.input.gitlabCredentials !== null
        && ctx.input.gitlabCredentials !== undefined
        && ctx.input.gitlabCredentials !== '' ? ctx.input.gitlabCredentials : 'backstage';

      try {
        let jobXml = '';
        if ( ctx.input.jobType === "job") {
          jobXml = buildCreateJobXml(ctx.input.repoUrl, branch, gitlabCredentials);
        } else {
          jobXml = buildCreatePipelineXml(ctx.input.repoUrl, branch, gitlabCredentials);
        }

        ctx.logger.debug("Trying to create job jenkins with this xml {}", jobXml);

        await jenkins.job.create(ctx.input.jobName, jobXml);
        ctx.logger.info('Job created successfully!');
      } catch (err) {
        ctx.logger.error('Error creating job please check', err);
        throw err;
      }
    },
  });
}
