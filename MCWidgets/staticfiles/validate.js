/*
 * Código para la validación de widgets
 */

var ID_DIV_ERRORS = 'mcw_form_id_div';
var _mcw_modified_fields = {};

function __mcw_form_close_error()
{
    // Restaurar el estado de los widgets
    var n = document.getElementById(ID_DIV_ERRORS);
    if (n)
        n.parentNode.removeChild(n);

    for (n in _mcw_modified_fields) {
        var field = _mcw_modified_fields[n];
        try {
            field[0].style.borderStyle = field[1];
            field[0].style.borderColor = field[2];
            delete _mcw_modified_fields[n];
        } catch (e) {}
    }

    // Devolver falso por si se usa en un onclick
    return false;
}

function mcw_form_validate(tests)
{
    __mcw_form_close_error();

    var n;
    var errors = [];

    for (n = 0; n < tests.length; n++) {
        var test = tests[n];
        try {
            if(! eval(test.validate))
                errors[errors.length] = test;
        } catch (e) {
            /* Ignorar (por ahora, al menos) los errores que se produzcan
             * en un test concreto, para que los demás se puedan terminar
             */
        }
    }

    if (errors.length == 0)
        return true;

    // Mostrar los errores
    var diverrors = document.createElement('div');
    var list = document.createElement('ul');
    for (n = 0; n < errors.length; n++) {
        var error = errors[n];

        var anchor = document.createElement('a');
        anchor.href = "javascript:" + error.onselect;
        anchor.innerHTML = error.msg;

        var item = document.createElement('li');
        item.appendChild(anchor);
        list.appendChild(item);

        // Marcar el borde
        if (error.markitem) {
            item = document.getElementById(error.markitem);
            _mcw_modified_fields[error.markitem] = [item, item.style.borderStyle, item.style.borderColor];
            item.style.borderStyle = "solid";
            item.style.borderColor = "red";
        }
    }

    diverrors.appendChild(list);

    // DIV para contener la lista de errores
    var div = document.createElement('div');
    div.id = ID_DIV_ERRORS;
    div.className = 'errorbox';
    div.appendChild(document.createTextNode("Errores"));

    var img = new Image(); 
    img.src = '/staticmcw/cerrar.png';
    img.onclick = __mcw_form_close_error;

    div.appendChild(img);
    div.appendChild(diverrors);
    document.body.appendChild(div);

    return false;
}
