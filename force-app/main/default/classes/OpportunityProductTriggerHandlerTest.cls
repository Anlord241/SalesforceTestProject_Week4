@isTest
private class OpportunityProductTriggerHandlerTest {
  @TestSetup
  static void setup() {
    List<Product2> products = new List<Product2>();
    List<Opportunity> opportunities = new List<Opportunity>();
    for (Integer i = 0; i < 2; ++i) {
      Product2 product = new Product2(
        Name = 'Test' + i,
        ProductCode = 'Arduino'
      );
      Opportunity opportunity = new Opportunity(
        StageName = 'Proposal',
        Name = 'Test' + i,
        CloseDate = Date.today()
      );
      products.add(product);
      opportunities.add(opportunity);
    }
    insert products;
    insert opportunities;
  }
  @isTest
  static void pullProductFamilyTest() {
    List<Product2> products = [SELECT Id, Family FROM Product2];
    List<Opportunity> opportunities = [SELECT Id FROM Opportunity];
    List<OpportunityLineItem> items = new List<OpportunityLineItem>();
    OpportunityProductTriggerHandler opth = new OpportunityProductTriggerHandler();
    for (Integer i = 0; i < 2; ++i) {
      OpportunityLineItem item = new OpportunityLineItem(
        Product2Id = products.get(i).Id,
        OpportunityId = opportunities.get(i).Id
      );
      items.add(item);
    }
    opth.pullProductFamily(items);
    Integer counter = 0;
    for (OpportunityLineItem item : items) {
      System.assert(item.Product_Family__c == products.get(counter).Family);
    }
  }
}