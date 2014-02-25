<!--- COMPONENT --->
<cfcomponent displayname="UserDAO" output="false" hint="I am the UserDAO class.">

<!--- Pseudo-constructor --->
<cfset variables.instance = {
	datasource = ''
} />
<cffunction name="init" access="public" output="false" returntype="any" hint="I am the constructor method of the UserDAO class.">
  <cfargument name="datasource" type="any" required="true" hint="I am the Datasource bean." />
  <!--- Set the initial values of the Bean --->
  <cfscript>
	variables.instance.datasource = arguments.datasource;
  </cfscript>
  <cfreturn this>
</cffunction>
<!--- PUBLIC METHODS --->
<!--- CREATE --->
<cffunction name="createNewUser" access="public" output="false" returntype="numeric" hint="I insert a new user record into the users table in the database.">
  <cfargument name="user" type="any" required="true" hint="I am the User bean." />
  <cfset var qPutUser = '' />
  <cfset var insertResult = '' />
  <cftry>
  <cfquery name="qPutUser" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#" result="insertResult">
	INSERT INTO users
		(
		  username,
		  password,
		  role,
		  isActive
		) VALUES (
		  <cfqueryparam value="#APPLICATION.utils.dataEnc(ARGUMENTS.user.getUsername(), 'repeatable')#" cfsqltype="cf_sql_varchar" />,
		  <cfqueryparam value="#APPLICATION.utils.dataEnc(ARGUMENTS.user.getPassword())#" cfsqltype="cf_sql_varchar" />,
		  <cfqueryparam value="#ARGUMENTS.user.getRole()#" cfsqltype="cf_sql_varchar" />,
		  <cfqueryparam value="#ARGUMENTS.user.getIsActive()#" cfsqltype="cf_sql_bit" />
		)
  </cfquery>
  <!--- catch any errors --->
  <cfcatch type="any">
	<cfset APPLICATION.utils.errorHandler(cfcatch) />
	<cfreturn 0 />
  </cfcatch>
  </cftry>
  <!--- return the id generated by the database --->
<cfreturn insertResult.GENERATED_KEY />
</cffunction>

<!--- RETRIEVE - BY ID --->
<cffunction name="getUserByID" access="public" output="false" returntype="any" hint="I return a User bean populated with the details of a specific user record.">
  <cfargument name="id" type="numeric" required="true" hint="I am the numeric auto-increment id of the user to search for." />
  <cfset var qGetUser = '' />
  <cfset var userObject = '' />
  <cftry>
  <cfquery name="qGetUser" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">
	SELECT userId, username, password, role, isActive
	FROM users
	WHERE userId = <cfqueryparam value="#ARGUMENTS.id#" cfsqltype="cf_sql_integer" />
  </cfquery>
  <!--- catch any errors --->
  <cfcatch type="any">
	<cfset APPLICATION.utils.errorHandler(cfcatch) />
	<cfreturn createObject('component','core.beans.User').init() />
  </cfcatch>
  </cftry>
  <cfif qGetUser.RecordCount>
    <cfreturn createObject('component','core.beans.User').init(
	userId  	= qGetUser.userId,
	username	= APPLICATION.utils.dataDec(qGetUser.username, 'repeatable'),
	password	= APPLICATION.utils.dataDec(qGetUser.password),
	role    	= qGetUser.role,
	isActive	= qGetUser.isActive
    ) />
  <cfelse>
    <cfreturn createObject('component','core.beans.User').init() />
  </cfif>
</cffunction>

<!--- RETRIEVE - BY EMAIL --->
<cffunction name="getUserByEmail" access="public" output="false" returntype="any" hint="I return a User bean populated with the details of a specific user record.">
  <cfargument name="email" type="string" required="true" hint="I am the email address of the user to search for." />
  <cfset var qGetUser = '' />
  <cfset var userObject = '' />
  <cftry>
  <cfquery name="qGetUser" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">
	SELECT userId, username, password, role, isActive
	FROM users
	WHERE username = <cfqueryparam value="#APPLICATION.utils.dataEnc(ARGUMENTS.email, 'repeatable')#" cfsqltype="cf_sql_varchar" />
  </cfquery>
  <!--- catch any errors --->
  <cfcatch type="any">
	<cfset APPLICATION.utils.errorHandler(cfcatch) />
	<cfreturn createObject('component','core.beans.User').init() />
  </cfcatch>
  </cftry>
  <cfif qGetUser.RecordCount>
    <cfreturn createObject('component','core.beans.User').init(
	userId  	= qGetUser.userId,
	username	= APPLICATION.utils.dataDec(qGetUser.username, 'repeatable'),
	password	= APPLICATION.utils.dataDec(qGetUser.password),
	role    	= qGetUser.role,
	isActive	= qGetUser.isActive
    ) />
  <cfelse>
    <cfreturn createObject('component','core.beans.User').init() />
  </cfif>
</cffunction>

<!--- UPDATE --->
<cffunction name="updateUser" access="public" output="false" returntype="numeric" hint="I update this user record in the users table of the database.">
  <cfargument name="user" type="any" required="true" hint="I am the User bean." />
  <cfset var qUpdUser = '' />
  <cftry>
  <cfquery name="qUpdUser" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">
	UPDATE users SET
	  username = <cfqueryparam value="#APPLICATION.utils.dataEnc(ARGUMENTS.user.getUsername(), 'repeatable')#" cfsqltype="cf_sql_varchar" />,
	  password = <cfqueryparam value="#APPLICATION.utils.dataEnc(ARGUMENTS.user.getPassword())#" cfsqltype="cf_sql_varchar" />,
	  role = <cfqueryparam value="#ARGUMENTS.user.getRole()#" cfsqltype="cf_sql_varchar" />,
	  isActive = <cfqueryparam value="#ARGUMENTS.user.getIsActive()#" cfsqltype="cf_sql_bit" />
	WHERE userId = <cfqueryparam value="#ARGUMENTS.user.getUserId()#" cfsqltype="cf_sql_integer" />
  </cfquery>
  <!--- catch any errors --->
  <cfcatch type="any">
	<cfset APPLICATION.utils.errorHandler(cfcatch) />
	<cfreturn 0 />
  </cfcatch>
  </cftry>
  <cfreturn ARGUMENTS.user.getUserId() />
</cffunction>

<!--- DELETE --->
<cffunction name="deleteUserByID" access="public" output="false" returntype="boolean" hint="I delete a user from user table in the database.">
  <cfargument name="id" type="numeric" required="true" hint="I am the numeric auto-increment id of the user to delete." />
  <cfset var qDelUser = '' />
  <cftry>
    <cfquery name="qDelUser" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">
		DELETE FROM users
		WHERE userId = <cfqueryparam value="#ARGUMENTS.id#" cfsqltype="cf_sql_integer" />
	</cfquery>
    <cfcatch type="database">
      <cfreturn false />
    </cfcatch>
  </cftry>
  <cfreturn true />
</cffunction>

<!--- UTILITY FUNCTIONS --->
<!--- SAVE --->
<cffunction name="saveUser" access="public" output="false" returntype="any" hint="I handle saving a user either by creating a new entry or updating an existing one.">
  <cfargument name="user" type="any" required="true" hint="I am the User bean." />
  <cfif exists(ARGUMENTS.user)>
	<cfreturn updateUser(ARGUMENTS.user) />
  <cfelse>
	<cfreturn createNewUser(ARGUMENTS.user) />
  </cfif>
</cffunction>

<!--- EXISTS --->
<cffunction name="exists" access="private" output="false" returntype="boolean" hint="I check to see if a specific User is in the database, using ID as the check.">
  <cfargument name="user" type="any" required="true" hint="I am the User bean." />
  <cfset var qGetUser = '' />
  <cfquery name="qGetUser" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">
	SELECT userId FROM users
	WHERE userId = <cfqueryparam value="#ARGUMENTS.user.getUserId()#" cfsqltype="cf_sql_integer" />
  </cfquery>
  <cfif qGetUser.RecordCount>
	<cfreturn true />
  <cfelse>
	<cfreturn false />
  </cfif>
</cffunction>

<!--- CHECK IF USER EXISTS --->
<cffunction name="checkIfUserExists" access="public" returntype="boolean" output="false" hint="I check to see if a specific user is in the database, using their email address as the check.">
  <cfargument name="email" type="string" required="true" hint="I am the email address to check for the existence of." />
  <cfset var qGetUser = '' />
  <cfquery name="qGetUser" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">
	SELECT userId FROM users
	WHERE username = <cfqueryparam value="#APPLICATION.utils.dataEnc(ARGUMENTS.email, 'repeatable')#" cfsqltype="cf_sql_varchar" />
  </cfquery>
  <cfif qGetUser.RecordCount>
	<cfreturn true />
  <cfelse>
	<cfreturn false />
  </cfif>
</cffunction>

<!---                    --->
<!--- SESSION MANAGEMENT --->
<!---                    --->

<!--- EXPIRE OLD SESSIONS --->
<cffunction name="expireOldSessions" access="public" returntype="void" output="false" hint="I expire sessions that are older than the timeout period passed in.">
	<cfargument name="timeout" type="numeric" required="true" hint="I am the timeout period used to expire sessions." />
	
	<!--- var scope --->
	<cfset var qDelSessions = '' />
	
	<!--- delete sessions whose lastActionAt is older than the timeout --->
	<cfquery name="qDelSessions" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">
		DELETE FROM sessions
		WHERE lastActionAt < <cfqueryparam value="#DateAdd('n',-ARGUMENTS.timeout,Now())#" cfsqltype="cf_sql_timestamp" />
	</cfquery>
	
</cffunction>

<!--- IS VALID SESSION --->
<cffunction name="isValidSession" access="public" returntype="boolean" output="false" hint="I validate a session exists in the database.">
	<cfargument name="encId" type="string" required="true" hint="I am the encrypted session id returned from the cookie." />
	
	<!--- var scope --->
	<cfset var qGetSession = '' />
	<cfset var sid = APPLICATION.utils.dataDec(ARGUMENTS.encId, 'cookie') />
	
	<!--- get the session from the database --->
	<cfquery name="qGetSession" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">
		SELECT uniqueId
		FROM sessions
		WHERE sessionId = <cfqueryparam value="#Hash(sid,'SHA-512')#" cfsqltype="cf_sql_varchar" />
	</cfquery>
	
	<!--- check if the session exists (record returned) --->
	<cfif qGetSession.RecordCount>
		<!--- session exists, return true --->
		<cfreturn true />
	<!--- otherwise --->
	<cfelse>
		<!--- session does not exist, return false --->
		<cfreturn false />
	</cfif>
		
</cffunction>

<!--- GET USER ID FROM SESSION --->
<cffunction name="getUserIdFromSession" access="public" returntype="boolean" output="false" hint="I return the user id stored with the session.">
	<cfargument name="encId" type="string" required="true" hint="I am the encrypted session id returned from the cookie." />
	
	<!--- var scope --->
	<cfset var qGetSession = '' />
	<cfset var sid = APPLICATION.utils.dataDec(ARGUMENTS.encId, 'cookie') />
	
	<!--- get the session from the database --->
	<cfquery name="qGetSession" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">
		SELECT userId
		FROM sessions
		WHERE sessionId = <cfqueryparam value="#Hash(sid,'SHA-512')#" cfsqltype="cf_sql_varchar" />
	</cfquery>
	
	<!--- return the user id from the session --->
	<cfreturn qGetSession.userId />
		
</cffunction>

<!--- EXPIRE SESSION --->
<cffunction name="expireSession" access="public" returntype="void" output="false" hint="I expire a session based on the id passed in.">
	<cfargument name="encId" type="string" required="true" hint="I am the encrypted session id returned from the cookie." />
	
	<!--- var scope --->
	<cfset var qDelSession = '' />
	<cfset var sid = APPLICATION.utils.dataDec(ARGUMENTS.encId, 'cookie') />
	
	<!--- delete session by session id --->
	<cfquery name="qDelSession" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">
		DELETE FROM sessions
		WHERE sessionId = <cfqueryparam value="#Hash(sid,'SHA-512')#" cfsqltype="cf_sql_varchar" />
	</cfquery>
	
</cffunction>

<!--- ADD SESSION --->
<cffunction name="addSession" access="public" returntype="void" output="false" hint="I add a new session to the database.">
	<cfargument name="sid" type="string" required="true" hint="I am the unencrypted session id generated for this session." />
	<cfargument name="user" type="any" required="true" hint="I am the user object for the user this session is beging added for." />

	<!--- var scope --->
	<cfset var qAddSession = '' />
	
	<!--- add the session --->
	<cfquery name="qAddSession" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">
		INSERT INTO sessions
			(
			sessionId,
			userId,
			lastActionAt
			) VALUES (
			<cfqueryparam value="#Hash(ARGUMENTS.sid,'SHA-512')#" cfsqltype="cf_sql_varchar" />,
			<cfqueryparam value="#ARGUMENTS.user.getUserId()#" cfsqltype="cf_sql_integer" />,
			<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp" />
			)
	</cfquery>

</cffunction>
  
</cfcomponent>

