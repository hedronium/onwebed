import '../sass/edit.sass'

import { Elm } from '../../document_editor/src/Main.elm'

var app = Elm.Main.init({
    node: document.querySelector(".content"),
    flags: {
        pageName: page_name,
        pageTitle: page_title,
        content: page_content,
        csrfToken: csrf_token
    }
});

app.ports.overlay.subscribe(function(enable) {
    if (enable == true)
        document.querySelector("html").classList.add("noscroll");
    else
        document.querySelector("html").classList.remove("noscroll");
});

app.ports.setupTextEditor.subscribe(function(value) {
    let view_odl_overlay = document.getElementById("view_odl_overlay");

    let odl_editor_element;

    if (view_odl_overlay.classList.contains("invisible"))
        odl_editor_element = document.querySelector("#edit_box_overlay #odl_editor");
    else
        odl_editor_element = document.querySelector("#view_odl_overlay #odl_editor");

    let editor = ace.edit(odl_editor_element);

    editor.session.setValue(value);
    editor.session.setUseWrapMode(true);

    editor.on("change", function(e) {
        app.ports.setOdlString.send(editor.getValue());
    });
});

function adjust_spacing() {
    let window_width = (window.innerWidth > 0) ? window.innerWidth : screen.width;

    let menu_height = document.getElementById("menu").offsetHeight;
    let playground = document.getElementById("playground");

    if (window_width >= 769)
        playground.style.marginTop = menu_height + "px";
    else
        playground.style.marginTop = "0px";
}

document.addEventListener("DOMContentLoaded", adjust_spacing);
window.addEventListener('resize', adjust_spacing);