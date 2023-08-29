import {inject, lifeCycleObserver, LifeCycleObserver} from '@loopback/core';
import {juggler} from '@loopback/repository';

const config = {
  name: 'region',
  connector: 'memory',
  localStorage: '',
  file: '.env.region.db',
};

// Observe application's life cycle to disconnect the datasource when
// application is stopped. This allows the application to be shut down
// gracefully. The `stop()` method is inherited from `juggler.DataSource`.
// Learn more at https://loopback.io/doc/en/lb4/Life-cycle.html
@lifeCycleObserver('datasource')
export class RegionDataSource
  extends juggler.DataSource
  implements LifeCycleObserver
{
  static dataSourceName = 'region';
  static readonly defaultConfig = config;

  constructor(
    @inject('datasources.config.region', {optional: true})
    dsConfig: object = config,
  ) {
    super(dsConfig);
  }
}
