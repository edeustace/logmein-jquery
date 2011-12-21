# Introduction
A simple login component. Saves you from re-inventing the wheel each time you need a neat little login box.

[Here's an example](http://edeustace.com/logmein/)

[Tests are here](http://edeustace.com/logmein/test/SpecRunner.html)

# Usage

    $(document).ready(function(){
        $("#myLoginBox).logMeIn(
          {
            loginUrl: "/login.php",
            logoutUrl: "/logout.php"
          }
        );
    });
    
    ...
    
    <span id="myLoginBox"></span>
    
# Options
* buildParams: a callback to build the parameter object that will be sent to the login
* loginCallback: a callback to handle the login result
* logoutCallback: a callback to handle the logout result 
* isLoggedIn: if true then the logout link is shown otherwise the login link
* template : the template to use for the login form
* loginLabel : the label for the login link
* logoutLabel : the label for the logout link
* errorTemplate :  the template for the error message (gets added after the template)


See the example - its pretty straightforward.


# Building source
- you need coffeescript on your ```$PATH```

    $ cd logmein/
    
    $ ./scripts/create_js_lib
    

To build as you develop:

    $ ./scripts/watch_src
