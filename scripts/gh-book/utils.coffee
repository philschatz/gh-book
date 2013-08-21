define ['jquery', 'URI'], ($, URI) ->

  return {
    # Links in a navigation document are relative to where the nav document resides.
    # If it does not live in the same directory then they need to be resolved to
    # an absolute path so content Models can be looked up
    resolvePath: (context, relPath) ->
      return URI(relPath).absoluteTo(context).toString()


    # Given 2 paths that have the same root
    # generate a path that is relative from `context` to `relPath`.
    # For example: `A/B/cntx` and `A/C/D/file.txt` should yield `../C/D/file.txt`
    relativePath: (contextPath, targetPath) ->
      return URI("/#{targetPath}").relativeTo("/#{contextPath}").toString()

    elementAttributes: ($el) ->
      attrs = {}
      $.each $el[0].attributes, (index, attr) =>
        attrs[attr.name] = attr.value
      attrs
  }
