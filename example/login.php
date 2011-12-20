<?php

header('Cache-Control: no-cache, must-revalidate');
header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
header('Content-type: application/json');


$username = $_POST['username'];
$password = $_POST['password'];


if( $username == "bad_username")
{
  failed("incorrect username");
  exit;
}

if( $username == "test")
{
  if( $password == "password")
  {
    echo success();
    exit;
  }

  echo failed("incorrect password");
  exit;
}

echo failed("unknown failure");

function success()
{
  return json_encode(array('status'=>"success"));
}

function failed( $msg )
{
  return json_encode(array('status'=> "failed", 'msg' => $msg));
}
?>
