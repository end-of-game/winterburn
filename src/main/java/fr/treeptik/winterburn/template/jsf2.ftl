<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://java.sun.com/jsf/html"
	xmlns:f="http://java.sun.com/jsf/core"
	xmlns:ui="http://java.sun.com/jsf/facelets">

<ui:composition template="/template/main.xhtml">

	<ui:param name="${classNameToLowerCase}" value="active"></ui:param>


	<ui:define name="body">

		<h1>Créer un(e) ${classNameToLowerCase}</h1>
		
		<h:form>
		
				
		<#list fields?keys as field>
		<div class="control-group">
		<label class="control-label">${field}</label>
			<div class="controls">
		
		<h:inputText value="${r"#{"}${classNameToLowerCase}Controller.${classNameToLowerCase}.${field}}" styleClass="input input-large" />
		
			</div>
		</div>
		</#list>
		<div class="control-group">
					<h:commandButton action="${r"#{"}${classNameToLowerCase}Controller.save()}"
						value="Enregistrer"
						styleClass="btn btn-large btn-info" />
				</div>
			

	</h:form>
	<h1>Liste des ${classNameToLowerCase}s</h1>
	<h:dataTable styleClass="table table-index"
						value="${r"#{"}${classNameToLowerCase}Controller.${classNameToLowerCase}s}" var="${classNameToLowerCase}1">
						<#list fields?keys as field>
					<h:column>
    				
    				<f:facet name="header">${field}</f:facet>
    				
    				${r"#{"}${classNameToLowerCase}1.${field}}
    				
    			</h:column>
    			
    				</#list>
	</h:dataTable>
	
	</ui:define>
</ui:composition>

</html>