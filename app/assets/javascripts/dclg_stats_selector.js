//= require modal

$(function() {
  $('#reveal-non-imported-data').click(function(e) {
    e.preventDefault();
    $('#non-imported-data').toggle();
  });

  $('.btn-add-data').click(function(e) {
    e.preventDefault();
  });

  $('#preview thead th, #preview tbody td, #preview tfoot th').hover(function() {
    var fragmentClass = $(this).attr('class').split(' ')[0], // our custom fragment class is always the first..
        fragmentElements = $('.'+fragmentClass);
    fragmentElements.addClass('highlight');
    fragmentElements.find('.btn').show();
  },
  function() {
    var fragmentClass = $(this).attr('class').split(' ')[0], // our custom fragment class is always the first..
        fragmentElements = $('.'+fragmentClass);
    fragmentElements.removeClass('highlight');
    fragmentElements.find('.btn').hide();
  });
});