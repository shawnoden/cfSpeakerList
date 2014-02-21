<!--- COMPONENT --->
<cfcomponent displayname="SpeakerDAO" output="false" hint="I am the SpeakerDAO class.">

<!--- Pseudo-constructor --->
<cfset variables.instance = {
	datasource = ''
} />
<cffunction name="init" access="public" output="false" returntype="any" hint="I am the constructor method of the SpeakerDAO class.">
  <cfargument name="datasource" type="any" required="true" hint="I am the Datasource bean." />
  <!--- Set the initial values of the Bean --->
  <cfscript>
	variables.instance.datasource = arguments.datasource;
  </cfscript>
  <cfreturn this>
</cffunction>
<!--- PUBLIC METHODS --->
<!--- CREATE --->
<cffunction name="createNewSpeaker" access="public" output="false" returntype="numeric" hint="I insert a new speaker record into the speakers table in the database.">
  <cfargument name="speaker" type="any" required="true" hint="I am the Speaker bean." />
  <cfset var qPutSpeaker = '' />
  <cfset var insertResult = '' />
  <cftry>
  <cfquery name="qPutSpeaker" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#" result="insertResult">
	INSERT INTO speakers
		(
		  speakerKey,
		  userId,
		  firstName,
		  lastName,
		  email,
		  phone,
		  showPhone,
		  twitter,
		  showTwitter,
		  specialties,
		  locations,
		  isACP,
		  isAEL,
		  isUGM,
		  isOther
		) VALUES (
		  <cfqueryparam value="#ARGUMENTS.speaker.getSpeakerKey()#" cfsqltype="cf_sql_varchar" />,
		  <cfqueryparam value="#ARGUMENTS.speaker.getUserId()#" cfsqltype="cf_sql_integer" />,
		  <cfqueryparam value="#APPLICATION.utils.dataEnc(ARGUMENTS.speaker.getFirstName())#" cfsqltype="cf_sql_varchar" />,
		  <cfqueryparam value="#APPLICATION.utils.dataEnc(ARGUMENTS.speaker.getLastName())#" cfsqltype="cf_sql_varchar" />,
		  <cfqueryparam value="#APPLICATION.utils.dataEnc(ARGUMENTS.speaker.getEmail())#" cfsqltype="cf_sql_varchar" />,
		  <cfqueryparam value="#APPLICATION.utils.dataEnc(ARGUMENTS.speaker.getPhone())#" cfsqltype="cf_sql_varchar" />,
		  <cfqueryparam value="#ARGUMENTS.speaker.getShowPhone()#" cfsqltype="cf_sql_bit" />,
		  <cfqueryparam value="#APPLICATION.utils.dataEnc(ARGUMENTS.speaker.getTwitter())#" cfsqltype="cf_sql_varchar" />,
		  <cfqueryparam value="#ARGUMENTS.speaker.getShowTwitter()#" cfsqltype="cf_sql_bit" />,
		  <cfqueryparam value="#ARGUMENTS.speaker.getSpecialties()#" cfsqltype="cf_sql_varchar" />,
		  <cfqueryparam value="#ARGUMENTS.speaker.getLocations()#" cfsqltype="cf_sql_varchar" />,
		  <cfqueryparam value="#ARGUMENTS.speaker.getIsACP()#" cfsqltype="cf_sql_bit" />,
		  <cfqueryparam value="#ARGUMENTS.speaker.getIsAEL()#" cfsqltype="cf_sql_bit" />,
		  <cfqueryparam value="#ARGUMENTS.speaker.getIsUGM()#" cfsqltype="cf_sql_bit" />,
		  <cfqueryparam value="#ARGUMENTS.speaker.getIsOther()#" cfsqltype="cf_sql_bit" />
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
<cffunction name="getSpeakerByID" access="public" output="false" returntype="any" hint="I return a Speaker bean populated with the details of a specific speaker record.">
  <cfargument name="id" type="numeric" required="true" hint="I am the numeric auto-increment id of the speaker to search for." />
  <cfset var qGetSpeaker = '' />
  <cfset var speakerObject = '' />
  <cftry>
  <cfquery name="qGetSpeaker" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">
	SELECT speakerId, speakerKey, userId, firstName, lastName, email, phone, showPhone, twitter, showTwitter, specialties, locations, isACP, isAEL, isUGM, isOther
	FROM speakers
	WHERE speakerId = <cfqueryparam value="#ARGUMENTS.id#" cfsqltype="cf_sql_integer" />
  </cfquery>
  <!--- catch any errors --->
  <cfcatch type="any">
	<cfset APPLICATION.utils.errorHandler(cfcatch) />
	<cfreturn createObject('component','core.beans.Speaker').init() />
  </cfcatch>
  </cftry>
  <cfif qGetSpeaker.RecordCount>
    <cfreturn createObject('component','core.beans.Speaker').init(
		speakerId  	= qGetSpeaker.speakerId,
		speakerKey	= qGetSpeaker.speakerKey,
		userId     	= qGetSpeaker.userId,
		firstName  	= APPLICATION.utils.dataDec(qGetSpeaker.firstName),
		lastName   	= APPLICATION.utils.dataDec(qGetSpeaker.lastName),
		email      	= APPLICATION.utils.dataDec(qGetSpeaker.email),
		phone      	= APPLICATION.utils.dataDec(qGetSpeaker.phone),
		showPhone	= qGetSpeaker.showPhone,
		twitter    	= APPLICATION.utils.dataDec(qGetSpeaker.twitter),
		showTwitter	= qGetSpeaker.showTwitter,
		specialties	= qGetSpeaker.specialties,
		locations  	= qGetSpeaker.locations,
		isACP      	= qGetSpeaker.isACP,
		isAEL      	= qGetSpeaker.isAEL,
		isUGM      	= qGetSpeaker.isUGM,
		isOther    	= qGetSpeaker.isOther
    ) />
  <cfelse>
    <cfreturn createObject('component','core.beans.Speaker').init() />
  </cfif>
</cffunction>

<!--- RETRIEVE - BY KEY --->
<cffunction name="getSpeakerByKey" access="public" output="false" returntype="any" hint="I return a Speaker bean populated with the details of a specific speaker record.">
  <cfargument name="key" type="string" required="true" hint="I am the string key of the speaker to search for." />
  <cfset var qGetSpeaker = '' />
  <cfset var speakerObject = '' />
  <cftry>
  <cfquery name="qGetSpeaker" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">
	SELECT speakerId, speakerKey, userId, firstName, lastName, email, phone, showPhone, twitter, showTwitter, specialties, locations, isACP, isAEL, isUGM, isOther
	FROM speakers
	WHERE speakerKey = <cfqueryparam value="#ARGUMENTS.key#" cfsqltype="cf_sql_varchar" />
  </cfquery>
  <!--- catch any errors --->
  <cfcatch type="any">
	<cfset APPLICATION.utils.errorHandler(cfcatch) />
	<cfreturn createObject('component','core.beans.Speaker').init() />
  </cfcatch>
  </cftry>
  <cfif qGetSpeaker.RecordCount>
    <cfreturn createObject('component','core.beans.Speaker').init(
		speakerId  	= qGetSpeaker.speakerId,
		speakerKey	= qGetSpeaker.speakerKey,
		userId     	= qGetSpeaker.userId,
		firstName  	= APPLICATION.utils.dataDec(qGetSpeaker.firstName),
		lastName   	= APPLICATION.utils.dataDec(qGetSpeaker.lastName),
		email      	= APPLICATION.utils.dataDec(qGetSpeaker.email),
		phone      	= APPLICATION.utils.dataDec(qGetSpeaker.phone),
		showPhone	= qGetSpeaker.showPhone,
		twitter    	= APPLICATION.utils.dataDec(qGetSpeaker.twitter),
		showTwitter	= qGetSpeaker.showTwitter,
		specialties	= qGetSpeaker.specialties,
		locations  	= qGetSpeaker.locations,
		isACP      	= qGetSpeaker.isACP,
		isAEL      	= qGetSpeaker.isAEL,
		isUGM      	= qGetSpeaker.isUGM,
		isOther    	= qGetSpeaker.isOther
    ) />
  <cfelse>
    <cfreturn createObject('component','core.beans.Speaker').init() />
  </cfif>
</cffunction>

<!--- UPDATE --->
<cffunction name="updateSpeaker" access="public" output="false" returntype="numeric" hint="I update this speaker record in the speakers table of the database.">
  <cfargument name="speaker" type="any" required="true" hint="I am the Speaker bean." />
  <cfset var qUpdSpeaker = '' />
  <cftry>
  <cfquery name="qUpdSpeaker" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">
	UPDATE speakers SET
	  speakerKey = <cfqueryparam value="#ARGUMENTS.speaker.getSpeakerKey()#" cfsqltype="cf_sql_varchar" />,
	  userId = <cfqueryparam value="#ARGUMENTS.speaker.getUserId()#" cfsqltype="cf_sql_int" />,
	  firstName = <cfqueryparam value="#APPLICATION.utils.dataEnc(ARGUMENTS.speaker.getFirstName())#" cfsqltype="cf_sql_varchar" />,
	  lastName = <cfqueryparam value="#APPLICATION.utils.dataEnc(ARGUMENTS.speaker.getLastName())#" cfsqltype="cf_sql_varchar" />,
	  email = <cfqueryparam value="#APPLICATION.utils.dataEnc(ARGUMENTS.speaker.getEmail())#" cfsqltype="cf_sql_varchar" />,
	  phone = <cfqueryparam value="#APPLICATION.utils.dataEnc(ARGUMENTS.speaker.getPhone())#" cfsqltype="cf_sql_varchar" />,
	  showPhone = <cfqueryparam value="#ARGUMENTS.speaker.getShowPhone()#" cfsqltype="cf_sql_bit" />,
	  twitter = <cfqueryparam value="#APPLICATION.utils.dataEnc(ARGUMENTS.speaker.getTwitter())#" cfsqltype="cf_sql_varchar" />,
	  showPhone = <cfqueryparam value="#ARGUMENTS.speaker.getShowTwitter()#" cfsqltype="cf_sql_bit" />,
	  specialties = <cfqueryparam value="#ARGUMENTS.speaker.getSpecialties()#" cfsqltype="cf_sql_varchar" />,
	  locations = <cfqueryparam value="#ARGUMENTS.speaker.getLocations()#" cfsqltype="cf_sql_varchar" />,
	  isACP = <cfqueryparam value="#ARGUMENTS.speaker.getIsACP()#" cfsqltype="cf_sql_bit" />,
	  isAEL = <cfqueryparam value="#ARGUMENTS.speaker.getIsAEL()#" cfsqltype="cf_sql_bit" />,
	  isUGM = <cfqueryparam value="#ARGUMENTS.speaker.getIsUGM()#" cfsqltype="cf_sql_bit" />,
	  isOther = <cfqueryparam value="#ARGUMENTS.speaker.getIsOther()#" cfsqltype="cf_sql_bit" />
	WHERE speakerId = <cfqueryparam value="#ARGUMENTS.speaker.getUniqueID()#" cfsqltype="cf_sql_integer" />
  </cfquery>
  <!--- catch any errors --->
  <cfcatch type="any">
	<cfset APPLICATION.utils.errorHandler(cfcatch) />
	<cfreturn 0 />
  </cfcatch>
  </cftry>
  <cfreturn ARGUMENTS.speaker.getUniqueID() />
</cffunction>

<!--- DELETE --->
<cffunction name="deleteSpeakerByID" access="public" output="false" returntype="boolean" hint="I delete a speaker from speaker table in the database.">
  <cfargument name="id" type="numeric" required="true" hint="I am the numeric auto-increment id of the speaker to delete." />
  <cfset var qDelSpeaker = '' />
  <cftry>
    <cfquery name="qDelSpeaker" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">
		DELETE FROM speakers
		WHERE speakerId = <cfqueryparam value="#ARGUMENTS.id#" cfsqltype="cf_sql_integer" />
	</cfquery>
    <cfcatch type="database">
      <cfreturn false />
    </cfcatch>
  </cftry>
  <cfreturn true />
</cffunction>

<!--- UTILITY FUNCTIONS --->
<!--- SAVE --->
<cffunction name="saveSpeaker" access="public" output="false" returntype="any" hint="I handle saving a speaker either by creating a new entry or updating an existing one.">
  <cfargument name="speaker" type="any" required="true" hint="I am the Speaker bean." />
  <cfif exists(ARGUMENTS.speaker)>
	<cfreturn updateSpeaker(ARGUMENTS.speaker) />
  <cfelse>
	<cfreturn createNewSpeaker(ARGUMENTS.speaker) />
  </cfif>
</cffunction>

<!--- EXISTS --->
<cffunction name="exists" access="private" output="false" returntype="boolean" hint="I check to see if a specific Speaker is in the database, using ID as the check.">
  <cfargument name="speaker" type="any" required="true" hint="I am the Speaker bean." />
  <cfset var qGetSpeaker = '' />
  <cfquery name="qGetSpeaker" datasource="#variables.instance.datasource.getDSN()#" username="#variables.instance.datasource.getUsername()#" password="#variables.instance.datasource.getPassword()#">
	SELECT speakerId FROM speakers
	WHERE speakerId = <cfqueryparam value="#ARGUMENTS.speaker.getUniqueID()#" cfsqltype="cf_sql_integer" />
  </cfquery>
  <cfif qGetSpeaker.RecordCount>
	<cfreturn true />
  <cfelse>
	<cfreturn false />
  </cfif>
</cffunction>
</cfcomponent>

