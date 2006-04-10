
function mcw_radio_get_value(ids)
{
    for (var i = 0; i < ids.length; i++)
    {
        var o = document.getElementById(ids[i]);
        if (o.checked)
            return o.value;
    }
}
