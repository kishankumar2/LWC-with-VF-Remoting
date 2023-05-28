global class vfCmpController {
    public string lexOrigin {get{ 
        return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0]+'.lightning.force.com';
    } set;}
    
    @AuraEnabled(cacheable=true)
    public static string getVFOrigin() {
        string vfOrigin = '';
        string baseURL = URL.getOrgDomainUrl().toExternalForm(); 
        System.debug('baseURL: ' + baseURL);
        vfOrigin = 'https://streamer--uatbox--c.sandbox.vf.force.com';//baseURL.split('.my.')[0] + '--c.' + 'vf.force.com';
        System.debug('vfOrigin: ' + vfOrigin);
        return vfOrigin;
    }
    
    @RemoteAction @ReadOnly
    global static String getAccounts(String searchKey){
        System.debug(searchKey);
        String key='%'+searchKey+'%';
        map<id,Account> mapAcc=new Map<ID, Account>([select id,name from Account where name like:key]);
        list<id> lid = new list<id>();
        lid.addAll(mapAcc.keySet());
        System.debug(lid.size());
        responseWrapper res=new responseWrapper();
        res.AccIds=String.join(lid, ',');
        res.length=mapAcc.size();
        return JSON.serialize(res);
    }

    @AuraEnabled 
    public static Boolean updateAccountSync(String ids){
        System.debug('Came in Update Sync');
         Boolean Status =false;
        List<Id> lstAccIds = getIDfromAccountString (ids);
        System.debug('lstAccIds.Size'+lstAccIds.Size());
        System.debug('lstAccIds'+lstAccIds);
        List<Account> lstAccount = [select id, Description from Account where id in :lstAccIds ];
        for(Account acc : lstAccount){
            acc.Description = 'Updated from Sync Apex';
        }
       update lstAccount;
       Status = true;
       return Status;
    }

    @AuraEnabled 
    public static Boolean updateAccountASync(String ids){
        Boolean Status =false;
        List<Id> lstAccIds = getIDfromAccountString (ids);
        System.debug('lstAccIds.Size'+lstAccIds.Size());
        Database.executeBatch(new UpdateAccountBatch(lstAccIds), 200);
        Status = true;

        return Status;
     }



    
    public static List<Id> getIDfromAccountString (String strAccIds) {
        Integer intDiv = (Integer)Math.ceil(strAccIds.length()/190000);
        intDiv = intDiv + 1;
        Integer intMinLimit = 0;
        Integer intMaxLimit = 0;
        List<ID> lstAc = new List<ID>();
        List<ID> lstAccIds = new List<Id>();
        for (Integer i=0; i < intDiv; i++) {
            intMinLimit = i * 190000;
            intMaxLimit = intMinLimit + 190000;
            if (strAccIds.length() > intMinLimit && strAccIds.length() <= intMaxLimit) {
                String str1 = strAccIds.substring(intMinLimit);
                lstAc = (List<Id>) str1.split(',');
                system.debug('lstAccIds :: ' + lstAc.size());
                lstAccIds.addAll(lstAc);
            }
            else if (strAccIds.length() > intMinLimit && strAccIds.length() > intMaxLimit) {
                String str1 = strAccIds.substring(intMinLimit,intMaxLimit);
                system.debug('str1 :: ' + str1);
                lstAc = (List<Id>) str1.split(',');
                system.debug('lstAccIds :: ' + lstAc.size());
                lstAccIds.addAll(lstAc);
            }
        }
        return lstAccIds;
    }
     
    Public class responseWrapper{
        @AuraEnabled public String AccIds{get;set;}
         @AuraEnabled public integer length {get;set;}
    }
}