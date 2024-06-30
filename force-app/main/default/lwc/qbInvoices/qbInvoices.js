import { LightningElement, track , wire, api } from 'lwc';
import  getActiveQbInvoices  from '@salesforce/apex/RemindersController.getActiveQbInvoices';
export default class QbInvoices extends LightningElement {

@track qbInvoices;
@api recordId;

@wire(getActiveQbInvoices)
wiredAccounts({error, data}) {
if (data) {
this.qbInvoices = data;
} else if (error) {
console.error('Error fetching related invoices:   ')

 }
}
connectedCallback() {
    this.fetchInvoices();
}

fetchInvoices() {

    getQbInvoices().then(result => {
        this.qbInvoices = result;
    })
    .catch(error => {
        console.error('Error fetching accounts: ' + JSON.stringify(error));
    });

}

}