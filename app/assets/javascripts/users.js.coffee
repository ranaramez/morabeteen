$ ->
  $('form').on 'change', 'select[id$=_achievement_schedule]', (event) ->
    $(this).nextAll('.schedule-form').html($(this).find(":selected").attr('data-partial'))
