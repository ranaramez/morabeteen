$ ->
  $(document).on 'change', ".assign-default-level", (event) ->
    $(this).parents("form:first").submit()