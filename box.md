---
description: >-
  The concept of box is fundamental to the design of Onwebed. It's designed to
  be extensible, yet simple to understand. It's the building block of pages.
---

# Box

## Introduction

Every single website is composed of pages, which in turn is defined by _boxes._

There are two types of boxes - solid, and liquid. However, every single box has a _label_, and some _content_. As you can guess from the name, boxes are primarily there to hold something - its content. The label gives the box its identity, it defines what it stands for.

Solid boxes are more like pencil holders, they're there to organize things - that is, they hold other boxes. Liquid boxes, on the other side, hold text as their content, and as its name defines - it needs to be stored in a container \(solid box\), otherwise it'll spill all over the place!

> Every page is rendered to HTML to present to the viewer of the web page. Boxes, the building blocks of pages, are converted to HTML based on the label and its contents.

## Label

A label gives a box its identity, especially when the box is rendered to HTML.

A box, based on its label, may be rendered into multiple HTML elements. We'll look more into how a box is rendered into such elements in the following sections.

### Simple Labels

A label which is composed of a single word. E.g. `h1`, `div`, `this-is-a-single-word`, `div[id='lorem' class='ipsum']`.

> In the context of a label, a word is a series of characters without any space in between. An exception is when the space is enclosed in square brackets \(`[` and `]`\).

Boxes with simple labels always render to a single HTML element.

Example:

| Label | HTML \(`...` represents the content of the box\) |
| :--- | :--- |
| `h1` | `<h1>...</h1>` |

### Composite Labels

A label which is composed of multiple words. E.g. `div h1`, `first-word second-word third-word`, `div.first[id='intro'] div.second`. In the examples, the first and third labels contain 2 words, whilst the second label contains three words.

A label which has n-words will render to n-elements. So, a label with 5 words will render to 5 HTML elements. The ratio of words to elements is always 1:1.

Examples \(`...` represents the content of the box\):

* A box with label, "div h1" will be rendered to 2 HTML elements:  `<div><h1>...</h1></div>`.
* A box with label, "body div h1" will be rendered into 3 HTML elements:  `<body><div><h1>...</h1></div></body>`.

### Attributes

Each word in a label can have one or more attributes. When a word of a label gets rendered as an HTML element, its attributes are be put inside it.

Attributes are key-value pairs, separated with spaces, and enclosed in square brackets \(`[` and `]`\).

Examples \(`...` represents the content of the box\):

* A box with label, "h1\[class='title'\]" will be rendered as `<h1 class="title">...</h1>`.
* A box with label, "div\[id='menu'\]" will be rendered as `<div id="menu">...<div>`.
* A box with label, "button\[id='login' class='button is-primary'\]" will be rendered as `<button id="login" class="button is-primary">...</button>`.

### IDs and Classes of Elements

Anything in the label followed by a `#` is the `id` attribute of an HTML element, whereas anything followed by `.` is part of its `class` attribute.

> An HTML element can have multiple classes, but only one ID - for obvious reasons!

For example:

* A box with label, "h1.title" will be rendered as `<h1 class="title">...</h1>`, where `...` is its content.
* A box with label, "div\#menu" will be rendered as `<div id="menu">...<div>`, where `...` is its content.
* A box with label, "button\#login.button.is-primary" will be rendered as `<button id="login" class="button is-primary">...</button>`, where `...` is its content.

### Attributes of Elements

Anything in a label enclosed with square brackets, `[` and `]`, is regarded as the attribute of an element.

`id` and `class` are technically HTML attributes. You can define ID and classes using this way too.

So, for example:

* A box with label, "h1\[class='title'\]" will be rendered as `<h1 class="title">...</h1>`, where `...` is its content.
* A box with label, "div\[id='menu'\]" will be rendered as `<div id="menu">...<div>`, where `...` is its content.
* A box with label, "button\[id='login' class='button is-primary'\]" will be rendered as `<button id="login" class="button is-primary">...</button>`, where `...` is its content.

### Attributes of Multiple Elements

As seen in the previous sections, a single label can represent multiple HTML elements. It has a one-to-many relationship of labels to HTML elements.

As mentioned in one of the previous headings, spaces are used to split a label into multiple pieces, with each piece representing an HTML element's name. Besides the name, we can also add attributes to each piece \(representing an HTML element\).

For example:

* A box with label, "form\#login\_form button\#login.button" will be rendered as, `<form id="login_form"><button id="login" class="button">...</button>`, where `...` is its content.

