import {Client} from '@loopback/testlab';
import {BackApplication} from '../..';
import {clearDb, setupApplication} from './test-helper';

describe('CategoryController', () => {
  let app: BackApplication;
  let client: Client;

  beforeAll(async () => {
    ({app, client} = await setupApplication());
  });

  // beforeEach(clearDb);

  afterAll(async () => {
    await app.stop();
  });

  it('invokes GET /categories', async () => {
    const res = await client.get('/categories').expect(200);
  });
});
