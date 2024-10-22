import { createTemplateAction } from '@backstage/plugin-scaffolder-node';
import Jenkins from 'jenkins';

export function destroyJob(jenkins: Jenkins) {
  return createTemplateAction<{
    jobName: string;
  }>({
    id: 'jenkins:job:destroy',
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
        `Destroying jenkins job ${ctx.input.jobName}`,
      );

      try {
        await jenkins.job.destroy(ctx.input.jobName);
        ctx.logger.info('Job destroyed successfully!');
      } catch (err) {
        ctx.logger.error('Error destroying job please check', err);
        throw err;
      }
    },
  });
}
