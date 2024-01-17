public with sharing class TestClass {
    public static void getAccounts(){
        List<Account> accs = [Select Id, Name FROM Account];
    }
}