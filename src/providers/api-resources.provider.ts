import {inject, Provider} from '@loopback/core';
import {OperationRetval, RequestContext, Response, Send} from '@loopback/rest';
import {PaginatorSerializer} from '../utils/paginator';
import {instanceToPlain} from 'class-transformer';

export class ApiResourceProvider implements Provider<Send> {
  constructor(@inject.context() public requestContext: RequestContext) {}

  value() {
    return (response: Response, result: OperationRetval) => {
      //console.log('Provider<Send> Result: ', result);

      if (this.requestContext.request.method !== 'OPTIONS') {
        if (result) {
          response.json(
            result instanceof PaginatorSerializer
              ? result.toJson(this.requestContext)
              : instanceToPlain(result),
          );
        }
        response.end();
      }
    };
  }
}
