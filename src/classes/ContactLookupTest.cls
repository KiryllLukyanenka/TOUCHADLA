@isTest
private class ContactLookupTest {

    static testMethod void testContactLookup() {
        ContactLookup.getPrimaryContact('test@test.com', 'name');
    }
}