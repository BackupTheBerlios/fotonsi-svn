/*
 * Código para el widget ListMultiCol
 */


function __mcw_lmc_parse_str(str, idtable, num, rowid)
{
    return str.
        replace(/%I/g, idtable).
        replace(/%N/g, num).
        replace(/%R/g, rowid).
        replace(/%DELROW%/g, "mcw_lmc_delrow(&quot;"+idtable+"_row_"+num+"&quot;);");
}

function mcw_lmc_addrow(idtable, htmlcolumns, idcounter)
{
    var row, cell, i;

    table = document.getElementById(idtable);
    counter = document.getElementById(idcounter);

    num = counter.value;
    counter.value = parseInt(num) + 1;

    row = table.insertRow(table.rows.length)
    row.id = idtable + '_row_' + num;

    // Add the columns
    for (var i = 0; i < htmlcolumns.length; i++) {
        cell = row.insertCell(row.cells.length);
        cell.innerHTML = __mcw_lmc_parse_str(htmlcolumns[i], idtable, num, row.id);
    }

    __mcw_lmc_invoke_rows_change(row);
    return row.id;
}

function mcw_lmc_delrow(idrow)
{
    var r = document.getElementById(idrow);
    var p = r.parentNode;
    p.deleteRow(r.rowIndex);

    __mcw_lmc_invoke_rows_change(p);
}

function mcw_lmc_moverow(node, dir)
{
    // Encontrar la fila a la que pertenece
    while (node && node.nodeName.toLowerCase() != 'tr')
        node = node.parentNode;

    if (!node)
        return;

    var swap = node.rowIndex+dir;
    var rows = node.parentNode.rows;
    if ((swap < 1) || (!rows[swap]))
        return;

    swapNode(rows[swap], node);

    __mcw_lmc_invoke_rows_change(node);
}

function __mcw_lmc_invoke_rows_change(node)
{
    try {
        while(node) {
            if (node.tagName.toLowerCase() == 'table') {
                eval(window[node.id + '_js_rows_change']);
                return;
            }
            node = node.parentNode;
        }
    }
    catch(e)  
    {}
    
}

function mcw_lmw_getitems(idtable, counter, pattern)
{
    var result = [];
    var elements = _mcw_lmw_get_rows(idtable, counter);
    for (var i = 0; i < elements.length; i++) {
        var num = elements[i];
        var row = {};

        for (var j = 0; j < pattern.length; j++) {
            var field = pattern[j];
            row[field.name] = __mcw_lmc_parse_str(field.id, idtable, num, idtable + '_row_' + num);
        }

        result[i] = row;
    }

    return result;
}


function mcw_lmw_before_submit(tableid, counter, register)
{
    var rg = _mcw_lmw_get_rows(tableid, counter);
    document.getElementsByName(register)[0].value = rg.join('\x01');
    return true;
}

function _mcw_lmw_get_rows(tableid, counter)
{
    var rg = [];
    var rows =  document.getElementById(tableid).rows;

    for (var i = 0; i < rows.length; i++) {
        var cells = rows[i].cells;

        // Damos por hecho que el campo está en la última celda
        var last = cells[cells.length-1].childNodes;

        for (var c = 0; c < last.length; c++) {
            var item = last[c];
            if (item.name == counter)
                rg.push(item.value);
        }
    }

    return rg;
}

var __mcw_lmc_timeout_filter = {};

function mcw_lmc_filter_keypress(filter, tableid)
{
    clearTimeout(__mcw_lmc_timeout_filter[tableid]);
    __mcw_lmc_timeout_filter[tableid] = setTimeout(function() {
            __mcw_lmc_filter_action(filter, tableid);
    }, 300);
}

function __mcw_lmc_filter_action(filter, tableid)
{
    var words = [];
    var i, j;

    // Buscar las palabras
    var w = filter.value.toLowerCase().split(' ');
    for (i = 0; i < w.length; i++) {
        if((j = trim_spaces(w[i])))
            words.push(j);
    }

    var rows = document.getElementById(tableid).rows;

    if (words.length < 1) {
        // Si no hay ningún patrón, mostramos todas las filas

        for (i = 0; i < rows.length; i++) 
            if (rows[i].style.display == 'none')
                rows[i].style.display = '';

    } else {

        // Recorrer las filas para ver si están todas las 
        // palabras buscadas
        for (i = 1; i < rows.length; i++) {
            var cont = rows[i].textContent.toLowerCase();
            var display = '';
            for (j = 0; j < words.length; j++) {
                if (cont.indexOf(words[j]) < 0) {
                    display = 'none';
                    break;
                }
            }

            rows[i].style.display = display;
        }
    }

}
