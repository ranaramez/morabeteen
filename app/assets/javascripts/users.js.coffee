$ ->
  $(document).on 'change', 'select[id$=_achievement_schedule]', (event) ->
    $(this).parent().closest('div.form').find('.schedule-form').html($(this).find(":selected").attr('data-partial'))

  $(document).on 'change', 'select[id$=level-select]', (event) ->
    $(this).parents("form:first").submit()