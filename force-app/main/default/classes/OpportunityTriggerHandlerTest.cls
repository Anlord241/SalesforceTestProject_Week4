@isTest
private class OpportunityTriggerHandlerTest {
  private static final String GROUP_SALE_RECORD_TYPE = 'DIY Group Sale';
  private static final String CAMPUS_SALE_RECORD_TYPE = 'DIY Campus Sale';
  @isTest
  static void setRecordTypeTest() {
    OpportunityTriggerHandler oth = new OpportunityTriggerHandler();
    String groupSaleId = [
      SELECT id
      FROM RecordType
      WHERE name = :GROUP_SALE_RECORD_TYPE
      LIMIT 1
    ]
    .Id;
    String campusSaleId = [
      SELECT id
      FROM RecordType
      WHERE name = :CAMPUS_SALE_RECORD_TYPE
      LIMIT 1
    ]
    .Id;
    List<Opportunity> opportunities = new List<Opportunity>();

    for (Integer i = 0; i < 2; ++i) {
      Opportunity opportunity = new Opportunity(
        StageName = 'Proposal',
        Name = 'Test' + i,
        CloseDate = Date.today(),
        Number_of_students__c = 51 * i
      );
      opportunities.add(opportunity);
    }

    oth.setRecordType(opportunities);
    System.assertEquals(groupSaleId, opportunities.get(0).RecordTypeId);
    System.assertEquals(campusSaleId, opportunities.get(1).RecordTypeId);
  }

  @isTest
  static void createAccountInterestsTest() {
    List<Opportunity> opportunities = new List<Opportunity>();

    for (Integer i = 0; i < 2; ++i) {
      Opportunity opportunity = new Opportunity(
        StageName = 'Closed Won',
        Name = 'Test' + i,
        CloseDate = Date.today(),
        Number_of_students__c = 51 * i
      );
      opportunities.add(opportunity);
    }
  }
}
