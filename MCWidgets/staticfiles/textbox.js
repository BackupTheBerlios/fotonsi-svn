/*
 * Funciones para el widget TextBox y Numeric
 */
 

function mcw_tb_sync_widget(value, dest, maptable)
{
    var value;
    var dest;

    if (maptable)
        value = maptable[value];
    dest = document.getElementById(dest);
    dest.value = value
    new Effect.Highlight(dest);
}

function mcw_tb_trim_spaces(target)
{
    var g = /^\s*(.*?)\s*$/.exec(target.value);
    if (g)
        target.value = g[1];
    return true;
}

function _mcw_get_seps(widget_id)
{
    return window['__mcw__separatos__' + widget_id];
}

function mcw_numeric_focus (target) {
    var o = document.getElementById(target);
    var seps = _mcw_get_seps(target)[1];

    while (seps.length > 0 && o.value.indexOf(seps) >= 0)
        o.value = o.value.replace(seps, '');
    o.style.color = '';
}

function mcw_numeric_blur (target) {
    var seps = _mcw_get_seps(target);
    var target = document.getElementById(target);

    // Comprobar si es un número válido
    var value = target.value;
    value = value.replace(seps[0], ',');
    if (! (/^-?\d+(,\d+)?$/.exec(value))) {
        target.style.color = 'red';
        return true;
    }

    var parts = value.split(',')
    var pre = '';
    var i = parts[0];
    var d = parts[1] ? (seps[0]+parts[1]) : '';

    if (i[0] == '-') {
        pre = '-';
        i = i.substring(1)
    }

    target.value = pre + i.
        split('').reverse().join('').
        replace(/.{1,3}/g, function (n) { return seps[1] + n }).substr(seps[1].length).
        split('').reverse().join('')
        + d;
}

function mcw_numeric_get_value(id)
{
    var val = document.getElementById(id).value;
    var seps = _mcw_get_seps(target)[1];

    while (seps[1].length > 0 && o.value.indexOf(seps[1]) >= 0)
        o.value = o.value.replace(seps[1], '');
    return parseFloat(val.replace(seps[0], '.'));
}

