define [
  'underscore'
  'jquery'
  'backbone'
  'cs!models/content/module'
  'cs!gh-book/xhtml-file'
  'gh-book/googlejsapi'
], (_, $, Backbone, ModuleModel, XhtmlModel) ->

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
    if data.action is google.picker.Action.PICKED
        gdocpicker_deferred.resolve(data)
    else if data.action is google.picker.Action.CANCEL
        gdocpicker_deferred.reject()

  getGoogleDocHtml = (data) ->
    gdoc_resource_id = data.docs[0].id
    html_url = 'https://docs.google.com/document/d/' + gdoc_resource_id + 
               '/export?format=html&confirm=no_antivirus'
    gdoc_html_promise = $.get(html_url)
    return gdoc_html_promise

  transformGoogleDocHtml = (html) ->
    gdoc_transform_promise = $.ajax(
      dataType: "json"
      type: "POST"
      async: true
      url: "http://testing.oerpub.org/gdoc2html" # evetually http://remix.oerpub.org/gdoc2html
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
    mediaType: 'application/xhtml+xml'

    uniqueMediaType: 'application/vnd.org.cnx.gdoc-import'

    title: 'Google Document Import'

    initialize: () ->
      super()

    _loadComplex: (promise) ->
      gdocimport_promise = @_importGoogleDoc()
      return gdocimport_promise

    _injectHtml: (bodyhtml) ->
        # bodyhtml is "<body>...</body>"
        @set 'body', bodyhtml

    _cleanupFailedImport: () ->
      return

    _importGoogleDoc: () ->
      _this = this
      gdocimport_deferred = $.Deferred()
      gdocimport_promise = gdocimport_deferred.promise()

      gdocpicker_promise = newPicker()
      gdocpicker_promise.done (data) ->
        gdoc_html_promise = getGoogleDocHtml(data)
        gdoc_html_promise.done (data, status, xhr) ->
          html = data
          #alert "got html from google"
          gdoc_transform_promise = transformGoogleDocHtml(html)
          gdoc_transform_promise.done (data, status, xhr) ->
            # alert "gdoc2html service succeeded"
            bodyhtml = data["html"]
            _this._injectHtml(bodyhtml)
            gdocimport_promise.resolve()
          gdoc_transform_promise.fail (data, status, xhr) ->
            # alert "gdoc service failed to tranform html into aloha ready html."
            _this._cleanupFailedImport()
            gdocimport_promise.reject()
        gdoc_html_promise.fail (data, status, xhr) ->
          # alert "failed to get the google doc's html from google."
          _this._cleanupFailedImport()
          gdocimport_promise.reject()
      gdocpicker_promise.fail ->
        # alert "canceled out of the google doc picker."
        _this._cleanupFailedImport()
        gdocimport_promise.reject()
        
      return gdocimport_promise
