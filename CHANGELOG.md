# Changelog

## [1.1.7]
- Remove unnecessary dependency on flutter

## [1.1.6]

- Web platform support. (see [stackoverflow](https://stackoverflow.com/questions/65630743/how-to-solve-flutter-web-api-cors-error-only-with-dart-code) for CORSB problems needing attention)
- Dependency Update

## [1.1.2]

- Upload and download support progress, modified method parameters(read, read2File, write, writeFromFile)
- update dio 4.0.0 > 4.0.1

## [1.1.1]

- `writeFromFile` streams file content instead of reading it into memory.(thanks `@István Soós`)
- fix auth error when root directory is not supported by webdav(thanks `@dutsky`)

## [1.1.0]

- Fix no authorization when uploading and downloading 
- Related dependencies updated to the latest version

## [1.0.0]

- support null-safety

## [0.0.2] 

- fix when server nonce expired, add recertification Logic.

## [0.0.1] 

* common settings
* read dir
* make dir
* delete
* rename
* copy
* download file
* cancel request
