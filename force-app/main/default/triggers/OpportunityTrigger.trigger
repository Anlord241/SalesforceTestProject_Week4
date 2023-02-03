trigger OpportunityTrigger on Opportunity(before insert, before update) {
  OpportunityTriggerHandler oth = new OpportunityTriggerHandler();

  oth.setRecordType(Trigger.new);
  oth.deleteAccountInterests(Trigger.new);
  oth.createAccountInterests(
    Trigger.new,
    (Map<Id, Opportunity>) Trigger.oldMap
  );
}