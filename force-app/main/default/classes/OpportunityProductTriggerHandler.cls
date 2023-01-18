public with sharing class OpportunityProductTriggerHandler {
  public OpportunityProductTriggerHandler() {
  }

  private void pullProductFamily(List<OpportunityLineItem> items) {
    List<Id> productIds = new List<Id>();
    for (OpportunityLineItem item : (List<OpportunityLineItem>) items) {
      productIds.add(item.Product2Id);
    }
    List<Product2> products = [
      SELECT Id, Family
      FROM Product2
      WHERE Id IN :productIds
    ];
    Map<Id, Product2> productMap = new Map<Id, Product2>(products);
    for (OpportunityLineItem item : (List<OpportunityLineItem>) items) {
      item.Product_Family__c = productMap.get(item.Product2Id).Family;
    }
  }

  public void handleInsertAndUpdate() {
    pullProductFamily(Trigger.new);
  }
}
