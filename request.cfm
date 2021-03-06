<cfparam name="FORM['ff' & Hash('speakerKey','SHA-384')]" default="" type="string" />
<cfparam name="FORM.cName" default="" type="string" />
<cfparam name="FORM.orgName" default="" type="string" />
<cfparam name="FORM.email" default="" type="string" />
<cfparam name="FORM.eventName" default="" type="string" />
<cfparam name="FORM.venue" default="" type="string" />
<cfparam name="FORM.eventDate" default="" type="string" />
<cfparam name="FORM.eventTime" default="" type="string" />
<cfparam name="FORM.attendees" default="" type="string" />
<cfparam name="FORM.specialty" default="" type="string" />
<cfparam name="FORM.capcha" default="" type="string" />
<cfparam name="FORM['ff' & Hash('capcha')]" default="#APPLICATION.formZero#" type="string" />

<!--- make sure the form was submitted from this website --->
<cfif NOT APPLICATION.utils.checkReferer( CGI.HTTP_HOST, CGI.HTTP_REFERER )>
	<!--- it wasm't, redirect back to the index --->
	<cflocation url="/index.cfm" />
</cfif>

<!--- set a null error message to check for later --->
<cfset errorMsg = '' />

<!--- check if the form was submitted --->
<cfif IsDefined('FORM.btn_Submit')>

	<!--- it was, sanitize the form values --->
	<cfset saniForm = APPLICATION.utils.sanitize(FORM) />

	<!--- process required fields --->
	<cfset reqCheck = APPLICATION.utils.checkRequired(
		fields = {
			cName 		= saniForm.cName,
			orgName 	= saniForm.orgName,
			email 		= saniForm.email,
			eventName 	= saniForm.eventName,
			venue 		= saniForm.venue,
			eventDate 	= saniForm.eventDate,
			eventTime	= saniForm.eventTime,
			attendees 	= saniForm.attendees,
			specialty	= saniForm.specialty,
			capcha 		= saniForm.capcha
		}
	) />
	
	<!--- check if the required fields were not provided --->
	<cfif NOT reqCheck.result>
		<!--- some fields not provided, set an error message to display --->
		<cfset errorMsg = '<p>We&apos;re sorry, but the following fields are required but were not provided:</p><ul>' />
		<!--- loop through the missing fields --->
		<cfloop from="1" to="#ListLen(reqCheck.fields)#" index="iX">
			<!--- add this field as a list item --->
			<cfset errorMsg = errorMsg & '<li>#ListGetAt(reqCheck.fields,iX)#</li>' />
		</cfloop>
		<cfset errorMsg = errorMsg & '</ul>' />
	</cfif>
	
	<!--- verify the capcha is correct --->
	<cfif saniForm.capcha NEQ APPLICATION.utils.dataDec(saniForm['ff' & Hash('capcha')], 'form')>
		<!--- capcha mismatch, set an error message to display --->
		<cfset errorMsg = '<p>We&apos;re sorry, but you did not enter the correct sum of the two numbers. You may have added the numbers incorrectly, typo&apos;d the answer, or at worst... you may not be human. Please try again.</p>' />
	</cfif>	
	
	<!--- get the speaker object from the passed in speaker key --->
	<cfset speakerObj = APPLICATION.speakerDAO.getSpeakerByKey(FORM['ff' & Hash('speakerKey','SHA-384')]) />
	
	<!--- check if the speaker key provided returns a valid speaker --->
	<cfif NOT Len(speakerObj.getSpeakerId())>
		<!--- invalid speaker requested, set an error message to display --->
		<cfset errorMsg = '<p>We&apos;re sorry, but we did not receive the values we expected in your request. Please try your request again.</p>' />
	</cfif>	
	
	<!--- ensure we have no errors --->
	<cfif NOT Len(errorMsg)>	
	
		<!--- carriage return --->
		<cfset cR = Chr(10) & Chr(13) />

		<!--- create a speaker request object using the passed values --->
		<cfset speakerRequestObj = createObject('component','core.beans.SpeakerRequest').init(
			speakerRequestId	= 0,
			speakerId       	= speakerObj.getSpeakerId(),
			requestedBy     	= saniForm.cName,
			organization    	= saniForm.orgName,
			email           	= saniForm.email,
			eventName 			= saniForm.eventName,
			venue           	= saniForm.venue,
			eventDate       	= saniForm.eventDate,
			eventTime       	= saniForm.eventTime,
			attendees       	= saniForm.attendees,
			topic           	= saniForm.specialty,
			isAccepted      	= 0,
			isCompleted     	= 0,
			isActive        	= 1
	    ) />

	    <!--- save the speaker request object --->
	    <cfset speakerRequestObj.setSpeakerRequestId( APPLICATION.speakerRequestDAO.saveSpeakerRequest( speakerRequestObj ) ) />

	    <!--- generate the encrypted speaker request id --->
	    <cfset encRequestId = APPLICATION.utils.dataEnc(speakerRequestObj.getSpeakerRequestId(), 'form') />
	
		<!--- we have, send a request email to the speaker --->
		<cfmail to="#speakerObj.getEmail()#" from="#saniForm.email#" subject="#APPLICATION.siteName# Speaker Request" bcc="#APPLICATION.bccEmail#" charset="utf-8">
		 <cfmailpart type="html">
		 	<h4>#APPLICATION.siteName# Speaker Request</h4>
			<p>Hello #speakerObj.getFirstName()#,</p>
			<p>#saniForm.cName# (#saniForm.email#) from #saniForm.orgName# has sent the following speaker request to you from #APPLICATION.siteName#:</p>
			<table>
				<tr>
					<td><strong>Event Name</strong></td>
					<td>#saniForm.eventName#</td>
				</tr>
				<tr>
					<td><strong>Venue/Location</strong></td>
					<td>#saniForm.venue#</td>
				</tr>
				<tr>
					<td><strong>Date and Time</strong></td>
					<td>#saniForm.eventDate# #saniForm.eventTime#</td>
				</tr>
				<tr>
					<td><strong>Expected No. of Attendees</strong></td>
					<td>#saniForm.attendees#</td>
				</tr>
				<tr>
					<td><strong>Requested Topic/Specialty</strong></td>
					<td>#saniForm.specialty#</td>
				</tr>
			</table>
			<p>&nbsp;</p>
			<p>Please reply to this email to contact #saniForm.cName# directly about this request.</p>
			<p>&nbsp;</p>
			<p>If you accept this request, please click the following link to update your statistics in our system:</p>
			<p><a href="#CGI.HTTP_HOST#/accept.cfm/#encRequestId#">Click to accept</a></p>
			<p>&nbsp;</p>
			<p>Sincerely,<br />The #APPLICATION.siteName# Team</p>
		 </cfmailpart>
		 <cfmailpart type="plain">
			#APPLICATION.siteName# Speaker Request#cR##cR#
			Hello #APPLICATION.utils.decodeVal(speakerObj.getFirstName())#,#cR##cR#
			#APPLICATION.utils.decodeVal(saniForm.cName)# (#APPLICATION.utils.decodeVal(saniForm.email)#) from #APPLICATION.utils.decodeVal(saniForm.orgName)# has sent the following#cR#
			speaker request to you from #APPLICATION.siteName#:#cR##cR##cR#
			Event Name#chr(9)##chr(9)##APPLICATION.utils.decodeVal(saniForm.eventName)##cR##cR#
			Venue/Location#chr(9)##chr(9)##APPLICATION.utils.decodeVal(saniForm.venue)##cR##cR#
			Date and Time#chr(9)##chr(9)##APPLICATION.utils.decodeVal(saniForm.eventDate)# #APPLICATION.utils.decodeVal(saniForm.eventTime)##cR##cR#
			Expected No. of Attendees#chr(9)##chr(9)##APPLICATION.utils.decodeVal(saniForm.attendees)##cR##cR#
			Requested Topic/Specialty#chr(9)##APPLICATION.utils.decodeVal(saniForm.specialty)##cR##cR##cR#
			Please reply to this email to contact #APPLICATION.utils.decodeVal(saniForm.cName)# directly about this request.#cR##cR##cR#
			If you accept this request, please click the following link to update your statistics in our system:#cR#
			#CGI.HTTP_HOST#/accept.cfm/#encRequestId##cR##cR#
			Sincerely,#cR#
			The #APPLICATION.siteName# Team#cR##cR#
		 </cfmailpart>
		</cfmail>	
		
	<!--- end ensuring we have no errors --->	
	</cfif>
	
<!--- otherwise --->
<cfelse>

	<!--- form not submitted, redirect back to the index --->
	<cflocation url="/index.cfm" />		

<!--- end checking if the form was submitted --->	
</cfif>

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="shortcut icon" href="favicon.ico">

    <title><cfoutput>#APPLICATION.siteName#</cfoutput> &raquo; Speaker Request</title>

    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" rel="stylesheet">
    <link href="//cdn.vsgcom.net/css/jumbotron.css" rel="stylesheet">

    <!--- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries --->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>

  <body>

    <div class="navbar navbar-inverse navbar-fixed-top" role="navigation">
      <div class="container">
        <div class="navbar-header">
          <a class="navbar-brand" href="index.cfm"><cfoutput>#APPLICATION.siteLongName#</cfoutput></a> <span class="navbar-brand">&raquo; Speaker Request</span>
        </div>
      </div>
    </div>

	<br />

    <div class="container">
	  <div class="row">
        <div class="col-md-12">

	  		<cfif Len(errorMsg)>

			<div class="panel panel-danger">
			  <div class="panel-heading">Speaker Request Incomplete</div>
			  <div class="panel-body">
				<cfoutput>#errorMsg#</cfoutput>
			  </div>
			  <cfif Len(speakerObj.getSpeakerKey())>
			  <div class="panel-footer">
			  	<cfoutput><a class="btn btn-info" href="si.cfm/#speakerObj.getSpeakerKey()#" role="button">Click here to try again</a></cfoutput>
			  </div>
			  </cfif>
			</div>
			
			<cfelse>
			
			<div class="panel panel-success">
			  <div class="panel-heading">Speaker Request Complete</div>
			  <div class="panel-body">
				<cfoutput><p>Congratulations! You have sent a speaking request for your event to #speakerObj.getFirstName()# #speakerObj.getLastName()#. This speaker has been notified via email and you should receive a response from the speaker soon. Thank you for using #APPLICATION.siteName# to contact speaker(s) for your event(s).</p></cfoutput>
			  </div>
			</div>
			
			</cfif>	
	  
		</div>
	  </div>

      <hr>

      <cfinclude template="includes/footer.cfm" />
    </div> <!--- /container --->

    <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
    <script src="//netdna.bootstrapcdn.com/bootstrap/3.3.1/js/bootstrap.min.js"></script>
  </body>
</html>
