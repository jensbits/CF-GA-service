CF-GA-service
=============

Accessing Google Analytics API with Service Account and Coldfusion

See http://www.jensbits.com/2013/12/28/google-analytics-api-offline-access-with-service-account-and-coldfusion/

Set up credentials for accessing GA as service:
-----------------------------------------------

1. Create your project in the Google console: https://code.google.com/apis/console

2. Go to API's & Auth and turn off all but the Analytics API.

3. Go to Credentials (under API's) and click Create a New Client ID.

4. Select Service Account from the pop up.

5. Save the .p12 file it will prompt you to download to a non-browsable place on your webserver. Feel free to rename it but keep the .p12 extension.

The service account email address will be under the Service Account setting box as Email Address and be in the form of xxxxxxxxxxxxxx@developer.gserviceaccount.com (the really long email)

6. Add this email to the Google analytics profile(s) as a user with Read & Analyze access.

Add the .jar files to the CF server
-----------------------------------

1. Add the Google Analytics API v3 client library .jar files to the CF server in the WEB-INF/lib folder. The files can be currently found at: https://developers.google.com/api-client-library/java/apis/analytics/v3 The readme.html will list the dependencies. As of this post they are the following when using Jackson 2:
  google-api-services-analytics-v3-rev77-1.17.0-rc.jar
  google-api-client-1.17.0-rc.jar
  google-oauth-client-1.17.0-rc.jar
  google-http-client-1.17.0-rc.jar
  jsr305-1.3.9.jar
  google-http-client-jackson2-1.17.0-rc.jar
  jackson-core-$2.1.3.jar

2. Restart the CF server (if you installed the .jar files directly on the server).

Save the cfanalytics.cfc to your web root
-----------------------------------------

1. Save the cfanalytics folder to your web root or where you keep your com objects.

2. init() the cfanalytics object. This can be done as an application variable. The pathToKeyFile = expandPath("/your-path-to-key-file/your-key-name.p12"). Make sure this is non-browsable!

3. Call the getData() method to access data.

4. Use the following links for references on getting profile information and data from GA:
  https://developers.google.com/accounts/docs/OAuth2ServiceAccount
  https://code.google.com/p/google-api-java-client/wiki/OAuth2
  https://developers.google.com/api-client-library/java/apis/analytics/v3
  https://developers.google.com/analytics/devguides/reporting/core/dimsmets
  http://ga-dev-tools.appspot.com/explorer/
