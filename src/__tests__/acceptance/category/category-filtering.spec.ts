import {Client} from '@loopback/testlab';
import {BackApplication} from '../../../index';
import {setupApplication} from '../helpers/test-helper';
import {Category} from '../../../models';
import {ListCategoryFixture} from './fixtures';
import {givenEmptyDatabase} from '../helpers/database.helpers';
import {omit} from 'lodash';

describe('CategoriesController Filtering (e2e)', () => {
  let app: BackApplication;
  let client: Client;
  // let category: Category;
  let categoryList: Category[];

  beforeAll(async () => {
    ({app, client} = await setupApplication());
    categoryList = [];
    // start with an empty DB
    await givenEmptyDatabase();
  });

  afterAll(async () => {
    await app.stop();
  });

  it('Create & check 5 Categories', async () => {
    const today = new Date();
    categoryList = Category.fake()
      .theCategories(5)
      .withName(index => `test name ${5 - index}`)
      .withCreated(today)
      .build();

    // eslint-disable-next-line @typescript-eslint/no-misused-promises
    categoryList.forEach(async cat => {
      await client.post('/categories').send(cat).expect(200);
    });

    let res = await client.get('/categories/count');
    expect(res.status).toBe(200);
    expect(res.body.count).toBe(5);

    res = await client.get('/categories');
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
        .expect(value.expected);
    });
  });

  // it('List Categories with filter: fields, order, limit & skip', async () => {
  //   const filter = {
  //     fields: ['name', 'email'],
  //     order: 'name ASC',
  //     limit: 3,
  //     skip: 1,
  //   };

  //   const res = await client.get(
  //     '/categories?filter=' + JSON.stringify(filter),
  //   );
  //   const keys = Object.keys(res.body[0]);

  //   expect(res.status).toBe(200);
  //   expect(res.body.length).toBe(3);
  //   expect(keys).toStrictEqual(['name']);

  //   expect(res.body[0].name).toStrictEqual(categoryList[3].name);
  //   expect(res.body[1].name).toStrictEqual(categoryList[2].name);
  //   expect(res.body[2].name).toStrictEqual(categoryList[1].name);
  // });

  // // REMOVED: endpoints that weren’t necessary.
  // // it('Update One Category in 5', async () => {
  // //   const update: Category = JSON.parse(JSON.stringify(categoryList[3]));
  // //   update.didToken = 'updated didToken';

  // //   const res = await client
  // //     .put('/categories/' + update.id)
  // //     .send(update)
  // //     .set('Authorization', 'Bearer ' + cJWT);
  // //   expect(res.status).toBe(200);
  // // });

  // it('Check if update did not change other entries', async () => {
  //   const filter = {
  //     limit: 5,
  //     order: 'name ASC',
  //   };

  //   const res = await client.get(
  //     '/categories?filter=' + JSON.stringify(filter),
  //   );
  //   expect(res.status).toBe(200);
  //   expect(res.body.length).toBe(5);

  //   for (let r = 0; r < categoryList.length; r++) {
  //     if (r !== 3) {
  //       expect(categoryList[r]).toStrictEqual(res.body[4 - r]);
  //     } else {
  //       categoryList[r] = res.body[4 - r];
  //     }
  //   }
  // });

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

  // it('Check if partial update did not change other entries', async () => {
  //   const filter = {
  //     limit: 5,
  //     order: 'name ASC',
  //   };

  //   const res = await client.get(
  //     '/categories?filter=' + JSON.stringify(filter),
  //   );
  //   expect(res.status).toBe(200);
  //   expect(res.body.length).toBe(5);

  //   for (let r = 0; r < categoryList.length; r++) {
  //     if (r !== 4) {
  //       expect(categoryList[r]).toStrictEqual(res.body[4 - r]);
  //     }
  //   }
  // });
});
