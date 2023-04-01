import 'package:mobile_wallet/model/address_book_entry.dart';
import 'package:mobile_wallet/service/address_book_service.dart';
import 'package:mockito/mockito.dart';

class MockAddressBookService extends Mock implements AddressBookService {
  Future<void> saveAddressBook(List<AddressBookEntry> addressBook) async {
    return Future(() => {});
  }

  Future<List<AddressBookEntry>> getAddressBook() async {
    return Future(() => <AddressBookEntry>[]);
  }

  Future<void> addToAddressBook(String name, String address) async {
    return Future(() => {});
  }

  Future<bool> hasAddress(String address) async {
    return Future(() => false);
  }
}
