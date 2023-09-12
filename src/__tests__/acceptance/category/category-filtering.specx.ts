import {Client} from '@loopback/testlab';
import {BackApplication} from '../../../index';
import {setupApplication} from '../helpers/test-helper';
import {Category} from '../../../models';
import {ListCategoryFixture} from './fixtures';

describe('CategoriesController Filtering (e2e)', () => {
  let app: BackApplication;
  let client: Client;
  let category: Category;
  let categoryList: Category[];
  let cJWT: string;

  beforeAll(async () => {
    ({app, client} = await setupApplication());
    await client.get('/test-helper/cleanup-db').expect(200);
    categoryList = [];
    const res = await client
      .post('/test-helper/create-category-jwt')
      .send({
        id: '123',
        email: 'category@t.com',
      })
      .expect(200);
    [cJWT, category] = res.body;
    // delete this category, it was just to get a JWT token
    await client
      .delete('/categories/' + category.id)
      .set('Authorization', 'Bearer ' + cJWT);
    expect(res.status).toBe(200);
  });

  afterAll(async () => {
    await app.stop();
  });

  it('Create & check 5 Categories', async () => {
    categoryList = Category.fake()
      .theCategories(5)
      .withName(index => `test name ${5 - index}`)
      .build();

    let res = await client
      .post('/categories/many')
      .set('Authorization', 'Bearer ' + cJWT)
      .send(categoryList);
    expect(res.status).toBe(200);

    categoryList = res.body; // update with id

    res = await client
      .get('/categories/count')
      .set('Authorization', 'Bearer ' + cJWT);
    expect(res.status).toBe(200);
    expect(res.body.count).toBe(5);

    res = await client
      .get('/categories')
      .set('Authorization', 'Bearer ' + cJWT);
    expect(res.status).toBe(200);
    expect(res.body.length).toBe(5);
  });

  describe('Should return error with invalid filter', () => {
    const invalidRequest = ListCategoryFixture.arrangeInvalidFilter();
    const arrange = Object.keys(invalidRequest).map(key => ({
      label: key,
      value: invalidRequest[key],
    }));

    test.each(arrange)('when filter is $label', ({value}) => {
      return client
        .get('/categories?filter=' + JSON.stringify(value.filter_data))
        .set('Authorization', 'Bearer ' + cJWT)
        .expect(value.expected);
    });
  });

  it('List Categories with filter: fields, order, limit & skip', async () => {
    const filter = {
      fields: ['name', 'email'],
      order: 'name ASC',
      limit: 3,
      skip: 1,
    };

    const res = await client
      .get('/categories?filter=' + JSON.stringify(filter))
      .set('Authorization', 'Bearer ' + cJWT);
    const keys = Object.keys(res.body[0]);

    expect(res.status).toBe(200);
    expect(res.body.length).toBe(3);
    expect(keys).toStrictEqual(['name']);

    expect(res.body[0].name).toStrictEqual(categoryList[3].name);
    expect(res.body[1].name).toStrictEqual(categoryList[2].name);
    expect(res.body[2].name).toStrictEqual(categoryList[1].name);
  });

  // REMOVED: endpoints that weren’t necessary.
  // it('Update One Category in 5', async () => {
  //   const update: Category = JSON.parse(JSON.stringify(categoryList[3]));
  //   update.didToken = 'updated didToken';

  //   const res = await client
  //     .put('/categories/' + update.id)
  //     .send(update)
  //     .set('Authorization', 'Bearer ' + cJWT);
  //   expect(res.status).toBe(200);
  // });

  it('Check if update did not change other entries', async () => {
    const filter = {
      limit: 5,
      order: 'name ASC',
    };

    const res = await client
      .get('/categories?filter=' + JSON.stringify(filter))
      .set('Authorization', 'Bearer ' + cJWT);
    expect(res.status).toBe(200);
    expect(res.body.length).toBe(5);

    for (let r = 0; r < categoryList.length; r++) {
      if (r !== 3) {
        expect(categoryList[r]).toStrictEqual(res.body[4 - r]);
      } else {
        categoryList[r] = res.body[4 - r];
      }
    }
  });

  // REMOVED: endpoints that weren’t necessary.
  // it('Update One Category In 5 Partially With Where', async () => {
  //   const update = JSON.parse(JSON.stringify(categoryList[4]));

  //   const updateData = {
  //     didToken: 'another didToken',
  //   };

  //   const res = await client
  //     .patch('/categories?where=' + JSON.stringify({id: update.id}))
  //     .send(updateData)
  //     .set('Authorization', 'Bearer ' + cJWT);
  //   expect(res.status).toBe(200);
  // });

  it('Check if partial update did not change other entries', async () => {
    const filter = {
      limit: 5,
      order: 'name ASC',
    };

    const res = await client
      .get('/categories?filter=' + JSON.stringify(filter))
      .set('Authorization', 'Bearer ' + cJWT);
    expect(res.status).toBe(200);
    expect(res.body.length).toBe(5);

    for (let r = 0; r < categoryList.length; r++) {
      if (r !== 4) {
        expect(categoryList[r]).toStrictEqual(res.body[4 - r]);
      }
    }
  });
});
