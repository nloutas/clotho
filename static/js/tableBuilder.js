
var MM, PR, OK, CC;
var i, y, button, input, fm, table, tbody, tr, td;

// TABLE 
function TBUILD() {
	this.holder = document.getElementById("tableHolder");
}

TBUILD.prototype.init = function() {
	this.table = this.holder.childNodes[0];
	// initiate menu and property objects
	MM = new MENU();
	PR = new PROPERTY();
	if (!this.table){
		TB.addTable();
	} else {
		// editing table - convert cells to objects 
		var rows = this.table.rows;
		for(i=0; i<rows.length; i++){
			var cols = rows[i].cells;
			for(y=0; y<cols.length; y++){
				CC = new CELL(this, null, null, cols[y]);
			}
		}
	}
	MM.editMenu();
}


// MENU 
function MENU(){
	this.holder = document.getElementById("menuHolder");
}

// PROPERTY 
function PROPERTY(){
	this.holder = document.getElementById("propertyHolder");
}

// PROPERTY FOR ITEM 
PROPERTY.prototype.show = function(element, item){
	
	if (this.PropertyOpen!=null){ return; }
	this.PropertyOpen = true;
	
	if (TB.lockCell!=null) { TB.setCell(TB.lockCell) }
	PR.properties(item);
	if (item=='tr'){
		element = element.parentNode;
	}
	
	fm = document.createElement('FORM');
	fm.name = "propertyForm";
	
	table = document.createElement('TABLE');
	tbody = document.createElement('TBODY');
	table.appendChild(fm);
	
	// NN doesnt support setting value of the fields directly
	// I'll load it into finished document form after all is done
	var nnFieldName = new Array();
	var nnFieldValue = new Array();
	
	for(i=0; i<this.attr.length; i++){
		tr 				= document.createElement('TR');
		td 				= document.createElement('TD');
		td.className 	= 'f_text_optional';
		td.innerHTML	= this.attr[i].toLowerCase();
		tr.appendChild(td);
		td 				= document.createElement('TD');
		input 			= document.createElement('INPUT');
		input.id  		= this.attr[i];
		input.name 		= this.attr[i];
		
		var prValue =  PR.value(element, this.attr[i]);
		if(!isNN()){ 
			input.value = prValue; //not in NN
		} else {
			nnFieldName[i]	= this.attr[i];
			nnFieldValue[i]	= prValue;
		}
		td.appendChild(input);
		tr.appendChild(td);
		tbody.appendChild(tr);
	}
	
	table.appendChild(tbody);
	
	var prop = document.createElement('DIV');
	prop.appendChild(table);	
	
	button = document.createElement('IMG');
	button.src = '/static/img/tb_ok.gif';
	button.onclick = function(e) { 
		PR.setValues(element);
	}
	prop.appendChild(button);
	this.holder.appendChild(prop);
	
	if(isNN()){ // here load NN properies in the form fields
		for(i=0; i<nnFieldName.length; i++){
			document.getElementById(nnFieldName[i]).value = nnFieldValue[i];
		}
	}
} 

// PROPERTIES SET VALUES 
PROPERTY.prototype.setValues = function(element){
	for(i=0; i<this.attr.length; i++){
		element.setAttribute(this.attr[i],document.getElementById(this.attr[i]).value)
	}
	PR.shouldClose();
}

// PROPERTY SHOULD CLOSE
PROPERTY.prototype.shouldClose = function(){
	MM.edittable.disabled=false;
	
	if (TB.currentCell==null){ 
		disableCellButtons();
	} else {
		enableCellButtons();
	}
		
	var menu = this.holder.childNodes;
	for(var i=0; i<menu.length ; i++){
		this.holder.removeChild(menu[i])
	}
	this.PropertyOpen = null;
}

// PROPERTIES FOR ELEMENTS
PROPERTY.prototype.properties = function(kind){
	
	this.attr = new Array();
	
	if (kind=='table'){
		this.attr[0] = 'width';		
		this.attr[1] = 'cellPadding';
		this.attr[2] = 'cellSpacing';
		this.attr[3] = 'className';
		this.attr[4] = 'bgColor';
		this.attr[5] = 'border';
		this.attr[6] = 'borderColorLight';
		this.attr[7] = 'borderColorDark';		
	}
	if (kind=='td'){
		this.attr[0] = 'width';		
		this.attr[1] = 'colspan';
		this.attr[2] = 'bgColor';
		this.attr[3] = 'vAlign';
		this.attr[4] = 'align';
	}
	if (kind=='tr'){
		this.attr[0] = 'bgColor';		
		this.attr[1] = 'vAlign';
		this.attr[2] = 'align';
	}
}

// VALUE FOR KIND AND PROPERTY
PROPERTY.prototype.value = function(element, attribute){
	if(element==null || attribute==null){ alert("Something wrong!");}
	return element.getAttribute(attribute);
}

// EDIT MENU
MENU.prototype.editMenu = function(){
	
	var br = document.createElement('BR');
	
	// EDIT TABLE
	this.edittable = document.createElement('IMG');
	this.edittable.src = '/static/img/tb_edit.gif';
	this.edittable.style.marginRight = '3px';
	this.edittable.onclick = function(e) { 
		PR.show(TB.table, 'table'); 
	}
	this.holder.appendChild(this.edittable);

	//ADD COL
	this.addcol = document.createElement('IMG');
	this.addcol.src = '/static/img/tb_add_col.gif';
	this.addcol.style.marginRight = '3px';
	this.addcol.onclick = function(e) { TB.addColumn(); }
	this.holder.appendChild(this.addcol);
	
	//DELETE COL
	this.delcell = document.createElement('IMG');
	this.delcell.src = '/static/img/tb_del_col_d.gif';
	this.delcell.onclick = function(e) { TB.deleteColumn(); }
	this.holder.appendChild(this.delcell);
	
	this.holder.appendChild(br);
	
	//ADD ROW
	this.addrow = document.createElement('IMG');
	this.addrow.src = '/static/img/tb_add_row.gif';
	this.addrow.style.marginRight = '3px';
	this.addrow.onclick = function(e) { TB.addRow(); }
	this.addrow.style.marginLeft = '127px';
	this.addrow.style.marginTop = '3px';
	this.addrow.style.marginBottom = '3px';
	this.holder.appendChild(this.addrow);
	
	//EDIT ROW
	this.editrow = document.createElement('IMG');
	this.editrow.src = '/static/img/tb_edit_row_d.gif';
	this.editrow.style.marginRight = '3px';
	this.editrow.onclick = function(e) {
		if (TB.currentCell){
			PR.show(TB.currentCell, 'tr'); 
			disableCellButtons();
		}
	}
	this.editrow.style.marginTop = '3px';
	this.editrow.style.marginBottom = '3px';
	this.holder.appendChild(this.editrow);

	//DELETE ROW
	this.delrow = document.createElement('IMG');
	this.delrow.src = '/static/img/tb_del_row_d.gif';
	this.delrow.style.marginTop = '3px';
	this.delrow.style.marginBottom = '3px';
	this.delrow.style.marginRight = '3px';
	this.delrow.onclick = function(e) { TB.deleteRow(); }
	this.holder.appendChild(this.delrow);
	
	var br = document.createElement('BR');
	this.holder.appendChild(br);
	
	//ADD CELL
	this.addcell = document.createElement('IMG');
	this.addcell.src = '/static/img/tb_add_cell_d.gif';
	this.addcell.style.marginLeft = '127px';
	this.addcell.style.marginRight = '3px';
	this.addcell.onclick = function(e) { TB.addCell(TB.currentCell); }
	this.holder.appendChild(this.addcell);
	
	//EDIT CELL
	this.editcell = document.createElement('IMG');
	this.editcell.src = '/static/img/tb_edit_cell_d.gif';
	this.editcell.style.marginRight = '3px';
	this.editcell.onclick = function(e) {
		if (TB.currentCell){
			PR.show(TB.currentCell, 'td'); 
			disableCellButtons(); 
		}
	}
	this.holder.appendChild(this.editcell);
	
	//COLSPAN CELLS
	this.colspancell = document.createElement('IMG');
	this.colspancell.src = '/static/img/tb_colspan_d.gif';
	this.colspancell.onclick = function(e) { TB.colspanCells(); }
	this.holder.appendChild(this.colspancell);
	
	//REVIEW
	butt = document.createElement('IMG');
	butt.src = '/static/img/tb_preview.gif';
	butt.onclick = function(e) { TB.done(); }
	document.getElementById("doneButtonHolder").appendChild(butt);
}

// ADD TABLE
TBUILD.prototype.addTable = function(){
	
	var table = document.createElement('TABLE');
	table.border = '1px';
	table.width = '100%';
	table.cellSpacing = '0px';
	table.cellPadding = '0px';
	
	var tbody = document.createElement('TBODY');
	table.appendChild(tbody)
	this.holder.appendChild(table);
	this.table = table;
	
	TB.addRow();
	TB.addColumn();
}

//ADD CELL
function CELL(ref,rowPossition, colPossition, CC){
	
	if (rowPossition!=null && colPossition!=null){
		// this is called from add column or row
		ref.table.tBodies[0].rows[rowPossition].insertCell(colPossition);
		ref.table.tBodies[0].rows[rowPossition].cells[colPossition].innerHTML = "new cell";
		CC = ref.table.tBodies[0].rows[rowPossition].cells[colPossition]
	}
	if(isNN()){
		CC.onmousedown = function(e) { TB.selectCell(CC); TB.editCell(CC); enableCellButtons(); }
	} else {
		CC.onclick = function(e) { TB.selectCell(CC) }
		CC.ondblclick = function(e) { TB.editCell(CC) }
	}
	
}

// SELECT CELL 
TBUILD.prototype.selectCell = function(cell){
	enableCellButtons();
	
	TB.currentCell = cell;
	PR.shouldClose();
	MM.editcell.disabled=false; 
	var cells = document.getElementsByTagName('TD');
	for(i=0; i<cells.length; i++){
		cells[i].borderColor = '';
	}
	if (cell!=null) { cell.borderColor = '#ff0000' }
	if (this.lockCell!=null && this.lockCell!=cell) { this.setCell(this.lockCell) }
}

// EDIT CELL 
TBUILD.prototype.editCell = function(cell){
	PR.shouldClose();
	
	// if some cell is in edit mode, save it
	if (this.lockCell!=null && this.lockCell!=cell){
		this.setCell(this.lockCell);
	}
	
	if(this.lockCell==null){
	
		this.lockCell = cell;
	
		var previousValue = cell.innerHTML;
	
		var agt=navigator.userAgent.toLowerCase();

		if (isIePC()) {
    		// rich text editor
			var ifr 		= document.createElement('IFRAME');
			ifr.name		= 'body'; 
			ifr.id 			= 'body';
			ifr.style.width	= '100%';
			ifr.style.height		= '100';
			ifr.style.marginWidth 	= '0';
			ifr.style.marginHeight	= '0';
			ifr.style.border		= '0';
			
			div = document.createElement('DIV');
			div.id = "flagbody";
			
			RichEdits[0] = 'body';
			
			cell.innerHTML = ifr.outerHTML;
    		insertCurrentValues('body',previousValue);
			document.getElementById('toolbarbody').style.visibility = 'visible';
			defaultEditArea('body');
			
		} else {
			var fm = document.createElement('FORM');
			fm.name = "cellForm";
	
			this.input = document.createElement('TEXTAREA');
			this.input.style.width = '100%';
			this.input.style.height = '100';
			this.input.style.border = '0';
			this.input.name = "cellValue";
			this.input.id = "cellValue";
	
			// this doesnt work in NN, can't set value??? bastard
			if(!isNN()){ this.input.value = previousValue; } 
	
			fm.appendChild(this.input);
			cell.innerHTML = "";
			if(!isNN()){
				cell.innerHTML = this.input.outerHTML;
			} else {
				cell.appendChild(fm);
				document.cellForm.cellValue.value = previousValue;
			}
		}
	}
}

// ADD CELL 
TBUILD.prototype.addCell = function(cell){
	if (this.currentCell!=null){
		var row = this.currentCell.parentNode.rowIndex;
		CC = new CELL(this, row, eval(cell.cellIndex+1) );
	}
}

// SET CELL VALUE
TBUILD.prototype.setCell = function(cell){
	
    var val;
	
	if(isIePC()){
		
		val = body.document.body.innerHTML;
		document.getElementById('toolbarbody').style.visibility = 'hidden';
		
	} else {
		var pattern = /\n/ig;
		val = document.getElementById("cellValue").value.replace(pattern,'<br/>');
	}
	cell.innerHTML = val;
	this.lockCell = null;
	
}

// DONE
TBUILD.prototype.done = function(){
	if (this.lockCell!=null) { this.setCell(this.lockCell) }
	TB.selectCell();
	disableCellButtons();
}

// ADD COLUMN
TBUILD.prototype.addColumn = function(){
	
	var insertPossition;
	
	if (this.currentCell!=null){
		insertPossition = this.currentCell.cellIndex + 1;
	} else {
		insertPossition = this.table.tBodies[0].rows[0].cells.length;
	}
	
	var rows = this.table.tBodies[0].rows;
	for(i=0; i<rows.length; i++){
		CC = new CELL(this, i, insertPossition);
	}
}

// DELETE COLUMN
TBUILD.prototype.deleteColumn = function(){
	
	var deletePossition;
	
	if (this.currentCell!=null){
		deletePossition = this.currentCell.cellIndex;
		
		var rows = this.table.tBodies[0].rows;
		for(i=0; i<rows.length; i++){
			if (this.table.tBodies[0].rows[i].cells.length > deletePossition){
				this.table.tBodies[0].rows[i].deleteCell(deletePossition)
			}
		}
	}
	disableCellButtons();
}

// COLSPAN CELLS
TBUILD.prototype.colspanCells = function(){
	
	if (this.currentCell!=null){
		var cellPossition = this.currentCell.cellIndex;
		var rowPossition = this.currentCell.parentNode.rowIndex;
		
		var x = this.currentCell.getAttribute('colSpan');
		if (x==""){ x=1 }
		
		if (this.table.tBodies[0].rows[rowPossition].cells.length > 1){
//		if (cellsNo>=eval(cellPossition+1)){
			var cs = x+1; // must be here, bug in NN6
			this.currentCell.colSpan=cs;
			this.table.tBodies[0].rows[rowPossition].deleteCell(cellPossition+1);
		}
	}
}

// MAXIMUM COLS
function maxCols(){
	
	var rows = TB.table.tBodies[0].rows;
	var count = 0;
	for(i=0; i<rows.length; i++){
		if (count<rows[i].cells.length){
			count = rows[i].cells.length;
		}
	}
	return count;
}

// DELETE ROW
TBUILD.prototype.deleteRow = function(){
	
	var deletePossition;
	
	if (this.currentCell!=null){
		deletePossition = this.currentCell.parentNode.rowIndex;
		this.table.tBodies[0].deleteRow(deletePossition);
		disableCellButtons();
	}
}


// ADD ROW
TBUILD.prototype.addRow = function(){
	
	var insertPossition;
	
	if (this.currentCell!=null){
		insertPossition = this.currentCell.parentNode.rowIndex + 1;
	} else {
		insertPossition = this.table.tBodies[0].rows.length;
	}
	
	this.table.tBodies[0].insertRow(insertPossition);
	
	var cols = this.table.tBodies[0].rows[0].cells;
	for(i=0; i<cols.length; i++){
		CC = new CELL(this, insertPossition, i);
	}
}



function enableCellButtons() {
	MM.editcell.src		= '/static/img/tb_edit_cell.gif';
	MM.editrow.src		= '/static/img/tb_edit_row.gif';
	MM.delcell.src		= '/static/img/tb_del_col.gif';
	MM.delrow.src		= '/static/img/tb_del_row.gif';
	MM.colspancell.src	= '/static/img/tb_colspan.gif';
	MM.addcell.src		= '/static/img/tb_add_cell.gif';
}

function disableCellButtons() {
	MM.editcell.src 	= '/static/img/tb_edit_cell_d.gif';
	MM.editrow.src		= '/static/img/tb_edit_row_d.gif';
	MM.delcell.src 		= '/static/img/tb_del_col_d.gif';
	MM.delrow.src 		= '/static/img/tb_del_row_d.gif';
	MM.colspancell.src	= '/static/img/tb_colspan_d.gif';
	MM.addcell.src		= '/static/img/tb_add_cell_d.gif';
	
}

var agt=navigator.userAgent.toLowerCase();

function isNN(){
	if (agt.indexOf("netscape") != -1 ) {// NN
  		return true;
	}
	return false;
}
function isIeMac(){
	if (agt.indexOf("msie") != -1 && navigator.platform.indexOf('Mac')!= -1) {
		// Internet Explorer on Mac
  		return true;
	}
	return false;
}
function isIePC(){
	if (agt.indexOf("msie") != -1 && navigator.platform.indexOf('Win')!= -1) {
		// Internet Explorer on PC
  		return true;
	}
	return false;
}


// DEBUGGING
function show(object) {
	for (var i in object) {     
		document.write("Property: ",i," Value: ",object [i], "<BR>");
	}
}
