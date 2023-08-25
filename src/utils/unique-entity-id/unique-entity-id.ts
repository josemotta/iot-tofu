import {v4 as uuidv4, validate as uuidValidate} from "uuid";
import InvalidUuidError from './invalid-uuid-error';
import ValueObject from "./value-object";

export class UniqueEntityId extends ValueObject<string> {

    constructor(readonly id?: string) {
        super(id = id || uuidv4());
        this.validate();
    }

    private validate() {
        const isValid = uuidValidate(this.id);
        if(!isValid){
            throw new InvalidUuidError();
        }
    }
}

export default UniqueEntityId;
