<!--- create a user object, modify 'myemail' and 'mypassword' --->
<cfset userObj = CreateObject('component','core.beans.User').init(
	userId  	= 0,
	username	= 'testAdmin',
	password	= LCase(Hash('password','SHA-384')),
	role    	= 'admin',
	isActive	= 1
) />
 
<!--- save the user object --->	
<cfset userObj.setUserId(APPLICATION.userDAO.saveUser(userObj)) />
 
<!--- generate a speaker object --->
<cfset speakerObj = CreateObject('component','core.beans.Speaker').init(
		speakerId  	= 0,
		speakerKey	= RandRange(100000,999999),
		userId     	= userObj.getUserId(),
		firstName  	= 'Admin',
		lastName   	= 'User',
		email      	= userObj.getUsername(),
		showPhone	= 0,
		showTwitter	= 0,
		isOnline   	= 0,
		speakerPrograms = SerializeJSON('')
) />
 
<!--- save the speaker object --->
<cfset speakerObj.setSpeakerId(APPLICATION.speakerDAO.saveSpeaker(speakerObj)) />


<br><br>
USER CREATED
<br><br>
<cfdump var="#userObj#">
<cfdump var="#speakerObj#">
