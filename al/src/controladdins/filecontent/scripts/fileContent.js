
var fileContent

function Init() {    
    setupIFrame();

    addFileContentControl();
}

function setupIFrame() {
    let iframe = window.frameElement;

    iframe.parentElement.style.display = 'flex';
    iframe.parentElement.style.flexDirection = 'column';
    iframe.parentElement.style.flexGrow = '1';

    iframe.style.removeProperty('height');
    iframe.style.removeProperty('min-height');
    iframe.style.removeProperty('max-height');

    iframe.style.flexGrow = '1';
    iframe.style.flexShrink = '1';
    iframe.style.flexBasis = 'auto';
    iframe.style.paddingBottom = '42px';
}

function addFileContentControl() {
    let div = document.getElementById("controlAddIn");
    div.style = "width:99%; height:99%;overflow: auto";
    div.innerHTML = "";

    fileContent = document.createElement("pre");
    fileContent.readOnly = true;
    fileContent.setAttribute("style","border: none; height: 100%;width: 100%; -webkit-box-sizing: border-box; -moz-box-sizing: border-box; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;font: normal;")

    document.getElementById("controlAddIn").appendChild(fileContent);
}

function Load(data) {
    fileContent.textContent = data;
}
