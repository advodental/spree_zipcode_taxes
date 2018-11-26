Spree.ready ($) ->
  $('#tax-rate-file-section #file-field').change ->
    $('#tax-rate-file-section form').submit()
    return
