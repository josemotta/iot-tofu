import {CategoryRepository} from '../../../repositories';
import {testdb} from './testdb.datasource';

export async function givenEmptyDatabase() {
  await new CategoryRepository(testdb).deleteAll();
}
