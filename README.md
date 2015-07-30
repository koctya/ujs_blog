# README for UJS blog tutorial

sample ujs blog app built in Rails 4 from [Using Unobtrusive JavaScript and AJAX with Rails 3](http://code.tutsplus.com/tutorials/using-unobtrusive-javascript-and-ajax-with-rails-3--net-15243)

## Background: What is Unobtrusive JavaScript?

To start off, what exactly is UJS? Simply, UJS is JavaScript that is separated from your HTML markup. The easiest way to describe UJS is with an example. Take an onclick event handler; we could add it obtrusively:

    <a href='#' onclick='alert("Inline Javscript")'>Link</a>

Or we could add it unobtrusively by attaching the event to the link (using jQuery in this example):

    <a href='#'>Link</a>
    <script>
    $('a').bind('click', function() {
        alert('Unobtrusive!');
    }
    </script>

As mentioned in my introduction, this second method has a variety of benefits, including easier debugging and cleaner code.

> "Rails 3, on the other hand, is JavaScript framework agnostic. In other words, you can use your JavaScript framework of choice, provided a Rails UJS implementation exists for that framework."

Up until version 3, Ruby on Rails generated obtrusive JavaScript. The resulting code wasn't clean, but even worse, it was tightly coupled to the Prototype JavaScript framework. This meant that unless you created a plugin or hacked Rails, you had to use the Prototype library with Rail's JavaScript helper methods.

Rails 3, on the other hand, is JavaScript framework agnostic. In other words, you can use your JavaScript framework of choice, provided a Rails UJS implementation exists for that framework. The current UJS implementations include the following:

Prototype (default)
jQuery
MooTools

Rails 3 now implements all of its JavaScript Helper functionality (AJAX submits, confirmation prompts, etc) unobtrusively by adding the following HTML 5 custom attributes to HTML elements.

- data-method - the REST method to use in form submissions.
- data-confirm - the confirmation message to use before performing some action.
- data-remote - if true, submit via AJAX.
- data-disable-with - disables form elements during a form submission

For example, this link tag

    <td><a href="/posts/2" class="delete_post" data-confirm="Are you sure?" data-method="delete" data-remote="true" rel="nofollow">Destroy</a></td>

would send an AJAX delete request after asking the user "Are you sure?."

You can imagine how much harder to read that would be if all that JavaScript was inline.


## orig stuff...

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


Please feel free to use a different markup language if you do not plan to run
<tt>rake doc:app</tt>.
