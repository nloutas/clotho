
var isDOM=mybrowser.dom;
var isIE=mybrowser.ie;
var isNS=mybrowser.ns;
var isNS4=mybrowser.ns4;
var isIE4=mybrowser.ie4;
var isOp=mybrowser.opera5;
var isDyn=isDOM||isIE||isNS;


function getRef(id, par)
{
 par=!par?document:(par.navigator?par.document:par);
 return (isIE ? par.all[id] :
  (isDOM ? (par.getElementById?par:par.ownerDocument).getElementById(id) :
  (isNS4 ? par.layers[id] : null)));
}

function getSty(id, par)
{
 var r=getRef(id, par);
 return r?(isNS4?r:r.style):null;
}

if (!window.LayerObj) {
   var LayerObj = new Function('id', 'par','this.ref=getRef(id, par); this.sty=getSty(id, par); return this');
}
function getLyr(id, par) { return new LayerObj(id, par) }

function LyrFn(fn, fc) {
 LayerObj.prototype[fn] = new Function('var a=arguments,p=a[0],px=isNS4||isOp?0:"px"; ' + 'with (this) { '+fc+' }');
}

LyrFn('x','if (!isNaN(p)) sty.left=p+px; else return parseInt(sty.left)');
LyrFn('y','if (!isNaN(p)) sty.top=p+px; else return parseInt(sty.top)');
LyrFn('vis','sty.visibility=p');
LyrFn('bgColor','if (isNS4) sty.bgColor=p?p:null; ' +
 'else sty.background=p?p:"transparent"');
LyrFn('bgImage','if (isNS4) sty.background.src=p?p:null; ' +
 'else sty.background=p?"url("+p+")":"transparent"');
LyrFn('clip','if (isNS4) with(sty.clip){left=a[0];top=a[1];right=a[2];bottom=a[3]} ' +
 'else sty.clip="rect("+a[1]+"px "+a[2]+"px "+a[3]+"px "+a[0]+"px)" ');
LyrFn('write','if (isNS4) with (ref.document){write(p);close()} else ref.innerHTML=p');
LyrFn('alpha','var f=ref.filters,d=(p==null); if (f) {' +
 'if (!d&&sty.filter.indexOf("alpha")==-1) sty.filter+=" alpha(opacity="+p+")"; ' +
 'else if (f.length&&f.alpha) with(f.alpha){if(d)enabled=false;else{opacity=p;enabled=true}} }' +
 'else if (isDOM) sty.MozOpacity=d?"":p+"%"');


function setLyr(lVis, docW, par)
{
 if (!setLyr.seq) setLyr.seq=0;
 if (!docW) docW=0;
 var obj = (!par ? (isNS4 ? window : document.body) :
  (!isNS4 && par.navigator ? par.document.body : par));
 var IA='insertAdjacentHTML', AC='appendChild', newID='_js_layer_'+setLyr.seq++;

 if (obj[IA]) obj[IA]('beforeEnd', '<div id="'+newID+'" style="position:absolute"></div>');
 else if (obj[AC])
 {
  var newL=document.createElement('div');
  obj[AC](newL); newL.id=newID; newL.style.position='absolute';
 }
 else if (isNS4)
 {
  var newL=new Layer(docW, obj);
  newID=newL.id;
 }

 var lObj=getLyr(newID, par);
 with (lObj) if (ref) { vis(lVis); x(0); y(0); sty.width=docW+(isNS4?0:'px') }
 return lObj;
}


var CSSmode=document.compatMode;
CSSmode=(CSSmode&&CSSmode.indexOf('CSS')!=-1)||isDOM&&!isIE||isOp?1:0;

if (!window.page) var page = { win: window, minW: 0, minH: 0, MS: isIE&&!isOp,
 db: CSSmode?'documentElement':'body' }

page.winW=function()
 { with (this) return Math.max(minW, MS?win.document[db].clientWidth:win.innerWidth) }
page.winH=function()
 { with (this) return Math.max(minH, MS?win.document[db].clientHeight:win.innerHeight) }

page.scrollX=function()
 { with (this) return MS?win.document[db].scrollLeft:win.pageXOffset }
page.scrollY=function()
 { with (this) return MS?win.document[db].scrollTop:win.pageYOffset }



// *** MOUSE EVENT CONTROL FUNCTIONS ***
// Most of these are passed the relevant 'menu Name' and 'item Number'.
// The 'with (this)' means it uses the properties and functions of the current menu object.
function popOver(mN, iN) { with (this)
{
 // Cancel any pending menu hides from a previous mouseout.
 clearTimeout(hideTimer);
 // Set the 'over' variables to point to this item.
 overM = mN;
 overI = iN;
 // Call the 'onMouseOver' event if it exists, and the item number is 1 or more.
 if (iN && this.onmouseover) onmouseover(mN, iN);


 // Remember what was lit last time, and compute a new hierarchy.
 litOld = litNow;
 litNow = new Array();
 var litM = mN, litI = iN;
 while(1) {
  litNow[litM] = litI;
  // If we've reached the top of the hierarchy, exit loop.
  if (litM == 'root') break;
  // Otherwise repeat with this menu's parent.
  litI = menu[litM][0].parentItem;
  litM = menu[litM][0].parentMenu;
 }

 // If the two arrays are the same, return... no use hiding/lighting otherwise.
 var same = true;
 for (var z in menu) if (litNow[z] != litOld[z]) same = false;
 if (same) return;

 // If this is a different menu, clear another pending show.
 clearTimeout(showTimer);

 // Cycle through menu array, lighting and hiding menus as necessary.
 for (thisM in menu) with (menu[thisM][0]) {
  // Doesn't exist yet? Keep rollin'...
  if (!lyr) continue;

  // The number of this menu's item that is to be lit, undefined if none.
  litI = litNow[thisM];
  oldI = litOld[thisM];

  // If it's lit now and wasn't before, highlight...
  if (litI && (litI != oldI)) changeCol(thisM, litI, true);

  // If another item was lit but isn't now, dim the old item.
  if (oldI && (oldI != litI)) changeCol(thisM, oldI, false);

  // Make sure if it's lit, it's shown, and set the visNow flag.
  if (litI && !visNow && (thisM != 'root')) {
   showMenu(thisM);
   visNow = true;
  }

  // If this menu has no items from the current hierarchy in it, and is currently
  // onscreen, call the hide function.
  if (isNaN(litI) && visNow) {
   hideMenu(thisM);
   visNow = false;
  }
 }


 // Get target menu to show - if we've got one, position & show it.
 // If this menu is set to show submenus on click, skip this.
 nextMenu = '';
 if ((menu[mN][iN].type == 'sm:') && !menu[mN][0].subsOnClick) {
  // The target menu and the layer object of the current menu itself (not this item).
  var targ = menu[mN][iN].href, lyrM = menu[mN][0].lyr;

//if (!menu[targ][0].lyr) update(false, targ);
//if (!menu[targ][0].lyr) return;

  // Either show immediately or after a delay if set by passing it to the position and show functions.
  // Set nextMenu to the impending show, so the popOut() function knows when not to cancel it.
  var showStr = 'with ('+myName+') { menu.'+targ+'[0].visNow = true; ' +
   'position("'+targ+'"); showMenu("'+targ+'") }';
  nextMenu = targ;
  if (showDelay) showTimer = setTimeout(showStr, showDelay);
  else eval(showStr);
 }
}}


function popOut(mN, iN) { with (this)
{
 // Sometimes, across frames, overs and outs can get confused.
 // So, return if we're exiting an item we have yet to enter...
 if ((mN != overM) || (iN != overI)) return;

 // Evaluate the onmouseout event, if any.
 if (this.onmouseout) onmouseout(mN, iN);

 var thisI = menu[mN][iN];

 // Stop showing another menu if this item isn't pointing to the same one.
 if (thisI.href != nextMenu)
 {
  clearTimeout(showTimer);
  nextMenu = '';
 }

 if (hideDelay)
 {
  var delay = ((mN == 'root') && (thisI.type != 'sm:')) ? 50 : hideDelay;
  hideTimer = setTimeout(myName + '.over("root", 0)', delay);
 }

 // Clear the 'over' variables.
 overM = 'root';
 overI = 0;
}}


function popClick(mN, iN) { with (this)
{
 // Evaluate the onclick event, if any.
 if (this.onclick) onclick(mN, iN);

 var thisI = menu[mN][iN], hideM = true;

 with (thisI) switch (type)
 {
  // Targeting another popout? Either activate show-on-click or skip to the end.
  case 'sm:':
  {
   if (menu[overM][0].subsOnClick)
   {
    menu[href][0].visNow = true;
    position(href);
    showMenu(href);
    hideM = false;
   }
   break;
  }
  // A JavaScript function? Eval() it and break out of switch.
  case 'js:': { eval(href); break }
  // Otherwise, point to the window if nothing else and navigate.
  case '': type = 'window';
  default: type = (type ? type : 'window'); if (href) eval(type + '.location.href = "' + href + '"');
 }

 // Hide all menus if we're supposed to.
 if (hideM) over('root', 0);
}}


function popChangeCol(mN, iN, isOver) { with (this.menu[mN][iN])
{
 if (!lyr || !lyr.ref) return;

 // Pick a new background colour, and decide on whether it's an image (contains a period?).
 var col = isOver?overCol:outCol;
 var bgFn = (col.indexOf('.')==-1) ? 'bgColor' : 'bgImage';
 // Then we do it before or after the text/border change due to Netscape bugs.
 if (isNS4) lyr[bgFn](col);

 if ((overClass != outClass) || (outBorder != overBorder)) with (lyr)
 {
  if (isNS4) write(this.getHTML(mN, iN, isOver));
  else
  {
   ref.className = (isOver ? overBorder : outBorder);
   var chl = (isDOM ? ref.childNodes : ref.children)
   if (chl) for (var i = 0; i < chl.length; i++) chl[i].className = isOver?overClass:outClass;
  }
 }

 if (!isNS4) lyr[bgFn](col);

 // Alpha filtering activated? Might as well set that then too...
 // Weirdly it has to be done after the border change, another random Mozilla bug...
 if (outAlpha != overAlpha) lyr.alpha(isOver ? overAlpha : outAlpha);
}}


function popPosition(posMN) { with (this)
{
 // Pass a menu name to position, or nothing to position all menus.
 for (mN in menu)
 {
  if (posMN && (posMN != mN)) continue;
  with (menu[mN][0])
  {
   // If the menu hasn't been created or is not set to be visible, loop.
   if (!lyr || !lyr.ref || !visNow) continue;

   // Set up some variables and the initial calculated positions.
   var pM, pI, newX = eval(offX), newY = eval(offY);
   // Find its parent menu references, if it's not the topmost root menu.
   if (mN != 'root')
   {
    pM = menu[parentMenu];
    pI = pM[parentItem].lyr;
    // Having no parent item is a bad thing, especially in cross-frame code.
    if (!pI) continue;
   }

   // Find parent window for correct page object, or this window if not.
   var eP = eval(par);
   var pW = (eP && eP.navigator ? eP : window);

   // Find proper numerical values for the current window position + edges, so menus
   // don't make a beeline for the upper-left corner of the page.
   with (pW.page) var sX=scrollX(), wX=sX+winW(), sY=scrollY(), wY=winH()+sY;
   wX = isNaN(wX)||!wX ? 9999 : wX;
   wY = isNaN(wY)||!wY ? 9999 : wY;

   // Relatively positioned submenus? Add parent menu/item position & check screen edges.
   if (pM && typeof(offX)=='number') newX = Math.max(sX,
    Math.min(newX+pM[0].lyr.x()+pI.x(), wX-menuW-(isIE?5:20)));
   if (pM && typeof(offY)=='number') newY = Math.max(sY,
    Math.min(newY+pM[0].lyr.y()+pI.y(), wY-menuH-(isIE?5:20)));

   // Assign the final calculated positions.
   lyr.x(newX);
   lyr.y(newY);
  }
 }
}}


// *** MENU OBJECT CONSTRUCTION FUNCTIONS ***
// This takes arrays of data and names and assigns the values to a specified object.
function addProps(obj, data, names, addNull)
{
 for (var i = 0; i < names.length; i++) 
    if(i < data.length || addNull) { obj[names[i]] = data[i]; }
}

function ItemStyle()
{
 // Like the other constructors, this passes a list of property names that correspond to the list
 // of arguments.
 var names = ['len', 'spacing', 'popInd', 'popPos', 'pad', 'outCol', 'overCol', 'outClass',
  'overClass', 'outBorder', 'overBorder', 'outAlpha', 'overAlpha', 'normCursor', 'nullCursor'];
 addProps(this, arguments, names, true);
}

function popStartMenu(mName) { with (this)
{
 // Create a new array within the menu object if none exists already, and a new menu object within.
 if (!menu[mName]) { menu[mName] = new Array(); menu[mName][0] = new Object(); }

 // Clean out existing items in this menu in case of a menu update.
 // actMenu is a reference to this menu for addItem() function later, while the local variable
 // aM is a quick reference to the current menu descriptor -- array index 0, 1+ are items.
 actMenu = menu[mName];
 aM = actMenu[0];
 actMenu.length = 1;

 // Not all of these are actually passed to the constructor -- the last few are null.
 // N.B: I pass 'isVert' twice so the first parameter (the menu name) is overwritten & ignored.
 var names = ['isVert', 'isVert', 'offX','offY', 'width', 'itemSty', 'par',
  'parentMenu', 'parentItem', 'visNow', 'oncreate', 'subsOnClick'];
 addProps(aM, arguments, names, true);

 // extraHTML is a string added to menu layers for things like dropshadows, backgrounds etc.
 aM.extraHTML = '';
 // Set the menu dimensions to zero initially. Also these are used to position items.
 aM.menuW = aM.menuH = 0;

 // Reuse old layers if we can, no use creating new ones every time the menus refresh.
 if (!aM.lyr) aM.lyr = null;
 
 // Assign a default oncreate event to the root menu to show it.
 if (mName == 'root') menu.root[0].oncreate = new Function('this.visNow=true; ' +
  myName + '.position("root"); this.lyr.vis("visible")');
}}


function popAddItem() { with (this) with (actMenu[0])
{
 // 'with' the current menu object and active menu descriptor object from startMenu().

 // Add these properties onto a new 'active Item' at the end of the active menu.
 var aI = actMenu[actMenu.length] = new Object();

 // Add function parameters to object. Again, the last few are undefined, set later.
 var names = ['text', 'href', 'type', 'itemSty', 'len', 'spacing', 'popInd', 'popPos',
  'pad', 'outCol', 'overCol', 'outClass', 'overClass', 'outBorder', 'overBorder',
  'outAlpha', 'overAlpha', 'normCursor', 'nullCursor',
  'iX', 'iY', 'iW', 'iH', 'lyr'];
 addProps(aI, arguments, names, true);

 // Find an applicable itemSty -- either passed to this item or the menu[0] object.
 var iSty = (arguments[3] ? arguments[3] : actMenu[0].itemSty);
 // Loop through its properties, add them if they don't already exist (overridden e.g. length).
 for (prop in iSty) if (aI[prop]+'' == 'undefined') aI[prop] = iSty[prop];

 // In NS4, since borders are assigned to the contents rather than the layer, increase padding.
 if (aI.outBorder)
 {
  if (isNS4) aI.pad++;
 }

 // The actual dimensions of the items, store here as properties so they can be accessed later.
 aI.iW = (isVert ? width : aI.len);
 aI.iH = (isVert ? aI.len : width);

 // The spacing of the previous menu item in this menu, if relevant.
 var lastGap = (actMenu.length > 2) ? actMenu[actMenu.length - 2].spacing : 0;

 // 'spc' is the amount we subtract from this item's position so borders overlap a little.
 // Of course we don't do it to the first item.
 var spc = ((actMenu.length > 2) && aI.outBorder ? 1 : 0);

 // We position this item at the end of the current menu's dimensions,
 // and then increase the menu dimensions by the size of this item.
 if (isVert)
 {
  menuH += lastGap - spc;
  aI.iX = 0; aI.iY = menuH;
  menuW = width; menuH += aI.iH;
 }
 else
 {
  menuW += lastGap - spc;
  aI.iX = menuW; aI.iY = 0;
  menuW += aI.iW; menuH = width;
 }

 if (aI.outBorder && CSSmode)
 {
  aI.iW -= 2;
  aI.iH -= 2;
 }
}}



// *** MAIN MENU CREATION/UPDATE FUNCTIONS ***
// Returns the inner HTML of an item, used for menu generation, and highlights in NS4.
function popGetHTML(mN, iN, isOver) { with (this)
{
 var itemStr = '';
 with (menu[mN][iN])
 {
  var textClass = (isOver ? overClass : outClass);

  // If we're supposed to add a popout indicator, add it before text so it appears below in NS4.
  if ((type == 'sm:') && popInd)
  {
   if (isNS4) itemStr += '<layer class="' + textClass + '" left="'+ ((popPos+iW)%iW) +
    '" top="' + pad + '" height="' + (iH-2*pad) + '">' + popInd + '</layer>';
   else itemStr += '<div class="' + textClass + '" style="position: absolute; left: ' +
    ((popPos+iW)%iW) + 'px; top: ' + pad + 'px; height: ' + (iH-2*pad) + 'px">' + popInd + '</div>';
  }

  // For NS4, if a border is assigned, add a spacer to push border out to layer edges.
  // Add a link both to generate an onClick event and to stop the ugly I-beam text cursor appearing.
  if (isNS4) itemStr += (outBorder ? '<span class="' + (isOver?overBorder:outBorder) +
   '"><spacer type="block" width="' + (iW-8) + '" height="' + (iH-8) + '"></span>' : '') +
   '<layer left="' + pad + '" top="' + pad + '" width="' + (iW-2*pad) + '" height="' +
   (iH-2*pad) + '"><a class="' + textClass + '" href="#" ' +
   'onClick="return false" onMouseOver="status=\'\'; ' + myName + '.over(\'' + mN + '\',' +
   iN + '); return true">' + text + '</a></layer>';

  // IE4+/NS6 is an awful lot easier to work with sometimes.
  else itemStr += '<div class="' + textClass + '" style="position: absolute; left: ' + pad +
   'px; top: ' + pad + 'px; width: ' + (iW-2*pad) + 'px; height: ' + (iH-2*pad) + 'px">' +
   text + '</div>';
 }
 return itemStr;
}}


// The main menu creation/update routine. The first parameter is 'true' if you want the script
// to use document.write() to create the menus. Second parameter is optionally the name of one
// menu only to update rather then create all menus.
function popUpdate(docWrite, upMN) { with (this)
{
 // 'isDyn' (set at the very top of the script) signifies a DHTML-capable browser.
 if (!isDyn) return;

 // Loop through menus, using properties of menu description object (array index 0)...
 for (mN in menu) with (menu[mN][0])
 {
  // If we're updating one specific menu, only run the code for that.
  if (upMN && (upMN != mN)) continue;

  // Variable for holding HTML for items.
  var str = '';

  // Remember, items start from 1 in the array (0 is menu object itself, above).
  // Also use properties of each item nested in the other with() for construction.
  for (var iN = 1; iN < menu[mN].length; iN++) with (menu[mN][iN])
  {
   // An ID for divs/layers contained within the menu.
   var itemID = myName + '_' + mN + '_' + iN;

   // Now is a good time to assign another menu's parent to this if we've got a popout item.
   var targM = menu[href];
   if (targM && (type == 'sm:'))
   {
    targM[0].parentMenu = mN;
    targM[0].parentItem = iN;
   }

   // Have we been given a background image? It'll have a period in its name if so...
   var isImg = (outCol.indexOf('.') != -1) ? true : false;

   // NS6 uses a different cursor name for the 'hand' cursor than IE.
   if (!isIE && normCursor=='hand') normCursor = 'pointer';

   // Create a div or layer text string with appropriate styles/properties.
   // At the end we set the alpha transparency (if specified) and the mouse cursor.
   if (isDOM || isIE4)
   {
    str += '<div id="' + itemID + '" ' + (outBorder ? 'class="'+outBorder+'" ' : '') +
     'style="position: absolute; left: ' + iX + 'px; top: ' + iY + 'px; width: ' + iW +
     'px; height: ' + iH + 'px; z-index: 1000; background: ' + (isImg?'url('+outCol+')':outCol) +
     ((typeof(outAlpha)=='number') ? '; filter: alpha(opacity='+ outAlpha + '); -moz-opacity: ' +
      (outAlpha/100) : '') +
     '; cursor: ' + ((type!='sm:' && href) ? normCursor : nullCursor) + '" ';
   }
   else if (isNS4)
   {
    // NS4's borders must be assigned within the layer so they stay when content is replaced.
    str += '<layer id="' + itemID + '" left="' + iX + '" top="' + iY + '" width="' +
     iW + '" height="' + iH + '" z-index="1000" ' +
     (outCol ? (isImg ? 'background="' : 'bgcolor="') + outCol + '" ' : '');
   }

   // Add mouseover and click handlers, contents, and finish div/layer.
   var evtMN = '(\'' + mN + '\',' + iN + ')"';
   str += 'onMouseOver="' + myName + '.over' + evtMN +
     ' onMouseOut="' + myName + '.out' + evtMN +
     ' onClick="' + myName + '.click' + evtMN + '>' +
     getHTML(mN, iN, false) + (isNS4 ? '</layer>' : '</div>');

  // End loop through items and with(menu[mN][iN]).
  }


  // The parent frame for this menu, if any.
  var eP = eval(par);

  setTimeout(myName + '.setupRef(' + docWrite + ', "' + mN + '")', 50);

  // Initial menu visibility, hidden unless tweaked otherwise.
  var mVis = visNow ? 'visible' : 'hidden';

  if (docWrite)
  {
   // Find the right target frame.
   var targFr = (eP && eP.navigator ? eP : window);
   targFr.document.write('<div id="' + myName + '_' + mN + '_Div" style="position: absolute; ' +
    'visibility: ' + mVis + '; left: 0px; top: 0px; width: ' + (menuW+2) + 'px; height: ' +
    (menuH+2) + 'px; z-index: 1000">' + str + extraHTML + '</div>');
  }
  else
  {
   if (!lyr || !lyr.ref) lyr = setLyr(mVis, menuW, eP);
   else if (isIE4) setTimeout(myName + '.menu.' + mN + '[0].lyr.sty.width=' + (menuW+2), 50);

   // Give it a high Z-index, and write its content.
   with (lyr) { sty.zIndex = 1000; write(str + extraHTML) }
  }

 // End loop through menus and with (menu[mN][0]).
 }
}}


function popSetupRef(docWrite, mN) { with (this) with (menu[mN][0])
{
 // Get a reference to a div, only needed for Fast creation mode.
 if (docWrite || !lyr || !lyr.ref) lyr = getLyr(myName + '_' + mN + '_Div', eval(par));

 // Loop through menu items again to set up individual references.
 for (var i = 1; i < menu[mN].length; i++)
  menu[mN][i].lyr = getLyr(myName + '_' + mN + '_' + i, (isNS4?lyr.ref:eval(par)));

 // Call the 'oncreate' method of this menu if it exists (e.g. to show root menu).
 if (menu[mN][0].oncreate) oncreate();
}}



// *** POPUP MENU MAIN OBJECT CONSTRUCTOR ***

function PopupMenu(myName)
{
 // These are the properties of any PopupMenu objects you create.
 this.myName = myName;

 // Manage what gets lit and shown when.
 this.showTimer = 0;
 this.hideTimer = 0;
 this.showDelay = 0;
 this.hideDelay = 500;
 this.showMenu = '';

 // 'menu': the main data store, contains subarrays for each menu e.g. pMenu.menu['root'][];
 this.menu =  new Array();
 // litNow and litOld arrays control what items get lit in the hierarchy.
 this.litNow = new Array();
 this.litOld = new Array();

 // The item the mouse is currently over. Used by click processor to help NS4.
 this.overM = 'root';
 this.overI = 0;

 // The active menu, to which addItem() will assign its results.
 this.actMenu = null;

 // Functions to create and manage the menu.
 this.over = popOver;
 this.out = popOut;
 this.changeCol = popChangeCol;
 this.position = popPosition;
 this.click = popClick;
 this.startMenu = popStartMenu;
 this.addItem = popAddItem;
 this.getHTML = popGetHTML;
 this.update = popUpdate;
 this.setupRef = popSetupRef;

 // Default show and hide functions, overridden in the example script by the clipping routine.
 this.showMenu = new Function('mName', 'this.menu[mName][0].lyr.vis("visible")');
 this.hideMenu = new Function('mName', 'this.menu[mName][0].lyr.vis("hidden")');
}


///////////////////////////////////////////////////////// moved to navigation.js


// ANIMATION:
//
function menuAnim(menuObj, menuName, dir)
{
 // The array index of the named menu (e.g. 'mPersonal') in the menu object (e.g. 'pMenu').
 var mD = menuObj.menu[menuName][0];
 // Add timer and counter variables to the menu data structure, we'll need them.
 if (!mD.timer) mD.timer = 0;
 if (!mD.counter) mD.counter = 0;

 with (mD)
 {
  // Stop any existing animation.
  clearTimeout(timer);

  // If the layer doesn't exist (cross-frame navigation) quit.
  if (!lyr || !lyr.ref) return;
  // Show the menu if that's what we're doing.
  if (dir>0) lyr.vis('visible');
  // Also raise showing layers above hiding ones.
  lyr.sty.zIndex = 1001 + dir;

  //if (isIE && window.createPopup) lyr.alpha(counter&&(counter<100) ? counter : null);

  // Clip the visible area. Tweak this if you want to change direction/acceleration etc.
  lyr.clip(0, 0, menuW+2, (menuH+2)*Math.pow(Math.sin(Math.PI*counter/200),0.75) );
  // Remove clipping in NS6 on completion, seems to help old versions.
  if ((isDOM&&!isIE) && (counter>=100)) lyr.sty.clip='';

  counter += dir;
  if (counter>100) counter = 100;
  else if (counter<0) { counter = 0; lyr.vis('hidden') }
  else timer = setTimeout(menuObj.myName+'.'+(dir>0?'show':'hide')+'Menu("'+menuName+'")', 40);
 }
}

// Here's the alternative IE5.5+ filter animation function.
function menuFilterShow(menuObj, menuName, filterName)
{
 var mD = menuObj.menu[menuName][0];
 with (mD.lyr)
 {
  sty.filter = filterName;
  var f = ref.filters;
  if (f&&f.length&&f[0]) f[0].Apply();
  vis('visible');
  if (f&&f.length&&f[0]) f[0].Play();
 }
}



// BORDERS AND DROPSHADOWS:

function addMenuBorder(mObj, iS, alpha, bordCol, bordW, backCol, backW)
{
 // Loop through the menu array of that object, finding matching ItemStyles.
 for (var mN in mObj.menu)
 {
  var mR=mObj.menu[mN], dS='<div style="position:absolute; background:';
  if (mR[0].itemSty != iS) continue;
  // Loop through the items in that menu, move them down and to the right a bit.
  for (var mI=1; mI<mR.length; mI++)
  {
   mR[mI].iX += bordW+backW;
   mR[mI].iY += bordW+backW;
  }
  // Extend the total dimensions of menu accordingly.
  mW = mR[0].menuW += 2*(bordW+backW);
  mH = mR[0].menuH += 2*(bordW+backW);

  // Set the menu's extra content string with divs/layers underneath the items.
  if (isNS4) mR[0].extraHTML += '<layer bgcolor="'+bordCol+'" left="0" top="0" width="'+mW+
   '" height="'+mH+'" z-index="980"><layer bgcolor="'+backCol+'" left="'+bordW+'" top="'+
   bordW+'" width="'+(mW-2*bordW)+'" height="'+(mH-2*bordW)+'" z-index="990"></layer></layer>';
  else mR[0].extraHTML += dS+bordCol+'; left:0px; top:0px; width:'+mW+'px; height:'+mH+
   'px; z-index:980; '+(alpha!=null?'filter:alpha(opacity='+alpha+'); -moz-opacity:'+(alpha/100):'')+
   '">'+dS+backCol+'; left:'+bordW+'px; top:'+bordW+'px; width:'+(mW-2*bordW)+'px; height:'+
   (mH-2*bordW)+'px; z-index:990"></div></div>';
 }
}


function addDropShadow(mObj, iS)
{
 // Pretty similar to the one above, just loops through list of extra parameters making
 // dropshadow layers (from arrays) and extending the menu dimensions to suit.
 for (var mN in mObj.menu)
 {
  var a=arguments, mD=mObj.menu[mN][0], addW=addH=0;
  if (mD.itemSty != iS) continue;
  for (var shad=2; shad<a.length; shad++)
  {
   var s = a[shad];
   if (isNS4) mD.extraHTML += '<layer bgcolor="'+s[1]+'" left="'+s[2]+'" top="'+s[3]+'" width="'+
    (mD.menuW+s[4])+'" height="'+(mD.menuH+s[5])+'" z-index="'+(arguments.length-shad)+'"></layer>';
   else mD.extraHTML += '<div style="position:absolute; background:'+s[1]+'; left:'+s[2]+
    'px; top:'+s[3]+'px; width:'+(mD.menuW+s[4])+'px; height:'+(mD.menuH+s[5])+'px; z-index:'+
    (a.length-shad)+'; '+(s[0]!=null?'filter:alpha(opacity='+s[0]+'); -moz-opacity:'+(s[0]/100):'')+
    '"></div>';
   addW=Math.max(addW, s[2]+s[4]);
   addH=Math.max(addH, s[3]+s[5]);
  }
  mD.menuW+=addW; mD.menuH+=addH;
 }
}


// *** ITEMSTYLES ***
// styleName = new ItemStyle(length of items, spacing after items, 'popout indicator HTML',
//  popout indicator position, padding of text within item, 'out background colour or image
//  filename', 'hover background colour or filename', 'out text stylesheet class', 'hover text class',
//  'out border stylesheet class', 'hover border class', out opacity percentage or null to make
//  it fully opaque, hover opacity percentage or null, 'CSS mouse cursor for normal items',
//  'CSS cursor for sm: and blank items');

var hBar = new ItemStyle(99, 22, '', 0, 0, '#FFF', '#EEE', 'menuHead', 'menuHeadOver', '', '',
 null, null, 'hand', 'default');

var vBar = new ItemStyle(20, 1, '', 0, 0, '#FFF', '#EEE', 'menuHead', 'menuHeadOver', '', '',
 null, null, 'hand', 'default');

var helpStyle = new ItemStyle(70, 22, '', 0, 0, '#ED9', '#ED9', 'menuHead', 'menuHeadOver', '', '',
 null, null, 'help', 'help');

var subM = new ItemStyle(22, 0, '&gt;', -15, 3, '#CCC', '#DDD', 'lowText', 'highText',
 'itemBorder', 'itemBorder', null, null, 'hand', 'default');

var subBlank = new ItemStyle(22, 1, '&gt;', -15, 3, '#CCCCDD', '#6699CC', 'lowText', 'highText',
 'itemBorderBlank', 'itemBorder', null, null, 'hand', 'default');

var buttonStyle = new ItemStyle(22, 1, '&gt;', -15, 2, '#006633', '#CC6600', 'buttonText', 'buttonHover',
 'buttonBorder', 'buttonBorderOver', 80, 95, 'crosshair', 'default');


