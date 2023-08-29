import './bootstrap';
import {RestServer} from '@loopback/rest';
import {BackApplication} from './application';
import {ApplicationConfig} from '@loopback/core';
import config from '../config';
require('dotenv').config();

export * from './application';

export async function main(options: ApplicationConfig = {}) {
  console.log('--------------------- starting main');
  console.dir(options, {depth: 8});

  const app = new BackApplication(options);
  await app.boot();
  await app.start();

  const restServer = app.getSync<RestServer>('servers.RestServer');
  const url = restServer.url;
  console.log(`Server is running at ${url}`);
  console.log(`Try ${url}/ping`);

  return app;
}

if (require.main === module) {
  // Run the application
  main(config).catch(err => {
    console.error('Cannot start the application.', err);
    process.exit(1);
  });
}
