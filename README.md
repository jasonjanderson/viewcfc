ViewCFC
=======

View.cfc handles pagination, sorting and searching of data in a ColdFusion application.

Example:
```cfml
<!--- This section is used in conjuction with view.cfc to setup the table and its display functionalities like searching, sorting and general table layouts --->
<fieldset>
<cfoutput>
<legend>Hardware Items In Order #url.order#</legend>
</cfoutput>
<cfset variables.view = createObject('component', 'cfc/view')>
<cfscript>
	view.define_column("hw_type","HardwareType","hw_type", "false");
	view.define_column("model", "Model", "hw_model.model_name", "false");
	view.define_column("cpu_type", "CPU", "cpu_type", "false");
	view.define_column("cpu_speed", "CPU Speed", "cpu_speed", "false");
	view.define_column("intended_client", "Client", "intended_client", "false");
	view.define_column("intended_dept", "Client Department", "intended_dept", "false");
	view.define_column("cost", "Cost", "cost", "false");
    
	/* view.init(<default sort>, <default direction>, <base_url>, <url struct>, <form struct>) */
	view.init("hw_type", "ASC", "", url, form);
	
	/* Get table results from database */
	variables.qView = Application.hw_item_dao.item_list(url.order);
	
	variables.view.set_query(variables.qView);
</cfscript>
<table>
<th></th>
<cfscript>
	variables.view.print_header("hw_type");
	variables.view.print_header("model");
	variables.view.print_header("cpu_type");
	variables.view.print_header("cpu_speed");
	variables.view.print_header("intended_client");
	variables.view.print_header("intended_dept");
	variables.view.print_header("cost");
</cfscript>
<cfoutput query="qView">
  <tr>
    <td><a href="index.cfm?Go=hw_item&action=edit&item_id=#qView.hw_item_id#">Edit</a>/<a href="index.cfm?Go=hw_item&action=clone&item_id=#qView.hw_item_id#">Clone</a>/<a href="index.cfm?Go=hw_item&action=delete&item_id=#qView.hw_item_id#">Delete</a></td>
    <td>#variables.qView.hw_type#</td>
    <td>#variables.qView.model_name#</td>
    <td>#variables.qView.cpu_type#</td>
    <td>#variables.qView.cpu_speed#</td>
    <td>#variables.qView.intended_client#</td>
    <td>#variables.qView.intended_dept#</td>
    <td>#variables.qView.cost#</td>
  </tr>
</cfoutput>
<cfoutput>
	</table>
	<div align="center">
		Page #variables.view.get_current_page()# of #variables.view.get_last_page()#
	</div>
	<table width="90%">
		<tr>
			<td align="left">
</cfoutput>
			<!--- Generate Previous Link --->
<cfscript>
			variables.view.print_previous_link();
			
</cfscript>
<cfoutput>
			</td>
			<td align="right">
</cfoutput>
			<!--- Generate Next Link --->
<cfscript>
			variables.view.print_next_link();
</cfscript>
<cfoutput>
			</td>
		</tr>
	</table>
</cfoutput>


</fieldset>

```
