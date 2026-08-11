import {HttpErrors, post, requestBody, response} from '@loopback/rest';
import {execFile} from 'child_process';
import * as path from 'path';
import {promisify} from 'util';

const execFileAsync = promisify(execFile);

const RPI_DIR = path.resolve(__dirname, '../../rpi');

// Serial numbers are 8-character hex strings, e.g. "9f55bbfd" (see README).
const SERIAL_PATTERN = /^[0-9a-fA-F]{8}$/;

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

    const {stdout: installOut, stderr: installErr} = await execFileAsync(
      'bash',
      [installScript],
    );
    const {stdout: setupOut, stderr: setupErr} = await execFileAsync(
      'bash',
      [setupScript],
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
    if (!SERIAL_PATTERN.test(serial)) {
      throw new HttpErrors.BadRequest(
        'serial must be an 8-character hex string',
      );
    }
    const {stdout, stderr} = await execFileAsync('sudo', [
      'pxetools',
      '--add',
      serial,
    ]);
    return {output: stdout || stderr};
  }
}
