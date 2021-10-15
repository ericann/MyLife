trigger PMPriceTrigger on PMPrice__c (before insert) {
	new TriggerManagement().bind(TriggerType.BeforeInsert, new ThresholdCalHandler())
		.execute();
}