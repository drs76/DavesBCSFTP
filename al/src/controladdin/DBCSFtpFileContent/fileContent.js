
function Init() {
    setupIFrame();
}

function setupIFrame() {
    var iframe = window.frameElement;
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

function Load(base64Data, filename) {
    var container = document.getElementById('controlAddIn');
    container.style.cssText = 'width:100%;height:100%;overflow:auto;box-sizing:border-box;display:flex;align-items:flex-start;';
    container.innerHTML = '';

    var ext = getExtension(filename);

    if (isImage(ext)) {
        renderImage(container, base64Data, ext);
    } else if (ext === 'pdf') {
        renderPdf(container, base64Data);
    } else if (ext === 'csv') {
        renderCsv(container, base64Data);
    } else if (ext === 'xlsx' || ext === 'xls') {
        renderExcel(container, base64Data);
    } else {
        renderText(container, base64Data);
    }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function getExtension(filename) {
    if (!filename) return '';
    var parts = filename.split('.');
    return parts.length > 1 ? parts[parts.length - 1].toLowerCase() : '';
}

function isImage(ext) {
    return ['png', 'jpg', 'jpeg', 'gif', 'svg', 'webp', 'bmp', 'ico'].indexOf(ext) !== -1;
}

function getMimeType(ext) {
    var types = {
        png: 'image/png',
        jpg: 'image/jpeg',
        jpeg: 'image/jpeg',
        gif: 'image/gif',
        svg: 'image/svg+xml',
        webp: 'image/webp',
        bmp: 'image/bmp',
        ico: 'image/x-icon'
    };
    return types[ext] || 'application/octet-stream';
}

function base64ToText(base64) {
    try {
        return decodeURIComponent(escape(atob(base64)));
    } catch (e) {
        return atob(base64);
    }
}

function base64ToBlob(base64, mimeType) {
    var binary = atob(base64);
    var bytes = new Uint8Array(binary.length);
    for (var i = 0; i < binary.length; i++) {
        bytes[i] = binary.charCodeAt(i);
    }
    return new Blob([bytes], { type: mimeType });
}

function sharedStyle() {
    return 'font-family:"Segoe UI",Tahoma,Geneva,Verdana,sans-serif;font-size:13px;';
}

// ---------------------------------------------------------------------------
// Renderers
// ---------------------------------------------------------------------------

function renderImage(container, base64Data, ext) {
    var img = document.createElement('img');
    img.src = 'data:' + getMimeType(ext) + ';base64,' + base64Data;
    img.style.cssText = 'max-width:100%;height:auto;display:block;';
    container.appendChild(img);
}

function renderPdf(container, base64Data) {
    container.style.cssText += 'height:100%;';
    var url = URL.createObjectURL(base64ToBlob(base64Data, 'application/pdf'));
    var embed = document.createElement('embed');
    embed.src = url;
    embed.type = 'application/pdf';
    embed.style.cssText = 'width:100%;height:100%;min-height:600px;border:none;';
    container.appendChild(embed);
}

function renderText(container, base64Data) {
    var pre = document.createElement('pre');
    pre.style.cssText = 'width:100%;margin:0;padding:12px;box-sizing:border-box;'
        + 'white-space:pre-wrap;word-break:break-all;overflow:auto;'
        + sharedStyle();
    pre.textContent = base64ToText(base64Data);
    container.appendChild(pre);
}

function renderCsv(container, base64Data) {
    var text = base64ToText(base64Data);
    var rows = parseCsv(text);

    var wrapper = document.createElement('div');
    wrapper.style.cssText = 'overflow:auto;width:100%;padding:8px;box-sizing:border-box;';

    var table = document.createElement('table');
    table.style.cssText = 'border-collapse:collapse;width:100%;' + sharedStyle();

    rows.forEach(function (row, rowIdx) {
        var tr = document.createElement('tr');
        if (rowIdx === 0) {
            tr.style.cssText = 'background:#0078d4;color:white;font-weight:bold;position:sticky;top:0;';
        } else {
            tr.style.background = rowIdx % 2 === 0 ? '#f3f3f3' : 'white';
        }
        row.forEach(function (cell) {
            var td = document.createElement(rowIdx === 0 ? 'th' : 'td');
            td.textContent = cell;
            td.style.cssText = 'border:1px solid #ddd;padding:5px 10px;text-align:left;white-space:nowrap;';
            tr.appendChild(td);
        });
        table.appendChild(tr);
    });

    wrapper.appendChild(table);
    container.appendChild(wrapper);
}

function parseCsv(text) {
    var rows = [];
    var lines = text.replace(/\r\n/g, '\n').replace(/\r/g, '\n').split('\n');
    for (var l = 0; l < lines.length; l++) {
        var line = lines[l];
        if (line.trim() === '') continue;
        var row = [];
        var inQuote = false;
        var field = '';
        for (var i = 0; i < line.length; i++) {
            var ch = line[i];
            if (ch === '"') {
                if (inQuote && line[i + 1] === '"') { field += '"'; i++; }
                else inQuote = !inQuote;
            } else if (ch === ',' && !inQuote) {
                row.push(field);
                field = '';
            } else {
                field += ch;
            }
        }
        row.push(field);
        rows.push(row);
    }
    return rows;
}

function renderExcel(container, base64Data) {
    if (typeof XLSX !== 'undefined') {
        renderExcelWithLibrary(container, base64Data);
        return;
    }
    loadScript(
        'https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js',
        function () { renderExcelWithLibrary(container, base64Data); },
        function () { showError(container, 'Could not load the Excel viewer library. Internet access may be required, or bundle xlsx.full.min.js with the extension.'); }
    );
}

function renderExcelWithLibrary(container, base64Data) {
    try {
        var workbook = XLSX.read(base64Data, { type: 'base64' });

        var tabBar = document.createElement('div');
        tabBar.style.cssText = 'display:flex;flex-wrap:wrap;gap:4px;padding:4px 8px;background:#f0f0f0;border-bottom:1px solid #ddd;' + sharedStyle();

        var contentArea = document.createElement('div');
        contentArea.style.cssText = 'overflow:auto;width:100%;flex:1;padding:8px;box-sizing:border-box;';

        workbook.SheetNames.forEach(function (name, idx) {
            var tab = document.createElement('button');
            tab.textContent = name;
            tab.style.cssText = 'padding:4px 12px;border:1px solid #bbb;cursor:pointer;border-radius:3px;'
                + (idx === 0 ? 'background:#0078d4;color:white;' : 'background:white;color:#333;');
            tab.addEventListener('click', function () {
                tabBar.querySelectorAll('button').forEach(function (b) {
                    b.style.background = 'white'; b.style.color = '#333';
                });
                tab.style.background = '#0078d4';
                tab.style.color = 'white';
                renderSheet(contentArea, workbook, name);
            });
            tabBar.appendChild(tab);
        });

        renderSheet(contentArea, workbook, workbook.SheetNames[0]);

        container.style.cssText = 'width:100%;height:100%;display:flex;flex-direction:column;box-sizing:border-box;overflow:hidden;';
        if (workbook.SheetNames.length > 1) container.appendChild(tabBar);
        container.appendChild(contentArea);
    } catch (e) {
        showError(container, 'Could not render Excel file: ' + e.message);
    }
}

function renderSheet(container, workbook, sheetName) {
    container.innerHTML = '';
    var ws = workbook.Sheets[sheetName];
    var html = XLSX.utils.sheet_to_html(ws, { editable: false, id: 'xlsheet' });

    var wrapper = document.createElement('div');
    wrapper.innerHTML = html;

    var table = wrapper.querySelector('table');
    if (table) {
        table.style.cssText = 'border-collapse:collapse;' + sharedStyle();
        table.querySelectorAll('td,th').forEach(function (cell) {
            cell.style.cssText = 'border:1px solid #ddd;padding:4px 8px;white-space:nowrap;';
        });
        var firstRow = table.querySelector('tr');
        if (firstRow) firstRow.style.cssText = 'background:#0078d4;color:white;font-weight:bold;position:sticky;top:0;';
    }
    container.appendChild(wrapper);
}

function loadScript(url, onLoad, onError) {
    var script = document.createElement('script');
    script.src = url;
    script.onload = onLoad;
    script.onerror = onError;
    document.head.appendChild(script);
}

function showError(container, message) {
    var p = document.createElement('p');
    p.style.cssText = 'color:#d32f2f;padding:16px;' + sharedStyle();
    p.textContent = message;
    container.appendChild(p);
}
