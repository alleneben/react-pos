<?php
class KPSessionWrite
{
	function __construct()
    {

    }

	function Open($sessionid)
	{
		try
		{
			$dbl=new ConnDB();
			$cnn=$dbl->Connection();
			//$sessionid = $_COOKIE[session_name()];

			$sql="SELECT * FROM sps_session_open('$sessionid')";
			$stmt=$cnn->PrepareSP($sql);
			$cnn->Execute($stmt);

		}
		catch(ADODB_Exception $e)
		{
			return ErrorHandler::InterpretADODB($e);
		}
		catch(Exception $e)
		{
			return ErrorHandler::Interpret($e);
		}
		return true;
	}

	function Close()
	{
		try
		{
			$dbl=new ConnDB();
			$cnn=$dbl->Connection();
			$sql="SELECT * FROM sps_session_close()";
			$stmt=$cnn->PrepareSP($sql);
			$cnn->Execute($stmt);
	    	$cnn->Close();

		}
		catch(ADODB_Exception $e)
		{
			return ErrorHandler::InterpretADODB($e);
		}
		catch(Exception $e)
		{
			return ErrorHandler::Interpret($e);
		}
		return true;
	}

	function Read($sessionid)
	{

		try
		{
			$dbl=new ConnDB();
			$cnn=$dbl->Connection();
			$sql="SELECT * FROM sps_session_read('$sessionid')";
			$stmt=$cnn->PrepareSP($sql);
			$rc=$cnn->Execute($stmt);
			$sd = $rc->getarray();
			$sessiondata = $sd[0]['sps_session_read'];
		}
			catch(ADODB_Exception $e)
		{
			return ErrorHandler::InterpretADODB($e);

		}
		catch(Exception $e)
		{
			return ErrorHandler::Interpret($e);
		}
		return $sessiondata;
	}

	function Write($sessionid, $sessiondata)
	{
		try
		{
	  		$dbl=new ConnDB();
			$cnn=$dbl->Connection();
	  		$sql="SELECT * FROM sps_session_write('$sessionid','$sessiondata')";
	  		$stmt=$cnn->PrepareSP($sql);
			$cnn->Execute($stmt);

		}
		catch(ADODB_Exception $e)
		{
			return ErrorHandler::InterpretADODB($e);


		}
		catch(Exception $e)
		{
			return ErrorHandler::Interpret($e);
		}
		return true;
	}

	function Destroy()
	{
		try
		{
			$dbl=new ConnDB();
			$cnn=$dbl->Connection();
			$sessionid = $_COOKIE[session_name()];
			$sql="SELECT * FROM sps_session_destroy('$sessionid')";
			$stmt=$cnn->PrepareSP($sql);
			$cnn->Execute($stmt);

		}
		catch(ADODB_Exception $e)
		{
			return ErrorHandler::InterpretADODB($e);
		}
		catch(Exception $e)
		{
			return ErrorHandler::Interpret($e);
		}

		//Empty Session
		$_SESSION=array();
		//Delete Client's Session Cookie
		$CookieInfo = session_get_cookie_params();
   		if ( (empty($CookieInfo['domain'])) && (empty($CookieInfo['secure'])) )
   		{
        	setcookie(session_name(), '', time()-3600, $CookieInfo['path']);
    	}
    	elseif (empty($CookieInfo['secure']))
    	{
        	setcookie(session_name(), '', time()-3600, $CookieInfo['path'], $CookieInfo['domain']);
		}
		else
		{
        	setcookie(session_name(), '', time()-3600, $CookieInfo['path'], $CookieInfo['domain'], $CookieInfo['secure']);
    	}
		return true;
	}

	function GC()
	{
		try
		{
	  		$dbl=new ConnDB();
			$cnn=$dbl->Connection();
			$sql="SELECT * FROM sps_session_gc()";
			$stmt=$cnn->PrepareSP($sql);
	    	$cnn->Execute($stmt);

		}
	   	catch(ADODB_Exception $e)
		{
			return ErrorHandler::InterpretADODB($e);
		}
		catch(Exception $e)
		{
			return ErrorHandler::Interpret($e);
		}
		return true;
	}
}
?>
