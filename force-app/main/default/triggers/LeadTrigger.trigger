trigger LeadTrigger on Lead(before insert, before update) {
  LeadTriggerHandler lth = new LeadTriggerHandler();
  lth.fillLeadsScore(Trigger.new);
}
