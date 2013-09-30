define [
  'underscore'
  'jquery'
  'backbone'
  'cs!models/content/module'
  'cs!gh-book/xhtml-file'
  'gh-book/googlejsapi'
], (_, $, Backbone, ModuleModel, XhtmlModel) ->

  GDOC_TO_HTML_URL = 'http://testing.oerpub.org/gdoc2html' # eventually `http://remix.oerpub.org/gdoc2html`
  gdocsURL = (id) -> "https://docs.google.com/document/d/#{id}/export?format=html&confirm=no_antivirus"

  # the cannonical example of how to use google picker includes three functions
  # newPicker(), createPicker(), and pickerCallback. and so do we except ours
  # includes promises.

  gdocpicker_deferred = undefined

  newPicker = () ->
    google.load('picker', '1', {"callback" : createPicker})
    gdocpicker_deferred = $.Deferred()
    return gdocpicker_deferred.promise()

  createPicker = () ->
    picker = new google.picker.PickerBuilder().
      addView(google.picker.ViewId.DOCUMENTS).
      setCallback(pickerCallback).
      build()
    picker.setVisible(true);
    return picker

  pickerCallback = (data) ->
    # action can be { "cancel", "picked", "received", "loaded", "uploadProgress", "uploadScheduled", "uploadStateChange" }
    if data.action is google.picker.Action.PICKED
        gdocpicker_deferred.resolve(data)
    else if data.action is google.picker.Action.CANCEL
        gdocpicker_deferred.reject()

  getGoogleDocHtml = (data) ->
    gdoc_resource_id = data.docs[0].id
    html_url = gdocsURL(gdoc_resource_id)
    gdoc_html_promise = $.get(html_url)
    return gdoc_html_promise

  transformGoogleDocHtml = (html) ->
    gdoc_transform_promise = $.ajax(
      dataType: "json"
      type: "POST"
      async: true
      url: GDOC_TO_HTML_URL
      data:
        html: html
        textbook_html: 0
        copy_images: 0
    )
    return gdoc_transform_promise

  # The `Content` model contains the following members:
  #
  # * `title` - an HTML title of the content
  # * `language` - the main language (eg `en-us`)
  # * `subjects` - an array of strings (eg `['Mathematics', 'Business']`)
  # * `keywords` - an array of keywords (eg `['constant', 'boltzmann constant']`)
  # * `authors` - an `Collection` of `User`s that are attributed as authors
  return class GoogleDocXhtmlModel extends XhtmlModel

    title: 'Google Document Import'

    # **NOTE:** The mediaType (`application/xhtml+xml`) is inherited from XhtmlModel 
    # because a successful import will 'appear' as a XHTML document.
    # This mediaType is used in the OPF manifest

    # In order to add this type to the Add dropdown for a Book (OPF File)
    # this model must have a unique mediaType (not `application/xhtml+xml`)
    # This is used to register with `media-types` and is in the 
    # list of types `opf-file` accepts as a child (so it shows up in the filtered dropdown)
    uniqueMediaType: 'application/vnd.org.cnx.gdoc-import'

    _loadComplex: (fetchPromise) ->
      # **NOTE:** `fetchPromise` is not used because this type can only be created as a new object
      #           (the fetchPromise is already resolved)
      gdocimport_promise = @_importGoogleDoc()
      return gdocimport_promise

    # Saves the fetched and converted Document into this model for saving
    _injectHtml: (bodyhtml) ->
      # bodyhtml is "<body>...</body>"
      @set 'body', bodyhtml

    _cleanupFailedImport: () ->
      return

    _importGoogleDoc: () ->
      gdocimport_deferred = $.Deferred()
      gdocimport_promise = gdocimport_deferred.promise()

      # 1. Open the Google Doc picker dialog
      gdocpicker_promise = newPicker()
      gdocpicker_promise.done (data) =>
        # alert "selected a google doc"
        # 2. Get the HTML for the Google Doc from Google
        gdoc_html_promise = getGoogleDocHtml(data)
        gdoc_html_promise.done (data, status, xhr) =>
          html = data
          # alert "got html from google"
          # 3. Send the HTML to the transform service
          gdoc_transform_promise = transformGoogleDocHtml(html)
          gdoc_transform_promise.done (data, status, xhr) =>
            # alert "gdoc2html service succeeded"
            # 4.  Inject the cleaned HTML into the Model
            bodyhtml = data["html"]
            @_injectHtml(bodyhtml)
            gdocimport_promise.resolve()
          gdoc_transform_promise.fail (data, status, xhr) =>
            # alert "gdoc service failed to tranform html into aloha ready html."
            @_cleanupFailedImport()
            gdocimport_promise.reject()
        gdoc_html_promise.fail (data, status, xhr) =>
          # alert "failed to get the google doc's html from google."
          @_cleanupFailedImport()
          gdocimport_promise.reject()
      gdocpicker_promise.fail =>
        # alert "canceled out of the google doc picker."
        @_cleanupFailedImport()
        gdocimport_promise.reject()
        
      return gdocimport_promise
