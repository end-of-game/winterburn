package ${packageName}.${persistenceAPI}.${packageDAO};

import org.springframework.stereotype.Repository;

import java.util.List;

import org.apache.log4j.Logger;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.PersistenceException;
import javax.persistence.TypedQuery;

import fr.treeptik.exception.DAOException;

import ${packageToScan}.${className};
import ${packageName}.${packageDAO}.${className}DAO;



@Repository
public class ${className}JPADAO implements ${className}DAO{

	private Logger logger = Logger.getLogger(${className}JPADAO.class);
	//fields
	@PersistenceContext
	private EntityManager entityManager;

	//methods
	
	public ${className} save (${className} ${classNameLowerCase}) throws DAOException {
		try	{
		entityManager.persist(${classNameLowerCase});
		}
		catch (PersistenceException e) {
			throw new DAOException("Erreur création ${classNameLowerCase}",e);
			}	
		return ${classNameLowerCase};
	}
	
	public void delete (${className} ${classNameLowerCase}) throws DAOException {
		try	{
		entityManager.remove(${classNameLowerCase});
		}
		catch (PersistenceException e) {
			throw new DAOException("Erreur suppression ${classNameLowerCase}",e);
		}
	}
	
	public List<${className}> findAll() throws DAOException {
	TypedQuery<${className}> query;
		try	{
			 query = entityManager.createQuery(
				"Select e from ${className} e ", ${className}.class);
				} catch (PersistenceException e) {
			throw new DAOException("Erreur lister",e);
		}
		return query.getResultList();
	}
   
}