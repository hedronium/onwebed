# Onwebed

Onwebed is a visual way to create HTML documents. HTML can get messy at times, Onwebed keeps it clean!

This is how a simple HTML document may look like in Onwebed's editor:

![Simple Page](docs/images/simple_page.png)

It doesn't settle with static pages, it's powerful enough to create fully-featured dynamic sites, housing a markup language, Django's templating engine, and lots more!

# About

## It's Simple

Every single webpage you create with Onwebed is composed of "boxes."

Boxes can be used to define your content, act as placeholders for reducing redundancy, house other boxs, or even include other pages.

## It Lets You Code HTML but Visually

As mentioned in the previous heading, your webpages are built with what is known as "boxes." Each box may have a label attached to it.

Let's look at few examples to understand the concept behind labels:

- A box with label, "div" will be seen as a "div" element.

- A box with label, "div h1.title" will be seen as a "div" element with an "h1" element inside, having a class of "title".

- A box with label, "link[rel='stylesheet']." will be seen as a "link" element with an attribute "rel='stylesheet'." The fullstop resembles that the element won't have an ending tag.

When your page is rendered, the boxes are basically going to be converted to HTML, labels define what the box is.

## It's Extensible

The concept of boxes lets you extend the features of Onwebed pretty easily. You can define your own type of boxes which can do whatever you program it to do.

## It Got You Covered

Ever thought of going back to plain old text-based editing? Onwebed has a built-in markup language to help you out when visual editing isn't the most efficient.

## It's for Lazy People

Ever made a section in your website which is included in multiple pages? That sounds like a dynamic website! Onwebed got your back on this.

Onwebed also lets you "prototype" other pages - that is, inherit its content but replace some of it dynamically (yes, any change you make to a page will be reflected to the other pages which inherit from it).

At the end of the day, web development shouldn't be redundant, and Onwebed likes to keep it this way!

## It's Not WYSIWYG

WYSIWYG is cool, but it gets messy at times, it easy to lose control, and it can be limiting. For example, ever wanted to make a box inside another box, which is yet inside another box? Yes, it can get daunting in WYSIWYG! Onwebed is here to make life easier.

## It's Powered by Django

Yes, Onwebed is essentially a Django app. This is good news, it means that you have access to all of Django's features, that includes the templating engine!

# Concept

## Boxes

Every single page built with Onwebed is composed of "boxes."

Boxes are converted to HTML when a person visits your page.

Each box has a label, and may have some textual content, or may hold yet more boxes.

A box which holds text is called a **liquid box**, and a box which holds other boxes is called a **solid box**.

Each box may have a label, which defines it. The label is used primarily for converting a box to HTML.

Here's an empty solid box labeled, "div."

![Empty Solid Box](docs/images/empty_solid_box.png)

Here's that solid box, empty no more, as it holds a liquid box which contains the text "Hello."

![Solid Box with Liquid Box Inside](docs/images/solid_box_with_liquid_box_inside.png)

This is how a small, simple page may look like:

![Simple Page](docs/images/simple_page.png)

As you can see, it's like coding HTML, but in a visual way!