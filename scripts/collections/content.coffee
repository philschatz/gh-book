# All Content
# =======
#
# To prevent multiple copies of a model from floating around a single
# copy of all referenced content (loaded or not) is kept in this Collection
#
# This should be read-only by others
# New content models should be created by calling `ALL_CONTENT.add {}`

define [
  'underscore'
  'backbone'
  'cs!models/content/book'
  'cs!models/content/folder'
  'cs!models/content/module'
], (_, Backbone, Book, Folder, Module) ->

  return new (Backbone.Collection.extend
    model: (attrs, options) ->
      throw 'You must pass the model in when adding to the content collection.'
  )()