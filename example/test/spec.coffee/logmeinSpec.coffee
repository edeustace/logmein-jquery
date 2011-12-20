describe "logmein", ->

  logMeIn = null

  TAB = 9
  ENTER = 13

  createEvent = (type, keyCode) ->
    e = $.Event type
    e.which = keyCode
    e

  beforeEach ->
    $('body').append """<div id="logmein"></div>"""
    
    $.hasFocus = ($elem) ->
      $elem[0] == document.activeElement


    options = 
      loginUrl : '/logmein/login.php'
      logoutUrl : '/logmein/logout.php'

    logMeIn = new com.ee.LogMeIn( $("#logmein")[0], options)
    null

  afterEach ->
    $('#logmein').remove()

  it "is constructed", ->
    expect(logMeIn).toNotBe null
    null
  

  it "shows inputs when clicked", ->
    $('#logmein').find('a').trigger 'click'
    expect($('#logmein').find('input').length).toEqual 2

    
    $username = $("#logmein").find('input').first()
    
    expect($.hasFocus($username) ).toBe true
    
    $username.attr('value', 'test')
    val = $username.attr('value')
    expect(val).toEqual 'test' 

    e = createEvent "keydown", TAB
    $username.trigger e
    
    waits 200
    
    runs ->
     $password = $("#logmein").find('input').last()
     $password.trigger e
    null
  
  setUsername = (username) ->
    $username = $("#logmein").find('input').first()
    $username.attr 'value', username
    null
 
  setPassword = (password) ->
    $password = $("#logmein").find('input').last()
    $password.attr 'value', password

  tab = ->
    $username = $("#logmein").find('input').first()
    e = createEvent "keydown", TAB
    $username.trigger(e)

  enter = ->
    $password = $("#logmein").find('input').last()
    e = createEvent "keydown", ENTER
    $password.trigger(e)

  it "shows logout link after successful login", ->
    $('#logmein').find('a').trigger 'click'
    setUsername 'test'
    tab()
    waits 200
    runs ->
      setPassword 'password'
      enter()
    waits 300
    runs -> expect( $("#logmein").find('a').length ).toEqual 1 
      
    null

  it "shows login error", ->
    $('#logmein').find('a').trigger 'click'
    setUsername 'bad username'
    tab()
    waits 200
    runs ->
      setPassword 'password'
      enter()
    waits 300
    runs -> expect( $("#logmein").find('#errorMessage').length ).toEqual 1
      
    null
