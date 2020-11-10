enum WebdavErrorType {
  Default,
  XML,
  Cancel,
}

class WebdavError implements Exception {
  WebdavErrorType type;

  dynamic error;

  WebdavError({
    this.type = WebdavErrorType.Default,
    this.error,
  });

  String get message => (error?.toString() ?? '');

  @override
  String toString() {
    var msg = 'WebdavError [$type]: $message';
    if (error is Error) {
      msg += '\n${error.stackTrace}';
    }
    return msg;
  }
}
