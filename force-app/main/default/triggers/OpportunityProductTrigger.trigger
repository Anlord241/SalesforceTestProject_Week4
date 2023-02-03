trigger OpportunityProductTrigger on OpportunityLineItem(
  before insert,
  before update
) {
  OpportunityProductTriggerHandler opth = new OpportunityProductTriggerHandler();
  opth.pullProductFamily(Trigger.new);
}