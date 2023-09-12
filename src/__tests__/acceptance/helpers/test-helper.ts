import '../../../bootstrap';
import {BackApplication} from '../../../application';
import {givenHttpServerConfig, Client} from '@loopback/testlab';
import config from '../../../../config';
import supertest from 'supertest';
import {testdb} from './testdb.datasource';

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
  app.bind('datasources.region').to(testdb);

  await app.start();

  const client = supertest(`http://127.0.0.1:${id}`);

  return {app, client};
}

export function errorToMessage(bodyError: object): string {
  return JSON.stringify(bodyError, null, 2);
}

export interface AppWithClient {
  app: BackApplication;
  client: Client;
}
