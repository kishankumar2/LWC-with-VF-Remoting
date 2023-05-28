public class UpdateAccountBatch implements Database.Batchable<SObject> {
    private List<Id> accIds;
    
    public UpdateAccountBatch(List<Id> accIds) {
        this.accIds = accIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, Description FROM Account WHERE Id IN :accIds';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<Account> scope) {
        for (Account acc : scope) {
            acc.Description = 'Updated From Async Apex Batch';
        }
        update scope;
    }
    
    public void finish(Database.BatchableContext context) {
        // Do any post-processing here
    }
}