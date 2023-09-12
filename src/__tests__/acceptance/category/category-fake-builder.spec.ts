import {CategoryFakeBuilder} from './category-fake-builder';
import {Category} from '../../../models';
import {UniqueEntityId} from '../../../utils/unique-entity-id';

describe('CategoryFakeBuilder Unit Tests', () => {
  describe('unique_entity_id prop', () => {
    const faker = CategoryFakeBuilder.aCategory();

    it('should throw error when with methods are called', () => {
      expect(() => faker['getValue']('unique_entity_id')).toThrow(
        new Error(
          `Property unique_entity_id does not have a factory, use a 'with' method`,
        ),
      );
      expect(() => faker['getValue']('created')).toThrow(
        new Error(
          `Property created does not have a factory, use a 'with' method`,
        ),
      );
      expect(() => faker['getValue']('updated')).toThrow(
        new Error(
          `Property updated does not have a factory, use a 'with' method`,
        ),
      );
    });

    it('should be a undefined', () => {
      expect(faker['_unique_entity_id']).toBeUndefined();
      expect(faker['_created']).toBeUndefined();
      expect(faker['_updated']).toBeUndefined();
    });

    test('withUniqueEntityId', () => {
      const uniqueEntityId = new UniqueEntityId();
      const $this = faker.withUniqueEntityId(uniqueEntityId);
      expect($this).toBeInstanceOf(CategoryFakeBuilder);
      expect(faker['_unique_entity_id']).toBe(uniqueEntityId);

      faker.withUniqueEntityId(() => uniqueEntityId);
      expect(faker['_unique_entity_id']()).toBe(uniqueEntityId);

      expect(faker.unique_entity_id).toBe(uniqueEntityId);
    });

    // it('should pass index to unique_entity_id factory', () => {
    //   let mockFactory = jest.fn().mockReturnValue(new UniqueEntityId());
    //   faker.withUniqueEntityId(mockFactory);
    //   faker.build();
    //   expect(mockFactory).toHaveBeenCalledWith(0);

    //   mockFactory = jest.fn().mockReturnValue(new UniqueEntityId());
    //   const fakerMany = CategoryFakeBuilder.theCategories(2);
    //   fakerMany.withUniqueEntityId(mockFactory);
    //   fakerMany.build();

    //   expect(mockFactory).toHaveBeenCalledWith(0);
    //   expect(mockFactory).toHaveBeenCalledWith(1);
    // });
  });

  describe('name prop', () => {
    const faker = Category.fake().aCategory();

    it('should be a function', () => {
      expect(typeof faker['_name'] === 'function').toBeTruthy();
    });

    test('withName', () => {
      faker.withName('test name');
      expect(faker).toBeInstanceOf(CategoryFakeBuilder);
      expect(faker['_name']).toBe('test name');

      faker.withName(() => 'test name');
      //@ts-expect-error name is callable
      expect(faker['_name']()).toBe('test name');

      expect(faker.name).toBe('test name');
    });

    test('invalid too long', () => {
      faker.withInvalidNameTooLong();
      expect(faker['_name'].length).toBe(256);

      const tooLong = 'a'.repeat(256);
      faker.withInvalidNameTooLong(tooLong);
      expect(faker['_name'].length).toBe(256);
      expect(faker['_name']).toBe(tooLong);
    });

    test('invalid not a string', () => {
      faker.withInvalidNameNotString();
      expect(faker['_name']).not.toBeInstanceOf(String);
    });
  });

  describe('description prop', () => {
    const faker = Category.fake().aCategory();

    it('should be a function', () => {
      expect(typeof faker['_description'] === 'function').toBeTruthy();
    });

    test('withDescription', () => {
      faker.withDescription('test description');
      expect(faker).toBeInstanceOf(CategoryFakeBuilder);
      expect(faker['_description']).toBe('test description');

      faker.withDescription(() => 'test description');
      //@ts-expect-error description is callable
      expect(faker['_description']()).toBe('test description');

      expect(faker.description).toBe('test description');
    });

    test('invalid too long', () => {
      faker.withInvalidDescriptionTooLong();
      expect(faker['_description'].length).toBe(256);

      const tooLong = 'a'.repeat(256);
      faker.withInvalidDescriptionTooLong(tooLong);
      expect(faker['_description'].length).toBe(256);
      expect(faker['_description']).toBe(tooLong);
    });

    test('invalid not a string', () => {
      faker.withInvalidDescriptionNotString();
      expect(faker['_description']).not.toBeInstanceOf(String);
    });
  });

  it('should create a Category', () => {
    const category = new Category({
      id: '123',
      name: 'tst',
      description: 'tst',
    });
    // console.dir(category, {depth: 5});

    expect(typeof category.name === 'string').toBeTruthy();
    expect(typeof category.description === 'string').toBeTruthy();
  });

  it('should fake a Category', () => {
    const faker = Category.fake().aCategory();
    //console.dir(faker, {depth: 5});

    const category = faker
      .withName('test name')
      .withDescription('test description')
      .build();
    // console.dir(category, {depth: 5});

    expect(category.name).toBe('test name');
    expect(category.description).toBe('test description');
    expect(category.active).toBeTruthy();
  });

  it('should create many Categories', () => {
    const faker = Category.fake().theCategories(2);
    let categories = faker.build();
    // console.dir(categories, {depth: 5});

    categories.forEach(category => {
      expect(typeof category.name === 'string').toBeTruthy();
      expect(typeof category.description === 'string').toBeTruthy();
      expect(category.active).toBeTruthy();
    });

    categories = faker
      .withName('test name')
      .withDescription('test description')
      .build();

    categories.forEach(category => {
      expect(category.name).toBe('test name');
      expect(category.description).toBe('test description');
      expect(category.active).toBeTruthy();
    });
  });
});
