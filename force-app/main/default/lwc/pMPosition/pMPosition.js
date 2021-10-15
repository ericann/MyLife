import { LightningElement } from 'lwc';

export default class PMPosition extends LightningElement {
  greeting = 'World';
  changeHandler(event) {
    this.greeting = event.target.value;
  }
}
  