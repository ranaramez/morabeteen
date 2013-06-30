$ ->
  $(document).on 'change', 'select[id$=_achievement_schedule]', (event) ->
    $(this).parent().closest('div').nextAll('.field').find('.schedule-form').html($(this).find(":selected").attr('data-partial'))