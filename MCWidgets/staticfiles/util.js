
// Crear el nodo de la imagen, para que se esté bajada cuando haga falta.
var throbber_image = document.createElement('img');
throbber_image.setAttribute('src', '/staticmcw/throbber.gif');
throbber_image.display = 'none'

function add_throbber(node)
{
    var img = throbber_image.cloneNode(false);

    img.style.border = 0;
    img.style.position = 'absolute';
    img.style.marginLeft = '1em';
    img.style.display = ''
    node.parentNode.appendChild(img);
    return img;
}

function node_real_top(node)
{
    return node.offsetTop + node.offsetParent.top;
}

function html_escape(text)
{
    return text.
        replace(/&/g, '&amp;').
        replace(/>/g, '&gt;').
        replace(/</g, '&lt;');
}

/*
 * Efectos de transparencias 
 */

function node_set_opacity(node, opacity)
{
    node.style.filter = 'alpha(opacity: '+opacity+')';   // Para IE
    node.style.opacity = opacity / 100.                  // Para navegadores de verdad
}


function Fade(node, start, end, removeAtFinish) 
{
    var fade = new Array();
    fade.node = node;
    fade.start = start;
    fade.end = end;
    fade.removeAtFinish = removeAtFinish;
    fade.forceStop = false;
    fade.direction = start < end;   // 0 decrece, 1 crece

    // Ver si hay otro efecto en marcha
    if (node.mcwFadeObject) {
        node.mcwFadeObject.forceStop = true;
        fade.current = node.mcwFadeObject.current;
    } else {
        fade.current = start;
    }

    node.mcwFadeObject = fade;
    node_set_opacity(node, start);

    var fn = function() {  _fade_timer(fade); };
    fade.timer = setTimeout(fn, 50);
}

function _fade_timer(fade) {
    clearTimeout(fade.timer);
    if ((fade.direction && (fade.current > fade.end)) ||
        (!fade.direction && (fade.current < fade.end)) ||
        fade.forceStop) {

        if (fade.removeAtFinish)
            fade.node.parentNode.removeChild(fade.node);
    } else {
        node_set_opacity(fade.node, fade.current);
        fade.current += (fade.direction ? 10 : -10);

        var fn = function() { _fade_timer(fade) };
        fade.timer = setTimeout(fn, 50);
    }
}

// Intercambiar dos nodos en el DOM
function swapNode (nodeA) {
  var nextSibling = nodeB.nextSibling;
  var parentNode = nodeB.parentNode;
  nodeA.parentNode.replaceChild(nodeB, nodeA);
  parentNode.insertBefore(nodeA, nextSibling);
}


// Eliminar espacios por los lados
function trim_spaces(s)
{
    var g = /^\s*(.*?)\s*$/.exec(s);
    return g ? g[1] : s;
}
