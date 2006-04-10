/*
 * Funciones para el widget TextMultiBox
 */

function tmb_keypress(box, ids) {
    setTimeout(function() { tmb_check_value(box, ids); }, 10);
    return true;
}

function tmb_check_value(box, ids) {
    if ((box.value.length >= box.maxLength) &&
        (__tmb_cache_boxes[box.id] != box.value))
    {
        __tmb_cache_boxes[box.id] = box.value;
        for(var i = 0; i < (ids.length-1); i++) {
            if (ids[i] == box.id) {
                o = document.getElementById(ids[i+1]);
                o.focus();
                o.select();
                return;
            }
        }
    }
}

__tmb_cache_boxes = {};

