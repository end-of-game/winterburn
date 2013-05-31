package ${packageName}.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import fr.treeptik.exception.DAOException;
import fr.treeptik.exception.ServiceException;

import ${packageToScan}.${className};
import ${packageName}.${packageDAO}.${className}DAO;
import org.apache.log4j.Logger;

@Service
public class ${className}Service {
	
	private Logger logger = Logger.getLogger(${className}Service.class);
	
	//fields
	@Autowired
	private ${className}DAO ${classNameLowerCase}DAO;

	//methods
	
	@Transactional
	public ${className} save (${className} ${classNameLowerCase}) throws ServiceException{
		try {
		return ${classNameLowerCase}DAO.save(${classNameLowerCase});
		} catch (DAOException e) {
			throw new ServiceException("Erreur methode save ", e);
		}
	}
	@Transactional
	public void delete (${className} ${classNameLowerCase}) throws ServiceException{
		try {
		${classNameLowerCase}DAO.delete(${classNameLowerCase});
		} catch (DAOException e) {
			throw new ServiceException("Erreur methode delete ", e);
		}
	}
	
	public List<${className}> findAll() throws ServiceException{
		List<${className}> list;
		try {
		list = ${classNameLowerCase}DAO.findAll();
		} catch (DAOException e) {
			throw new ServiceException("Erreur methode list ", e);
		}
	return list;
	}
   
}