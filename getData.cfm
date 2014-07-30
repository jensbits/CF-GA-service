<!--- the serviceAccountID email must have access to GA profile (read and analyze level) --->
<!--- path to your .p12 file in pathToKeyFile (make sure it is NOT browsable --->

<!--- cfanalytics.cfc is saved in folder named cfanalytics hence the path "cfanalytics.cfanalytics" --->
<!--- use whatever path you saved the cfanalytics.cfc to --->
<cfset cfanalytics = createObject("component", "cfanalytics.cfanalytics").init(
										serviceAccountID="rdk2121kxxxxxxx@developer.gserviceaccount.com",
										pathToKeyFile=expandPath("key.p12"), 
										analyticsAppName="Your App Name in the GA Console") />
																		
<cfset cfanalytics.buildAnalytics()/>

<!--- run this only to get needed profile info. comment out or delete once you have the profile id --->
<cfset GAprofiles = cfanalytics.getProfiles() />

<!--- get profiles info. includes the profile id needed for the tableId parameter below --->
<cfdump var="#GAprofiles#">

<!--- tableId (profile id) of GA account to access --->
<!---note that tableId, startDate, endDate, and metrics are required per Google --->
<!--- dimensions, sort, filters, and maxResults are optional. maxResults default is 25 --->
<cfset GAdata = cfanalytics.getData(tableId="ga:XXXXXXXXX", 
					     	startDate="2014-01-01",
					     	endDate="2014-07-31",
					     	metrics="ga:visits",
					     	dimensions="ga:source,ga:keyword",
					     	sort="-ga:visits,ga:source",
					     	filters="ga:medium==organic",
					     	maxResults=50) />
									 
<!--- dump the structure returned --->
<cfdump var="#GAdata#">
