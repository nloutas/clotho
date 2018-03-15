var Adminform = document.getElementsByTagName('form')[0];
var iFrames = document.getElementsByTagName('IFrame');
var myFrame;
window.onload = function (){ myFrame = editFrame(iFrames[0]); }

function formatText(command,val){
	
        if (myFrame.richdoc.queryCommandEnabled(command)){
		//exec the command
		myFrame.richdoc.execCommand(command,false,val);
		myFrame.focus;
	}
	else {
		alert("Command "+command+" cannot be invoked on current selection !");
		return false;
	}
}

function editFrame(f){
	f.element = eval("Adminform.element_"+f.id);
	if (navigator.appVersion.indexOf("MSIE ") == -1) {
		f.richdoc = f.contentDocument;
		f.richdoc.body.innerHTML = f.element.value;
		f.richdoc.designMode="On";
	}
	else {
		f.richdoc = eval(f.name+".document");
		f.richdoc.designMode="On";
		f.richdoc.write(f.element.value);
	}
	return f;
}

Adminform.onsubmit = function (){
	//save the change into the hidden element
	return myFrame.element.value = myFrame.richdoc.body.innerHTML;
}

