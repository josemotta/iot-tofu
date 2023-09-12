import {juggler} from '@loopback/repository';
import {RegionDataSource} from '../../../datasources';

const config = {
  name: 'region',
  connector: 'memory',
  localStorage: '',
  file: '.env.region.test.db',
};

export const testdb: juggler.DataSource = new RegionDataSource(config);
