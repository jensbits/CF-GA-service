<!--- the serviceAccountID email must have access to GA profile (read and analyze level) --->
<!--- path to your .p12 file in pathToKeyFile (make sure it is NOT browsable --->

<!--- cfanalytics.cfc is saved in folder named cfanalytics hence the path "cfanalytics.cfanalytics" --->
<!--- use whatever path you saved the cfanalytics.cfc to --->
<cfset cfanalytics = createObject("component", "cfanalytics.cfanalytics").init(
										serviceAccountID="rdk2121kxxxxxxx@developer.gserviceaccount.com",
										pathToKeyFile=expandPath("key.p12"), 
										analyticsAppName="Your App Name in the GA Console") />
																		
<cfset cfanalytics.buildAnalytics()/>

<!--- tableId (profile id) of GA account to access --->
<!---note that tableId, startDate, endDate, and metrics are required per Google --->
<!--- dimensions, sort, filters, and maxResults are optional. maxResults default is 25 --->
<cfset GAdata = cfanalytics.getData(tableId="ga:XXXXXXXXX", 
					     	startDate="2013-01-01",
					     	endDate="2013-12-14",
					     	metrics="ga:visits",
					     	dimensions="ga:source,ga:keyword",
					     	sort="-ga:visits,ga:source",
					     	filters="ga:medium==organic",
					     	maxResults=50) />
									 
<!--- dump the structure returned --->
<cfdump var="#GAdata#">
