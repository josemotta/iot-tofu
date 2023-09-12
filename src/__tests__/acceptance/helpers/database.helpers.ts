import {CategoryRepository} from '../../../repositories';
import {testdb} from './test-datasource';

export async function givenEmptyDatabase() {
  await new CategoryRepository(testdb).deleteAll();
}
