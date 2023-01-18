public with sharing class ProductTriggerHandler {
  public ProductTriggerHandler() {
  }

  private void fillProductFamilyField(List<Product2> products) {
    List<Product_Family_by_Code_Mapping__mdt> metadata = Product_Family_by_Code_Mapping__mdt.getAll()
      .values();
    List<Id> oppportunityProductIds = new List<Id>();
    Map<String, String> productFamilyMap = new Map<String, String>();
    for (Product_Family_by_Code_Mapping__mdt item : metadata) {
      productFamilyMap.put(item.Product_Code__c, item.Product_Family__c);
    }
    for (Product2 item : products) {
      if (productFamilyMap.containsKey(item.ProductCode)) {
        item.Family = productFamilyMap.get(item.ProductCode);
        oppportunityProductIds.add(item.Id);
      } else {
        item.addError(
          'Such product code is not allowed in the system. Please update the PFC mapping or contact administrator'
        );
      }
    }
    Map<Id, Product2> productsMap = new Map<Id, Product2>(products);

    List<OpportunityLineItem> opportunityProducts = [
      SELECT Id
      FROM OpportunityLineItem
      WHERE Product2Id IN :oppportunityProductIds
    ];

    for (OpportunityLineItem item : opportunityProducts) {
      item.Product_Family_Match__c = productsMap.get(item.Product2Id).Family;
    }
    update opportunityProducts;
  }

  public void handleInsertAndUpdate() {
    fillProductFamilyField(Trigger.new);
  }
}
