trigger ProductTrigger on Product2(before insert, before update) {
  new ProductTriggerHandler().handleInsertAndUpdate();
}
