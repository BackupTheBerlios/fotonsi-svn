/* 
 * Funciones para el widget de ToolTop
 */

function mcw_tt_show_tooltop(idnode, html, userclass)
{
    var node = document.getElementById(idnode);
    var tt = document.createElement('div')

    tt.id = '__mcw_tooltip_' + idnode

    if (userclass) {
        tt.setAttribute('class', userclass)
    } else {
        tt.style.display = "none";
        tt.style.marginLeft = '1em';
        tt.style.background = '#ffa';
        tt.style.border = "1px solid black";
        tt.style.padding = "1em";
        tt.style.width = "20%";
        tt.style.fontSize = "0.8em";
    }

    tt.style.position = 'absolute';
    tt.innerHTML = html;
    node.parentNode.appendChild(tt);

    // Hacer que aparezca con el efecto visual
    //var f = Fade(tt, 0, 100, false);

    node_set_opacity(tt, 95);

    setTimeout("o = document.getElementById('"+tt.id+"'); if(o) o.style.display = ''", 1000);
}

function mcw_tt_hide_tooltip(idnode)
{
    var div = document.getElementById('__mcw_tooltip_' + idnode)
    //div.parentNode.removeChild(div);
    var f = Fade(div, 90, 0, true);
}
