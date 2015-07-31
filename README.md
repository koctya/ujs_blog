# README for UJS blog tutorial

sample ujs blog app from [Using Unobtrusive JavaScript and AJAX with Rails 3](http://code.tutsplus.com/tutorials/using-unobtrusive-javascript-and-ajax-with-rails-3--net-15243)
 updated to use haml, Bootstrap, and Rails 4

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

- Prototype
- jQuery (default)
- MooTools

Rails 3 now implements all of its JavaScript Helper functionality (AJAX submits, confirmation prompts, etc) unobtrusively by adding the following HTML 5 custom attributes to HTML elements.

- data-method - the REST method to use in form submissions.
- data-confirm - the confirmation message to use before performing some action.
- data-remote - if true, submit via AJAX.
- data-disable-with - disables form elements during a form submission

For example, this link tag

    <td><a href="/posts/2" class="delete_post" data-confirm="Are you sure?" data-method="delete" data-remote="true" rel="nofollow">Destroy</a></td>

would send an AJAX delete request after asking the user "Are you sure?."

You can imagine how much harder to read that would be if all that JavaScript was inline.

# Adding AJAX

Now that all the required JavaScript files are being included, we can actually start using Rails 3 to implement some AJAX functionality. Although you can write all of the custom JavaScript that you want, Rails provides some nice built-in methods that you can use to easily perform AJAX calls and other JavaScript actions.

Let's look at a couple of commonly used rails helpers and the JavaScript they generate

## AJAX Form Submission and Javascript ERB Files

If we look at our Posts form, we can see that whenever we create or edit a Post, the form is manually submitted and then we're redirected to a read-only view of that Post. What if we wanted to submit that form via AJAX instead of using a manual submission?

Rails 3 makes it easy to convert any form to AJAX. First, open your `_form.html.erb` partial in app/views/posts, and change the first line from:

    <%= form_for(@post) do |f| %>
to

    <%= form_for(@post, :remote => true) do |f| %>

Prior to Rails 3, adding :remote => true would have generated a bunch of inline JavaScript inside the form tag, but with Rails 3 UJS, the only change is the addition of an HTML 5 custom attribute. Can you spot it?

    <form accept-charset="UTF-8" action="/posts" class="new_post" data-remote="true" id="new_post" method="post">

The attribute is `data-remote="true"`, and the Rails UJS JavaScript binds to any forms with that attribute and submits them via AJAX instead of a traditional POST.

That's all that's needed to do the AJAX submit, but how do we perform a callback after the AJAX call returns?

The most common way of handling a return from an AJAX call is through the use of JavaScript ERB files. These work exactly like your normal ERB files, but contain JavaScript code instead of HTML. Let's try it out.

The first thing we need to do is to tell our controller how to respond to AJAX requests. In `posts_controller.rb` (app/controllers) we can tell our controller to respond to an AJAX request by adding

    format.js

in each `respond_to` block that we are going to call via AJAX. For example, we could update the create action to look like this:

    def create
      @post = Post.new(post_params)

      respond_to do |format|
        if @post.save
          format.html { redirect_to @post, notice: 'Post was successfully created.' }
          format.json { render :show, status: :created, location: @post }
          format.js
        else
          format.html { render :new }
          format.json { render json: @post.errors, status: :unprocessable_entity }
          format.js
        end
      end
    end

Because we didn't specify any options in the `respond_to` block, Rails will respond to JavaScript requests by loading a `.js` ERB with the same name as the controller action (`create.js.erb`, in this case).

Now that our controller knows how to handle AJAX calls, we need to create our views. For the current example, add `create.js.erb` in your `app/views/posts` directory. This file will be rendered and the JavaScript inside will be executed when the call finishes. For now, we'll simply overwrite the form tag with the title and contents of the blog post:

    $('body').html("<h1><%= escape_javaScript(@post.title) %></h1>").append("<%= escape_javaScript(@post.content) %>");

Now if we create a new Post we get the following on the screen. Success!

The advantage of this method is that you can intersperse ruby code that you set up in your controller with your JavaScript, making it really easy to manipulate your view with the results of a request.

## AJAX Callbacks Using Custom JavaScript Events

Each Rails UJS implementation also provides another way to add callbacks to our AJAX calls - custom JavaScript events. Let's look at another example. On our Posts index view (http://localhost:3000/posts/), we can see that each post can be deleted via a delete link.

Let's AJAXify our link by adding :remote=>true and additionally giving it a CSS class so we can easily find this POST using a CSS selector.

    <td><%= link_to 'Destroy', post, :confirm => 'Are you sure?', :method => :delete, :remote=>true, :class=>'delete_post' %></td>

Which produces the following output:

    <td><a href="/posts/2" class="delete_post" data-confirm="Are you sure?" data-method="delete" rel="nofollow">Destroy</a></td>

Each rails UJS AJAX call provides six custom events that can be attached to:

- ajax:before - right before ajax call
- ajax:loading - before ajax call, but after XmlHttpRequest object is created)
- ajax:success - successful ajax call
- ajax:failure - failed ajax call
- ajax:complete - completion of ajax call (after ajax:success and ajax:failure)
- ajax:after - after ajax call is sent (note: not after it returns)

In our case we'll add an event listener to the `ajax:success` event on our delete links, and make the deleted post fade out rather than reloading the page. We'll add the following JavaScript to our  `application.js` file.

    $('.delete_post').bind('ajax:success', function() {
        $(this).closest('tr').fadeOut();
    });

(correction)

    $(document).ready(function() {

      $('.delete_post').bind('ajax:before', function() {
        $(this).closest('tr').fadeOut();
      });
    });


We'll also need to tell our posts_controller not to try to render a view after it finishes deleting the post.

    def destroy
      @post = Post.find(params[:id])
      @post.destroy

      respond_to do |format|
        format.html { redirect_to(posts_url) }
        format.js   { render :nothing => true }
      end

Now when we delete a Post it will gradually fade out.


## Comments

If you're using Rails 3.2.13, you don't need to download jquery.js nor rails.js. It's already included by default in the Gemfile (jquery-rails). Simply create the new project and rails generate scaffold as shown in the tutorial. Change the create.js.erb though

from this:

    $('body').html("<h1><%= escape_javaScript(@post.title) %></h1>").append("<%= escape_javaScript(@post.content) %>");

to this:

    $('body').html("<h1><%= escape_javascript(@post.title) %></h1>").append("<%= escape_javascript(@post.content) %>");

"javascript" all lowercase, not camel case. Otherwise, Rails will complain that there's an undefined method.

---

i found one obstacle in my browser - jquery bind only attaches an event listener to items already in the dom - when i added a new row via ujs the event listener did not get attached, so ujs deletes were not possible for the newly added rows

fortunately jquery provides an easy solution: all you need do is use the jquery "live" method instead of the jquery "bind method.

    $(document).ready(function() {
      $('.deletePost').live('ajax:success', function() {
        $(this).closest('tr').fadeOut();
      });
    });


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
