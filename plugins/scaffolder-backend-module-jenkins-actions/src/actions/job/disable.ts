import { createTemplateAction } from '@backstage/plugin-scaffolder-node';
import Jenkins from 'jenkins';

export function disableJob(jenkins: Jenkins) {
  return createTemplateAction<{
    jobName: string;
  }>({
    id: 'jenkins:job:disable',
    description: 'Disable an existing job jenkins given a name',
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
        `Disabling jenkins job ${ctx.input.jobName}`,
      );

      try {
        await jenkins.job.disable(ctx.input.jobName);
        ctx.logger.info('Job disabled successfully!');
      } catch (err) {
        ctx.logger.error('Error Disabling job please check', err);
        throw err;
      }
    },
  });
}
