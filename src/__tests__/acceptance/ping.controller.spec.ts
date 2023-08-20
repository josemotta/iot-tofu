import {Client} from '@loopback/testlab';
import {BackApplication} from '../../application';
import {setupApplication} from './test-helper';

describe('PingController', () => {
  let app: BackApplication;
  let client: Client;

  beforeAll(async () => {
    ({app, client} = await setupApplication());
  });

  afterAll(async () => {
    await app.stop();
  });

  it('invokes GET /ping', async () => {
    const res = await client.get('/ping').expect(200);

    // expect(res.body).toContain({greeting: 'Hello from Boot-Back'});
  });
});
