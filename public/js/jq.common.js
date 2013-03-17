jQuery.support.cors = true

function odd_lines() {
$('.an_list:odd').css({'background-color':'#fafafa'});
$('.an_list:odd .eas').css({'background':'url(/img/easing-grad-g.png)'});
}

function odd_lines_lab() {
$('.labs_table tr:odd').css({'background-color':'#fafafa'});
$('.labs_table tr:even').css({'background-color':'#ffffff'});
}

function odd_lines_ref() {
$('.referentical_div table tr:odd').css({'background-color':'#fafafa'});
$('.referentical_div table tr:even').css({'background-color':'#ffffff'});
}


$(window).load(function(){
if (navigator.userAgent.toLowerCase().indexOf("chrome") >= 0) {

var chromechk_watchdog = 0;
var chromechk = setInterval(function() {
if($('input:-webkit-autofill').length>0)
{
clearInterval(chromechk);
$('input:-webkit-autofill').each(function(){
var text = $(this).val();
var name = $(this).attr('name');
$(this).after(this.outerHTML).remove();
$('input[name=' + name + ']').val(text);
});
}
else if(chromechk_watchdog>20)
clearInterval(chromechk);
chromechk_watchdog++;
},10);
}

if($("#loginEnterToSite").val() == '' )
{	

	$("#loginEnterToSite").prev().text('E-mail').show();
	$("#passwordEnterToSite").prev().text('Пароль').show();

}

if ($("#loginEnter").val() == '') {

	$("#loginEnter").prev().text('E-mail').show();
	$("#passwordEnter").prev().text('Пароль').show();
}


});


(function($) {
				$.fn.panelslider = function(options) {
				
				r = $.extend({}, options);
				var rc = 0;
				var pages = $('.slide_p_c').size();
				var soffset = $('.slide_p_c').innerWidth();
				for(var i = 1; i <= pages; i++) {
				$('.dnav_p').append('<li></li>');
				}
				$('.dnav_p li:first').addClass('act_li');
				
				$('.dnav_p li').click(function() {
				var ti = $(this).index();
				rc = ti;
				
				var curr0ff = ti * soffset;

				$('.slider_p').animate({
				'left':'-'+curr0ff
				});
				show_lists(rc);
				});
				
				$('.left_t_nav').hide();
				$('.right_t_nav').click(function() {
				rc++;
				slide_c(rc);
				});
				
				$('.left_t_nav').click(function() {
				rc--;
				slide_c(rc);
				});
				
								
				function slide_c(rc) {
				var curr0ff = rc * soffset;
				if (rc <= 0 || rc < pages) {
				$('.slider_p').animate({
				'left':'-'+curr0ff
				});
			
				}
				show_lists(rc);				
				}
				
				function show_lists(rc){
				if (rc > 0) {
				$('.left_t_nav').fadeIn();
				}
				if (rc <= 0) {
				$('.left_t_nav').fadeOut();
				rc = 0;
				}
				if (rc >= pages - 1) {
				$('.right_t_nav').fadeOut();
				rc = pages - 1;
				}
				if (rc < pages - 1) {
				$('.right_t_nav').fadeIn();
				}
				$('.dnav_p li').siblings().removeClass('act_li');
				$('.dnav_p li').eq(rc).addClass('act_li');
				}
				
				
				
				
				}
							
				
	
				})(jQuery);
				
				
				

$(document).ready(function () {
ajax = false
function SpriteAnim (options) {
  var timerId, i = 0,
      element = document.getElementById(options.elementId);
	if (element === null) return false 
  element.style.width = options.width + "px";
  element.style.height = options.height + "px";
  element.style.backgroundRepeat = "no-repeat";
  element.style.backgroundImage = "url(" + options.sprite + ")";

  timerId = setInterval(function () {
    if (i >= options.frames) {
      i = 0;
    }
    element.style.backgroundPosition = "0px -" + i * options.height + "px";
     i++;
  }, 200);

  this.stopAnimation = function () {
    clearInterval(timerId);
  };
}

var loader = new SpriteAnim({
  width: 30,
  height: 30,
  frames: 4,
  sprite: "/img/analiz-loader.png",
  elementId : "a_loader"
});

odd_lines();
$('.steps').hover(function(){$('.est_h', this).show(); $('.hover_popup', this).show()}, function(){$('.est_h', this).hide(); $('.hover_popup', this).hide()})
$('.not_act_diag').hover(function(){
$('#diag_m').fadeIn()
}, function(curtxt){
$('#diag_m').fadeOut()
})


$('.test_control ul li').click(function() {
clearInterval(slide_timing);
var ti = $(this).index();
slide_panels(ti)
});

var typingTimer = null;                

$('input[name="term"]').keyup(function(){
    var _this = $(this)
	if(typingTimer) {
            clearTimeout(typingTimer);
        }
	typingTimer = setTimeout(function(){doneTyping(_this)}, 500);
});


$('input[name="term"]').keydown(function(){
	$('#an_se_r').css({ opacity: 0.5 });
});


function doneTyping (_this) {
	dosearch(_this)
}


function dosearch(_this) {
var quer = _this.val();
var where = _this.attr('id');
var type = _this.attr('data-type')


if (where == 'inner_s') {
var ret_state = $("#an_se_r");
var icount = 12;
} else if (where == 'main_s') {
var ret_state = $("#ls");
var icount = 4;
}
var url, a_href;
if (type == 'test') { url = 'collection'; a_href = 'tests' }
if (type == 'diag') { url = 'diagnostic'; a_href = 'diagnostic' }

if (quer.length >= 3) {
if(ajax && ajax.readystate != 4){
 ajax.abort();
 }
ajax = $.ajax({
  type: "POST",
  url: "/"+url+"/search",
  data: { term: quer }
}).done(function(data) {
	ret_state.empty();
	if ( data.length >= icount) {
			$('.more_results').attr('data-item-page', 1);
			$('.more_results').attr('data-item-quer', quer);
			$('.more_results').attr('data-item-count', data.length);
			$('.more_results').attr('data-where', type);
			$('.more_results').show()
			$('.search_end').hide()
	 } else if (data.length < icount) {
	  $('.more_results').hide()
	  $('.search_end').hide()
	 }
	
	if (data != "") {	
    $.each(data, function(i,list){
	var panels = '';
	
	
		if (list.inbasket == 0) {
		var inbasket = '<span class="gren_b" onclick="yaCounter17144653.reachGoal(\'basket\'); _gaq.push([\'_trackEvent\', \'Actions\', \'add_to_cart\', \'\']); return true;"><span class="gb_r"><span class="gb_c">Выбрать</span></span></span>';
		var cclass = '';
		} else if (list.inbasket == 1) {
		var cclass = 'cart_t'
		var inbasket = '<a class="yellow_b incart" href="/labs/"><span class="yb_r"><span class="yb_c">Где сдать?</span></span></a>';
		}
	
		if (type == 'test' && list.panel.length > 0) {
		 panels += '<div class="t_in_p"><span class="t_in_p_title">Входит в панели: </span>'
		 $.each(list.panel, function(i,p){
		 var z
		 if (list.panel.length != i+1) {
		  z = ', '
		 } else {
		  z = ''
		 }
		panels += '<a href="/panels/id/' + p.id + '">' + p.name + '</a>' + z
		})
		panels += '</div>'
		} 
		
       $('<div data-type="'+type+'" class="an_list '+cclass+'" data-item-id="'+list.id+'"><div class="ico_link"><i class="aico"></i><a href="/'+ a_href +'/id/'+list.id+'/" title="'+list.value+'">'+list.value+'</a><i class="eas"></i></div>'+inbasket+'<div class="clear"></div>'+panels+'</div>').appendTo(ret_state);
	  
      if ( i == icount ) return false; 
	  
    });
	
	
	
	
	} else {
	$('<div class="not_f">Ничего не найдено. Пожалуйста, сформулируйте запрос иначе.</div>').appendTo(ret_state);
	}
	odd_lines();
	if (ret_state.is(':hidden')) ret_state.slideDown();
	$("#an_se_r").css({ opacity: 1 });
  });
  
} else if (where == 'main_s') {
ret_state.slideUp();
}
$("#an_se_r").css({ opacity: 1 });
}
$('.vitr_searchf').mouseleave(function() {
$('#ls').slideUp();
});

$('.qlike a').click(function() {
var nval = $(this).text()
$('input[name="term"]').val(nval);
return false
});

$('.main_pan_bott').panelslider();




$('#login_on_s, #reg_on_s, #same_l_e').click(function() {
var wclick = $(this).attr('data-item-show');
$('#login_layer').fadeIn();
$('#login_splash').show();
$('#login_splash').animate({
'width': 461,
'height': 461,
'marginLeft':-230,
'marginTop':-230
},{duration: 500, complete:  function() { showlogins(wclick); } });
return false;
})

$('#login_layer').click(function() {
$(this).fadeOut();
$('#login_splash').animate({
'width': 1,
'height': 1,
'marginLeft':0,
'marginTop':0
}).hide();
$('#user_login, #user_register, #log_switch').hide()
});

$('.lss, .lsr').click(function() {
var wclick = $(this).attr('data-item-show');
showlogins(wclick)
})

function showlogins(wclick) {
$('#log_switch').show()
if (wclick == 'login_f') {
var slpos = $('.lss');
$('#user_login').fadeIn();
$('#user_register').fadeOut();
} else if (wclick == 'reg_f') {
var slpos = $('.lsr');
$('#user_register').fadeIn();
$('#user_login').fadeOut();
}
var lrlft = slpos.position();
var lrwidth = slpos.innerWidth();
$('.lsslider').animate({
'width':lrwidth,
'marginLeft':lrlft.left
},{complete:function() {$('.ent_t').siblings().removeClass('lr_act'); slpos.addClass('lr_act');}});
}

$(".logi_p").on('focus', 'input',
function(e)
{
	var clicked = $(e.target),
		clickedId = clicked.attr("id");
	

	if(clickedId=="loginEnterToSite" || clickedId=="loginEnter")
	{
		clicked.prev().text('').hide();
	}
	
	/*
		если поле пароль получило фокус, удаляем текст в label для пароль
	*/
	else if(clickedId=="passwordEnterToSite" || clickedId=="passwordEnter")
	{
		clicked.prev().text('').hide();
	}

});

$(".logi_p").on('blur', 'input',
function(e)
{	
	var clicked = $(e.target),
		clickedId = clicked.attr("id");
		

	/*
		если ушли из поля логин и его значение пусто, добавляем текст в label для логин
	*/
	if(clickedId=="loginEnterToSite" || clickedId=="loginEnter")
	{
		if(clicked.val()=='') clicked.prev().text('E-mail').show();
	}
	/*
		если ушли из поля пароль и его значение пусто, добавляем текст в label для пароль
	*/
	else if(clickedId=="passwordEnterToSite" || clickedId=="passwordEnter")
	{
		if(clicked.val()=='')
		{
			clicked.prev().text('Пароль').show();
		}
	}

});

$('#site_lf').submit(function(){
var login = $('#loginEnter').val()
var passw = $('#passwordEnter').val()
$('#log_error_l div').fadeOut();
$.getJSON("/callback/authcheck",
  {
    login: login,
	password: passw
  }, 
  function(data) {
  if (data.Status == 'OK') {
  document.location.reload(false)
  } else if (data.Status == 'FAILED') {
  $('#log_error_l div').fadeIn();
  $('#log_error_l div').text('Неверное имя пользователя или пароль');
  
  }

  })

return false;
});

$('#an_se_r, #ls').on('click', '.gren_b, .red_b', function() {
if ($(this).attr('class') == 'gren_b') {
var action = 'add_to_basket'
} else if ($(this).attr('class') == 'red_b') {
var action = 'del_from_basket'
}
var an_list = $(this).closest('.an_list');
var id = an_list.attr('data-item-id');
var type = an_list.attr('data-type');
var _this = $(this);
$(an_list).css({'background-image':'url(\'/img/ajax.gif\')'})

var post = {};
if (type == 'test') post.cid = id
if (type == 'diag') post.did = id

$.post("/callback/"+action, post, function(data) {
   if (action == 'add_to_basket') {
  if (data.Status == '0') {
  _this.replaceWith('<a class="yellow_b incart" href="/labs/"><span class="yb_r"><span class="yb_c">Где сдать?</span></span></a>');
  //$('<span class="red_b"><span class="gb_r"><span class="gb_c">Удалить</span></span></span>').insertAfter(_this)
  an_list.addClass("cart_t");
  var _n = data.Count
  refresh_top_cart(_n, data.Price, data.Currency)
  }
  } else if (action == 'del_from_basket') {
  if (data.Status == '0') {
  _this.prev().removeClass('incart').html('<span class="gb_r"><span class="gb_c">Выбрать</span></span>').show()
  an_list.removeClass("cart_t");
  _this.remove();
  var _n = data.Count
	refresh_top_cart(_n, data.Price, data.Currency)
  }
  }
  $(an_list).css({'background-image':'none'})
}, "json").error(function() { 
  alert("Ошибка сервера"); 
  $(an_list).css({'background-image':'none'})
  });
});

$('.test_right').on('click', '.gren_b, .red_b', function() {
if ($(this).attr('class') == 'gren_b') {
var action = 'add_to_basket';
if ($(this).attr('data-oneselect') == '1') {
var slib =  $(this).closest('.slider_p').find('.panel_tp');
}
} else if ($(this).attr('class') == 'red_b') {
var action = 'del_from_basket'
}
var panel_id = $(this).closest('.panel_id');
var id = panel_id.attr('data-item-id');
var _this = $(this);

$.post("/callback/"+action, {pid: id}, function(data) {
  if (action == 'add_to_basket') {
  if (data.Status == '0') {
 var _n = data.Count
  refresh_top_cart(_n, data.Price, data.Currency)
  if (slib) {
	slib.removeClass('cart_t')
	slib.find('.yellow_b').replaceWith('<span class="gren_b" data-oneselect="1"><span class="gb_r"><span class="gb_c">Выбрать</span></span></span>')
	}
	_this.replaceWith('<a class="yellow_b p_incart" href="/labs/"><span class="yb_r"><span class="yb_c">Где сдать?</span></span></a>');
	//_this.addClass("incart");
	//$('<span class="red_b"><span class="gb_r"><span class="gb_c">Удалить</span></span></span>').insertAfter(_this)
	panel_id.addClass("cart_t");
  }
  } else if (action == 'del_from_basket') {
  if (data.Status == '0') {
  _this.prev().removeClass('incart').html('<span class="gb_r"><span class="gb_c">Выбрать</span></span>').show()
  panel_id.removeClass("cart_t");
  _this.remove();
  var _n = data.Count
  refresh_top_cart(_n, data.Price, data.Currency)
  }
  }
}, "json").error(function() { 
  alert("Ошибка сервера"); 
  $(an_list).css({'background-image':'none'})
  });
})

$('.sel_lab_s').hover(function(){
$('.top_arrows').addClass('ta_second_step')
$(this).addClass('tactive')
}, function(){
$('.top_arrows').removeClass('ta_second_step')
$(this).removeClass('tactive')
})

$('.sel_order_s').hover(function(){
$('.top_arrows').addClass('ta_third_step')
$(this).addClass('tactive')
$('.sel_lab_s').addClass('tactive')
}, function(){
$('.top_arrows').removeClass('ta_third_step')
$(this).removeClass('tactive')
$('.sel_lab_s').removeClass('tactive')
})

$('#open_pdf').click(function() {
$('.pdf_open').show()
return false;
})

$('.get_pdf_double').click(function() {
$('.pdf_open').hide()
})

$('.sel_lab_s a#go_to_labs').click(function(e) {
e.preventDefault()
var href = $(this).attr('href')
var count = $(this).attr('data-status')
var err = $('.stop_analises')
if (typeof timeout != 'undefined') {
clearTimeout(timer);
}

	if (count == 0) {
	show_warning(err)
	} else {
	window.location = href;
	}

var oerr = $('.stop_cart')
hide_warning(oerr)
})

$('.sel_order_s').click(function() {
if (typeof timeout != 'undefined') {
clearTimeout(timer);
}
var val = $('#u_id').val()
var err = $('.stop_cart')
var oerr = $('.stop_analises')
hide_warning(oerr)
if (val == "" || typeof val == 'undefined') {
show_warning(err)
} else {
$('#submit_order').submit()
}
})

$('.hlmain').click(function() {
$(this).next('.research_list').slideToggle();
$(this).find('i').toggleClass('merg_icon_minus');
})

$('.test_right').on("hover", ".cart_t", function(e) {
if (e.type == "mouseenter") {
    $('.incart', this).hide(); 
	$('.red_b', this).show();
    }
    else { // mouseleave
    $('.incart', this).show(); 
	$('.red_b', this).hide();
    }
});

$('.switchers').children().hide()
$('.switchers').children(':first').show()

$('.test_right').on("hover", ".panel_tp, .add_t_block", function(e) {
if (e.type == "mouseenter") {
    $('.p_add_c, .po_add_c', this).fadeIn();
    }
    else { // mouseleave
    $('.p_add_c, .po_add_c', this).fadeOut();
    }
});


$('body').on('click', 'label.sbi', function() {
var input = $('input', this);
var inp_type = input.attr('type');
var inp_name =  input.attr('name');
if (inp_type == 'radio') {
var labels = $('input[name="'+inp_name+'"]').closest('label');
labels.removeClass('checkedinp');
$(this).addClass('checkedinp');

}



})


$('.search_analiz').on('click', '.more_results', function() {
var item_c = $(this).attr('data-item-count');
var c_page = $(this).attr('data-item-page');
var quer = $(this).attr('data-item-quer');
var type = $(this).attr('data-where');

if (type == 'test') { url = 'collection'; a_href = 'tests' }
if (type == 'diag') { url = 'diagnostic'; a_href = 'diagnostic' }

_this = $(this);
$('.more_results #a_loader').show();
$('.more_results #sm_sp').hide();
$.getJSON("/"+url+"/search",
  {
    term: quer,
	page: c_page
  }, 
  function(data) {
    $.each(data, function(i,list){
		if (list.inbasket == 0) {
		var inbasket = '<span class="gren_b" onclick="yaCounter17144653.reachGoal(\'basket\'); _gaq.push([\'_trackEvent\', \'Actions\', \'add_to_cart\', \'\']); return true;"><span class="gb_r"><span class="gb_c">Выбрать</span></span></span>';
		var cclass = '';
		} else if (list.inbasket == 1) {
		var cclass = 'cart_t'
		var inbasket = '<a class="yellow_b incart" href="/labs/"><span class="yb_r"><span class="yb_c">Где сдать?</span></span></a>';
		}
       $('<div class="an_list '+cclass+'" data-type="'+type+'" data-item-id="'+list.id+'"><div class="ico_link"><i class="aico"></i><a href="/'+a_href+'/id/'+list.id+'/" title="'+list.value+'">'+list.value+'</a><i class="eas"></i></div>'+inbasket+'<div class="clear"></div></div>').appendTo('#an_se_r');
    });	
	c_page = parseFloat(c_page)+1;
	_this.attr('data-item-page', c_page);
	if ($('.an_list').size() >= item_c) {
	$('.more_results').hide()
	$('.search_end').show()
	}
	$('.more_results #a_loader').hide();
	$('.more_results #sm_sp').show();
	odd_lines();

  })


})


$('.an_tr').hover(function() {
$('.red_b', this).show()

}, function(){
$('.red_b', this).hide()

});

$('.an_a_p .red_b').click(function() {
var id = $(this).attr('data-id');
var _this = $(this)
var an_tr = $(_this).closest('.an_tr')
var post = {}
var type = an_tr.attr('data-type')

an_tr.css({'background-image':'url(\'/img/ajax.gif\')'})

if (type == 'test') post.cid = id
if (type == 'diag') post.did = id

$.post("/callback/del_from_basket", post, function(data) {
  if (data.Status == 0) {
  var _n = data.Count
	refresh_top_cart(_n, data.Price, data.Currency)
  $(_this).closest('.an_tr').fadeOut()
  $('.rsu').html('<b>'+Math.round(data.Price)+'</b>')
  $.ajax({
  url: "/cart/welcome?type=ajax",
  dataType: 'json'
}).done(function ( data ) {
	$('#c_coll').text(data.collection)
	$('#c_diag').text(data.diagnostic)
  })
  if (data.Count_collection == 0) {
  $('#test_cart').fadeOut()
  }
  
  if (data.Count_diagnostic == 0) {
  $('#diag_cart').fadeOut()
  $('.sep').fadeOut()
  }
 
  if (data.Count == 0) {
  cart_empty()
  }
  }

  $(_this).closest('.an_tr').css({'background-image':'none'})
}, "json").error(function() { 
  alert("Ошибка сервера"); 
  $(an_list).css({'background-image':'none'})
  });
})



$('#close_mpp').click(function(){
$('.change_dir').css({'left':'-100000px'});
});

$('.content').on('click', '.dirr_a, #change_loc', function() {
var offset = $('.dirr_a').offset();
var position = $('.swith_dir').position();
var left = offset.left - 363;
var top = offset.top - 8

if (left < 60) left = 60;

$('.change_dir').show();
$('.change_dir').css({'left':left+'px','top':top+'px'});
$('html, body').animate({scrollTop:0}, 'slow');
})

$('#geo_adress').on('keyup', function(e) {
var quer = $(this).val();

if ($('.geo_a_list').size() > 0) {
switch (e.keyCode) {
                    case 38: top_down($('#geo_results'), 'up'); return false; break;
                    case 40: top_down($('#geo_results'), 'down'); return false; break;
					case 13: set_new_location(); return false; break;
                }
	}
if (quer.length >= 5) {
//quer = encodeURIComponent(quer);
$('#geo_results').empty()
$.getJSON("//geocode-maps.yandex.ru/1.x/?callback=?",
  {
	format: 'json',
    geocode:quer,
	results: 5
  }, 
  function(data) {
  $('#geo_results').empty()
  $.each(data.response.GeoObjectCollection.featureMember, function(i,item){
			
			$('<div class="geo_a_list" data-coord="'+item.GeoObject.Point.pos+'">'+item.GeoObject.metaDataProperty.GeocoderMetaData.AddressDetails.Country.AddressLine+'</div>').appendTo('#geo_results');
    });
 }).error(function(jqXHR, textStatus, errorThrown) { alert(errorThrown); })
} else {
$('#geo_results').empty()
}
})

$('#geo_results').on('click', '.geo_a_list', function() {
var positions = $(this).attr('data-coord');
positions = positions.split(' ')
positions = positions.reverse()
$('#geo_adress').val($(this).text())
get_center(positions);
$('#geo_results').empty()
})



$('.button_dirr_a').click(function() {
geo_ip('1')
})

$('.button_dirr_s').click(function() {
	set_new_location()
})

function validateEmail(email) {  
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
}


$('.login_s').click(function() {
var email = $('#rEmail').val()
 if (validateEmail(email)) {
    $.ajax({
		type: "POST",
		url: "/auth/register",
		data: { email: email, ajax: 1 }
		}).done(function( data ) {
		if (data.status == "Error" || data.status == "Invalid") {
		$('#log_error_r div').text(data.text);
		$('#log_error_r div').fadeIn();
		$('#rEmail').closest('div').css({'border':'1px solid #ff0033'})
		} else if (data.status == "Ok") {
		$('#user_register').children().hide()
		$('#r_m_tt').html('<img class="m_s_img" src="/img/secret_mail_email_envelope.png" />Регистрация прошла успешно. На указанный вами Email выслано письмо с дальнейшими инструкциями')
		$('#r_m_tt').fadeIn();
		_gaq.push(['_trackEvent', 'Actions', 'register_mail', ''])
		}

		});
  } else {
	$('#log_error_r div').text('Неверный Email');
	$('#log_error_r div').fadeIn();
	$('#rEmail').closest('div').css({'border':'1px solid #ff0033'})
  }
})

$('#rEmail').on('keyup', function() {
$('#rEmail').closest('div').css({'border':'1px solid #cccccc'})
$('#log_error_r div').text('');
$('#log_error_r div').fadeOut();
})

$('.save_button').click(function() {
$('#user_form').submit();
});

$('.reorder').click(function() {
var id = $(this).attr('data-id')
_this = $(this)

$.post("/callback/add_to_basket", {oid: id}, function(data) {
	var _n = data.Count
		refresh_top_cart(_n, data.Price, data.Currency)
	if (data.Status == 0) {
	$(_this).removeClass('gren_b')
	$(_this).html('Добавлено в корзину')
	} else if (data.Status == 1) {
	$(_this).removeClass('gren_b')
	$(_this).html('Все анализы есть в корзине')
	}
}, "json").error(function() { 
  alert("Ошибка сервера"); 
  $(an_list).css({'background-image':'none'})
  });


});


$('.analiz_content').on("hover", ".price_a_p", function(e) {
if (e.type == "mouseenter") {
    $('.bincart').hide()
	$('.bred_b').css({'display':'block'})
    }
    else { // mouseleave
	$('.bincart').show()
	$('.bred_b').hide()
    }
});


$('.price_a_p').on('click', '.bgb, .bred_b', function() {
if ($(this).attr('data-action') == 'add_cart_in') {
var action = 'add_to_basket';
} else if ($(this).attr('data-action') == 'del_cart_in') {
var action = 'del_from_basket'
}

var type = $(this).closest('.price_a_p').attr('data-type')

var id = $(this).closest('.price_a_p').attr('data-id')
var _this = $(this);

var postData = {};
if (type == 'test') {
postData['cid'] = id;
} else if (type == 'panel') {
postData['pid'] = id;
} else if (type == 'diag') {
postData['did'] = id;
}

$.post("/callback/"+action, postData, function(data) {
  if (action == 'add_to_basket') {
  if (data.Status == '0') {
   var _n = data.Count
	refresh_top_cart(_n, data.Price, data.Currency)
	_this.html("В корзине");
	_this.addClass("bincart");
	$('<span data-action="del_cart_in" class="bred_b"><span class="bgb_r"><span class="bgb_c">Удалить</span></span></span><a class="go_to_fuckin_cart" href="/labs/">Где сдать?</a>').insertAfter(_this)
  }
  } else if (action == 'del_from_basket') {
  if (data.Status == '0') {
  _this.prev().removeClass('bincart').html('<span class="bgb_r"><span class="bgb_c">Выбрать</span></span>').show()
  _this.next().remove();
  _this.remove();
   var _n = data.Count
	refresh_top_cart(_n, data.Price, data.Currency)
  }
  }
}, "json").error(function() { 
  alert("Ошибка сервера"); 
  $(an_list).css({'background-image':'none'})
  });

})

$('.remove_a').click(function() {
var id = $(this).attr('data-id')
var type = $(this).attr('data-type')
var _this = $(this);
var postData = {};
if (type == 'test') {
postData['cid'] = id;
} else if (type == 'diag') {
postData['did'] = id;
}

$.post("/callback/del_from_basket", postData, function(data) {
   
 if (data.Status == '0') {
   var stop = 0;
   var _n = data.Count
   refresh_top_cart(_n, data.Price, data.Currency)
   _this.closest('.entry_a').fadeOut().remove();
   var fprice = $('.final_c em b').text();
   var cprice = _this.closest('.entry_a').find('.e_pr b').text();
   $('.final_c em b').text(fprice - cprice)
   
   $('.entry_a').each(function(i) {
   if ($(this).hasClass("red_n")) {stop = 1;}
   })
   
   if (data.Count_collection == 0) {
   $('#cart_analises').fadeOut()
   $('#ic_id').val('')
   }
   
   if (data.Count_diagnostic == 0) {
   $('#cart_diag').fadeOut()
   $('#id_id').val('')
   }
   
   if (data.Count == 0) {
   $('#cart_body').hide();
   $('#cart_empty').fadeIn();
   }
   
   if (stop == 0) {
   $('.bgb_njs').removeClass('bdisable')
   $('.bgb_njs').attr('data-stop', 0)
   $('.c_error').slideUp();
   }
 }
})
});

$('.ann_left').on('click', '.bgb_njs', function() {
var s = $(this).attr('data-stop')
if (s == 1) {
$('.c_error').slideDown();
} else if (s == 0) {
$('#submit_order').submit()
}

})


$('#by_long, #YMapsID').on('click', '.ltb', function() {
var l_id = $(this).attr('data-lid')
$('#u_id').val(l_id);
$('[data-lid="'+l_id+'"]').hide()
$('<div class="u_sell_lab">Выбрано</div>').insertAfter('[data-lid="'+l_id+'"]')

setTimeout(function(){$('#submit_order').submit()}, 400)
})

$('.sort_b_price').click(function(){
$('.s_arr_s', this).text('▼')
$('.sort_b_long .s_arr_s').text('▲')
price_sort()
})
$('.sort_b_long').click(function(){
$('.s_arr_s', this).text('▼')
$('.sort_b_price .s_arr_s').text('▲')
dist_sort()
})


$('#by_long').on('click', '.more_labs', function() {
var vis = $('#by_long table tr:visible').size();
var vall = $('#by_long table tr').size();
if (vall > vis) {
$('#by_long table tr').slice(0,vis+14).show()
} else {
$('.more_labs').hide()
$('.search_end').show()
}
slide_selector()
})

$('#by_long').on('click', '.show_puncts', function() {
var n = $(this).attr('data-punct-n');
var action = $(this).attr('data-action');
if (action == 'show') {
$('.parrent_tr.lab_id_'+n).show()
$(this).text('Скрыть')
 $(this).attr('data-action','hide');
} else if (action == 'hide') {
$('.parrent_tr.lab_id_'+n).slice(3).hide()
$(this).text('Показать все приемные пункты')
 $(this).attr('data-action','show');
}
slide_selector()

})

$('.panel_ui').hover(function(){$('.dell_panel_min', this).css({'visibility':'visible'})}, function(){$('.dell_panel_min', this).css({'visibility':'hidden'})})

$('.dell_panel_min').click(function(){
var id = $(this).attr('data-pid');
var name = $(this).prev().text()
generate_del_popup(id,name,false,false)
})

$('body').on('click', '.cancel_p_del', function(){
$('.pid_d_pup').fadeOut(function () {$('.pid_d_pup').remove()})
})

$('#analises, #reserch').click(function() {
var w = $(this).attr('id');
$('#analises, #reserch').removeClass('sel_a');
$('#analises, #reserch').addClass('sel_n');
$(this).removeClass('sel_n');
$(this).addClass('sel_a');

if (w == 'reserch') {
$('#main_s').attr('data-type', 'diag');
$('.vitr_searchf').addClass('diag_s')
$('.form_search').addClass('dfs')
$('.input_submit').addClass('gss')
$('#ex_test').hide()
$('#ex_diag').show()
$('#mform').attr('action', '/diagnostic/')
} else if (w == 'analises') {
$('#main_s').attr('data-type', 'tests');
$('.vitr_searchf').removeClass('diag_s')
$('.form_search').removeClass('dfs')
$('.input_submit').removeClass('gss')
$('#ex_diag').hide()
$('#ex_test').show()
$('#mform').attr('action', '/tests/')
}

})

$('#by_long').on('hover', '.urgently, .price_home', function(e) {
var text = $(this).attr('data-text')
var html = '<div class="hint_main"><div class="hint_top"></div><div class="hint_body"><div class="hint_content">'+text+'</div></div><div class="hint_bottom"></div></div>'
	if (e.type == "mouseenter") {
    $(this).append(html);
	var height = $(".hint_main").innerHeight();
	height = height + 13;
	$(".hint_main").css({"top":"-"+height+"px"})

	$(".hint_main").animate({
	"opacity": "1",
	"top":"-"+(height-16)+"px"
	},300)
    }
    else { // mouseleave
    $(".hint_main").remove()
    }
	
	})


$('body').on('click', '.confirm_del_b, .confirm_clear_b', function(){
var id = $(this).attr('data-pid');
if (id > 0) {
$.post("/callback/del_from_basket", {pid: id}, function(data) {

	var _n = data.Count
	refresh_top_cart(_n, data.Price, data.Currency)
  $('.rsu').html('<b>'+Math.round(data.Price)+'</b>')
  $.ajax({
  url: "/cart/welcome?type=ajax",
  dataType: 'json'
}).done(function ( data ) {
	$('.labs_inys a').text(data.collection)
  })


var cpanel =  $('.panel_ui[data-pid="'+id+'"]')
var panel_cell = cpanel.closest('.panels_cell');
cpanel.fadeOut(function () {
cpanel.remove()
panel_cell.each(function(i) {
var txt = $.trim($(this).text())
if (txt == "") {
$(this).closest('.an_tr').fadeOut();
}
})
});

if (data.Count == 0) {
  cart_empty()  
  }
}, "json")
} else {
var where = $(this).attr('data-where');
$.ajax({
  url: "/callback/empty_basket",
  type: "POST",
  data: {where: where},
  dataType: 'json'
}).done(function ( data ) {
    
	
	if (where == 'collection') {
  $('#test_cart').fadeOut()
  }
  
  if (where == 'diagnostic') {
  $('#diag_cart').fadeOut()
  $('.sep').fadeOut()
  
  }
  
  if (data.Status == 0) cart_empty()
	
  })
}

$('.pid_d_pup').fadeOut(function () {$('.pid_d_pup').remove()})
})


$('#by_long').on('click', 'tr:not(#menu_tr, .lab_scope)', function() {
$('td._select_td').removeClass('_clicked')
var lab_id = $('.ltb', this).attr('data-lid')
//$('.sel_lab').fadeIn();
odd_lines_lab()
var tr_id = $(this)
tr_id.css({'background-color':'#99ff99'})
$('td._select_td', tr_id).addClass('_clicked')
tr_id.siblings().find('.ltb').show()
tr_id.siblings().find('.u_sell_lab').remove()
center_map(lab_id)
})

$('.anan_tabs div:not(.crumbs)').click(function() {
var _class = $(this).attr('id');
$('.an_tab').removeClass('a_act');
$(this).addClass('a_act');
$('#pan_swither').children().hide();
$('#pan_swither').find('div.'+_class).show();

})

$('.blood_switcher span').click(function() {
var type = $(this).attr('data-btype');

$('.switchers').children().hide()
$('.switchers').children('#'+type).show()
$('.blood_switcher').children('span').removeClass('active');
$(this).addClass('active');
});

$('#no_r_send_m').click(function() {
$('.new_user').slideToggle()
return false
})

$('.clean_cart').click(function() {
var where = $(this).attr('data-where');
generate_del_popup(false,false,1,where);
})
});

function slide_panels (ti) {
var soffset = $('.panel_item').innerWidth();
var curr0ff = ti * soffset;

$('.slide_div').animate({
'left':'-'+curr0ff
}, 1000);

$('.test_control ul li:eq('+ti+')').siblings().removeClass('act_li');
$('.test_control ul li:eq('+ti+')').addClass('act_li');

}

function rus_numeric(n, str_1, str_2, str_3, str_4) {
	var nmod10 = n%10
    var nmod100 = n%100
    var str   
    if (!n || n == 0)
    {
              str = str_1;
			  $('#curr').html('')
    } else if ( (n == 1) || (nmod10 == 1 && nmod100 != 11))
    {
    		str  =  str_2;
    
    } else if ( (nmod10 > 1) && (nmod10 < 5) && (nmod100 != 12 && nmod100 != 13 && nmod100 != 14))
    {
              str = str_3;
    } else
    {
              str = str_4;
    }
    return str;
}

function show_warning(err) {
err.css({"display":"block"})
err.animate({
marginTop:"10px",
"opacity":"1"
})

timer = setTimeout(function(){
timeout = 1;
hide_warning(err)
}, 3000)
}

function hide_warning(err) {
err.animate({
marginTop:"40px",
"opacity":"0",
"display":"none"
},500); 
}

function refresh_top_cart(_n, dprice, dcurr) {
  var price, curr
  curr = get_curr(dcurr)
  if (curr !== false && dprice != 0) $('#curr').html(curr), $('#profit_c').html(curr)
  if (dprice == 0) $('#curr').html('')
  if (_n == 0 || dprice == 0) {price = ''} else { price = ', ~ '+Math.round(dprice)}
  var c_txt = rus_numeric(_n, 'Не выбрано', _n+' исследование', _n+' исследования', _n+' исследований' )
  $('.cart_txt b').html(c_txt+price)
}

function get_curr(c) {
var curr = {'RUR':'<ins>i</ins>', 'KZT':'<var>a</var>', 'UAH':'₴', 'BYR':'Br'}
if (c === null) {
return false
} else {
return curr[c]
}
}

function set_new_location () {
var quer = $('#geo_adress').val();
$('#geo_results').empty()
if (quer != '') {
$.getJSON("https://geocode-maps.yandex.ru/1.x/?callback=?",
  {
	format: 'json',
    geocode: quer,
	results: 1
  }, 
  function(data) {
  if (data.response.GeoObjectCollection.metaDataProperty.GeocoderResponseMetaData.found > 0) {
	$('.map_i_dirr').css({'background-image':'url(/img/pl.gif)'});
  $.each(data.response.GeoObjectCollection.featureMember, function(i,item){
				$('#geo_adress').val(item.GeoObject.metaDataProperty.GeocoderMetaData.AddressDetails.Country.AddressLine);
				
				var positions = item.GeoObject.Point.pos.split(' ')
				positions = positions.reverse()
				get_center(positions)

				$.ajax({
					type: "POST",
					url: "/user/set_address",
					data: { position: item.GeoObject.Point.pos, addr: item.GeoObject.metaDataProperty.GeocoderMetaData.AddressDetails.Country.AddressLine }
				}).done(function( msg ) {
				setTimeout(function() {
				$('.change_dir').css({'left':'-100000px'});
				$('.n_adress').text(item.GeoObject.metaDataProperty.GeocoderMetaData.AddressDetails.Country.AddressLine);
				$('.map_i_dirr').css({'background-image':'none'});
				document.location.reload(false)
				}, 500)
				});
  
    });
	} else {
	alert('Не верный запрос')
	}
 })
 } else {
 alert('Пустой запрос')
 }
}

function generate_del_popup(id,name,clear_cart,where_clean) {
$('.pid_d_pup').remove()
$('body').prepend('<div class="pid_d_pup"></div>');
if (clear_cart == 1 && where_clean == 'all') {
$('.pid_d_pup').append('<div class="confirm_del">Вы уверены, что хотите очистить корзину?<br/>'+
'<span class="bgb confirm_clear_b" data-where="'+where_clean+'"><span class="bgb_r"><span class="bgb_c">Очистить</span></span></span> <span class="bgb_b cancel_p_del"><span class="bgb_r_b"><span class="bgb_c_b">отмена</span></span></span>'+
'<div class="clear"></div></div>')
} else if (where_clean == 'diagnostic') {
$('.pid_d_pup').append('<div class="confirm_del">Вы уверены, что хотите удалить все диагностические исследования из корзины?<br/>'+
'<span class="bgb confirm_clear_b" data-where="'+where_clean+'"><span class="bgb_r"><span class="bgb_c">Очистить</span></span></span> <span class="bgb_b cancel_p_del"><span class="bgb_r_b"><span class="bgb_c_b">отмена</span></span></span>'+
'<div class="clear"></div></div>')
} else if (where_clean == 'collection') {
$('.pid_d_pup').append('<div class="confirm_del">Вы уверены, что хотите удалить все анализы из корзины?<br/>'+
'<span class="bgb confirm_clear_b" data-where="'+where_clean+'"><span class="bgb_r"><span class="bgb_c">Очистить</span></span></span> <span class="bgb_b cancel_p_del"><span class="bgb_r_b"><span class="bgb_c_b">отмена</span></span></span>'+
'<div class="clear"></div></div>')
} else {
$('.pid_d_pup').append('<div class="confirm_del">Удалить панель:<br/><span class="d_p_title"><span class="quote">«</span><a href="/panels/id/'+id+'/">'+name+'</a>»</span><br/>из корзины?<br/>'+
'<span data-pid="'+id+'" class="bgb confirm_del_b"><span class="bgb_r"><span class="bgb_c">Удалить</span></span></span> <span class="bgb_b cancel_p_del"><span class="bgb_r_b"><span class="bgb_c_b">отмена</span></span></span>'+
'<div class="clear"></div></div>')
}
var height = $('.confirm_del').innerHeight()
$('.pid_d_pup').animate({
height: height+'px'
}, {
	complete: function() {
      $('.confirm_del').css({'visibility':'visible'})
    }
})
}

function cart_empty() {
$('#summ').hide()
$('#curr').html('')
  $('.bot_select').fadeOut()
  $('.cart_th').fadeOut()
  $('.labs_inys').fadeOut()
  $('.an_tr').fadeOut()
  $('.cart_txt b').html('Не выбрано')
  $('.clean_cart').fadeOut()
	setTimeout(function() {
  $('.car_b_i').prepend('<div class="cart_empty" style="display:none">Корзина пуста.<br/><br/><small><small>Воспользуйтесь <a href="/tests/">поиском</a>, чтобы выбрать анализы.</small></small></div>')
  $('.cart_empty').fadeIn()
  
  }, 400)
}
var kTriggered = 0;
function top_down(container, direct) {
if (direct == 'up') kTriggered--;
if (direct == 'down') kTriggered++;
var pos = container.find('.geo_a_list')
var _n = pos.size()
if (kTriggered > _n) kTriggered = 1
if (kTriggered < 1) kTriggered = _n

var curr_item = pos.eq(kTriggered-1)
curr_item.siblings().removeClass("geo_a_hovered");
curr_item.addClass("geo_a_hovered");
var positions = curr_item.attr('data-coord');
positions = positions.split(' ')
positions = positions.reverse()
$('#geo_adress').val(curr_item.text())
}

function init_map(position) {

puMap = new ymaps.Map("pu_map", {
			center: position,
			zoom: 14,
			behaviors: ["default","scrollZoom"]
			//type: 'yandex#publicMap'
});
medCollection2 = new ymaps.GeoObjectCollection({});
if ($("#YMapsID").length > 0) {
myMap = new ymaps.Map("YMapsID", {
			center: position,
			zoom: 14,
			behaviors: ["default","scrollZoom"]
			//type: 'yandex#publicMap'
});

myMap.controls.add('zoomControl', { top: 5, left: 5, noTips:true })
myMap.controls.add('typeSelector');

myMap.geoObjects.add(medCollection2);

myMap.geoObjects.events.add(['click', 'center_balloon'], function (e) {
    var geoObject = e.get('target');
    var projection = myMap.options.get('projection');
    var position = geoObject.geometry.getCoordinates();
	var globalPixel = projection.toGlobalPixels(position, myMap.getZoom())
	myMap.panTo(projection.fromGlobalPixels([globalPixel[0], globalPixel[1] - 100], myMap.getZoom()),{delay: 0});
    //myMap.setGlobalPixelCenter([oldGlobalPixelCenter[0] + 100, oldGlobalPixelCenter[1] + 100]);
});



labs_collection = new ymaps.GeoObjectCollection();
myMap.geoObjects.add(labs_collection);
add_labs()
}
medCollection = new ymaps.GeoObjectCollection({});

puMap.geoObjects.add(medCollection);
get_center(position)

}



function add_labs() {
labs_collection.removeAll();

if (typeof direct_arr == 'undefined' ) {
if (typeof witout_cart == 'undefined') {
$.getJSON("/callback/maps?on_main=true",{},function(data) {
  labs_to_map(data, 'on_main')
  })
  }
} else {
  labs_to_map(direct_arr, 'on_labs')
}
}

function labs_to_map(data, where) {


 var far
 var myBalloonLayout = ymaps.templateLayoutFactory.createClass(
                '<div class="balloon_am"><div class="balloon_top"></div><div class="balloon_center"><div class="balloon_content">$[properties.balloonContent]$[properties.price]</div></div><div class="balloon_bottom"> $[properties.selectLab] $[properties.closeButton]</div></div>', {
				build: function () {
				this.constructor.superclass.build.call(this);
				this.update();
				},
				update: function(){
				$('.balloon_am').css({'margin-top': ((-1 * $('.balloon_am').innerHeight())+7)+'px'} );
				
				var lid = this.getData().properties.get('lab_id')	
						
						if ($('#u_id').val() == lid) {
							_this = $('.balloon_bottom .ltb')
							_this.hide()
							$('<div class="u_sell_lab">Выбрано</div>').insertAfter(_this)
						}
					}
				});
$.each(data, function(i,lab) {
	if (lab.far == 1) far = true;
 var position = lab.position.split(' ')
 position = position.reverse()


			
				
			var labsProperties = {}, lab_name
			
			labsProperties['closeButton'] = '<div class="close_balloon"><b class="action_close_b" onclick="myMap.balloon.close()">Закрыть</b></div>'
			labsProperties['lab_id'] = lab.id
			if (where == 'on_main') {
			labsProperties['selectLab'] = ''
			labsProperties['price'] = ''
			lab_name = lab.lab
			} else if (where == 'on_labs') {
			labsProperties['selectLab'] = '<div class="select_lab"><span data-lid="'+lab.id+'" class="gren_b ltb"><span class="gb_r"><span class="gb_c">Выбрать</span></span></span></div>'
			labsProperties['price'] = '<div class="balloon_price">Цена: '+ lab.price +' <ins>i</ins></div>'
			lab_name = lab.network
			}
			labsProperties['balloonContent'] = '<div class="an_ballun"><a class="lab_m_h" href="/labs/id/'+lab.id+'">'+lab_name+' ('+lab.name+')</a></div>'
			var pin
			if (lab.have_collection == 1 && lab.have_diagnostic == 0) {
			pin = '/img/pin.png'
			} else if (lab.have_diagnostic == 1 && lab.have_collection == 0) {
			pin = '/img/pin-green.png'
			} else if (lab.have_collection == 1 && lab.have_diagnostic == 1) {
			pin = '/img/pin-mixed.png'
			} else {
			pin = '/img/pin.png'
			}			
			labPlacemark = new ymaps.Placemark(position, 
                    labsProperties
                , {
                    hideIconOnBalloonOpen: true,
                    // Изображение иконки метки
                    iconImageHref: pin,
                    // Размеры изображения иконки
                    iconImageSize: [43, 50],
					iconImageOffset: [-28, -45],
                    balloonLayout: myBalloonLayout,
					balloonShadow: false,
					balloonAutoPan: false
                  
                });
				
	labs_collection.add(labPlacemark);

})
myMap.geoObjects.add(labs_collection);

if (far == true) {
myMap.setBounds(labs_collection.getBounds());
}
}

function geo_ip(_do) {
if(navigator.geolocation==undefined) geo_supp = false;
else 
geo_supp = true;

if (geo_supp === true) {
var out
function initiate_geolocation() {  
navigator.geolocation.getCurrentPosition(handle_geolocation_query);
$('#load_ico').css({'background-position':'top right'});

function animate(c) {

if (c == undefined || c > 4) {c = 0}
var o = c * 21
$('#load_ico').css({'background-position': 'right  -'+ o +'px'});
c = c + 1; 
out = setTimeout(function(){animate(c)}, 500)
}
animate(1)
}
  
function handle_geolocation_query(position){  
get_center([position.coords.latitude, position.coords.longitude]);
if (_do == '1') {
reverse_coord([position.coords.latitude, position.coords.longitude])
}
clearTimeout(out)
$('#load_ico').css({'background-position':'top left'});
}
initiate_geolocation()
} else {
//error_f('К сожалению ваш браузер не поддерживает геолокацию');
}
}

function get_center(positions) {

medCollection.removeAll();
medCollection2.removeAll();
myPlacemark = new ymaps.Placemark(positions, {
                    balloonContent: 'Вы здесь!'
                }, {
                    iconImageHref: '/img/you.png', // картинка иконки
                    iconImageSize: [43, 50], // размеры картинки
                    iconImageOffset: [-28, -45], // смещение картинки
					zIndex: '701'
                }
			);
myPlacemark2 = new ymaps.Placemark(positions, {
                    balloonContent: 'Вы здесь!'
                }, {
                    iconImageHref: '/img/you.png', // картинка иконки
                    iconImageSize: [43, 50], // размеры картинки
                    iconImageOffset: [-28, -45], // смещение картинки
					zIndex: '701'
                }
			);
medCollection.add(myPlacemark);
medCollection2.add(myPlacemark2);

puMap.setCenter(positions, 14);
if ($("#YMapsID").length > 0) {
myMap.setCenter(positions, 14);
}
}

function reverse_coord(positions) {
ymaps.geocode(positions).then(function (res) {
var names = [];
res.geoObjects.each(function (obj) {
    names.push(obj.properties.get('name'));
});
$('#geo_adress').val(names.reverse().splice(1, 100).join(', '))
})

}

function center_map(labid){
labs_collection.each(function (item) {
if (item.properties.get('lab_id') == labid) {
item.events.fire('center_balloon')
item.balloon.open();
}
})
}
