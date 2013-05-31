package ${packageName}.${packageController};

import java.io.Serializable;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ManagedProperty;
import javax.faces.bean.SessionScoped;
import javax.faces.model.ListDataModel;
import org.apache.log4j.Logger;


import fr.treeptik.exception.ServiceException;
import ${packageToScan}.${className};
import ${packageName}.${packageService}.${className}Service;


@ManagedBean()
@SessionScoped
public class ${className}Controller implements Serializable {

	private static final long serialVersionUID = 1L;
	
	private Logger logger = Logger.getLogger(${className}Controller.class);
	
	private ${className} ${classNameLowerCase} = new ${className}();
	
	private ListDataModel<${className}> ${classNameLowerCase}s = new ListDataModel<${className}>();
	
	@ManagedProperty(value= "${r"#{"}${classNameLowerCase}Service}")
	private ${className}Service  ${classNameLowerCase}Service;
	
	//Methods
	
	public String save() throws ServiceException{
	${classNameLowerCase} = ${classNameLowerCase}Service.save(${classNameLowerCase});
	${classNameLowerCase} = new ${className}();
	return "${classNameLowerCase}";
	}
	
	public ListDataModel<${className}> get${className}s() throws ServiceException {
	${classNameLowerCase}s.setWrappedData(${classNameLowerCase}Service.findAll());
	return ${classNameLowerCase}s;
	}
	
	//Getters & Setters
	
	public ${className} get${className}(){
		return ${classNameLowerCase};
	}
	
	public void set${className}(${className} ${classNameLowerCase}){
		this.${classNameLowerCase} = ${classNameLowerCase};
	}
	
	public ${className}Service get${className}Service(){
		return ${classNameLowerCase}Service;
	}
	
	public void set${className}Service(${className}Service ${classNameLowerCase}Service){
		this.${classNameLowerCase}Service = ${classNameLowerCase}Service;
	}
	
}