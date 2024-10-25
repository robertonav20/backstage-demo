import { createTemplateAction } from '@backstage/plugin-scaffolder-node';
import Jenkins from 'jenkins';

export function buildJob(jenkins: Jenkins) {
  return createTemplateAction<{
    jobName: string;
    jobParameters: any;
  }>({
    id: 'jenkins:job:build',
    description: 'Run an existing job jenkins given a name',
    schema: {
      input: {
        type: 'object',
        required: ['jobName'],
        properties: {
          jobName: {
            title: 'Jenkins job name',
            description: 'Name of jenkins item',
            type: 'string',
          },
          jobParameters: {
            title: 'Jenkins job parameters',
            description: 'Parameters passed to job jenkins',
            type: 'any'
          }
        },
      },
    },
    async handler(ctx) {
      ctx.logger.info(
        `Starting jenkins job ${ctx.input.jobName}`,
      );

      try {
        await jenkins.job.build(ctx.input.jobName, ctx.input.jobParameters);
        ctx.logger.info('Job started successfully!');
      } catch (err) {
        ctx.logger.error('Error creating job please check', err);
        throw err;
      }
    },
  });
}
