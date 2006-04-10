/*
 * Código para el widget MultiSelect
 */

function mcw_mv_additem(idtable, val, htmlcolumns, register)
{
    var row, cell, i, data;

    table = document.getElementById(idtable);

    // Evitar duplicados
    row_id = idtable + '_row_' + hex_md5(val);
    row = document.getElementById(row_id);
    if (row) {
        new Effect.Highlight(row);
    } else {

        // Insertar la fila en el DOM
        row = table.insertRow(table.rows.length)
        row.id = row_id;

        // Add the columns
        data = htmlcolumns[val];
        if (data) {
            for (i = 0; i < data.length; i++) {
                cell = row.insertCell(row.cells.length);
                cell.innerHTML = html_escape(data[i]);
            }
        } else {
            cell = row.insertCell(0);
            cell.innerHTML = html_escape(val);
        }

        cell = row.insertCell(row.cells.length);
        val = escape(val).replace(/%/g, '\\x');
        cell.innerHTML = '<input type="button" value="-" onclick="mcw_mv_delitem(&quot;'+row_id+'&quot;)" />' +
                         '<input type="hidden" value="' + val + '" name="' + register + '" />';
    }

    return row_id;
}

function mcw_mv_delitem(idrow)
{
    r = document.getElementById(idrow);
    r.parentNode.deleteRow(r.rowIndex);
}

function mcw_mv_keydown(widget, event, fnadd)
{
    if (event.keyCode == 13) {
        fnadd();
        widget.select();
        return false;
    }
    return true;
}
