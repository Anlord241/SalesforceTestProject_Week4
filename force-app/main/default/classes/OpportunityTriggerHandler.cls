public with sharing class OpportunityTriggerHandler {
  private static final String GROUP_SALE_RECORD_TYPE = 'DIY Group Sale';
  private static final String CAMPUS_SALE_RECORD_TYPE = 'DIY Campus Sale';

  public OpportunityTriggerHandler() {
  }

  private void setRecordType(List<Opportunity> opportunities) {
    String groupSaleId = [
      SELECT id
      FROM RecordType
      WHERE name = :GROUP_SALE_RECORD_TYPE
      LIMIT 1
    ]
    .Id;
    String campusSaleId = [
      SELECT id
      FROM RecordType
      WHERE name = :CAMPUS_SALE_RECORD_TYPE
      LIMIT 1
    ]
    .Id;

    for (Opportunity item : opportunities) {
      item.RecordTypeId = item.Number_of_Students__c > 50
        ? campusSaleId
        : groupSaleId;
    }
  }

  private void deleteAccountInterests(List<Opportunity> opportunities) {
    List<String> opportunitiesIds = new List<String>();

    List<Account_Interest__c> accountInterests = new List<Account_Interest__c>();
    for (Opportunity item : opportunities) {
      if (!item.StageName.equals('Closed Won')) {
        opportunitiesIds.add(item.Id);
      }
    }
    accountInterests = [
      SELECT id
      FROM Account_Interest__c
      WHERE Deal_Link__c IN :opportunitiesIds
    ];
    delete accountInterests;
  }

  private void createAccountInterests(
    List<Opportunity> opportunities,
    Map<Id, Opportunity> oldOpportunitiesMap
  ) {
    List<Account_Interest__c> newAccountInterests = new List<Account_Interest__c>();
    List<String> opportunitiesIds = new List<String>();

    for (Opportunity item : opportunities) {
      if (
        item.StageName.equals('Closed Won') &&
        !oldOpportunitiesMap.get(item.Id).StageName.equals('Closed Won')
      ) {
        opportunitiesIds.add(item.Id);
      }
    }
    List<OpportunityLineItem> products = [
      SELECT OpportunityId, Name
      FROM OpportunityLineItem
      WHERE OpportunityId IN :opportunitiesIds
    ];
    for (OpportunityLineItem item : products) {
      newAccountInterests.add(
        new Account_Interest__c(
          Deal_Link__c = item.OpportunityId,
          Name = 'Account Interest for ' + item.Name
        )
      );
    }
    insert newAccountInterests;
  }

  private void processRelatedAccountInterests(
    List<Opportunity> opportunities,
    Map<Id, Opportunity> oldOpportunitiesMap
  ) {
    deleteAccountInterests(opportunities);
    createAccountInterests(opportunities, oldOpportunitiesMap);
  }

  public void handleInsertAndUpdate() {
    setRecordType(Trigger.new);
    processRelatedAccountInterests(
      Trigger.new,
      (Map<Id, Opportunity>) Trigger.oldMap
    );
  }
}
