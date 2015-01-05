<!--- COMPONENT --->
<cfcomponent displayname="Program" output="false" hint="I am the Program class.">
<cfproperty name="speakerId" type="string" default="" />
<cfproperty name="programId" type="string" default="" />
<cfproperty name="inactive" type="string" default="" />

<!--- PSEUDO-CONSTRUCTOR --->
<cfset variables.instance = {
	speakerId  = '',
	programId  = '',
	inactive   = ''
} />

<!--- INIT --->
<cffunction name="init" access="public" output="false" returntype="any" hint="I am the constructor method for the Program class.">
  <cfargument name="speakerId" type="string" required="true" default="" hint="" />
  <cfargument name="programId" type="string" required="true" default="" hint="" />
  <cfargument name="inactive" type="string" required="true" default="" hint="" />
  
  <!--- set the initial values of the bean --->
  <cfscript>
	setSpeakerId(ARGUMENTS.speakerId);
	setProgramId(ARGUMENTS.programId);
	setInactive(ARGUMENTS.inactive);
  </cfscript>
  <cfreturn this>
</cffunction>

<!--- SETTERS --->
<cffunction name="setSpeakerId" access="public" output="false" hint="I set the speakerId value into the variables.instance scope.">
  <cfargument name="speakerId" type="string" required="true" default="" hint="I am the speakerId value." />
  <cfset variables.instance.speakerId = ARGUMENTS.speakerId />
</cffunction>

<cffunction name="setProgramId" access="public" output="false" hint="I set the programId value into the variables.instance scope.">
  <cfargument name="programId" type="string" required="true" default="" hint="I am the programId value." />
  <cfset variables.instance.programId = ARGUMENTS.programId />
</cffunction>

<cffunction name="setInactive" access="public" output="false" hint="I set the inactive value into the variables.instance scope.">
  <cfargument name="inactive" type="string" required="true" default="" hint="I am the inactive value." />
  <cfset variables.instance.inactive = ARGUMENTS.inactive />
</cffunction>

<!--- GETTERS --->
<cffunction name="getSpeakerId" access="public" output="false" returntype="string" hint="I return the speakerId value.">
  <cfreturn variables.instance.speakerId />
</cffunction>

<cffunction name="getProgramId" access="public" output="false" returntype="string" hint="I return the programId value.">
  <cfreturn variables.instance.programId />
</cffunction>

<cffunction name="getInactive" access="public" output="false" returntype="string" hint="I return the inactive value.">
  <cfreturn variables.instance.inactive />
</cffunction>

<!--- UTILITY METHODS --->
<cffunction name="getMemento" access="public" output="false" hint="I return a struct of the variables.instance scope.">
  <cfreturn variables.instance />
</cffunction>
</cfcomponent>

