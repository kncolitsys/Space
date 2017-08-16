<cfcomponent output="false" hint="">

<cffunction name="init" returntype="assembla" access="public" output="false">
  <cfargument name="configfile"	type="string" required="false" default="#getDirectoryFromPath(getCurrentTemplatePath())#config/#listFirst(getFileFromPath(getCurrentTemplatePath()),'.')#.ini" />

	<cfloop collection="#arguments#" item="myArg">	
		<cfset variables.instance[myArg] = arguments[myArg] />
	</cfloop>
	<cfset variables.instance['config'] = loadConfigFile(arguments.configfile) />

	<cfreturn this />
</cffunction>


<cffunction name="getSpaces" returntype="any" access="public" output="false" hint="">
	<cfargument name="url"			type="string" required="true" hint="" />
	<cfargument name="username" type="string" required="true" hint="" />
	<cfargument name="password" type="string" required="true" hint="" />
	<cfargument name="owned"		type="string" required="false" default="false" />

	<cfset var myResult = structNew() />
	<cfset var mySpace	= "" />

	<cfhttp url="#arguments.url#" method="get" username="#arguments.username#" password="#arguments.password#" result="myResult.content">
		<cfhttpparam type="header" name="Accept" value="application/xml" />
	</cfhttp>
	<cfset myResult.xml = xmlParse(myResult.content.fileContent) />

	<cfset myResult.data = queryNew('ID,Name,Info,Alias,Owned,createdAt,updatedAt') />

	<cfloop from="1" to="#arrayLen(myResult.xml.xmlRoot.xmlChildren)#" index="mySpace">
		<cfset queryAddRow(myResult.data) />
		<cfset querySetCell(myResult.data,'ID',myResult.xml.xmlRoot.xmlChildren[mySpace].xmlChildren[5].xmlText) />
		<cfset querySetCell(myResult.data,'Name',myResult.xml.xmlRoot.xmlChildren[mySpace].xmlChildren[9].xmlText) />
		<cfset querySetCell(myResult.data,'Info',myResult.xml.xmlRoot.xmlChildren[mySpace].xmlChildren[4].xmlText) />
		<cfset querySetCell(myResult.data,'Alias',myResult.xml.xmlRoot.xmlChildren[mySpace].xmlChildren[15].xmlText) />
		<cfset querySetCell(myResult.data,'Owned',myResult.xml.xmlRoot.xmlChildren[mySpace].xmlChildren[1].xmlText) />
		<cfset querySetCell(myResult.data,'createdAt',myResult.xml.xmlRoot.xmlChildren[mySpace].xmlChildren[2].xmlText) />
		<cfset querySetCell(myResult.data,'updatedAt',myResult.xml.xmlRoot.xmlChildren[mySpace].xmlChildren[13].xmlText) />
	</cfloop>
	
	<cfreturn myResult.data />
</cffunction>


<cffunction name="getData" returntype="query" access="public" output="false" hint="">
	<cfargument name="action"		type="string" required="true"  hint="" />
	<cfargument name="url"			type="string" required="false" hint="" />
	<cfargument name="username" type="string" required="false" hint="" />
	<cfargument name="password" type="string" required="false" hint="" />

	<cfset var myResult = "" />
	<cfinvoke component="#this#" method="#arguments.action#" argumentcollection="#arguments#" returnvariable="myResult" />

	<cfreturn myResult />
</cffunction>


<!--- CFC-Basis --->
<cffunction name="getServerName" returntype="string" access="public" output="false" >
	<cfreturn listFirst(createObject('java','java.net.InetAddress').getLocalHost().getHostName(),'/') />
</cffunction>


<cffunction name="getConfig" returntype="any" access="public" >
  <cfargument name="myField" type="string" required="true" >

  <cfreturn evaluate('variables.instance.config.#arguments.myField#') />
</cffunction>


<cffunction name="loadConfigFile" returntype="struct" access="public" output="false" >
  <cfargument name="iniFile" type="string" required="true" />

  <cfset var struct   = structNew() />
  <cfset var myFile   = arguments.iniFile />
  <cfset var sections = getProfileSections(myFile) />

  <cfset var section  = "" />
  <cfset var entry    = "" />

  <cfloop collection="#sections#" item="section">
    <cfset myStruct[section] = structNew() />
    <cfloop list="#sections[section]#" index="entry">
      <cfset struct[section][entry] = getProfileString(myFile,section,entry) />
    </cfloop>
  </cfloop>

  <cfreturn struct />
</cffunction>


<cffunction name="getInstanceData" returntype="struct" access="public" >
  <cfreturn variables.instance />
</cffunction>

</cfcomponent>