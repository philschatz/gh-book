define ['cs!./new-book', 'cs!./new-module'], (newBook, newModule) ->
  total = 200
  content = (newModule {title: "Module in a Big Book #{num} of #{total}", body: '<p>Nothing</p>'} for num in [1..total])

  modulesHtml = ("<li><a href='#{module.id}' class='autogenerated-text'>[THIS TITLE SHOULD NOT BE VISIBLE]</a></li>" for module in content)

  content.push newBook
    title: 'Big Book'
    body: """
      <nav>
        <ol>
          #{modulesHtml.join('')}
        </ol>
      </nav>
    """

  return {
    content: content
  }
