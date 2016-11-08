{$, TextEditorView, View} = require 'atom-space-pen-views'
path = require 'path'

module.exports =
class Dialog extends View
  @content: ({prompt} = {}) ->
    @div class: 'tree-view-dialog', =>
      @label prompt, class: 'icon', outlet: 'promptText'
      @subview 'miniEditor', new TextEditorView(mini: true)
      @div class: 'error-message', outlet: 'errorMessage'

  initialize: ({initialPath, select, iconClass} = {}) ->
    @promptText.addClass(iconClass) if iconClass
    atom.commands.add @element,
      'core:confirm': => @onConfirm(@miniEditor.getText())
      'core:cancel': => @cancel()
    @miniEditor.on 'blur', => @close() if document.hasFocus()
    @miniEditor.getModel().onDidChange => @showError()
    @miniEditor.getModel().setText(initialPath)

    if select
      extension = path.extname(initialPath)
      baseName = path.basename(initialPath)
      if baseName is extension
        selectionEnd = initialPath.length
      else
        selectionEnd = initialPath.length - extension.length
      range = [[0, initialPath.length - baseName.length], [0, selectionEnd]]
      @miniEditor.getModel().setSelectedBufferRange(range)

  attach: (currentSelectedEntry) ->
    if currentSelectedEntry?
      @selectionPath = currentSelectedEntry.getPath()
    @panel = atom.workspace.addModalPanel(item: this.element)
    @miniEditor.focus()
    @miniEditor.getModel().scrollToCursorPosition()

  close: ->
    panelToDestroy = @panel
    @panel = null
    panelToDestroy?.destroy()
    if @selectionPath?
      parentPath = @selectionPath.substring(0, @selectionPath.lastIndexOf(path.sep))
      $("[data-path='#{parentPath}']").parents('li')[0].classList.add('selected')
      $('.tree-view').focus()
    else
      atom.workspace.getActivePane().activate()

  cancel: ->
    @close()
    $('.tree-view').focus()

  showError: (message='') ->
    @errorMessage.text(message)
    @flashError() if message
