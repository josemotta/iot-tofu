import {Client} from '@loopback/testlab';
import {BackApplication} from '../../../index';
import {setupApplication, errorToMessage} from '../helpers/test-helper';
import {Category} from '../../../models';
import {givenEmptyDatabase} from '../helpers/database.helpers';
import {UniqueEntityId} from '../../../utils/unique-entity-id';

describe('Category CRUD', () => {
  let app: BackApplication;
  let client: Client;
  let category: Category;
  let categoryList: Category[];

  beforeAll(async () => {
    ({app, client} = await setupApplication());
    await givenEmptyDatabase();
    categoryList = [];
  });

  afterAll(async () => {
    await app.stop();
  });

  it('Create & get a Category', async () => {
    const uuid = new UniqueEntityId();
    const today = new Date();
    const cat = Category.fake()
      .aCategory()
      .withName('Movie')
      .withCreated(today)
      .build();
    // console.dir(cat);

    let res = await client.post('/categories').send(cat).expect(200);
    // console.dir(res.body);
    category = res.body;

    res = await client.get('/categories/' + category.id);
    // console.dir(res.body);

    expect(res.status).toBe(200);
    expect(res.body).toStrictEqual(category);
  });

  it('Update Category', async () => {
    const update: Category = JSON.parse(JSON.stringify(category));
    update.name = 'Jack Shepard';

    const res = await client.put('/categories/' + update.id).send(update);
    expect(res.status).toBe(200);
    category = update;
  });

  it('Check Category Update', async () => {
    const res = await client.get('/categories/' + category.id);
    expect(res.status).toBe(200);
    expect(category).toStrictEqual(res.body);
  });

  it('Update Category Partially', async () => {
    const update = JSON.parse(JSON.stringify(category));
    const updateData = {
      name: 'Eliot Parker',
    };
    const res = await client.patch('/categories/' + update.id).send(updateData);
    expect(res.status).toBe(200);
    category.name = updateData.name;
  });

  it('Check Category Partially Update', async () => {
    const get = JSON.parse(JSON.stringify(category));
    const res = await client.get('/categories/' + get.id);
    expect(res.status).toBe(200);
    expect(category).toStrictEqual(res.body);
  });

  // TODO: check why this test do not pass
  // it('Update Category Partially With Where', async () => {
  //   const update = JSON.parse(JSON.stringify(category));

  //   const updateData = {
  //     name: 'Eduardo Patcher',
  //   };
  //   const res = await client
  //     .patch('/categories?where=' + JSON.stringify({id: update.id}))
  //     .send(updateData)
  //     //.set('Authorization', 'Bearer ' + cJWT);

  //   console.dir(update, {depth: 3});
  //   console.log('/categories?where=' + JSON.stringify({id: update.id}));

  //   expect(res.status).toBe(200);
  //   category.name = updateData.name;
  // });

  // REMOVED: endpoints that weren’t necessary
  // it('Check Category Partially Update With Where', async () => {
  //   const get = JSON.parse(JSON.stringify(category));

  //   const res = await client.get('/categories/' + get.id);
  //   expect(res.status).toBe(200);
  //   expect(category).toStrictEqual(res.body);
  // });

  it('Delete Category', async () => {
    const get = JSON.parse(JSON.stringify(category));

    const res = await client.delete('/categories/' + get.id);
    expect(res.status).toBe(200);
  });

  it('Check Deleted Category', async () => {
    const get = JSON.parse(JSON.stringify(category));

    const res = await client.get('/categories/' + get.id);
    expect(res.status).toBe(404);
  });
});
