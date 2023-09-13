import {Client} from '@loopback/testlab';
import {BackApplication} from '../../../index';
import {setupApplication, errorToMessage} from '../helpers/test-helper';
import {Category} from '../../../models';
import {ListCategoryFixture} from './fixtures';
import {CategoryRepository} from 'repositories';
import {givenEmptyDatabase} from '../helpers/database.helper';

describe('CategoriesController Validation (e2e)', () => {
  let app: BackApplication;
  let client: Client;
  let category: Category;
  let categoryList: Category[];
  let categoryRepo: CategoryRepository;

  beforeAll(async () => {
    ({app, client} = await setupApplication());
    categoryList = [];
    categoryRepo = app.getSync('repositories.CategoryRepository');

    // start with an empty DB
    await givenEmptyDatabase();

    // a category
    category = Category.fake()
      .aCategory()
      .withName('Movie')
      .withCreated(new Date())
      .build();
  });

  afterAll(async () => {
    await app.stop();
  });

  describe('should have response 422 to EntityValidationError', () => {
    const validationError =
      ListCategoryFixture.arrangeForEntityValidationError();
    const arrange = Object.keys(validationError).map(key => ({
      label: key,
      value: validationError[key],
    }));

    test.each(arrange)('when body is $label', async ({value}) => {
      const res = await client
        .post('/categories')
        .send(value.send_data)
        .expect(422);
      expect(res.body.error.statusCode).toBe(value.expected.error.statusCode);
      expect(res.body.error.message).toBe(value.expected.error.message);
    });
  });
});
