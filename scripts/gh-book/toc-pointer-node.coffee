define ['cs!gh-book/toc-node'], (TocNode) ->

  class TocPointerNode extends TocNode
    mediaType: 'application/BUG-mediaType-not-set' # This will get overridden to be whatever this node points to
    accept: []      # This will get overridden to be whatever this node points to

    initialize: (options) ->
      throw 'BUG: Missing constructor options' if not options
      throw 'BUG: Missing model this points to' if not options.model

      # Shadow properties/events on the original model
      @model = options.model
      @mediaType = @model.mediaType
      @accept = @model.accept

      # Should be used ONLY for serializing to HTML tree
      @id = @model.id

      @model.on 'all', () => @trigger.apply @, arguments

      # When the title changes on the XhtmlModel update it in the ToC as well
      @model.on 'change:title', () => @set('title', @model.get('title'))
      # Set the title on the model now
      @set('title', @model.get('title'))

      options.title = options.title or @model.get 'title'
      super(options)

    # Pass through all model attributes except the title (if it is set)
    toJSON: () ->
      json = @model.toJSON()
      # If the title is overridden, change it in the json
      title = @get('title')
      json.title = title if title
      return json

    # Returns the model this points to.
    # Existence of this method means this is a pointer node
    dereferencePointer: () -> @model

    contentView: (callback) -> @model.contentView(callback)
