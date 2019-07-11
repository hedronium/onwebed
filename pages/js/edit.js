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
    var editor = ace.edit("odl_editor");

    editor.session.setValue(value);
    editor.session.setUseWrapMode(true);

    editor.on("change", function(e) {
        app.ports.setOdlString.send(editor.getValue());
    });
});