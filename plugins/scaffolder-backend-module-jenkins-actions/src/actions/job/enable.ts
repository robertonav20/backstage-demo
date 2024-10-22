import { createTemplateAction } from '@backstage/plugin-scaffolder-node';
import Jenkins from 'jenkins';

export function enableJob(jenkins: Jenkins) {
  return createTemplateAction<{
    jobName: string;
  }>({
    id: 'jenkins:job:enable',
    description: 'Destroy an existing job jenkins given a name',
    schema: {
      input: {
        type: 'object',
        required: ['jobName'],
        properties: {
          jobName: {
            title: 'Jenkins job name',
            description: 'Name of jenkins item',
            type: 'string',
          }
        },
      },
    },
    async handler(ctx) {
      ctx.logger.info(
        `Enabling jenkins job ${ctx.input.jobName}`,
      );

      try {
        await jenkins.job.enable(ctx.input.jobName);
        ctx.logger.info('Job enabled successfully!');
      } catch (err) {
        ctx.logger.error('Error enabling job please check', err);
        throw err;
      }
    },
  });
}
