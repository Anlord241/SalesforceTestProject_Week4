@isTest
private class LeadTriggerHandlerTest {
  @isTest
  static void fillLeadsScoreTest_result19() {
    List<Lead> leads = new List<Lead>();
    LeadTriggerHandler lth = new LeadTriggerHandler();
    Lead lead = new Lead(
      LastName = 'Test',
      Company = 'Test',
      Email = 'test@test.com',
      Number_of_Students__c = 27,
      Number_of_Sets_Required__c = 17
    );
    leads.add(lead);
    lth.fillLeadsScore(leads);
    System.assert(lead.Score__c == 19);
  }

  @isTest
  static void fillLeadsScoreTest_result0() {
    List<Lead> leads = new List<Lead>();
    LeadTriggerHandler lth = new LeadTriggerHandler();
    Lead lead = new Lead(LastName = 'Test', Company = 'Test');
    leads.add(lead);
    lth.fillLeadsScore(leads);
    System.assert(lead.Score__c == 0);
  }
}