import {Category} from '../../../../models/category.model';

export class CategoryFixture {
  static keysInResponse() {
    return ['id', 'description', 'name'];
  }

  static arrangeInvalidFilter() {
    return {
      INVALID_FIELDS: {
        filter_data: {
          fields: ['invalid', 'email'],
          order: 'name ASC',
          limit: 3,
          skip: 1,
        },
        expected: 400,
      },
      // Test passes (status 500) but Netune connector also logs a console error:
      // Error: Field "invalid" must be in field list!
      //
      // INVALID_ORDER: {
      //   filter_data: {
      //     fields: ['name', 'email'],
      //     order: 'invalid',
      //     limit: 3,
      //     skip: 1,
      //   },
      //   expected: 500,
      // },
      INVALID_LIMIT: {
        filter_data: {
          fields: ['name', 'email'],
          order: 'name ASC',
          limit: 'invalid',
          skip: 1,
        },
        expected: 400,
      },
      INVALID_SKIP: {
        filter_data: {
          fields: ['name', 'email'],
          order: 'name ASC',
          limit: 3,
          skip: 'invalid',
        },
        expected: 400,
      },
    };
  }

  static arrangeForEntityValidationError() {
    const faker = Category.fake().aCategory();
    const defaultExpected = {
      statusCode: 422,
      name: 'UnprocessableEntityError',
      code: 'VALIDATION_FAILED',
    };
    const requestBodyIsInvalid = {
      error: {
        ...defaultExpected,
        message:
          'The request body is invalid. See error object `details` property for more info.',
      },
    };
    return {
      EMPTY: {
        send_data: {},
        expected: requestBodyIsInvalid,
      },
      NAME_UNDEFINED: {
        send_data: {
          name: faker.withInvalidNameEmpty(undefined).name,
        },
        expected: requestBodyIsInvalid,
      },
      NAME_NULL: {
        send_data: {
          name: faker.withInvalidNameEmpty(null).name,
        },
        expected: requestBodyIsInvalid,
      },
      NAME_EMPTY: {
        send_data: {
          name: faker.withInvalidNameEmpty('').name,
        },
        expected: requestBodyIsInvalid,
      },
      NAME_NOT_STRING: {
        send_data: {
          name: faker.withInvalidNameNotString().name,
        },
        expected: requestBodyIsInvalid,
      },
    };
  }
}

export class ListCategoryFixture {
  static keysInResponse() {
    return CategoryFixture.keysInResponse();
  }

  static arrangeInvalidFilter() {
    return CategoryFixture.arrangeInvalidFilter();
  }

  static arrangeForEntityValidationError() {
    return CategoryFixture.arrangeForEntityValidationError();
  }
}
