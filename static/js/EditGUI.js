/* 
Name 		: EditGUI.js
Description 	: Class EditGUI
                  Page edit GUI toolbars
*/

function EditGUI(unpublishedChanges, statusid, staticDir){ 
    this.browser            = mybrowser;
    this.selectedelement    = null;
    this.highlightedelement = null;
    this.docBody            = null;
    this.elementPalette     = null;
    this.pagePalette        = null;
    this.grid               = false;
    this.addMenu            = null;
    this.areas              = new Array();
    this.pageForm           = null;
    this.saveButton         = null;
    this.unsavedChanges     = false;
    this.unpublishedChanges = unpublishedChanges ? true : false;
    this.statusid           = statusid;
    this.staticDir          = staticDir;
     
    this.mX                 = 0;
    this.mY                 = 0;
    this.showGuides         = false;
    this.webView            = false;
    this.pagePaletteDrag    = false;
    this.elementPaletteDrag = false;
    this.dragOffsetX        = null;
    this.dragOffsetY        = null;
    this.pageWidth          = this.browser.ie ? document.body.clientWidth : window.innerWidth;
        
    /* get a convenience reference to the document body */
    this.docBody = document.getElementsByTagName('BODY')[0];
        
    /* initialise the areas */
    var divs = findMatches(document.getElementsByTagName('DIV'),'className','area');
    for (var i = 0; i < divs.length; i++ ) {
        areaObj = new EditGUI_area(divs[i], this);
        this.areas.push(areaObj);
        areaObj.init();
    }
    
    /* build the palettes */
    this.makeElementPalette();
    this.makePagePalette();
    /* start tracking the mouse */
    this.docBody.onmousemove = function(e) { eg.trackMouse(e) };
    
    /* initialise in Edit view */
    this.webView = true;
    this.toggleWebView();    
    return this;
}

EditGUI.prototype.trackMouse = function(e) {
        if ( this.browser.ns  ) {
		this.mX = e.pageX;
		this.mY = e.pageY;
	}
	else {  
		this.mX = parseInt(event.clientX) + document.body.scrollLeft; 
		this.mY = parseInt(event.clientY) + document.body.scrollTop;
	}

	if ( this.pagePaletteDrag ) {
	    this.pagePalette.style.left   = this.mX - this.dragOffsetX;
	    this.pagePalette.style.top    = this.mY - this.dragOffsetY;
	}
	else if ( this.elementPaletteDrag ) {
	    this.elementPalette.style.left = this.mX - this.dragOffsetX;
	    this.elementPalette.style.top  = this.mY - this.dragOffsetY;
	}
	
/*
this.elementPalette.innerHTML = 'X:' + this.mX + 'Y:' + this.mY + '<br>' + 'px:' + this.elementPalette.loc.minX + '-' + this.elementPalette.loc.maxX + '<br>' + 'py:' + this.elementPalette.loc.minY + '-' + this.elementPalette.loc.maxY + '<br>' + 'wx:' + this.selectedelement.minX + '-' + this.selectedelement.maxX + '<br>' + 'wy:' + this.selectedelement.minY + '-' + this.selectedelement.maxY;
*/
	    
    if ( this.selectedelement && 0 &&
        ( ! isWithinBounds(this.mX, this.mY, this.elementPalette.loc.minX, this.elementPalette.loc.minY, this.elementPalette.loc.maxX, this.elementPalette.loc.maxY) && 
          ! isWithinBounds(this.mX, this.mY, this.selectedelement.minX, this.selectedelement.minY, this.selectedelement.maxX, this.selectedelement.maxY) ) ) {
        this.selectElement(null);
	}
	
    if ( this.highlightedelement &&
        ( ! isWithinBounds(this.mX, this.mY, this.highlightedelement.minX, this.highlightedelement.minY, this.highlightedelement.maxX, this.highlightedelement.maxY) ) ) {
        this.highlightelement(null);
	}
}

EditGUI.prototype.tryHide = function(e) {
    this.highlightelement(null);
}

EditGUI.prototype.alertSave = function(e) {
    if ( this.unsavedChanges ) {
        return false;
    }
    this.unsavedChanges = true;
    this.saveButton.style.background = 'orange';
    return true;
}

EditGUI.prototype.startPagePaletteDrag   = function(e) {
    this.pagePaletteDrag = true;
    this.dragOffsetX     = this.mX - parseInt(this.pagePalette.style.left);
    this.dragOffsetY     = this.mY - parseInt(this.pagePalette.style.top);
    this.elementPalette.style.zIndex = 2;
    this.pagePalette.style.zIndex    = 3;
}

EditGUI.prototype.startelementPaletteDrag = function(e) {
    this.elementPaletteDrag = true;
    this.dragOffsetX       = this.mX - parseInt(this.elementPalette.style.left);
    this.dragOffsetY       = this.mY - parseInt(this.elementPalette.style.top);
    this.elementPalette.style.zIndex = 3;
    this.pagePalette.style.zIndex    = 2;
    return false;
}

EditGUI.prototype.ceaseDrag = function() {
    this.elementPaletteDrag = false;
    this.pagePaletteDrag   = false;
}

EditGUI.prototype.savePage = function() {
    this.pageForm.updateArea.value = this.encodeareas();
    this.pageForm.submit();
}

EditGUI.prototype.commitPage = function() {
    this.pageForm.updateArea.value = this.encodeareas();
    this.pageForm.commit.value = 1;
    this.pageForm.submit();
}

EditGUI.prototype.updateStatus = function() {
    this.pageForm.updateArea.value = this.encodeareas();
    this.pageForm.update_status.value = this.statusid > 2 ? -1 : 1;
    this.pageForm.commit.value = 1;
    this.pageForm.submit();
}

EditGUI.prototype.addPage = function() {
    self.location = '?view=admin&template=addPage';
}

EditGUI.prototype.editPage = function() {
    self.location = '?view=admin&template=editPage';
}

EditGUI.prototype.adminPages = function() {
    self.location = '/?view=admin&template=adminPages';
}

EditGUI.prototype.toggleGuides = function(forceoff) {
    if ( forceoff || this.showGuides ) {
        for (var i = 0; i < this.areas.length; i++ ) {
           this.areas[i].ref.style.border = '0px';
           this.areas[i].ref.style.background = 'transparent';
        }
        this.showGuides = false;
    }
    else {
        for (var i = 0; i < this.areas.length; i++ ) {
           this.areas[i].ref.style.border = '1px dotted #AAA' ;
           this.areas[i].ref.style.background = '#EEE';
        }
        this.showGuides = true;
    }
}

EditGUI.prototype.toggleWebView = function() {
    var all_elements = new Array();
    for (var i = 0; i < this.areas.length; i++ ) {
       for (var j = 0; j < this.areas[i].elements.length; j++ ) {
          all_elements.push(this.areas[i].elements[j].ref);
       }
    }
    if ( this.webView ) {
        for (var i = 0; i < all_elements.length; i++ ) {
            all_elements[i].style.border = '1px #AAA solid';
            all_elements[i].style.cursor = 'text';
            all_elements[i].onclick = function(e) { return false; };
        }
        
        this.toggleGuides();
        this.pagePalette.style.MozOpacity = 0.8;
        this.pagePalette.style.filter     = 'alpha(opacity=80)';
        this.webView = false;
    }
    else {
        this.selectElement(null);
        this.highlightelement(null);
        this.elementPalette.style.visibility = 'hidden';
        this.toggleGuides(1);
        this.pagePalette.style.MozOpacity = 0.4;
        this.pagePalette.style.filter     = 'alpha(opacity=40)';
        for (var i = 0; i < all_elements.length; i++ ) {
            all_elements[i].style.cursor = 'auto';
            all_elements[i].style.border = '0px';
            all_elements[i].onclick = null;
        }
        this.webView = true;
    }
}


EditGUI.prototype.paletteShow = function() {
    if ( this.selectedelement && ! this.elementPaletteDrag ) { //&& 
         //this.selectedelement == this.lastSelectedelement) {
        this.elementPalette.style.left       = this.mX;
        this.elementPalette.style.top        = this.mY;
        this.elementPalette.style.visibility = 'visible';
        this.elementPalette.style.zIndex     = 3;
        this.pagePalette.style.zIndex       = 2;
        
    //this.elementPalette.innerHTML = "element: " + this.selectedelement.elementid
        
        /* recalculate positions of the palette */
        this.elementPalette.loc.minX = this.mX
        this.elementPalette.loc.minY = this.mY
    	this.elementPalette.loc.maxX = this.mX + parseInt(this.elementPalette.offsetWidth);
    	this.elementPalette.loc.maxY = this.mY + parseInt(this.elementPalette.offsetHeight);
    	this.elementPalette.elementid = this.selectedelement.elementid;
    }
}

EditGUI.prototype.highlightelement = function(element) {

    if ( ! element ) {
        this.higlightedelement = null;
           
        for (var i = 0; i < this.areas.length; i++ ) {
            for (var j = 0; j < this.areas[i].elements.length; j++ ) {
                if ( ! this.areas[i].elements[j] == this.selectedelement ) {
                    this.areas[i].elements[j].beUnHighlighted(this.grid);
                }
            }
        }
    }
    
    if ( this.webView ) {
        return false;    
    }
    
    for (var i = 0; i < this.areas.length; i++ ) {
        for (var j = 0; j < this.areas[i].elements.length; j++ ) {
            if ( this.areas[i].elements[j].ref == element ) {
                this.highlightedelement = this.areas[i].elements[j];
                if ( this.highlightedelement != this.selectedelement ) {
                    this.areas[i].elements[j].beHighlighted(this.grid);
                }
            }
            else {
                if ( this.areas[i].elements[j] != this.selectedelement ) {
                    this.areas[i].elements[j].beUnHighlighted(this.grid);
                }
            }
        }
    }
    return true;    
}

// function SELECT element 
EditGUI.prototype.selectElement = function(element) {
    if ( this.selectedelement ) {
        var oldarea = this.selectedelement.area;
    }
    
    if ( ! element ) {
        this.selectedelement = null;
        this.elementPalette.style.visibility = 'hidden';
        for (var i = 0; i < this.areas.length; i++ ) {
            for (var j = 0; j < this.areas[i].elements.length; j++ ) {
                this.areas[i].elements[j].beUnSelected(this.grid);
            }
        }
    }
    
    if ( this.webView ) {
        return false;    
    }

    for (var i = 0; i < this.areas.length; i++ ) {
        for (var j = 0; j < this.areas[i].elements.length; j++ ) {
            if ( this.areas[i].elements[j].ref == element ) {
                this.selectedelement = this.areas[i].elements[j]
                this.selectedelement.beSelected(this.grid);

                /* update options in addmenu if we've switched areas */
                if (oldarea != this.selectedelement.area) {
                    var t;
                    for ( t = this.addMenu.options.length - 1; t >= 0; t-- ) {
                        this.addMenu.options[t] = null;    
                    }
                    var opt; 
                    for ( t = 0; t < this.selectedelement.area.permittedTypes.length; t++ ) {
                        opt = new Option(this.selectedelement.area.permittedTypes[t], this.selectedelement.area.permittedTypes[t]);
                        this.addMenu.options[t] = opt;
                    }
                    this.addMenu.options[0].selected = true;
                }
                this.paletteShow();
            }
            else {
                this.areas[i].elements[j].beUnSelected(this.grid);
            }
        }
    }
    return true;    
}

// function UNSELECT element 
EditGUI.prototype.unselectElement = function() {

    this.selectedelement.beUnSelected(this.grid);
    this.elementPalette.style.visibility = 'hidden';
}

EditGUI.prototype.encodeareas = function() {
    var areaEncode = new Array();
    for (var i = 0; i < this.areas.length; i++ ) {
	areaEncode.push(this.areas[i].encodeSelf());
    }
    return areaEncode.join('%');
}


// EDITING ACTIONS
// function REMOVE
EditGUI.prototype.removeelement = function() {
    if ( ! this.selectedelement ) {
        return false;   
    }
    this.selectedelement.ref.parentNode.removeChild(this.selectedelement.ref);
    
    var z = this.selectedelement.area;
    for (var i = 0; i < z.elements.length; i++ ) {
        if ( z.elements[i].elementid == this.selectedelement.elementid ) {
            break;    
        }
    }
    z.elements.splice(i, 1)
    if ( z.elements.length == 0 ) {
        var e_z = document.createElement('DIV');
        e_z.className = 'element';
        e_z.elementid  = '0';
        e_z.type      = '';
        e_z.id        = 'emptyElement';
        e_z.appendChild(document.createTextNode('Empty area'));
        z.ref.appendChild(e_z);
        
        var elementObj = new EditGUI_element(e_z, z)
        elementObj.init();
        z.elements.push(elementObj);
    }
    this.selectElement(null);
    return this.alertSave();
}
	

// function UP 
EditGUI.prototype.upelement = function() {

    if ( ! this.selectedelement ) {
        return false;
    }
    var z = this.selectedelement.area;
    var i;
    for (i = 0; i < z.elements.length; i++ ) {
        if ( z.elements[i].elementid == this.selectedelement.elementid ) {
            break;    
        }
    }
    if ( i == 0 ) {
        return false;    
    }
	
    this.selectedelement.ref.parentNode.insertBefore(this.selectedelement.ref,z.elements[i-1].ref);
	
    z.elements[i]   = z.elements[i-1];
    z.elements[i-1] = this.selectedelement;
    z.elements[i].whereAmI();
    z.elements[i-1].whereAmI();
    return this.alertSave();
}

// function DOWN 
EditGUI.prototype.downelement = function() {
    if ( ! this.selectedelement ) {
        return false;
    }
    var z = this.selectedelement.area;
    var i;

    for ( i = 0; i < z.elements.length; i++ ) {
        if ( z.elements[i].elementid == this.selectedelement.elementid ) {
            break;    
        }
    }
  
    if ( i + 2 == z.elements.length ) {
        // it's the end of elements array. in order to use insertBefore 
        //we will insert the last node before current 
        this.selectedelement.ref.parentNode.insertBefore(z.elements[i+1].ref,this.selectedelement.ref);
    } else if ( i + 2 > z.elements.length ) {
	return false;
    } else {
        // insert node before second after 
        this.selectedelement.ref.parentNode.insertBefore(this.selectedelement.ref,z.elements[i+2].ref);
    }
		
    z.elements[i]   = z.elements[i+1];
    z.elements[i+1] = this.selectedelement;
    z.elements[i].whereAmI();
    z.elements[i+1].whereAmI();
    return this.alertSave();
}

EditGUI.prototype.launchEditMe = function() {
    if ( this.selectedelement ) {
        if ( this.selectedelement.elementid == 0 ) {
            this.launchInsert(0);
        }
        else {
            var z = this.selectedelement.area;
            var insertIndex=0;
            for (var i = 0; i < z.elements.length; i++ ) {
                if ( z.elements[i] == this.selectedelement ) {
                    insertIndex = i;
                    break;
                }
            }
            self.location = '?view=admin&template=editElement' + 
                '&elementid=' + this.selectedelement.elementid +
                '&area=' + this.selectedelement.area.areaid + '&areaoffset=' + insertIndex;
        }
    }
}

EditGUI.prototype.launchInsert = function(offset) {
	
    if ( this.selectedelement ) {
        z = this.selectedelement.area;
        var insertIndex;
        for (var i = 0; i < z.elements.length; i++ ) {
            if ( z.elements[i] == this.selectedelement ) {
                insertIndex = i + offset;
                break;
            }
        }
        
	var elementType;
        if ( this.addMenu.options.length && this.addMenu.selectedIndex!=-1) {
           elementType = this.addMenu.options[this.addMenu.selectedIndex].value;
        } else {
           elementType = "Text";
        }
        self.location = '?view=admin&template=addElement' + 
                        '&element_type=' + elementType + 
                        '&area=' + z.areaid + '&areaoffset=' + insertIndex;
    }
}

// MAKE element PALETTE
EditGUI.prototype.makeElementPalette = function() {
	
    var w = document.createElement('DIV');
    w.className = 'elementPalette';
    var s = w.style;
    s.filter = 'alpha(opacity=80)';
    
    // grip bar
    var gripBar = document.createElement('DIV');
    gripBar.className = 'gripBar';
    gripBar.onmousedown = function(e) { eg.startelementPaletteDrag(e) }
    gripBar.onmouseup   = function(e) { eg.ceaseDrag()  }
    
    var dismiss = document.createElement('SPAN');
    dismiss.onclick = function(e)   { eg.elementPalette.style.visibility = 'hidden'; eg.selectElement(null) }
    dismiss.innerHTML = 'X';
    dismiss.className = 'dismissButton';
    
    //if ( document.all ) {
    //    grip.ondragstart = function(e) { return false; }
    //}
    
    gripBar.appendChild(dismiss);
    w.appendChild(gripBar);
    
    // elementMenu
    var elementMenu = document.createElement('DIV');
    elementMenu.className = 'elementMenu';
  
    // button Bar
    var btBar = document.createElement('DIV');
    btBar.name = 'buttonBar';
    btBar.style.padding = '7px';	
    elementMenu.appendChild(btBar);

    // edit
    var editButton = document.createElement('SPAN');
    editButton.innerHTML = 'Edit';
    editButton.className = 'elementPaletteButton';
    editButton.onclick = function(e) { eg.launchEditMe() }
    btBar.appendChild(editButton);
    
    // up
    var upButton = document.createElement('SPAN');
    upButton.innerHTML = 'Up';
    upButton.className = 'elementPaletteButton';
    upButton.onclick = function(e) { eg.upelement() }
    btBar.appendChild(upButton);
   
   	//down
    var downButton = document.createElement('SPAN');
    downButton.innerHTML = 'Down';
    downButton.className = 'elementPaletteButton';
    downButton.onclick = function(e) { eg.downelement() }
    btBar.appendChild(downButton);
    
	// remove
    var removeButton = document.createElement('SPAN');
    removeButton.innerHTML = 'Remove';
    removeButton.className = 'elementPaletteButton';
    removeButton.onclick = function(e) { eg.removeelement() }
    btBar.appendChild(removeButton);
    
	// insert up
/*    var insertupButton = document.createElement('SPAN');
    insertupButton.innerHTML = 'Insert Above';
    insertupButton.className = 'elementPaletteButton';
    insertupButton.onclick = function(e) { eg.launchInsert(0); }
    btBar.appendChild(insertupButton);
*/
    // insert down
    var insertdownButton = document.createElement('SPAN');
    insertdownButton.innerHTML = 'Insert';
    insertdownButton.className = 'elementPaletteButton';
    insertdownButton.onclick = function(e) { eg.launchInsert(1) }
    btBar.appendChild(insertdownButton);
    
    // form
    var formdiv = document.createElement('DIV');
    formdiv.name = 'elementFormDiv';
    formdiv.style.padding = '1px';	
  	
    var fm = document.createElement('FORM');
    fm.name = 'elementForm';
    fm.id = 'elementFormID';
	
    // select
    var selectah = document.createElement('SELECT');
    selectah.name = 'elementSelect';
    if (this.browser.isIeMac){
	selectah.style.height = '35px';
	selectah.style.fontSize = 'x-small';
	selectah.size = 2; // odd but mac wont work if this is 1 
	selectah.style.width = '185px';
    } else {
	selectah.style.width = '220px';	
    }
	
    this.addMenu = selectah;
    fm.appendChild(this.addMenu);
    formdiv.appendChild(fm);
    elementMenu.appendChild(formdiv);
    w.appendChild(elementMenu);
    
    /* link reference into EditGUI, add to document */
    this.elementPalette = w;
    this.docBody.appendChild(this.elementPalette);
    this.elementPalette.loc = new Array();
}

// MAKE PAGE PALETTE

EditGUI.prototype.makePagePalette = function() {
    var pp = document.createElement('DIV');
    pp.className = 'pagePalette';
    var s = pp.style; //pp style positioning necessary to drag the palette
    s.top   = '0px';
    if (this.browser.ie){ s.width = '682px'; }
    s.left  = ((Math.max(0,this.pageWidth)/2)-340)+'px';
    s.filter= 'alpha(opacity=80)';

    var pageForm = document.createElement('FORM');
    pageForm.action = '?';
    pageForm.method = 'POST';
    pageForm.style.display = 'none';
    pageForm.style.padding = '1px';

    var updateArea, view, update_status, commit;
    if (this.browser.ie){
       updateArea = document.createElement("<input type=hidden name=updateArea>");
       view = document.createElement("<input type=hidden name=view value=edit>");
       update_status = document.createElement("<input type=hidden name=update_status>");
       commit = document.createElement("<input type=hidden name=commit>");
    }
    else {

       updateArea = document.createElement('INPUT');
       view = document.createElement('INPUT');
       update_status = document.createElement('INPUT');
       commit = document.createElement('INPUT');
       updateArea.type = view.type = update_status.type = commit.type = 'hidden';
	
       updateArea.name = 'updateArea';
       view.name = 'view'; view.value = 'edit';
       update_status.name = 'update_status';
       commit.name = 'commit';
    }

    pageForm.appendChild(updateArea);
    pageForm.appendChild(view);
    pageForm.appendChild(update_status);
    pageForm.appendChild(commit);

	// gripBar
    var gripBar = document.createElement('DIV');
    gripBar.className = 'gripBar';
    gripBar.onmousedown = function() { eg.startPagePaletteDrag() }
    gripBar.onmouseup   = function() { eg.ceaseDrag() }
    pp.appendChild(gripBar);
    
	// add new
    var addNewButton = document.createElement('SPAN');
    addNewButton.className = 'pagePaletteButton';
    addNewButton.innerHTML = 'ADD NEW PAGE';
    addNewButton.onclick = function() { eg.addPage() }
    pp.appendChild(addNewButton);
    
	// edit
    var editButton = document.createElement('SPAN');
    editButton.className = 'pagePaletteButton';
    editButton.innerHTML = 'EDIT PAGE';
    editButton.onclick = function() { eg.editPage() }
    pp.appendChild(editButton);
    
	// save
    var saveButton = document.createElement('SPAN');
    saveButton.className = 'pagePaletteButton';
    saveButton.innerHTML = 'SAVE PAGE';
    saveButton.onclick = function() { eg.savePage() }
    pp.appendChild(saveButton);
    
	// guides
/*    
    var guidesButton = document.createElement('SPAN');
    guidesButton.className = 'pagePaletteButton';
    guidesButton.innerHTML = 'SHOW/HIDE GUIDES';
    guidesButton.onclick = function(e) { eg.toggleGuides() }
    pp.appendChild(guidesButton);
*/    
	// commit
    var commitButton = document.createElement('SPAN');
    commitButton.className = 'pagePaletteButton';
    commitButton.innerHTML = 'COMMIT PAGE';
    commitButton.onclick = function() { eg.commitPage() }
    commitButton.style.background = (this.unpublishedChanges) ?'orange' : '#777';
    pp.appendChild(commitButton);
    
	// status
    var statusButton = document.createElement('SPAN');
    statusButton.className = 'pagePaletteButton';
    if ( this.statusid == 1 ) { // neo status
        statusButton.innerHTML = 'PUBLISH';
    }
    else if ( this.statusid == 2 ) { //live status
        statusButton.innerHTML = 'ARCHIVE';
    }
    else { //archive status
        statusButton.innerHTML = 'REPUBLISH';
    }
    statusButton.innerHTML += ' PAGE';
    statusButton.onclick = function() { eg.updateStatus() }
    pp.appendChild(statusButton);
    
	// web/admin view
    var editViewButton = document.createElement('SPAN');
    editViewButton.className = 'pagePaletteButton';
    editViewButton.innerHTML = 'ADMIN/WEB VIEW';
    editViewButton.onclick = function() { eg.toggleWebView() }
    pp.appendChild(editViewButton);
    
	// admin site
    var adminButton = document.createElement('SPAN');
    adminButton.className = 'pagePaletteButton';
    adminButton.innerHTML = 'ADMIN SITE';
    adminButton.onclick = function() { eg.adminPages() }
    pp.appendChild(adminButton);
    
	// sitemap
    var sitemapButton = document.createElement('SPAN');
    sitemapButton.className = 'pagePaletteButton';
    sitemapButton.innerHTML = 'SITEMAP';
    sitemapButton.onclick = function() { window.open('/sitemap','_blank','toolbar=no,scrollbars=yes,status=yes,resizable=yes,width=750,height=450'); }
    pp.appendChild(sitemapButton);
    
	// help
    var helpButton = document.createElement('SPAN');
    helpButton.className = 'pagePaletteButton';
    helpButton.innerHTML = 'HELP';
    helpButton.staticDir = this.staticDir; //store staticDir into helpButton Obj for 'onclick' use 
    helpButton.onclick = function() { window.open(this.staticDir+'/help/index.html','_blank'); }
    pp.appendChild(helpButton);
    

    this.pageForm = pageForm;
    this.saveButton = saveButton;
    this.pagePalette = pp;
    this.docBody.appendChild(this.pagePalette);
    this.docBody.appendChild(this.pageForm);
}

function EditGUI_area(div,gui) {
    this.ref = div;
    this.gui = gui;
    this.areaid   = this.ref.getAttribute('areaid');
    this.locked = this.ref.getAttribute('locked');
    this.permittedTypes = Array();
    this.permittedTypes = this.ref.getAttribute('permittype').split(':');
    return this;
}

/* init area elements */
EditGUI_area.prototype.init = function() {
    this.elements  = new Array();
    var divs = findMatches(this.ref.getElementsByTagName('DIV'),'className','element');
    
    for (var i = 0; i < divs.length; i++ ) {
        if ( elementid = divs[i].getAttribute('elementid') ) {
            var elementObj = new EditGUI_element(divs[i], this)
            elementObj.init();
            this.elements.push(elementObj);
        }
    }
    
    this.placeholders = new Array();
}

EditGUI_area.prototype.encodeSelf = function() {
    var elementIds = new Array();
    for (var i = 0; i < this.elements.length; i++ ) {
       if (this.elements[i].elementid != 0){
          elementIds.push(this.elements[i].elementid);
       }
    }
    return this.areaid + ':' + elementIds.join(',');
}


EditGUI_area.prototype.upelement = function(wid) {
    for (var i = 1; i < this.elements.length; i++ ) {
        if ( this.elements[i].elementid == wid ) {
            this.ref.insertBefore(this.elements[i].ref, this.elements[i-1].ref);
        }
    } 
}

function EditGUI_element(div, area) {
    this.ref      = div;
    this.area     = area;
    this.elementid = this.ref.getAttribute('elementid');
    //this.path     = this.ref.getAttribute('path');
    this.type     = this.ref.getAttribute('type');
    return this;
}

EditGUI_element.prototype.whereAmI = function() {
    this.minX = parseInt(this.ref.offsetLeft);
    this.minY = parseInt(this.ref.offsetTop);
    
    var node = this.ref.offsetParent;
    while ( node && ! node.tagName == 'BODY' ) {
      if ( node.offsetLeft ) {
        this.minX += parseInt(this.ref.offsetLeft);
        this.minY += parseInt(this.ref.offsetTop);
        node = node.offsetParent;
      }
      /* Moz */
      else if ( document.defaultView.getComputedStyle ) {
    	this.minX += parseInt(document.defaultView.getComputedStyle(node.getPropertyValue('left')));
    	this.minY += parseInt(document.defaultView.getComputedStyle(node.getPropertyValue('top')));
      }
    }
    
    if ( this.ref.offsetLeft ) {
        this.maxX += this.minX + parseInt(this.ref.offsetWidth);
        this.maxY += this.minY + parseInt(this.ref.offsetHeight);
    }
    else if ( document.defaultView.getComputedStyle ) {
    	this.maxX = this.minX + parseInt(document.defaultView.getComputedStyle(this.ref.getPropertyValue('width')));
        this.maxY = this.minY + parseInt(document.defaultView.getComputedStyle(this.ref.getPropertyValue('height')));
    }
    
    //alert(this.elementid + ':' + this.minX + '-' + this.maxX + '-' + this.minY + '-' + this.maxY);  
}

EditGUI_element.prototype.beHighlighted = function(grid) {
    this.ref.style.backgroundColor = '#FFF';
}
EditGUI_element.prototype.beUnHighlighted = function(grid) {
    this.ref.style.backgroundColor = '';
}
EditGUI_element.prototype.beSelected = function(grid) {
    this.ref.style.backgroundColor = '#7E7';
}
EditGUI_element.prototype.beUnSelected = function(grid) {
    this.ref.style.backgroundColor = '';
}

EditGUI_element.prototype.init = function() {
    
    if ( this.ref.addEventListener ) {
   	var fmouseover = function(e) { eg.highlightelement(this); }
   	this.ref.addEventListener('mouseover', fmouseover, true);
        var fclick = function(e) { eg.selectElement(this); }
        this.ref.addEventListener('click', fclick, true);
        var fmouseout = function(e) { eg.tryHide(); }
        this.ref.addEventListener('mouseout', fmouseout, true);
    }
    else {
	this.ref.onmouseover = function() { eg.highlightelement(this); }
        this.ref["oncontextmenu"] = function() { eg.selectElement(this); return false;}
        this.ref.onmouseleave = function() { eg.tryHide(); }
    }
    this.whereAmI();
}

function removeMe(elementID) {
    d = document.getElementById('element_' + elementID);
    d.parentNode.removeChild(d);
}

function findMatches(arr, pname, pvalue) {
    var found = Array();
    for (var i = 0; i < arr.length; i++ ) {
        if ( arr[i][pname] && arr[i][pname] == pvalue ) {
            found.push(arr[i])
        }   
    }
    return found;
}

function isWithinBounds(x, y, min_x, min_y, max_x, max_y) {
    if ( x < min_x || x > max_x || y < min_y || y > max_y ) {
        return false;
    }
    return true;
}

