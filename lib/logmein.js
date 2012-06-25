(function() {

  window.com || (window.com = {});

  com.ee || (com.ee = {});

  /*
  Simple username component.
  displays a username link, then turns into 2 input fields. hitting enter in the password field 
  completes the username.
  
  the config object can contains username and logout callbacks that will be invoked after
  receiving a response from the server.
  */

  this.com.ee.LogMeIn = (function() {
    /*
      param: isLoggedIn - if user is logged in - shows the logout link
      param: config - a config object
    */
    function LogMeIn(element, config) {
      var defaultConfig, getUid, template, uid;
      uid = Math.floor(Math.random() * 10000);
      console.log(uid);
      this.ENTER = 13;
      this.TAB = 9;
      template = "<input id='username' type=\"text\" placeholder=\"username\"></input>\n<input id='password' type=\"password\" placeholder=\"password\"></input>";
      this.$element = $(element);
      getUid = function(name) {
        return name + "_" + Math.floor(Math.random() * 1000);
      };
      this._logoutUid = getUid("logout");
      this._messageUid = getUid("message");
      defaultConfig = {
        buildParams: this._buildParams,
        loginCallback: this._loginCallback,
        logoutCallback: this._logoutCallback,
        isLoggedIn: false,
        template: template,
        loginLabel: "login",
        logoutLabel: "logout",
        errorTemplate: "<span><br/>${message}</span>"
      };
      this.config = config != null ? $.extend(defaultConfig, config) : defaultConfig;
      if (this.config.isLoggedIn) {
        this.addLogoutLink();
      } else {
        this.addusernameLink();
      }
    }

    LogMeIn.prototype.showError = function(message) {
      var processed;
      processed = this.config.errorTemplate.replace("${message}", message);
      processed = "<span id='errorMessage'>" + processed + "</span>";
      this.$element.append($(processed));
      return null;
    };

    LogMeIn.prototype._removeError = function() {
      this.$element.find("#errorMessage").remove();
      return null;
    };

    LogMeIn.prototype.addusernameLink = function() {
      return this._addLinkAndCallback(this._loginUid, this.config.loginLabel, this._onLoginClick);
    };

    LogMeIn.prototype._onLoginClick = function(event) {
      var $username;
      this.addInputs();
      $username = this.$element.find("#username");
      $username.focus();
      return null;
    };

    LogMeIn.prototype._loginCallback = function(response) {
      var data, msg;
      data = this._parseResponse(response);
      if (data.status !== 'success') {
        msg = data.msg != null ? data.msg : "An unknown error occured";
        this.showError(msg);
        return;
      }
      this.addLogoutLink();
      return null;
    };

    LogMeIn.prototype.addLogoutLink = function() {
      this._addLinkAndCallback(this._logoutUid, "logout", this._onLogoutClick);
      return null;
    };

    LogMeIn.prototype._onLogoutClick = function() {
      var _this = this;
      $.get(this.config.logoutUrl + ("?_ck=" + (Math.random())), function(data) {
        return _this.config.logoutCallback.call(_this, data);
      });
      return null;
    };

    LogMeIn.prototype._addLinkAndCallback = function(uid, label, callback) {
      var link,
        _this = this;
      if (!(callback != null)) throw "callback not defined";
      link = "<a id=\"" + uid + "\" href=\"javascript:void(0)\">" + label + "</a>";
      this.$element.html(link);
      this.$element.find("#" + uid).click(function(event) {
        return callback.call(_this, event);
      });
      return null;
    };

    LogMeIn.prototype._logoutCallback = function(response) {
      var data;
      data = this._parseResponse(response);
      if (data.status === "success") this.addusernameLink();
      return null;
    };

    LogMeIn.prototype._parseResponse = function(response) {
      if (typeof response === "string") {
        return $.parseJSON(response);
      } else {
        return response;
      }
    };

    LogMeIn.prototype.addInputs = function() {
      var $password, $username, process, processedTemplate,
        _this = this;
      process = function(template) {
        return template.replace(/type=["|']password["|']/g, "type=\"text\" ");
      };
      processedTemplate = process(this.config.template);
      this.$element.html(processedTemplate);
      $username = this.$element.find("#username");
      $username.keydown(function(event) {
        _this._removeError();
        if (_this._keyCodeMatches(_this.TAB, event)) {
          event.preventDefault();
          setTimeout((function() {
            return _this._convertPasswordInput();
          }), 100);
        }
        return null;
      });
      $password = this.$element.find("#password");
      $password.click(function() {
        return setTimeout((function() {
          return _this._convertPasswordInput();
        }), 100);
      });
      return null;
    };

    LogMeIn.prototype._buildParams = function(username, password) {
      return {
        username: username,
        password: password
      };
    };

    LogMeIn.prototype._login = function() {
      var params, password, username,
        _this = this;
      username = this.$element.find('#username').attr('value');
      password = this.$element.find("#password").attr('value');
      params = this.config.buildParams(username, password);
      if (!(this.config.loginUrl != null)) throw "no login url provided";
      $.post(this.config.loginUrl, params, function(data) {
        return _this.config.loginCallback.call(_this, data);
      });
      return null;
    };

    LogMeIn.prototype._convertPasswordInput = function() {
      var $input, $newPassword, inputString, process, rawString,
        _this = this;
      $input = this.$element.find("#password");
      if ($input.attr('type') === 'password') {
        $input.focus();
        return;
      }
      process = function(input) {
        return input.replace(/type=["|']text["|'']/, "type=\"password\" ");
      };
      rawString = $input.clone().wrap('<div>').parent().html();
      inputString = process(rawString);
      $(inputString).insertAfter($input);
      $input.remove();
      $newPassword = this.$element.find('#password');
      $newPassword.focus();
      $newPassword.keydown(function(event) {
        _this._removeError();
        if (_this._keyCodeMatches(_this.ENTER, event)) _this._login();
        return null;
      });
      return null;
    };

    LogMeIn.prototype._keyCodeMatches = function(code, event) {
      return event.keyCode === code || event.which === code;
    };

    return LogMeIn;

  })();

  /*
  register with jQuery
  */

  jQuery.fn.logMeIn = function(options) {
    this.each(function(index) {
      console.log(this);
      new com.ee.LogMeIn(this, options);
      return null;
    });
    return this;
  };

}).call(this);
