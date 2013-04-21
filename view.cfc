
<cfcomponent displayname="view" output="false">
<!--- ======================================================================================== --->
	<cfscript>
		variables.safetext = Application.safe;
		
		variables.column = StructNew();
		variables.sortable = StructNew();
		variables.sql = StructNew();
		
		variables.up_arrow = "./images/up.jpg";
		variables.down_arrow = "./images/down.jpg";
		variables.base_url = "";
		variables.search = "";
		
		variables.default_sort = "";
		variables.default_dir = "";
		
		variables.sort = "";
		variables.dir = "ASC";
		
		variables.page = 1;
		variables.row = Application.listitemsperpage;
		variables.total_row = 0;
		variables.show_all = False;
		
		variables.name_sort = "sort";
		variables.name_dir = "dir";
		variables.name_page = "page";
		variables.name_row = "row";
		
		variables.url_name_search = "search";
		variables.form_name_search = "search";
		
	</cfscript>
	
	<!--- 
	==================================================================================================
	FUNCTION NAME: init
	DESCRIPTION: 
		- Sets the default sort criteria and direction
		- Sets the base URL used in links that are outputted
		- Cleans URL and form structs
		- Populates variables based on the contents of the form and URL structs
	RETURNS: void
	--------------------------------------------------------------------------------------------------
	ARGUMENTS
	--------------------------------------------------------------------------------------------------
	@default_sort -- string -- What to sort by if no sort criteria is supplied
	@default_dir -- string -- What direction to sort @default_sort by if no sort criteria is given
	@base_url -- string -- Base URL used to build up the next/previous + pagination + sort + rows links
	@url -- struct -- The raw URL struct.
	@form -- struct -- The raw form struct.
	==================================================================================================
	 --->
	<cffunction name="init" returntype="void">
		<!--- Function Arguments ----------------------------------------------------- --->
		<cfargument name="default_sort" type="string">
		<cfargument name="default_dir" type="string">
		<cfargument name="base_url" type="string">
		<cfargument name="url" type="struct">
		<cfargument name="form" type="struct">
		<!--- ------------------------------------------------------------------------ --->
		<cfscript>
			variables.base_url = arguments.base_url;
			
			/* Clean URL struct */
			variables.safetext.SafeStruct(arguments.url);
			
			/* Clean form struct */
			variables.safetext.SafeStruct(arguments.form);
			
			variables.default_sort = arguments.default_sort;
			variables.default_dir = arguments.default_dir;
			
			/* Check for sort criteria in the URL. If it doesn't exist,
				use the default sort criteria */
			if (IsDefined("arguments.url.#variables.name_sort#"))
			{
				This.set_sort(evaluate("arguments.url.#variables.name_sort#"));
			}
			else
			{
				This.set_sort(variables.default_sort);
			}
			/* Check for sort direction in the URL. If it doesn't exist,
				use the default sort direction */
			if (IsDefined("arguments.url.#variables.name_dir#"))
			{
				This.set_dir(evaluate("arguments.url.#variables.name_dir#"));
			}
			else
			{
				This.set_dir(variables.default_dir);
			}
			
			/* Check if the number of rows to display is in the URL. */
			if (IsDefined("arguments.url.#variables.name_row#"))
			{
				This.set_row(evaluate("arguments.url.#variables.name_row#"));
			}
			
			/* Check if the the page number is in the URL. */
			if (IsDefined("arguments.url.#variables.name_page#"))
			{
				This.set_page(evaluate("arguments.url.#variables.name_page#"));
			}
			/* Check if the search form was submitted. If not, check the URL for search query. */
			if (IsDefined("arguments.form.#variables.form_name_search#"))
			{
				This.set_search(evaluate("arguments.form.#variables.form_name_search#"));
			}
			else if (IsDefined("arguments.url.#variables.url_name_search#"))
			{
				This.set_search(evaluate("arguments.url.#variables.url_name_search#"));
			}
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->

	<!--- 
	==================================================================================================
	FUNCTION NAME: set_sort
	DESCRIPTION: Helper function to set the sort criteria. 
		If the input is not valid or the sort criteria is not sortable, the default_sort will be used.
	RETURNS: void
	--------------------------------------------------------------------------------------------------
	ARGUMENTS
	--------------------------------------------------------------------------------------------------
	@sort -- string -- Criteria to sort by.
	==================================================================================================
	 --->
	<cffunction name="set_sort" returntype="void">
		<cfargument name="sort" type="string">
		
		<cfscript>
			/* Check if the column is valid and if it is sortable. */
			if (StructKeyExists(variables.column, arguments.sort)
				AND StructKeyExists(variables.sortable, arguments.sort))
			{
				variables.sort = arguments.sort;
			}
			/* Else use default_sort. */
			else
			{
				variables.sort = variables.default_sort;
			}
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->
	
	<!--- 
	==================================================================================================
	FUNCTION NAME: set_dir
	DESCRIPTION: Sets/normalizes the direction that is passed.
	RETURNS: void
	--------------------------------------------------------------------------------------------------
	ARGUMENTS
	--------------------------------------------------------------------------------------------------
	@dir -- string -- direction to sort.
	==================================================================================================
	 --->
	<cffunction name="set_dir" returntype="void">
		<cfargument name="dir" type="string">
		
		<cfscript>
			/* If 'dir' is passed and is "DESC" or "desc", sort in descending order */
			if (ucase(arguments.dir) EQ "DESC")
			{
				variables.dir = "DESC";
			}
			/* Else sort in ascending order */
			else
			{
				variables.dir = "ASC";
			}
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->

	<!--- 
	==================================================================================================
	FUNCTION NAME: set_row
	DESCRIPTION: Sets the number of rows to display.
	RETURNS: void
	--------------------------------------------------------------------------------------------------
	ARGUMENTS
	--------------------------------------------------------------------------------------------------
	@row -- string -- Can either be numeric or a string.
	==================================================================================================
	 --->
	<cffunction name="set_row" returntype="void">
		<cfargument name="row" type="string">
		
		<cfscript>
			/* Check that 'arguments.row' is a number and is not negative */
			if (IsNumeric(arguments.row) AND arguments.row GT 0)
			{
				variables.row = arguments.row;
			}
			/* Else display all records. */
			else
			{
				variables.show_all = True;
			}
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->

	<!--- 
	==================================================================================================
	FUNCTION NAME: set_page
	DESCRIPTION: Sets what the current page is.
	RETURNS: void
	--------------------------------------------------------------------------------------------------
	ARGUMENTS
	--------------------------------------------------------------------------------------------------
	@page -- string
	==================================================================================================
	 --->
	<cffunction name="set_page" returntype="void">
		<cfargument name="page" type="string">
		
		<cfscript>
			/* Verify that 'arguments.page' is numeric and not negative */
			if (IsNumeric(arguments.page) AND arguments.page GT 0)
			{
				variables.page = arguments.page;
			}
			/* If 'arguments.page' is negative or not numeric, set the page to the first page */
			else
			{
				variables.page = 1;
			}
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->

	<!--- 
	==================================================================================================
	FUNCTION NAME: set_search
	DESCRIPTION: Sets the search
	RETURNS: void
	--------------------------------------------------------------------------------------------------
	ARGUMENTS
	--------------------------------------------------------------------------------------------------
	@search -- string
	==================================================================================================
	 --->
	<cffunction name="set_search" returntype="void">
		<cfargument name="search" type="string">
		
		<cfscript>
			/* Clear extra spaces from the search */
			variables.search = trim(arguments.search);
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->


	<cffunction name="set_name_sort" returntype="void">
		<cfargument name="name" type="string" required="yes">
		
		<cfscript>
			variables.name_sort = arguments.name;
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->

	<cffunction name="set_name_dir" returntype="void">
		<cfargument name="name" type="string" required="yes">
		
		<cfscript>
			variables.name_dir = arguments.name;
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->

	<cffunction name="set_name_page" returntype="void">
		<cfargument name="name" type="string" required="yes">
		
		<cfscript>
			variables.name_page = arguments.name;
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->

	<cffunction name="set_name_search" returntype="void">
		<cfargument name="name" type="string" required="yes">
		
		<cfscript>
			variables.name_search = arguments.name;
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->

	<cffunction name="set_name_row" returntype="void">
		<cfargument name="name" type="string" required="yes">
		
		<cfscript>
			variables.name_row = arguments.name;
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->
	
	<!--- 
	==================================================================================================
	FUNCTION NAME: get_search
	DESCRIPTION: Returns the search that was picked up from either the form or URL. (or an empty string)
	RETURNS: string
	==================================================================================================
	 --->
	<cffunction name="get_search" returntype="string">
		<cfscript>
			return variables.search;
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->

	<!--- 
	==================================================================================================
	FUNCTION NAME: get_sort
	DESCRIPTION: Returns the sort criteria that was either set in the URL or is the default sort.
	RETURNS: string
	==================================================================================================
	 --->	
	<cffunction name="get_sort" returntype="string">
		<cfscript>
			return variables.sort;
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->
	
	<!--- 
	==================================================================================================
	FUNCTION NAME: get_direction
	DESCRIPTION: Returns the direction that was either set in the URL or is the default dir.
	RETURNS: string
	==================================================================================================
	 --->
	<cffunction name="get_direction" returntype="string">
		<cfscript>
			return variables.dir;
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->
	
	<!--- 
	==================================================================================================
	FUNCTION NAME: get_first_row
	DESCRIPTION: Returns the first row on the current page
	RETURNS: numeric
	==================================================================================================
	 --->
	<cffunction name="get_first_row" returntype="numeric">
		<cfscript>
			/* Check if all records are being displayed. If so, return 1; */
			if (variables.show_all EQ True)
			{
				return 1;
			}
			/* Else return the first row based on the current page and number of rows */
			return ((variables.row * variables.page) - variables.row) + 1;
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->
	
	<!--- 
	==================================================================================================
	FUNCTION NAME: get_last_row
	DESCRIPTION: Returns the last row on the current page
	RETURNS: numeric
	==================================================================================================
	 --->
	<cffunction name="get_last_row" returntype="numeric">
		<cfscript>
			/* Check if all records are being displayed.
				Check if the calculated last row (number of rows * page number) is greater than
					the total number of rows based on the query.
				If EITHER of the above conditions are met, return the number of rows from the query. */
			if (variables.show_all EQ True
				OR (variables.row * variables.page) GT variables.total_row)
			{
				return variables.total_row;
			}
			/* Else return the calcuated last row */
			return variables.row * variables.page;
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->
	
	<!--- 
	==================================================================================================
	FUNCTION NAME: get_total_row
	DESCRIPTION: Returns the total number of rows in the query.
	RETURNS: numeric
	==================================================================================================
	 --->
	<cffunction name="get_total_row" returntype="numeric">
		<cfscript>
			return variables.total_row;
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->

	<!--- 
	==================================================================================================
	FUNCTION NAME: get_last_page
	DESCRIPTION: Returns the last page of the query based on the number of rows being displayed.
	RETURNS: numeric
	==================================================================================================
	 --->
	<cffunction name="get_last_page" returntype="numeric">
		<cfscript>
			if (variables.show_all EQ True)
			{
				return 1;
			}
			return Ceiling(variables.total_row / variables.row);
		</cfscript>
	</cffunction>	
<!--- ======================================================================================== --->

	<!--- 
	==================================================================================================
	FUNCTION NAME: get_current_page
	DESCRIPTION: Returns the current page of the query.
	RETURNS: numeric
	==================================================================================================
	 --->
	<cffunction name="get_current_page" returntype="numeric">
		<cfscript>
			/* Check if all records are being displayed. If so, return the only page */
			if (variables.show_all EQ True)
			{
				return 1;
			}
			/* Else return the page that was set in the variable */
			return variables.page;
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->

	<!--- 
	==================================================================================================
	FUNCTION NAME: get_num_row
	DESCRIPTION: Returns the number of rows on the page.
	RETURNS: numeric
	==================================================================================================
	 --->
	<cffunction name="get_num_row" returntype="numeric">
		<cfscript>
			/* Check if all records are being displayed. If so, return the total number of records */
			if (variables.show_all EQ True)
			{
				return variables.total_row;
			}
			/* Else return the number of rows that was set in the variable */
			return variables.row;
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->

	<!--- 
	==================================================================================================
	FUNCTION NAME: set_query
	DESCRIPTION: Passes the query to the view component.
	RETURNS: void
	--------------------------------------------------------------------------------------------------
	ARGUMENTS
	--------------------------------------------------------------------------------------------------
	@query -- query -- The query to paginate and sort.
	==================================================================================================
	 --->
	<cffunction name="set_query" returntype="void">
		<cfargument name="query" type="query">
		
		<cfscript>
			/* Make sure the query returned results */
			if (IsDefined("arguments.query.RecordCount"))
			{
				variables.total_row = arguments.query.RecordCount;
				
				/* If all records are being displayed, set the number of rows to display to the total
					number of rows in the query */
				if (variables.show_all EQ True)
				{
					variables.row = variables.total_row;
				}
			}
			
			/* Reconfigure the current page number based on the query */
			if (variables.show_all EQ True
				OR variables.page GT Ceiling(variables.total_row / variables.row))
			{
				variables.page = 1;
			}
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->

	<!--- 
	==================================================================================================
	FUNCTION NAME: get_search_form_url
	DESCRIPTION: Generates a URL that keeps the current items per page + sort + direction for the 
		search to POST to.
	RETURNS: string
	==================================================================================================
	 --->
	<cffunction name="get_search_form_url" returntype="string">
		<cfscript>
			var link = variables.base_url;
			
			/* Verify that the sort and direction are different from the defaults
				(keeps the clutter in the URL down) */
			if (variables.sort NEQ variables.default_sort
				OR variables.dir NEQ variables.default_dir)
			{
				link = link & "&#variables.name_sort#=#variables.sort#";
				link = link & "&#variables.name_dir#=#variables.dir#";
			}
			
			/* Verify that the current records per page is different from the default
				(also to keep the clutter in the URL down) */
			if (variables.row NEQ Application.listitemsperpage)
			{
				link = link & "&#variables.name_row#=#URLEncodedFormat(variables.row)#";
			}
			
			return link;
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->

	<!--- 
	==================================================================================================
	FUNCTION NAME: get_sort_sql
	DESCRIPTION: Returns the name of the SQL field that we are sorting by.
		Used primary in the function that actually calls the database query.
	RETURNS: string
	==================================================================================================
	 --->
	<cffunction name="get_sort_sql" returntype="string">
		<cfreturn variables.sql[This.get_sort()]>
	</cffunction>
<!--- ======================================================================================== --->
	
	<!--- 
	==================================================================================================
	FUNCTION NAME: define_column
	DESCRIPTION: Sets the valid column names and defines if a column is sortable or not
	RETURNS: void
	--------------------------------------------------------------------------------------------------
	ARGUMENTS
	--------------------------------------------------------------------------------------------------
	@name -- string -- Name assigned to the column. Also used in the URL when sorting.
	@title -- string -- Title of the column header on the table.
	@sql -- string -- SQL column name for column.
	@sortable -- boolean -- Defines if the column can be sorted.
	==================================================================================================
	 --->
	<cffunction name="define_column" returntype="void">
		<cfargument name="name" type="string">
		<cfargument name="title" type="string">
		<cfargument name="sql" type="string" default="#arguments.name#" required="no">
		<cfargument name="sortable" type="boolean" default="true" required="no">
		
		<cfscript>
			StructInsert(variables.column, arguments.name, arguments.title);
			StructInsert(variables.sql, arguments.name, arguments.sql);
			
			/* Only add the struct key to the struct if the column will be sortable */
			if (arguments.sortable EQ True)
			{
				StructInsert(variables.sortable, arguments.name, arguments.sortable);
			}
		</cfscript>
	</cffunction>
<!--- ======================================================================================== --->
	<!--- 
	==================================================================================================
	FUNCTION NAME: print_header 
	DESCRIPTION: Prints the title and sorting links for the defined header
	RETURNS: void
	--------------------------------------------------------------------------------------------------
	ARGUMENTS
	--------------------------------------------------------------------------------------------------
	@name -- string -- Name of the column to print header for.
	==================================================================================================
	 --->
	<cffunction name="print_header" returntype="void">
		<cfargument name="name" type="string">
		
		<cfscript>
			var link = variables.base_url;
			var arrow = "";
		</cfscript>
		
		<cfoutput>
			<td nowrap="true">
		</cfoutput>
		
		<!--- Only print the link and arrows if the column is sortable --->
		<cfif StructKeyExists(variables.sortable, arguments.name)>
			<cfscript>
				link = link & "&#variables.name_sort#=#arguments.name#";
				
				/* Check if the column being printed is the column that we are sorting by.
					If so, print the arrows on either side of the title */
				if (arguments.name EQ variables.sort)
				{
					/* Print the link as the inverse of the current sort direction */
					if (variables.dir EQ "ASC")
					{
						/* When ASCENDING, display the UP arrow and print the link as DESCENDING */
						arrow = variables.up_arrow;
						link = link & "&#variables.name_dir#=DESC";
						
					}
					else
					{
						/* When DESCENDING, display the DOWN arrow and print the link as ASCENDING */
						arrow = variables.down_arrow;
						link = link & "&#variables.name_dir#=ASC";
					}
				}
				
				link = link & "&#variables.name_page#=1";
				
				/* Use the special keyword "all" if all rows are being displayed */
				if (variables.show_all EQ True)
				{
					link = link & "&#variables.name_row#=all";
				}
				/* Else use the numeric value of the number of rows per page */
				else
				{
					link = link & "&#variables.name_row#=#URLEncodedFormat(variables.row)#";
				}
				
				/* If there is a search set, append the search to the column header */
				if (variables.search NEQ "")
				{
					link = link & "&#variables.url_name_search#=#URLEncodedFormat(variables.search)#";
				}
			</cfscript>
			<!--- BEGIN ============== Output the generated link and column title ============== BEGIN --->
			<cfoutput>
				<a href="#link#">
					<!--- Only display arrow if it is set
						(meaning, if the query is sorted by the currently begin printed criteria) --->
					<cfif arrow NEQ "">
					<img src="#arrow#">
					</cfif>
					#evaluate("variables.column.#arguments.name#")#
					<!--- Only display arrow if it is set
						(meaning, if the query is sorted by the currently begin printed criteria) --->
					<cfif arrow NEQ "">
					<img src="#arrow#">
					</cfif>
				</a>
			</cfoutput>
			<!--- END ================= Output the generated link and column title ================ END --->
			
		<!--- Column is not sortable so just print the title --->
		<cfelse>
			<!--- BEGIN ======================== Output the column title ======================== BEGIN --->
			<cfoutput>
				#evaluate("variables.column.#arguments.name#")#
			</cfoutput>
			<!--- END ========================== Output the column title ========================== END --->
		</cfif>
		<cfoutput>
			</td>
		</cfoutput>
	</cffunction>
<!--- ======================================================================================== --->
	
	<!--- 
	==================================================================================================
	FUNCTION NAME: print_row_link
	DESCRIPTION: Prints the link to the current page with the sort + direction + search populated
		(if need be) as long with the row set to arguments.row
	RETURNS: void
	--------------------------------------------------------------------------------------------------
	ARGUMENTS
	--------------------------------------------------------------------------------------------------
	@row -- string -- Number of rows to display on a page. Use "Show All" to display all the records
	of the query.
	==================================================================================================
	 --->
	<cffunction name="print_row_link" returntype="void">
		<cfargument name="row" type="string">
		
		<cfscript>
			var link = variables.base_url;
		</cfscript>
		<!--- If the page is displaying the current number of rows per page,
			print arguments.row as plain text --->
		<cfif variables.row EQ arguments.row
			OR (variables.show_all EQ True AND arguments.row EQ "Show All")>
			<cfoutput>
				#arguments.row#
			</cfoutput>
			<cfreturn>
		</cfif>
				
		<cfscript>
			/* Verify that the sort and direction are different from the defaults
				(keeps the clutter in the URL down) */
			if (variables.sort NEQ variables.default_sort OR
				variables.dir NEQ variables.default_dir)
			{
				link = link & "&#variables.name_sort#=#variables.sort#";
				link = link & "&#variables.name_dir#=#variables.dir#";
			}
			
			/* Reset the page to 1 */
			link = link & "&#variables.name_page#=1";
			
			/* If the link being printed is the "Show All" link, use the keyword all in the URL */
			if (arguments.row EQ "Show All")
			{
				link = link & "&#variables.name_row#=all";
			}
			/* Else if the link is for a numeric row count, print arguments.row in the URL */
			else
			{
				link = link & "&#variables.name_row#=#URLEncodedFormat(arguments.row)#";
			}
			/* If the the search is not empty, add it to the URL as well */
			if (variables.search NEQ "")
			{
				link = link & "&#variables.url_name_search#=#URLEncodedFormat(variables.search)#";
			}
		</cfscript>
		
		<!--- Print the link with arguments.row as the column --->
		<cfoutput>
			<a href="#link#">#arguments.row#</a>
		</cfoutput>
	</cffunction>
<!--- ======================================================================================== --->
	
	<cffunction name="print_next_link" returntype="void">
		<cfargument name="title" type="string" required="false" default="Next >>">
		
		<cfscript>
			var link = variables.base_url;
			
			if (variables.show_all EQ True)
			{
				return;	
			}
		</cfscript>
			
		<cfif variables.total_row GT 0>
			<cfscript>
				if ((variables.page * variables.row) GTE variables.total_row)
				{
					return;
				}
				
				/* ============ Start Populate Next Link =========== */
				if (variables.sort NEQ variables.default_sort OR
					variables.dir NEQ variables.default_dir)
				{
					link = link & "&#variables.name_sort#=#variables.sort#";
					link = link & "&#variables.name_dir#=#variables.dir#";
				}
				link = link & "&#variables.name_page#=#variables.page + 1#";
				
				if (variables.show_all EQ True)
				{
					link = link & "&#variables.name_row#=all";
				}
				else
				{
					link = link & "&#variables.name_row#=#URLEncodedFormat(variables.row)#";
				}

				if (variables.search NEQ "")
				{
					link = link & "&#variables.url_name_search#=#URLEncodedFormat(variables.search)#";
				}
				/* ============ End Populate Next Link =========== */
			</cfscript>
			<cfoutput>
				<a href="#link#">#arguments.title#</a>
			</cfoutput>
		</cfif>
	</cffunction>
<!--- ======================================================================================== --->
	
	
	<cffunction name="print_previous_link" returntype="void">
		<cfargument name="title" type="string" required="false" default="<< Previous">
		
		<cfscript>
			var link = variables.base_url;
			
			if (variables.show_all EQ True)
			{
				return;	
			}
		</cfscript>
			
		<cfif variables.total_row GT 0>
			<cfscript>
				if (variables.page LTE 1)
				{
					return;
				}
				
				/* ============ Start Populate Previous Link =========== */
				if (variables.sort NEQ variables.default_sort OR
					variables.dir NEQ variables.default_dir)
				{
					link = link & "&#variables.name_sort#=#variables.sort#";
					link = link & "&#variables.name_dir#=#variables.dir#";
				}
				link = link & "&#variables.name_page#=#variables.page - 1#";
				
				if (variables.show_all EQ True)
				{
					link = link & "&#variables.name_row#=all";
				}
				else
				{
					link = link & "&#variables.name_row#=#URLEncodedFormat(variables.row)#";
				}
			
				if (variables.search NEQ "")
				{
					link = link & "&#variables.url_name_search#=#URLEncodedFormat(variables.search)#";
				}
				/* ============ End Populate Previous Link =========== */
			</cfscript>
			<cfoutput>
				<a href="#link#">#arguments.title#</a>
			</cfoutput>
		</cfif>
	</cffunction>
<!--- ======================================================================================== --->
</cfcomponent>