<!---
Author: jen
Date: 12/17/13
Updated: 02/19/15
References: https://developers.google.com/accounts/docs/OAuth2ServiceAccount
            https://code.google.com/p/google-api-java-client/wiki/OAuth2
            https://developers.google.com/api-client-library/java/apis/analytics/v3
            https://developers.google.com/analytics/devguides/reporting/core/dimsmets 
            http://ga-dev-tools.appspot.com/explorer/
--->

<cfcomponent displayname="cfanalytics" output="false">

	<cffunction name="init" access="public" output="false" returntype="Cfanalytics">
		<cfargument name="serviceAccountId" type="string" required="true" />
		<cfargument name="pathToKeyFile" type="string" required="true" />
		<cfargument name="analyticsAppName" type="string" required="true" />
		<cfscript>
			variables.serviceAccountId         = arguments.serviceAccountId;
			variables.pathToKeyFile            = arguments.pathToKeyFile;
			variables.analyticsAppName		   = arguments.analyticsAppName;

			variables.HTTP_Transport           = createObject("java", "com.google.api.client.http.javanet.NetHttpTransport").init();
			variables.JSON_Factory             = createObject("java", "com.google.api.client.json.jackson2.JacksonFactory").init();
			variables.HTTP_Request_Initializer = createObject("java", "com.google.api.client.http.HttpRequestInitializer");
			variables.Credential_Builder       = createObject("java", "com.google.api.client.googleapis.auth.oauth2.GoogleCredential$Builder");

			variables.Analytics_Scopes         = createObject("java", "com.google.api.services.analytics.AnalyticsScopes");
			variables.Analytics_Builder        = createObject("java", "com.google.api.services.analytics.Analytics$Builder").init(
																	     variables.HTTP_Transport, 
																	     variables.JSON_Factory, 
																	     javaCast("null", ""));
																	    
			variables.Collections              = createObject("java", "java.util.Collections");
			variables.File_Obj                 = createObject("java", "java.io.File");

			variables.credential 			   = "";
			variables.analytics                = "";
		</cfscript>
		<cfreturn this />
	</cffunction>

	<cffunction name="buildAnalytics" access="public" output="false" returntype="struct" hint="creates analytics object">
		<cfset local = {} />
		<cfset local.credential = "" />
		<cfset local.returnStruct = {} />
		<cfset local.returnStruct.success = true />
		<cfset local.returnStruct.error = "" />

		<!--- Access tokens issued by the Google OAuth 2.0 Authorization Server expire in one hour. 
		When an access token obtained using the assertion flow expires, then the application should 
		generate another JWT, sign it, and request another access token. 
		https://developers.google.com/accounts/docs/OAuth2ServiceAccount --->

		<cftry>
			 <cfset local.credential = Credential_Builder
						    .setTransport(variables.HTTP_Transport)
						    .setJsonFactory(variables.JSON_Factory)
						    .setServiceAccountId(variables.serviceAccountId)
						    .setServiceAccountScopes(Collections.singleton(variables.Analytics_Scopes.ANALYTICS_READONLY))
						    .setServiceAccountPrivateKeyFromP12File(variables.File_Obj.Init(variables.pathToKeyFile))
						    .build() />

			<cfcatch type="any">
				<cfset local.returnStruct.error = "Credential Object Error: " & cfcatch.message & " - " & cfcatch.detail />
				<cfset local.returnStruct.success = false />
			</cfcatch>
		</cftry>
		 
		<cfif  local.returnStruct.success>
			<cftry>
				<cfset variables.analytics = variables.Analytics_Builder
								.setApplicationName(variables.analyticsAppName)
								.setHttpRequestInitializer(local.credential)
								.build() />

				<cfcatch type="any">
					<cfset local.returnStruct.error = "Analytics Object Error: " & cfcatch.message & " - " & cfcatch.detail />
					<cfset local.returnStruct.success = false />
				</cfcatch>
			</cftry>
		</cfif>
		
		<cfreturn local.returnStruct />
	</cffunction>

	<cffunction name="getProfiles" access="public" output="false" returntype="struct" hint="returns all profiles">
		<cfset local = {} />
		<cfset local.results = {} />
		<cfset local.results.error = "" />

		<cftry>
			<cfset local.results = variables.analytics.management().profiles().list("~all", "~all").execute() />
			<cfcatch type="any">
				<cfset local.results.error = cfcatch.message & " " & cfcatch.detail />
			</cfcatch>
		</cftry>

		<cfreturn local.results />
	</cffunction>

	<cffunction name="getData" access="public" output="false" returntype="struct" hint="returns GA data">
		<cfargument name="tableId" required="true" type="string" hint="profile (table) id to be queried" />
		<cfargument name="metrics" required="true" type="string" hint="query metrics" />
		<cfargument name="dimensions" required="false" type="string" default="" hint="query dimensions" />
		<cfargument name="startDate" required="true" type="string" hint="query start date format yyyy-mm-dd" />
		<cfargument name="endDate" required="true" type="string" hint="query end date format yyyy-mm-dd" />
		<cfargument name="sort" required="false" type="string" default="" hint="query sort" />
		<cfargument name="filters" required="false" type="string" default="" hint="query filters" />
		<cfargument name="maxResults" required="false" type="numeric" default="25" hint="max num of results" />

		<!--- Dimensions and metrics list: https://developers.google.com/analytics/devguides/reporting/core/dimsmets 
			  Use the query explorer to help build queries: http://ga-dev-tools.appspot.com/explorer/ --->
		<cfset local = {} />
		<cfset local.request = "" />
		<cfset local.results = {} />
		<cfset local.results.error = "" />

		<cftry>
			<cfset local.request = variables.analytics.data().ga().get(arguments.tableId, 
										   arguments.startDate, 
										   arguments.endDate, 
										   arguments.metrics) />
			<!--- optional parameters --->
			<cfif Len(arguments.dimensions)>
				<cfset local.request.setDimensions(arguments.dimensions) />
			</cfif>

			<cfif Len(arguments.sort)>
				<cfset local.request.setSort(arguments.sort) />
			</cfif>

			<cfif Len(arguments.filters)>
				<cfset local.request.setFilters(arguments.filters) />
			</cfif>
		
			<cfset local.request.setMaxResults(arguments.maxResults) />

			<cfset local.results = local.request.execute() /> 
			<cfcatch type="any">
				<cfset local.results.error = cfcatch.message & " " & cfcatch.detail />
			</cfcatch>
		</cftry>

		<cfreturn local.results />
	</cffunction> 
	
	<cffunction name="getRealTimeData" access="public" output="false" returntype="struct" hint="returns GA data">
		<cfargument name="tableId" required="true" type="string" hint="profile (table) id to be queried" />
		<cfargument name="metrics" required="true" type="string" hint="query metrics" />
		<cfargument name="dimensions" required="false" type="string" default="" hint="query dimensions" />
		<cfargument name="sort" required="false" type="string" default="" hint="query sort" />
		<cfargument name="filters" required="false" type="string" default="" hint="query filters" />
		<cfargument name="maxResults" required="false" type="numeric" default="25" hint="max num of results" />

		<!--- Dimensions and metrics list: https://developers.google.com/analytics/devguides/reporting/realtime/dimsmets/ 
			  Use the query explorer to help build queries: https://developers.google.com/apis-explorer/#p/analytics/v3/analytics.data.realtime.get --->
		<cfset local = {} />
		<cfset local.request = "" />
		<cfset local.results = {} />
		<cfset local.results.error = "" />

		<cftry>
			<cfset local.request = variables.analytics.data().realtime().get(arguments.tableId, arguments.metrics) />

			<!--- optional parameters --->
			<cfif Len(arguments.dimensions)>
				<cfset local.request.setDimensions(arguments.dimensions) />
			</cfif>

			<cfif Len(arguments.sort)>
				<cfset local.request.setSort(arguments.sort) />
			</cfif>

			<cfif Len(arguments.filters)>
				<cfset local.request.setFilters(arguments.filters) />
			</cfif>
		
			<cfset local.request.setMaxResults(arguments.maxResults) />

			<cfset local.results = local.request.execute() /> 

			<cfcatch type="any">
				<cfset local.results.error = cfcatch.message & " " & cfcatch.detail />
			</cfcatch>
		</cftry>

		<cfreturn local.results />
	</cffunction> 

</cfcomponent>
