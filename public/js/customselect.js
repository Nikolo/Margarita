$(document).ready(function() {
$(this).click(function(e) {
var $target = $(e.target);
var cs = $target.closest(".custom_select");
if (cs.length == 0 && $target != $(".custom_select")) {
$('.ful').hide();
}
})


$(".custom_select").each(function() {
var selected = false;
var active_span = $(this).find('.curr_sel'); 
var sel_ul = $('.ful', this)
$('li', this).each(function() {
if ($(this).attr('name') == 'selected') {
selected = true;
active_span.html($(this).text())
active_span.attr('data-id', $(this).attr('data-id'))
}
})
if (selected == false) {
active_span.text(active_span.attr('data-default'))
}
})

$('.ful').on('click', 'li', function() {
var id = $(this).attr('data-id');
var d_id = $(this).closest('ul').attr('data-id');
var text = $(this).text();
var curr_sel = $(this).closest('.custom_select')
var active_span = curr_sel.find('.curr_sel')
var sel_ul = curr_sel.find('.ful')
active_span.attr('data-id', id)
active_span.text(text)
$('.ful').hide();
onchange_select(id, d_id)
})

$(".custom_select").click(function(e) {
if (e.target.nodeName !== 'LI') {
$('.ful').hide();

if ($(this).attr('data-open') == 1) {
$(this).find('.ful').hide();
$(this).attr('data-open', 0)
} else {
$(this).find('.ful').show();
var atid = $(this).find('.curr_sel').attr('data-id');
$('li[data-id="'+atid+'"]', this).addClass('li_sel')
$(this).attr('data-open', 1)
}
}
})

$('.ful').hover(function() {
$('li', this).removeClass('li_sel')
})
})