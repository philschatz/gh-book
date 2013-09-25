define [
  'underscore'
  'jquery'
  'backbone'
  'cs!models/content/module'
  'cs!gh-book/xhtml-file'
], (_, $, Backbone, ModuleModel, XhtmlModel) ->

  # The `Content` model contains the following members:
  #
  # * `title` - an HTML title of the content
  # * `language` - the main language (eg `en-us`)
  # * `subjects` - an array of strings (eg `['Mathematics', 'Business']`)
  # * `keywords` - an array of keywords (eg `['constant', 'boltzmann constant']`)
  # * `authors` - an `Collection` of `User`s that are attributed as authors
  return class GoogleDocXhtmlModel extends XhtmlModel
    mediaType: 'application/xhtml+xml'

    uniqueMediaType: 'application/vnd.org.cnx.gdoc-import'

    title: 'Google Document Import'

    _loadComplex = (promise) ->
      return promise
