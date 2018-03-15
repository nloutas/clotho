//Date: year, month, day
//var today = new Date(2004,0,27);
var today = new Date();
var thisyear = today.getYear();
if (navigator.appVersion.indexOf("MSIE ") == -1) thisyear += 1900 ;

var days,months;
days = new Array("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday");
months = new Array("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
var displayDate = days[today.getDay()] + ', ' + today.getDate() + ' ' + months[today.getMonth()] + ' ' + thisyear; 

var bottomnav = '<div class="bottom">';
bottomnav += '<h5>&#169;2004 <a href="http://www.loutas.com" class="adminLink">loutas.com</a> '+displayDate+'</h5> ';
bottomnav += '<img border="0" valign="top" src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0!" height="31" width="88" align="center" onclick="self.location=\'http://validator.w3.org/check/referer\'"> &nbsp;';
bottomnav += '<img border="0" valign="top" src="http://jigsaw.w3.org/css-validator/images/vcss" alt="Valid CSS!" height="31" width="88" align="center" onclick="self.location=\'http://jigsaw.w3.org/css-validator/\'"> '; 
bottomnav += '</div>';
document.write(bottomnav);

