/*
 * Código para el widget MultiSelect
 */

function mcw_sb_ajax_update(dest, ajax_url, value, headoption)
{
    dest = document.getElementById(dest);
    dest.disabled = true;

    var throbber = add_throbber(dest);
    var ajax_url = ajax_url.replace('%s', value);

    dojo.io.bind({
        'url': ajax_url,
        'load': function(type, data, event) {

            dest.options.length = 0;

            if (headoption) {
                var opt = new Option(headoption, '');
                opt.disabled = true;
                opt.style.fontStyle = 'italic';
                dest.options[0] = opt;
                dest.selectedIndex = 0;
            }

            var newlist = eval(data);
            for (var i = 0; i < newlist.length; i++) {
                dest.options[dest.options.length] = new Option(newlist[i][1], newlist[i][0]);
            }
            dest.disabled = false;
            throbber.parentNode.removeChild(throbber);

            if (dest.onchange != undefined)
                dest.onchange();
        }
    });
}
