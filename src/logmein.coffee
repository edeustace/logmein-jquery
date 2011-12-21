window.com || (window.com = {})
com.ee || (com.ee = {})
###
Simple username component.
displays a username link, then turns into 2 input fields. hitting enter in the password field 
completes the username.

the config object can contains username and logout callbacks that will be invoked after
receiving a response from the server.
###
class @com.ee.LogMeIn

  ###
  param: isLoggedIn - if user is logged in - shows the logout link
  param: config - a config object
  ###
  constructor: (element, config)->

    uid = Math.floor( Math.random() * 10000 )
    console.log uid
    @ENTER = 13
    @TAB = 9
    
    template = """
    <input id='username' type="text" value="username"></input>
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
      loginLabel : "login"
      logoutLabel : "logout"
      errorTemplate :  """<span><br/>${message}</span>"""

    
    @config = if config? then $.extend defaultConfig, config else defaultConfig
    

    getUsernameValueFromTemplate = (template) ->
      matches = template.match /type="text" value="(.*?)"/
      matches[1]

    @usernameValue = getUsernameValueFromTemplate @config.template
    console.log "username value: #{@usernameValue}"

    if @config.isLoggedIn then @addLogoutLink() else @addusernameLink()
    

  showError: (message) ->
    processed = @config.errorTemplate.replace "${message}", message
    processed = """<span id='errorMessage'>#{processed}</span>"""
    @$element.append $(processed)
    null

  _removeError: ->
    @$element.find("#errorMessage").remove()
    null

  addusernameLink: ->
    @_addLinkAndCallback @_loginUid, @config.loginLabel, @_onLoginClick

  _onLoginClick: (event)->
    @addInputs()
    $username = @$element.find("#username")
    $username.focus()
    $username.attr 'value', ''
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
    if !callback? 
      throw "callback not defined"
    
    link = """<a id="#{uid}" href="javascript:void(0)">#{label}</a>"""
    @$element.html link
    @$element.find("##{uid}").click (event) => 
      callback.call this, event
    null;

  _logoutCallback: (response) ->
    data = @_parseResponse response
    if data.status == "success"
      @addusernameLink()
    null

  _parseResponse: (response) -> if typeof(response) == "string" then $.parseJSON(response) else response

  addInputs: ->
    process = (template) ->
      template.replace /type=["|']password["|']/g, """type="text" """

    processedTemplate = process @config.template
    
    @$element.html processedTemplate

    $username = @$element.find "#username"
    $username
      .click ->
        if $(this).attr('value') == @usernameValue
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
    username = @$element.find('#username').attr 'value'
    password = @$element.find("#password").attr 'value'
    
    params = @config.buildParams username, password

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

    
    $(inputString).insertAfter $input
    $input.remove()
    
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
    console.log this
    new com.ee.LogMeIn(this, options);
    null
    #if !jQuery(this).data('com_ee_logmein')
    #  jQuery(this).data('com_ee_logmein', new com.ee.LogMeIn(this,options))
  this

