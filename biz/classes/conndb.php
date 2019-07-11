<?php
	Class ConnDB
	{
		function Connection($pgdirect=false)
		{
			if($pgdirect==false)
			{
				//use ADODB
				$db = NewADOConnection('postgres');
				$db->SetFetchMode(ADODB_FETCH_ASSOC);
				$db->Connect('localhost','postgres','naas','pos');
				// $db->Connect('localhost','postgres','ampofo07','ampofodb');
				// $db->Connect('localhost','postgres','$i$+m!n','mackerd');

				return $db;
			}
			else
			{
				//connect directly
				return pg_connect('host='.'localhost'.' port='.'5432'.' dbname='.'sys'.' user='.'postgres'.' password='.'naas');
			}
		}

	}
?>
