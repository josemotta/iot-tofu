import {UniqueEntityId} from '../../../utils/unique-entity-id';
import {Category} from '../../../models';
import {omit} from 'lodash';

describe('Category Unit Tests', () => {
  let faker;
  let today;
  let uniqueId;
  let category: Category;

  beforeEach(() => {
    uniqueId = new UniqueEntityId();
    faker = Category.fake().aCategory();
    today = new Date();
  });

  test('category constructor without dates', () => {
    category = faker
      .withUniqueEntityId(uniqueId)
      .withName('Movie')
      .withDescription('Terror')
      .build();
    const props = omit(category, 'created', 'updated');
    expect(props).toStrictEqual({
      id: uniqueId.id,
      name: 'Movie',
      description: 'Terror',
      active: true,
    });
    expect(category.created).toBeUndefined();
    expect(category.updated).toBeUndefined();
  });

  test('category constructor with created', () => {
    category = faker
      .withUniqueEntityId(uniqueId)
      .withName('Movie')
      .withDescription('Terror')
      .withCreated(today)
      .build();
    const props = omit(category, 'created', 'updated');
    expect(props).toStrictEqual({
      id: uniqueId.id,
      name: 'Movie',
      description: 'Terror',
      active: true,
    });
    expect(category.created).toBeInstanceOf(Date);
    expect(category.created).toBe(today);
    expect(category.updated).toBeUndefined();
  });

  test('category constructor with created & updated', () => {
    category = faker
      .withUniqueEntityId(uniqueId)
      .withName('Movie')
      .withDescription('Terror')
      .withCreated(today)
      .withUpdated(today)
      .build();
    const props = omit(category, ['created', 'updated']);
    expect(props).toStrictEqual({
      id: uniqueId.id,
      name: 'Movie',
      description: 'Terror',
      active: true,
    });
    expect(category.created).toBeInstanceOf(Date);
    expect(category.created).toBe(today);
    expect(category.updated).toBeInstanceOf(Date);
    expect(category.updated).toBe(today);
  });
});
