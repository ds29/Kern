# Kern CHANGELOG

## 0.9.5

- New default behavior to handle JSON without root entities.  Root entities are still supported.
- Added methods to process collections according to a status indicator ['DUN' == ('D' == deleted, 'U' == updated, 'N' == new)]
- Multithreading features

## 0.9.2

- Let's just pretend 0.9 and 0.9.1 never happened, ok?

## 0.9.1

- Use sharedContext on NSManagedObjectContextDidSaveNotification instead of self.

## 0.9

- Set NSManagedObjectContextDidSaveNotification listener to use self.

## 0.8

Initial stable release.
