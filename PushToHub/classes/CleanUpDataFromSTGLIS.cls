/**

 * Created by Nagesh on 11/13/17. SFDC-865 Prevent STORAGE_LIMIT_EXCEEDED in SFDC
                                  SFDC-1260. Create a batch job to clean up data in STGLIS(Case, Contact, Order & OrderHolds)
                                  The Order of the objects to be removed: Case - OrderHold - Order - Contact - Account
 
*/

/*
public without sharing class CleanUpDataFromSTGLIS implements Database.Batchable<sObject> {

   public Database.QueryLocator start(Database.BatchableContext BC){
       
        }

   public void execute(Database.BatchableContext bc, List<sObject> scope){

       Date daysAgo = Date.today().addDays(-30);
       
       // Delete Case Records:
       List<Case> cases = [Select Id From Case where Day_Only(CreatedDate) <= :daysAgo];
       Database.delete(cases, false);
       
       //Delete OrderHold Records:
       List<Order_Hold__c> ordHolds = [Select Id From Order_Hold__c where Day_Only(CreatedDate) <= :daysAgo];
       Database.delete(ordHolds, false);
       
       //Delete Order Records:
       List<Order> ords = [Select Id From Order where Day_Only(CreatedDate) <= :daysAgo];
       Database.delete(ords, false);
       
       //Delete Contact Records:
       List<Contact> cons = [Select Id From Contact where Day_Only(CreatedDate) <= :daysAgo];
       Database.delete(cons, false);
       
       //Delete Account Records:
       List<Account> accts = [Select Id From Account where Day_Only(CreatedDate) <= :daysAgo];
       Database.delete(ords, false);
       

   }

   public void finish(Database.BatchableContext bc){

   }

}
*/

public without Sharing class  CleanUpDataFromSTGLIS implements Database.Batchable<string>, Database.Stateful  {
public boolean bReRun = false; //will be used to determine if batch has to re-run in case there are more that 10K of records
public Iterable<string> start(Database.BatchableContext ctx) {
    return new list<String> { 'Case', 'Order_Hold__c', 'Order','Contact','Account'}; //list of strings with my object names
}
public void execute(Database.BatchableContext ctx, list<string> lstsObjectName) {
	Date daysAgo = Date.today().addDays(-30);
    list<sObject> lstDeleteRecords = new list<sObject>();
    for(string strObjectName : lstsObjectName) {
        for(sObject objsObject : database.query('Select Id from ' + strObjectName + ' where Day_Only(CreatedDate) <= :'+daysAgo)) {
            if(lstDeleteRecords.size() < 9998)
                lstDeleteRecords.add(objsObject);
            else {
                bReRun = true;
                break;
            }
        }
    }
    lstDeleteRecords.sort();
    Database.delete(lstDeleteRecords, false);
}
public void finish(Database.BatchableContext ctx) {
    if(bReRun) {
         Database.executebatch(new CleanUpDataFromSTGLIS());
    }
}

}