import {post, requestBody, response} from '@loopback/rest';
import {exec} from 'child_process';
import * as path from 'path';
import {promisify} from 'util';

const execAsync = promisify(exec);

const RPI_DIR = path.resolve(__dirname, '../../rpi');

export class RegionController {
  @post('/regions/setup')
  @response(200, {
    description: 'Install and setup pxetools on the boot server',
    content: {
      'application/json': {
        schema: {
          type: 'object',
          properties: {
            install: {type: 'string'},
            setup: {type: 'string'},
          },
        },
      },
    },
  })
  async setup(): Promise<object> {
    const installScript = path.join(RPI_DIR, 'pxetools-install.sh');
    const setupScript = path.join(RPI_DIR, 'pxetools-setup.sh');

    const {stdout: installOut, stderr: installErr} = await execAsync(
      `bash ${installScript}`,
    );
    const {stdout: setupOut, stderr: setupErr} = await execAsync(
      `bash ${setupScript}`,
    );

    return {
      install: installOut || installErr,
      setup: setupOut || setupErr,
    };
  }

  @post('/regions/rpi')
  @response(200, {
    description: 'Add a RPi to the region by serial number',
    content: {
      'application/json': {
        schema: {
          type: 'object',
          properties: {
            output: {type: 'string'},
          },
        },
      },
    },
  })
  async addRpi(
    @requestBody({
      content: {
        'application/json': {
          schema: {
            type: 'object',
            required: ['serial'],
            properties: {
              serial: {type: 'string', example: '9f55bbfd'},
            },
          },
        },
      },
    })
    body: {serial: string},
  ): Promise<object> {
    const {serial} = body;
    const {stdout, stderr} = await execAsync(
      `sudo pxetools --add ${serial}`,
    );
    return {output: stdout || stderr};
  }
}
