import 'dart:typed_data';

class LocalBinary {

  // null indicates that the blob is null in the database
  Future<ByteBuffer?> _byteBuffer;

  Future<bool> isNullInDatabase () async {
    final ByteBuffer? b = await _byteBuffer;
    return b == null;
  }

  LocalBinary({
    required Future<ByteBuffer?> byteBuffer
  }): _byteBuffer = byteBuffer;

  LocalBinary.nullValue(
  ): _byteBuffer = Future<ByteBuffer?>.value(null);
}

class DocumentPointer {

  // null indicates that data is not downloaded from the database.
  // The local binary of a PDF (or powerpoint etc.) can be updated, in which case this LocalBinary instance is replaced with a newly constructed one.
  LocalBinary? _local; // Note: if the actual blob is null in the database but is already locally stored (as a null value), `_local` is non-null.

  bool _userChangedBinary = false;

  void setUserSpecifiedBinary(LocalBinary binary) {
    _userChangedBinary = true;
    _local = binary;
  }

  Future<LocalBinary> get local async {

    // Return if non null
    if (_local case var loc?) { return loc; }

    throw UnimplementedError("Downloading from the database is not implemented yet.");

    // _local = await download();
    // return _local;
  }


  bool userMadeAChange() {
    return _userChangedBinary;
  }

  // Document binary is stored locally. Might also be stored in the database.
  bool get storedLocally {
    return _local != null;
  }

  DocumentPointer({
    LocalBinary? local
  }):
    _local = local
  ;

  // Used for generating a temporary reference item that can be edited by the user.
  // The copied item can be removed if the user does not edit the record.
  DocumentPointer clone() => DocumentPointer(
    local: this._local // point at the same local binary.
  );
}

class ReferenceItem {
  String title;
  String authors;
  DocumentPointer documentPointer; // the actual binary might not be fetched from the database

  ReferenceItem clone() {
    ReferenceItem c = ReferenceItem();
    c.copyPropertiesFrom(this);
    return c;
  }

  void copyPropertiesFrom(ReferenceItem other) {
    title = other.title;
    authors = other.authors;
    documentPointer = documentPointer.clone();  // although a clone, the binary points at the same blob instance (stored locally or in the database).
  }

  ReferenceItem({this.title = "",
                 this.authors = "",
                 DocumentPointer? documentPointer = null // If un-specified, we will create a database entry whose document blob is A null (not only locally, but also in the database).
  }):
    this.documentPointer = documentPointer?? DocumentPointer(
      local: LocalBinary.nullValue()
    )
  ;

  bool userMadeAChange(ReferenceItem original) {

    // Rule of thumb: compare by values
    return
        // Strings can be compared by their values in this manner
           (title != original.title)
        || (authors != original.authors)
        || documentPointer.userMadeAChange();
  }
}
