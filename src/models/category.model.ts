import {Entity, model, property} from '@loopback/repository';
import {CategoryFakeBuilder} from '../__tests__/acceptance/category';
// import {getModelSchemaRef} from '@loopback/rest';

export enum CategoryType {
  DIRECTOR = 1,
  ACTOR = 2,
}

@model()
export class Category extends Entity {
  @property({
    type: 'string',
    id: true,
    generated: true,
    jsonSchema: {
      exists: ['Category', 'id'],
    },
  })
  id?: string;

  @property({
    type: 'string',
    required: true,
    jsonSchema: {
      minLength: 1,
      maxLength: 255,
      errorMessage: 'Name must be between 1 and 255 characters',
    },
  })
  name: string;

  @property({
    type: 'number',
    required: false,
    jsonSchema: {
      enum: [CategoryType.DIRECTOR, CategoryType.ACTOR],
      errorMessage: 'Invalid type',
    },
  })
  type?: string;

  @property({
    type: 'string',
    required: false,
    jsonSchema: {
      nullable: true,
    },
    default: null,
  })
  description?: string;

  @property({
    type: 'boolean',
    required: false,
    default: true,
  })
  active: boolean;

  @property({
    type: 'date',
    required: true,
  })
  created: string;

  @property({
    type: 'date',
  })
  updated?: string;

  constructor(data?: Partial<Category>) {
    super(data);
  }

  static fake() {
    return CategoryFakeBuilder;
  }
}

export interface CategoryRelations {
  // describe navigational properties here
}

export type CategoryWithRelations = Category & CategoryRelations;

// const schema = getModelSchemaRef(Category, {
//   title: 'NewCategory',
//   partial: true,
// });
// console.dir(schema, {depth: 8});
