@isTest
private class OpportunityTriggerHandlerTest {
  private static final String GROUP_SALE_RECORD_TYPE = 'DIY Group Sale';
  private static final String CAMPUS_SALE_RECORD_TYPE = 'DIY Campus Sale';

  @TestSetup
  static void setup() {
    List<Product2> products = new List<Product2>();
    List<Opportunity> opportunities = new List<Opportunity>();
    List<OpportunityLineItem> items = new List<OpportunityLineItem>();

    for (Integer i = 0; i < 2; ++i) {
      Product2 product = new Product2(
        Name = 'Test' + i,
        ProductCode = 'Arduino'
      );
      Opportunity opportunity = new Opportunity(
        StageName = 'Closed Won',
        Name = 'Test' + i,
        CloseDate = Date.today(),
        Number_of_students__c = 51 * i
      );
      products.add(product);
      opportunities.add(opportunity);
    }

    insert products;
    insert opportunities;

    List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();

    for (Integer i = 0; i < 2; ++i) {
      PricebookEntry pricebookEntry = new PricebookEntry(
        Product2Id = products.get(i).Id,
        Pricebook2Id = Test.getStandardPricebookId(),
        UnitPrice = 1,
        IsActive = true
      );
      pricebookEntries.add(pricebookEntry);
    }
    insert pricebookEntries;

    for (Integer i = 0; i < 2; ++i) {
      OpportunityLineItem item = new OpportunityLineItem(
        Product2Id = products.get(i).Id,
        OpportunityId = opportunities.get(i).Id,
        Quantity = 100,
        TotalPrice = 100,
        PricebookEntryId = pricebookEntries.get(i).Id
      );
      items.add(item);
    }
    insert items;
  }

  @isTest
  static void setRecordTypeTest() {
    OpportunityTriggerHandler oth = new OpportunityTriggerHandler();
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
    List<Opportunity> opportunities = [
      SELECT RecordTypeId, Number_of_students__c
      FROM Opportunity
    ];

    oth.setRecordType(opportunities);
    System.assertEquals(groupSaleId, opportunities.get(0).RecordTypeId);
    System.assertEquals(campusSaleId, opportunities.get(1).RecordTypeId);
  }

  @isTest
  static void createAccountInterestsTest() {
    OpportunityTriggerHandler oth = new OpportunityTriggerHandler();
    List<Opportunity> opportunities = [
      SELECT Name, Id, StageName
      FROM Opportunity
    ];
    oth.createAccountInterests(opportunities, null);
    List<OpportunityLineItem> items = [
      SELECT Id, Name
      FROM OpportunityLineItem
    ];
    List<Account_Interest__c> accountInterests = [
      SELECT Deal_Link__c, Name, Id
      FROM Account_Interest__c
    ];
    Integer counter = 0;
    for (Account_Interest__c interest : accountInterests) {
      System.assertEquals(opportunities.get(counter).Id, interest.Deal_Link__c);
      System.assert(interest.Name.contains(items.get(counter).Name));
      counter++;
    }
  }

  @isTest
  static void deleteAccountInterestsTest() {
    OpportunityTriggerHandler oth = new OpportunityTriggerHandler();
    List<Opportunity> opportunities = [
      SELECT Name, Id, StageName
      FROM Opportunity
    ];
    oth.createAccountInterests(opportunities, null);
    List<OpportunityLineItem> items = [
      SELECT Id, Name
      FROM OpportunityLineItem
    ];
    List<Account_Interest__c> accountInterests = [
      SELECT Id
      FROM Account_Interest__c
    ];
    System.assert(!accountInterests.isEmpty());
    for (Opportunity item : opportunities) {
      item.StageName = 'Closed Lost';
    }
    oth.deleteAccountInterests(opportunities);
    accountInterests = [
      SELECT Id
      FROM Account_Interest__c
    ];
    System.assert(accountInterests.isEmpty());
  }
}
