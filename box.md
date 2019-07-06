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

## Label

A label gives a box its identity, and is primarily used to define HTML elements. We'll look more into how elements are defined in the following sections.

### Name of Element

A label is equal to the name of an HTML element \(except for few cases which we'll look in the following sections\).

For example:

* A box with label, "h1" will be rendered as an HTML element, `<h1>...</h1>`, where `...` is its content.

### Names of Multiple Elements

A label can represent multiple HTML elements, using space to separate the names of elements.

Here are few examples to help you understand the concept:

* A box with label, "div h1" will be rendered as `<div><h1>...</h1></div>` , where `...` is its content.
* A box with label, "body div h1" will be rendered as `<body><div><h1>...</h1></div></body>`, where `...` is its content.

### IDs and Classes of Elements

Anything in the label followed by a `#` is the `id` attribute of an HTML element, whereas anything followed by `.` is part of its `class` attribute.

> An HTML element can have multiple classes, but only one ID - for obvious reasons!

For example:

* A box with label, "h1.title" will be rendered as `<h1 class="title">...</h1>`, where `...` is its content.
* A box with label, "div\#menu" will be rendered as `<div id="menu">...<div>`, where `...` is its content.
* A box with label, "button\#login.button.is-primary" will be rendered as `<button id="login" class="button is-primary">...</button>`, where `...` is its content.

