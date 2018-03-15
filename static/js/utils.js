//Browser check 
var mybrowser = BrowserObj();
function BrowserObj(){ 
	this.ver=navigator.appVersion;
	this.agent=navigator.userAgent;
	this.dom=document.getElementById?1:0;
	this.opera5=(navigator.userAgent.indexOf("Opera")>-1 && document.getElementById)?1:0;
	this.ie5=(this.ver.indexOf("MSIE 5")>-1 && this.dom && !this.opera5)?1:0;
	this.ie6=(this.ver.indexOf("MSIE 6")>-1 && this.dom && !this.opera5)?1:0;
	this.ie4=(document.all && !this.dom && !this.opera5)?1:0;
	this.ie=this.ie4||this.ie5||this.ie6;
	this.mac=this.agent.indexOf("Mac")>-1;
	this.ns6=(this.dom && parseInt(this.ver) >= 5) ?1:0;
	this.ns4=(document.layers && !this.dom)?1:0;
	this.ns=this.ns6||this.ns4;
	this.bw=(this.ie6 || this.ie5 || this.ie4 || this.ns4 || this.ns6 || this.opera5);
        this.isIeMac=(this.ie && this.mac);
	return this;
}


//Image rollover
function rollPhoto(photosrc, photoname) {
        displayWaitMessage();         
	document.body.style.cursor='wait';
	window.status='please wait...';
	document.photoform.photoname.value=photoname;
	document.images["photoholder"].src=photosrc;	 
	window.status='Photo loaded!';
	document.body.style.cursor='default';	
	hideWaitMessage();
}

function hideWaitMessage() {
    var wait = document.getElementById('waitdiv');
    wait.style.visibility='hidden';
    var waitTxt = document.getElementById('waitTxtdiv');
    waitTxt.style.visibility='hidden';
        
    return true;
}
function displayWaitMessage() {

    this.scrollTo(0,0);

    var wait = document.getElementById('waitdiv') || document.createElement('DIV');
    wait.id = 'waitdiv';
    wait.className = 'waitdiv';
    wait.style.filter = 'alpha(opacity=70)';

    var waitTxt = document.getElementById('waitTxtdiv') || document.createElement('DIV');
    waitTxt.id = 'waitTxtdiv';
    waitTxt.className = 'waitTxtdiv';
    waitTxt.innerHTML = 'Please wait...';

    var b = document.getElementsByTagName('BODY')[0];
    b.appendChild(wait);
    b.appendChild(waitTxt);
    b.style.cursor = "wait";
    b.scroll = "no";

    return true;
}

function recalcDate(field){
   var form = document.adminform;
   eval('form.element_' + field +'.value = form.element_'+field+'_day.value + "/" + form.element_'+field+'_month.value + "/" + form.element_'+field+'_year.value');
}

function sitemapLink(link){
   if (window.opener){
      window.opener.location=link;
   }
   else {
      window.location=link;
   }
}
   
// Define new prototype methods for Array and Node objects
if ( document.all ) {
    Array.prototype.push = function(s) { this[this.length] = s; }

    Array.prototype.splice = function(ind, cnt) {
        if(arguments.length == 0) {
            return ind;
        }
        if (typeof ind != "number") {
            ind = 0;
        }
        if (ind < 0) {
            ind = Math.max(0,this.length + ind);
        }
        if (ind > this.length) {
            if(arguments.length > 2) ind = this.length;
            else return [];
        }
        if (arguments.length < 2) {
            cnt = this.length-ind;
        }
        cnt = (typeof cnt == "number") ? Math.max(0,cnt) : 0;
        removeArray = this.slice(ind,ind+cnt);
        endArray = this.slice(ind+cnt);
        this.length = ind;
        for (var i = 2; i < arguments.length;i++) {
            this[this.length] = arguments[i];
        }

        for (var i = 0; i < endArray.length; i++) {
            this[this.length] = endArray[i];
        }
        return removeArray;
    }
}


if ( ! document.all ) {
    Node.prototype.swapNode = function(node) {
        var nextSibling = this.nextSibling;
        var parentNode = this.parentNode;
        node.parentNode.replaceChild(this, node);
        parentNode.insertBefore(node, nextSibling);
    }
}

