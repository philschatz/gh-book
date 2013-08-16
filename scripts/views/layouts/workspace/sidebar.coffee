define [
  'marionette'
  'cs!collections/media-types'
  'cs!views/workspace/menu/add'
  'cs!views/workspace/sidebar/toc'
  'hbs!templates/layouts/workspace/sidebar'
], (Marionette, mediaTypes, AddView, TocView, sidebarTemplate) ->

  return class Sidebar extends Marionette.Layout
    template: sidebarTemplate

    regions:
      addContent: '.add-content'
      toc: '.workspace-sidebar'

    onShow: () ->
      model = @model
      collection = @collection or model.getChildren()

      # TODO: Make the collection a FilteredCollection that only shows @model.accepts
      @addContent.show(new AddView {context:model, collection:mediaTypes})
      @toc.show(new TocView {model:model, collection:collection})
