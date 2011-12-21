# Introduction
A simple login component. Saves you from re-inventing the wheel each time you need a neat little login box.
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
# Building source