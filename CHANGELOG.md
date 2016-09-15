## 0.2.2 (15/09/2016)

* Fix deprecation messages that appeared when using Rails 5.

## 0.2.1 (29/06/2014)

* Fixed bug that occured when using Rails 4.1.2.

## 0.2.0 (29/05/2014)

* Added support for Rails 4.1.

## 0.1.5 (25/04/2014)

* Made associations respect the class_name option
* Fixed cti_recreate_views_after_change_to so it also works for the base class

## 0.1.4 (8/04/2014)

* Fixed association issues

## 0.1.3 (3/11/2013)

* Fixed validation issue
* Improved handling of associations in new (not yet persisted) objects

## 0.1.2 (27/10/2013)

* Fundamental change to how associations are handled in order to solve problems with build
* Added support for accepts_nested_attributes_for
* Validation errors on associated models are now correctly handled

## 0.1.1 (23/10/2013)

* Fixed handling of the remote part of associations (i.e. the belongs_to part when a cti-class has e.g. a has_many association)
* Blocks passed to e.g. has_many are no longer ignored

## 0.1.0 (22/10/2013)

* Added transparent support for associations

## 0.0.1

* First Release