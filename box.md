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

Examples:

| Label | HTML \(`...` represents the content of the box\) |
| :--- | :--- |
| `div h1` | `<div><h1>...</h1></div>` |
| `body div h1` | `<body><div><h1>...</h1></div></body>` |

### Attributes

Each word in a label can have one or more attributes. When a word of a label gets rendered as an HTML element, its attributes are put inside the element.

Attributes of words are key-value pairs, separated with spaces, and enclosed in square brackets (`[` and `]`), just like the attributes of elements in HTML.

Examples:

| Label | HTML (`...` represents the content of the box) |
| :--- | :--- |
| `h1[class='title']` | `<h1 class="title">...</h1>` |
| `div[id='menu']` | `<div id="menu">...<div>` |
| `button[id='login' class='button is-primary']` | `<button id="login" class="button is-primary">...</button>` |

### Shortcuts for adding ID and Class Attributes

Instead of adding `id` and `class` attribute from what we've seen in the previous section, we can use shortcuts for doing the same thing.

Anything in the word followed by a `#` is the `id` attribute of an HTML element, whereas anything followed by `.` is part of its `class` attribute.

> An HTML element can have multiple classes, but only one ID which must be unique throughout the HTML document - for obvious reasons!

Examples:

| Label | HTML (`...` represents the content of the box) |
| :--- | :--- |
| `h1.title` | `<h1 class="title">...</h1>` |
| `div#menu` | `<div id="menu">...<div>` |
| `button#login.button.is-primary` | `<button id="login" class="button is-primary">...</button>` |

