trigger PropertyChangeTrigger on Property_Change__c (after insert) {

    Map<Id, Property_Change__c> changesByProperty =
        new Map<Id, Property_Change__c>();

    for (Property_Change__c pc : Trigger.new) {
        if (pc.Reassessment_Required__c == true &&
            pc.Property__c != null) {
            changesByProperty.put(pc.Property__c, pc);
        }
    }

    if (changesByProperty.isEmpty()) {
        return;
    }

    List<Property__c> propertiesToUpdate = [
        SELECT Id, Built_up_Area__c,
               Number_of_Floors__c, Usage_Type__c
        FROM Property__c
        WHERE Id IN :changesByProperty.keySet()
    ];

    for (Property__c p : propertiesToUpdate) {
        Property_Change__c pc = changesByProperty.get(p.Id);

        if (pc.New_Built_up_Area__c != null) {
            p.Built_up_Area__c = pc.New_Built_up_Area__c;
        }

        if (pc.New_Floors__c != null) {
            p.Number_of_Floors__c = pc.New_Floors__c;
        }

        if (pc.New_Usage__c != null) {
            p.Usage_Type__c = pc.New_Usage__c;
        }
    }

    update propertiesToUpdate;
}