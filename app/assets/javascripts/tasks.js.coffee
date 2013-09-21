$ ->
  # $('form').on 'click', '.remove_fields', (event) ->
  #   $(this).prev('input[type=hidden]').val('1')
  #   $(this).closest('fieldset').hide()
  #   event.preventDefault()

  $(document).on 'click', '.add_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()

  $(document).on 'click', ".checkable-task", (event) ->
    unless $(this).is(":checked")
      $(this).parents('form:first').find('.achievement-unchecked-task').val($(this).val())
    $(this).parents("form:first").submit()
