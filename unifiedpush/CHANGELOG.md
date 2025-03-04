## 6.0.0
**Breaking**:
* Use new platform interface: Process PushEndpoint/PushMessage, to get public keys informations and auto decrypt push messages
* registerApp

**New**:
* Add VAPID support
* Add tryUseCurrentOrDefaultDistributor, to use the system default distributor

## 5.0.2
* Add missing await for async tasks
* Deprecate registerAppWithDialog, use unifiedpush_ui if needed
* Update links to repository

## 5.0.1
* Upgrade max sdk

## 5.0.0
* getDistributor returns nullable string
* Android:
    * Ensure only one FlutterEngine is created
    * Do not explicitly call _onRegistered in unregisterApp

## 4.0.3
* Bump unifiedpush_android to 1.1.1

## 4.0.2
* Bump unifiedpush_android to 1.1.0

## 4.0.1
* Bump unifiedpush_android to 1.0.1
* Add option to dismiss dialog when there is no distributors
* Add removeNoDistributorDialogACK() to show the dialog again

## 4.0.0
* Use a platform interface

## 3.0.1
* android-connector:1.2.3
* Clean dependencies
* Update dependencies

## 3.0.0
* Make the lib null safe
* It is supposed to be a major release

## 2.1.0
* Make the lib null safe

## 2.0.0
* Add multi-instance support for receiving events:
    * Add initializeWithReceiverInstanciated
    * Add initializeWithCallbackInstanciated
* Callback functions passed as argument for initializeWithCallback now require to have `dynamic` args

## 1.1.0
* Add GetDistributor
* Add multi-instance support
* Fix saveDistributor
* Add custom distributor picker to the example
* Small fix on the example
* Update dependencies

## 1.0.6
* android-connector:1.2.0
    * registerAppWithDialog now displays application name instead of package name.
    * registerAppWithDialog now check if a distributor is already saved and re-register if so.
    * getDistributor(context: Context) now removes the saved distributor and returns an empty String if the distributor is not installed anymore.

## 1.0.5

* android-connector:1.1.3
    * Fix safeRemoveDistributor
* update dependencies

## 1.0.4

* android-connector:1.1.2
* update dependencies

## 1.0.3

* update dependencies

## 1.0.2

* fix: Null safe dependencies

## 1.0.1

* The first version ready to publish.

## 0.0.1

* TODO: Describe initial release.
