/* 
Name 		: Granterer.js
Description 	: Class Granterer
Author		: Alex Fenton

 PERMISSIONS GRANTERER 
*/

function Granterer() {
    this.paths        = Array();
    this.ref          = document.getElementById('granterer');
    this.docBody      = document.getElementsByTagName('BODY')[0];
    this.selectedPath = null;
    return this;
}

Granterer.prototype.addNode = function(path, name, have, startstate) {
    this.paths.push(new Granterer_Node(this, path, name, have, startstate) );
}

Granterer.prototype.makeHave = function() {
    if ( this.selectedPath && ! this.selectedPath.have ) {
        this.hv_ref.appendChild(this.selectedPath.ref);
        this.selectedPath.beHad();
    }
}

Granterer.prototype.makeNotHave = function() {
    if ( this.selectedPath && this.selectedPath.have ) {
        
        this.hvn_ref.appendChild(this.selectedPath.ref);
        this.selectedPath.beUnHad();
    }
}

Granterer.prototype.selectNode = function(noderef) {
    if ( this.selectedPath ) {
        this.selectedPath.beUnSelected();
    }
    var i;
    for ( i = 0; i < this.paths.length; i++ ) {
        if ( this.paths[i].ref == noderef ) {
            this.selectedPath = this.paths[i];
            this.selectedPath.beSelected();
            return true;
        }   
    }
    this.selectedPath = null;
}

Granterer.prototype.encode = function() {
    var encoded = '';
    var i;
    for ( i = 0; i < this.paths.length; i++ ) {
        encoded += this.paths[i].encode();
    }
    return encoded;
}

Granterer.prototype.init = function() {
    
    var grantfm = document.createElement('FORM');
    grantfm.method = 'POST';
    grantfm.onsubmit = function() { this.permissions.value = grant.encode(); }
    grantfm.action = document.location;
    
    var havenot = document.createElement('DIV');
    havenot.style.width = '200px';
    havenot.style.position = 'relative';
    havenot.style.left = '0px';
    this.hvn_ref = havenot;
    
    var control = document.createElement('DIV'); 
    control.style.width = '30px';
    control.style.position = 'relative';
    control.style.textAlign = 'center';
    this.ct_ref = control;
    
    var have = document.createElement('DIV'); 
    have.style.width = '300px';
    have.style.position = 'relative';
    this.hv_ref = have;
    
    var add         = document.createElement('INPUT');
    add.type        = 'BUTTON';
    add.value       = '>>';
    add.className   = 'go';
    add.onclick     = function() { grant.makeHave() }
    
    var remove      = document.createElement('INPUT');
    remove.type     = 'BUTTON';
    remove.value    = '<<';
    remove.className= 'go';
    remove.onclick  = function() { grant.makeNotHave() }
    
    var save        = document.createElement('INPUT');
    save.type       = 'BUTTON';
    save.value      = 'SAVE';
    save.onclick    = function() { 
        this.form.submit() 
	alert(this.form.permissions.value);
    }
    
    var hidden        = document.createElement('INPUT');
    hidden.type       = 'HIDDEN';
    hidden.value      = '';
    hidden.name       = 'permissions';
    
    control.appendChild(add);
    control.appendChild(document.createElement('BR'));
    control.appendChild(remove);
    control.appendChild(document.createElement('BR'));
    control.appendChild(save);
    control.appendChild(hidden);
    /* for some reason, IE doesn't provide normal JS 1.0 methods to access
    form elements by name, so we do this explicitly */
    grantfm.permissions = hidden;
    
    var i;
    for ( i = 0; i < this.paths.length; i++ ) {
        if ( this.paths[i].have ) {
            have.appendChild(this.paths[i].render()); 
        }
        else {
            havenot.appendChild(this.paths[i].render());
        }
    }
    
    var tb = document.createElement('TABLE');
    var tbb = document.createElement('TBODY');
    var tbr = document.createElement('TR');
    var tbd = document.createElement('TD');

    tbd.style.verticalAlign = 'top';
    tbd.appendChild(havenot);
    tbr.appendChild(tbd);
    
    tbd = document.createElement('TD');
    tbd.style.verticalAlign = 'top';
    tbd.appendChild(control);
    tbr.appendChild(tbd);
    
    tbd = document.createElement('TD');
    tbd.style.verticalAlign = 'top';
    tbd.appendChild(have);
    tbr.appendChild(tbd);
    
    tbb.appendChild(tbr);
    tb.appendChild(tbb);
    
    grantfm.appendChild(tb);
    this.ref.appendChild(grantfm);
}


function Granterer_Node(ref, path, name, have, startstate) {
    this.granterer = ref;
    this.path      = path;
    this.name      = name;
    this.have      = have;
    this.state     = startstate;
}

Granterer_Node.prototype.render = function() {
    var gn = document.createElement('DIV');
    gn.style.padding = '2px';
    gn.style.border  = '1px solid black';
    gn.style.margin  = '1px';
    gn.style.backgroundColor  = '#FFFFFF';
    gn.className     = 'consoletext';
        
    gn.appendChild(document.createTextNode(this.name));
    gn.onclick = function() { grant.selectNode(this) };
    
    
    var perms = document.createElement('DIV');
    perms.style.textAlign = 'right';
    
    var permission;
    for ( permission in this.state ) {
        var chk            = document.createElement('INPUT');
        chk.type           = 'checkbox';
        chk.name           = this.path + '_' + permission;
        chk.defaultChecked = this.state[permission];
        chk.onclick        = function(e) {
            if ( window.event) { 
                window.event.cancelBubble = true;
            }
            else if (e) {
                 e.cancelBubble = true; 
            } 
        }
        perms.appendChild(document.createTextNode(permission));
        perms.appendChild(chk);
        perms.appendChild(document.createTextNode('  '));
    }
    
    
    if ( ! this.have ) {
        perms.style.display = 'none';  
        gn.style.width   = '150px';
    }
    else {
        gn.style.width   = '300px';
    }
    
    gn.appendChild(perms);
    
    this.p_ref = perms;
    this.ref = gn;
    
    return gn;
}

Granterer_Node.prototype.encode = function() {
    if ( this.have ) {
        var enc = '%%' + this.path + ':';
        var permission;
        this.updateState();
        
        for ( permission in this.state ) {
            enc += permission + ',' + this.state[permission] + ',';
        }
        return enc.substr(0,enc.length-1);
    }
    else {
        return '';
    }
}

Granterer_Node.prototype.updateState = function() {
    var i;
    var checkboxes = this.p_ref.getElementsByTagName('INPUT');
    for ( i = 0; i < checkboxes.length; i++ ) {
        var perm = checkboxes[i].name.substr(this.path.length + 1);
        this.state[perm] = checkboxes[i].checked ? 1 : 0;   
    }
}

Granterer_Node.prototype.beSelected = function() {
    this.ref.style.backgroundColor = '#EEEEEE'; 
}

Granterer_Node.prototype.beUnSelected = function() {
    this.ref.style.backgroundColor = '#FFFFFF';  
}

Granterer_Node.prototype.beHad = function() {
    this.ref.style.width     = '300px';
    this.p_ref.style.display = '';
    this.have                = true;
}

Granterer_Node.prototype.beUnHad = function() {
    this.ref.style.width   = '150px';
    this.p_ref.style.display = 'none';
    this.have                = false;
}

