public with sharing class GetContact {
  public static String getContacts() {
    List<Contact> contacts = new List<Contact>();
    for (Integer i = 0; i < 10; i++) {
      Contact contact = new Contact();
      contact.FirstName = 'Test ' + i;
      contact.LastName = 'User';
      contacts.add(contact);
    }
    insert contacts;
    system.debug('Get Contacts');
    return 'Get Contact';
  }
}
