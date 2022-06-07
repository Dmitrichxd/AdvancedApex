/**
 * @name orderTrigger
 * @description
**/
trigger orderTrigger on Order (
    before insert, after insert
    ,before update, after update
) {

    if (Trigger.isAfter && Trigger.isUpdate) {
        OrderHelper.AfterUpdate((List<Order>) Trigger.new, (List<Order>) Trigger.old);
    }
}