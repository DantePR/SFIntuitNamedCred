public with sharing class RemindersController {
    public RemindersController() {
         qbId = ApexPages.currentPage().getParameters().get('id');
    }
    public List<Remider__c> reminders { get; set; }
    public String qbId  { get; set; }
    public void fetchReminders() {
        reminders = [SELECT Id, Name, Collected_Notes__c, Contacted_Email__c, Contacted_Number__c, FollowUp__c, QbInvoice__c, Resolution__c ,Status__c, Type__c FROM Remider__c where QbInvoice__c = :qbId WITH SECURITY_ENFORCED LIMIT 20];
        reminders =  Security.stripInaccessible(AccessType.READABLE, reminders).getRecords();
    }

    public PageReference refresh() {
        fetchReminders();
        return null;
    }

    @AuraEnabled
    public static string changeext(String newText){
        try {
            return 'New Message';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Remider__c> getReminders(Id recordId){
        try {
            List<Remider__c> myReminders = [SELECT Id, Name, Collected_Notes__c, Contacted_Email__c, Contacted_Number__c, FollowUp__c, QbInvoice__c, Resolution__c ,Status__c, Type__c FROM Remider__c where QbInvoice__c = :recordId WITH SECURITY_ENFORCED LIMIT 20];
            myReminders =  Security.stripInaccessible(AccessType.READABLE, myReminders).getRecords();
            return myReminders;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Invoice__c> getQbInvoices(Id recordId){
        try {
            //gets invoices  doing stripinaccesibel in new utilities function
            String whereClause = 'QbInvoice__c = ' + '\'' + Utilities.escapeSingleQuotes(recordId) + '\'';
            List<Invoice__c> myInvoices = Utilities.getFieldSetData('Invoice__c', 'QbInvoicesFS', whereClause);
            
            return myInvoices;
        
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Invoice__c> getActiveQbInvoices(){
        try {
            //gets invoices  doing stripinaccesibel in new utilities function
            String whereClause = 'Status__c = \'New\'';
            List<Invoice__c> myInvoices = Utilities.getFieldSetData('Invoice__c', 'QbInvoicesFS', whereClause);
            
            return myInvoices;
        
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}