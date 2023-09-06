import '../../bootstrap';
import {BackApplication} from '../../application';
import {givenHttpServerConfig, Client} from '@loopback/testlab';
import config from '../../../config';
import supertest from 'supertest';
import {RegionDataSource} from '../../datasources';
// import dbConfig from '../../datasources/esv7.datasource.config';

export async function setupApplication(): Promise<AppWithClient> {
  const id = `${Math.round(Math.random() * 10000) + 10000}`;
  const restConfig = givenHttpServerConfig({
    // Customize the server configuration here.
    // host: process.env.API_HOST,
    // port: +process.env.API_PORT,
    port: +id,
  });

  const options = {...config, rest: restConfig};

  // console.log('--------------------- test setupApplication - options:');
  // console.dir(options, {depth: 8});

  const app = new BackApplication(options);

  await app.boot();

  // Datasources here
  app.bind('datasources.region').to(testDb);

  await app.start();

  const client = supertest(`http://127.0.0.1:${id}`);

  return {app, client};
}

export interface AppWithClient {
  app: BackApplication;
  client: Client;
}

export const testDb = new RegionDataSource();

export async function clearDb() {
  await testDb.deleteAllDocuments();
}
