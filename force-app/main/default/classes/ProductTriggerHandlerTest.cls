@isTest
private class ProductTriggerHandlerTest {
  private static final String VALID_PRODUCT_CODE = 'Arduino';
  private static final String INVALID_PRODUCT_CODE = '4242';

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
        StageName = 'Proposal',
        Name = 'Test' + i,
        Pricebook2Id = Test.getStandardPricebookId(),
        CloseDate = Date.today()
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
  static void fillProductFamilyFieldTest() {
    ProductTriggerHandler pth = new ProductTriggerHandler();
    List<Product2> products = new List<Product2>();
    Product2 product = new Product2(
      Name = 'Test',
      ProductCode = VALID_PRODUCT_CODE
    );
    products.add(product);
    System.assert(product.Family == null);
    pth.fillProductFamilyField(products);
    System.assertEquals('Arduino Board', products.get(0).Family);
    System.assert(product.getErrors().isEmpty());
  }

  @isTest
  static void fillProductFamilyFieldTest_Error() {
    ProductTriggerHandler pth = new ProductTriggerHandler();
    List<Product2> products = new List<Product2>();
    Product2 product = new Product2(
      Name = 'Test',
      ProductCode = INVALID_PRODUCT_CODE
    );
    products.add(product);
    System.assert(product.Family == null);
    pth.fillProductFamilyField(products);
    System.assert(!product.getErrors().isEmpty());
    System.assert(
      product.getErrors()
        .get(0)
        .getMessage()
        .contains(
          'Such product code is not allowed in the system. Please update the PFC mapping or contact administrator!'
        )
    );

    System.assert(product.Family == null);
  }

  @isTest
  static void updateRelatedOpportunityProductsTest() {
    ProductTriggerHandler pth = new ProductTriggerHandler();
    List<Product2> products = [SELECT Id, Family FROM Product2];
    pth.updateRelatedOpportunityProducts(products);
    List<OpportunityLineItem> items = [
      SELECT Id, Product_Family_Match__c
      FROM OpportunityLineItem
    ];
    Integer i = 0;
    for (OpportunityLineItem item : items) {
      System.assertEquals(products.get(i).Family, item.Product_Family_Match__c);
    }
  }
}
