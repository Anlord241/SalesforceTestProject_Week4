trigger ProductTrigger on Product2(before insert, before update) {
  ProductTriggerHandler pth = new ProductTriggerHandler();
  pth.fillProductFamilyField(Trigger.new);
  if (Trigger.isUpdate) {
    pth.updateRelatedOpportunityProducts(Trigger.new);
  }
}