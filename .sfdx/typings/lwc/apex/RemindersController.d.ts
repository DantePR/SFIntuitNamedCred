declare module "@salesforce/apex/RemindersController.changeext" {
  export default function changeext(param: {newText: any}): Promise<any>;
}
declare module "@salesforce/apex/RemindersController.getReminders" {
  export default function getReminders(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/RemindersController.getQbInvoices" {
  export default function getQbInvoices(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/RemindersController.getActiveQbInvoices" {
  export default function getActiveQbInvoices(): Promise<any>;
}
