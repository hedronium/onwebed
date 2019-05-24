# Onwebed

Ever wanted a way to create webpages in a visual way without writing HTML? Onwebed is what you're looking for. HTML can get messy at times, Onwebed keeps it clean!

# About

## It's Simple

Every single webpage you create with Onwebed is composed of "boxes."

Boxes can be used to define your content, act as placeholders for reducing redundancy, or even include other pages.

## It's Extensible

The concept of boxes lets you extend the features of Onwebed pretty easily. You can define your own type of boxes which can do whatever you program it to do.

## It Got You Covered

Ever thought of going back to plain old text-based editing? Onwebed has a built-in markup language to help you out when visual editing isn't the most efficient.

## It's Not WYSIWYG

WYSIWYG is cool, but it gets messy at times, it easy to lose control, and it can be limiting. For example, ever wanted to make a box inside another box, which is yet inside another box? Yes, it can get daunting! Onwebed is here to make life easier.

## It's for Lazy People

Ever made a section in your website which is included in multiple pages? That sounds like a dynamic website! Onwebed got your back on this.

Onwebed also lets you "prototype" other pages - that is, inherit its content but replace some of it dynamically (yes, any change you make to a page will be reflected to the other pages which inherit from it).

At the end of the day, web development shouldn't be redundant, and Onwebed likes to keep it this way!

## It's Powered by Django

Yes, Onwebed is essentially a Django app. This is good news, it means that you have access to all of Django's features, that includes the templating engine!

## It Uses HTML Tags but Visually

As mentioned earlier, your webpages are built with what is known as "boxes." You can use HTML tags to define a box, though its label.

For example, a box labeled, "div" will be converted into the HTML code: `<div>...</div>` when the page will be rendered as HTML to be viewed by the public.

Another example would be that a box labeled, "div#welcome.is-blue" would be converted to the HTML code: `<div class="is-blue" id="welcome">...</div>`

# Concept

## Boxes

Every single page built with Onwebed is composed of "boxes."

Boxes are converted to HTML when a person visits your page.

Each box has a label, and may have some textual content, or may hold yet more boxes.

A box which holds text is called a **liquid box**, and a box which holds other boxes is called a **solid box**.

Each box may have a label, which defines it. The label is used primarily for converting a box to HTML.

Here's an empty solid box labeled, "div."

<img src="docs/images/empty_solid_box.png">

Here's that solid box, empty no more, as it holds a liquid box which contains the text "Hello."

<img src="docs/images/solid_box_with_liquid_box_inside.png">

This is how a small, simple page may look like:

<img src="docs/images/simple_page.png">

As you can see, it's like coding HTML, but in a visual way!