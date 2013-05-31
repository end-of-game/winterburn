package ${packageName}.${packageDAO};

import ${packageToScan}.${className};
import java.util.List;

import fr.treeptik.exception.DAOException;

public interface ${className}DAO {

	${className} save (${className} ${classNameLowerCase}) throws DAOException;
	
	void delete (${className} ${classNameLowerCase}) throws DAOException;
	
	List<${className}> findAll() throws DAOException;
   
}