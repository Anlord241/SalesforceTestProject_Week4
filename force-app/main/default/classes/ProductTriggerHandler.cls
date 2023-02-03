public with sharing class ProductTriggerHandler {
  public ProductTriggerHandler() {
  }

  public void fillProductFamilyField(List<Product2> products) {
    List<Product_Family_by_Code_Mapping__mdt> metadata = Product_Family_by_Code_Mapping__mdt.getAll()
      .values();
    Map<String, String> productFamilyMap = new Map<String, String>();
    for (Product_Family_by_Code_Mapping__mdt item : metadata) {
      productFamilyMap.put(item.Product_Code__c, item.Product_Family__c);
    }
    for (Product2 item : products) {
      if (productFamilyMap.containsKey(item.ProductCode)) {
        item.Family = productFamilyMap.get(item.ProductCode);
      } else {
        item.addError(
          'Such product code is not allowed in the system. Please update the PFC mapping or contact administrator!'
        );
      }
    }
  }

  public void updateRelatedOpportunityProducts(List<Product2> products) {
    Map<Id, Product2> productsMap = new Map<Id, Product2>(products);
    List<Id> productIds = new List<Id>();
    for (Product2 item : products) {
      productIds.add(item.Id);
    }
    List<OpportunityLineItem> opportunityProducts = [
      SELECT Id, Product2Id
      FROM OpportunityLineItem
      WHERE Product2Id IN :productIds
    ];

    for (OpportunityLineItem item : opportunityProducts) {
      item.Product_Family_Match__c = productsMap.get(item.Product2Id).Family;
    }
    update opportunityProducts;
  }
}
