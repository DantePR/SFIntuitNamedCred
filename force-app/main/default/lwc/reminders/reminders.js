import { LightningElement,track, wire, api } from 'lwc';
import getReminders from '@salesforce/apex/RemindersController.getReminders';


export default class Reminders extends LightningElement {
     
    @track reminders;
    @api recordId;

    @wire(getReminders, { recordId: '$recordId' })
    wiredReminders({error, data}) {
        if (data) {
            this.reminders = data;
        } else if (error) {
            console.error('Error fetching related reminders: ' + JSON.stringify(error));
        }
    }


    connectedCallback() {
        this.fetchReminders();
    }

    fetchReminders() {

        getReminders().then(result => {
            this.reminders = result;
        })
        .catch(error => {
            console.error('Error fetching accounts: ' + JSON.stringify(error));
        });

    }

}