public with sharing class LeadTriggerHandler {
  public LeadTriggerHandler() {
  }

  public enum LeadScoringAttributes {
    NOT_BLANK,
    BETWEEN,
    GREATER
  }

  private Boolean checkMetadataCondition(
    Lead lead,
    Lead_Setting__mdt metadataEntry
  ) {
    String fieldName = metadataEntry.Field__c;
    String condition = metadataEntry.Condition__c;
    Integer valueA = Integer.valueOf(metadataEntry.Value_A__c);
    Integer valueB = Integer.valueOf(metadataEntry.Value_B__c);

    if (condition.equals(LeadScoringAttributes.NOT_BLANK.name())) {
      String field = (String) lead.get(fieldName);
      return String.isNotBlank(field);
    }

    if (condition.equals(LeadScoringAttributes.BETWEEN.name())) {
      Integer field = Integer.valueOf(lead.get(fieldName));
      return valueA <= field && field <= valueB;
    }
    if (condition.equals(LeadScoringAttributes.GREATER.name())) {
      Integer field = Integer.valueOf(lead.get(fieldName));
      return field > valueA;
    }

    return false;
  }

  private Integer countScore(Lead lead) {
    Integer score = 0;
    List<Lead_Setting__mdt> metadata = Lead_Setting__mdt.getAll().values();
    for (Lead_Setting__mdt item : metadata) {
      if (checkMetadataCondition(lead, item)) {
        score += Integer.valueOf(item.Number_to_add__c);
      }
    }
    return score;
  }

  private void fillLeadsScore(List<Lead> items) {
    for (Lead item : items) {
      item.Score__c = countScore(item);
    }
  }

  public void handleInsertAndUpdate() {
    fillLeadsScore(Trigger.new);
  }
}
