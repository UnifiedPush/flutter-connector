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
