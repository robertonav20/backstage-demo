import { createTemplateAction } from '@backstage/plugin-scaffolder-node';
import Jenkins from 'jenkins';

export function copyJob(jenkins: Jenkins) {
  return createTemplateAction<{
    sourceJobName: string;
    targetJobName: string;
  }>({
    id: 'jenkins:job:copy',
    description: 'Creating a job jenkins given an existing job',
    schema: {
      input: {
        type: 'object',
        required: ['sourceJobName', 'targetJobName'],
        properties: {
          sourceJobName: {
            title: 'Jenkins job name',
            description: 'Name of jenkins item',
            type: 'string',
          },
          targetJobName: {
            title: 'Jenkins job name',
            description: 'Name of jenkins item',
            type: 'string',
          }
        },
      },
    },
    async handler(ctx) {
      ctx.logger.info(
        `Copying jenkins job ${ctx.input.sourceJobName} to ${ctx.input.targetJobName} to `,
      );

      try {
        await jenkins.job.copy(ctx.input.targetJobName, ctx.input.sourceJobName);
        ctx.logger.info('Job copied successfully!');
      } catch (err) {
        ctx.logger.error('Error copying job please check', err);
        throw err;
      }
    },
  });
}
