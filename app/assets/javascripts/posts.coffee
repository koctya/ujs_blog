# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# should this use live, bind or on, none seem to work consistently.
$(document).ready ->
  $(document).on 'ajax:success', '.delete_post', ->
    $(this).closest('tr').fadeOut()

