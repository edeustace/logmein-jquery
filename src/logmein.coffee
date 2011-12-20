window.com || (window.com = {})
com.ee || (com.ee = {})
###
Simple login component.
displays a login link, then turns into 2 input fields. hitting enter in the password field 
completes the login.

the config object can contains login and logout callbacks that will be invoked after
receiving a response from the server.
###
class @com.ee.LogMeIn

  ###
  param: isLoggedIn - if user is logged in - shows the logout link
  param: config - a config object
  ###
  constructor: (element, config)->

    @ENTER = 13
    @TAB = 9
    
    loginValue = "username"
    template = """
    <input id='login' type="text" value="#{loginValue}"></input>
    <input id='password' type="password" value="password"></input>
    """
    @$element = $(element)

    getUid = (name) -> name + "_" + Math.floor(Math.random() * 1000)

    @_logoutUid = getUid "logout"
    @_messageUid = getUid "message"

    defaultConfig = 
      buildParams: @_buildParams
      loginCallback: @_loginCallback
      logoutCallback: @_logoutCallback
      isLoggedIn: false
      template : template
      errorTemplate :  """<span><br/>${message}</span>"""
      loginValue : loginValue

    @config = if config? then $.extend defaultConfig, config else defaultConfig
    
    if @config.isLoggedIn then @addLogoutLink() else @addLoginLink()
    

  showError: (message) ->
    processed = @config.errorTemplate.replace "${message}", message
    processed = """<span id='errorMessage'>#{processed}</span>"""
    @$element.append $(processed)
    null

  _removeError: ->
    @$element.find("#errorMessage").remove()
    null

  addLoginLink: ->
    @_addLinkAndCallback @_loginUid, "login", @_onLoginClick

  _onLoginClick: (event)->
    @addInputs()
    $login = @$element.find("#login")
    $login.focus()
    $login.attr 'value', ''
    null
 
  _loginCallback: (response) ->
    data = @_parseResponse response
    if data.status != 'success'
      msg = if data.msg? then data.msg else "An unknown error occured"
      @showError msg
      return
    
    @addLogoutLink()
    null

  addLogoutLink: ->
    @_addLinkAndCallback @_logoutUid, "logout", @_onLogoutClick
    null

  _onLogoutClick: ->
    $.get @config.logoutUrl + "?_ck=#{Math.random()}", (data) => @config.logoutCallback.call this, data
    null

  _addLinkAndCallback: (uid, label, callback) ->
    link = """<a id="#{uid}" href="javascript:void(0)">#{label}</a>"""
    @$element.html link
    $("##{uid}").click (event) => 
      callback.call this, event
    null;

  _logoutCallback: (response) ->
    data = @_parseResponse response
    if data.status == "success"
      @addLoginLink()
    null

  _parseResponse: (response) -> if typeof(response) == "string" then $.parseJSON(response) else response

  addInputs: ->
    process = (template) ->
      template.replace /type=["|']password["|']/g, """type="text" """

    processedTemplate = process @config.template
    
    @$element.html processedTemplate

    $login = @$element.find "#login"
    loginValue = @config.loginValue
    $login
      .click ->
        if $(this).attr('value') == loginValue
          $(this).attr 'value', ''
        null
      .keydown (event)=>
        @_removeError()
        if @_keyCodeMatches @TAB, event
          event.preventDefault()
          setTimeout (=> @_convertPasswordInput()), 100
        null
      $password = @$element.find "#password"
      $password
        .click =>
          setTimeout ( => @_convertPasswordInput()), 100
    
    null
  
  
  _buildParams:(username, password) ->
    username: username
    password: password
    
  _login: ->
    login = @$element.find('#login').attr 'value'
    password = @$element.find("#password").attr 'value'
    
    params = @config.buildParams login, password

    if !@config.loginUrl?
      throw "no login url provided"

    $.post @config.loginUrl, params, (data)=> @config.loginCallback.call this, data
    null

  _convertPasswordInput: ->
    $input = @$element.find("#password")

    if $input.attr('type') == 'password'
      $input.focus()
      return
    
    process = (input)->
      input.replace /type=["|']text["|'']/, """type="password" """

    rawString = $input.clone().wrap('<div>').parent().html();
    inputString = process rawString 

    $input.remove()
    
    $(inputString).insertAfter @$element.find '#login'
    
    $newPassword = @$element.find '#password'
    $newPassword.focus()
    
    $newPassword.keydown (event) =>
      @_removeError()
      if @_keyCodeMatches @ENTER, event
        @_login()
      null
    null
  
  _keyCodeMatches: (code, event) -> event.keyCode == code || event.which == code


###
register with jQuery
###
jQuery.fn.logMeIn = (options)->
  this.each (index)->
    if !jQuery(this).data('com_ee_logmein')
      jQuery(this).data('com_ee_logmein', new com.ee.LogMeIn(this,options))
  this

