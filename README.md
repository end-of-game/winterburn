# Winterburn v.0.0.1

## Objectif du projet

L’outil de génération de code Winterburn s’appuie sur la technologie de l’Annotation Processing apparue en Java 1.5 pour générer automatiquement, sur la base d’un modèle (template), les fichiers JAVA et les pages Web nécessaires au fonctionnement d’une application Web en JAVA JEE. La première version du processor s'appuie sur un template JSF2/SpringIOC/JPA mais il est possible de l'adapter à n'importe quelle technologie en modifiant uniquement ces templates et la configuration du client.
L’ensemble des fichiers JAVA générés contient le code nécessaire à l’exécution des méthodes du C.R.U.D (sauvegarder, supprimer et lister les entités). Une page XHTML, contenant un formulaire de saisie de l’entité et la liste de toutes les entités en base, est également générée. Une prochaine version permettra, notamment, de charger directement le template de la page web depuis le projet client, ce qui permettra au développeur de personnaliser directement son projet au travers du client.
L’utilisation d’un tel outil permet un gain de temps indéniable pour le développeur dans la mesure où l’ensemble des fichiers intermédiaires sont générées automatiquement lorsqu’il sauvegarde un objet JAVA annoté avec @Entity. Tout le code générique est bien souvent long à copier et ne nécessite pas une réelle réflexion.

## Présentation du WinterBurnProcessor

### Côté Processor :

WinterBurnProcessor utilise l'API Pluggable Annotation AbstractProcessor, définie dans les packages javax.annotation.processing et javax.lang.model.
Cette classe hérite de l'interface javax.annotation.processing.AbstractProcessor et impose l'implémentation de la méthode process qui va être appelée à chaque fois que l'annotation va être lue.
Trois annotations peuvent être renseignées sur la classe processor :

- javax.annotation.processing.SupportedAnnotationTypes qui permet d'indiquer les annotations à partir desquelles le processor va être déclenché (ici l'annotation @Entity de javax.persistence)
- javax.annotation.processing.SupportedSourceVersion qui indique la version de Java des fichiers sources supportée (ici la version 7)
- javax.annotation.processing.SupportedOptions qui permet d'ajouter des options qui peuvent être passées en ligne de commande.

```java

package fr.treeptik.winterburn.processor;
...
@SupportedAnnotationTypes("javax.persistence.Entity")
@SupportedSourceVersion(SourceVersion.RELEASE_7)
public class WinterBurnProcessor extends AbstractProcessor {

```
La méthode process(), qui va être appelée à chaque fois que l'annotation est repérée par le processor dans la projet, prend en paramètre un Set d'éléments (classes, méthodes, champs ou données membres) annotés ainsi qu'un objet RoundEnvironment qui contient ces mêmes éléments annotés et permet à la méthode process() de les récupérer et de les utiliser. De plus, l'instance de l'objet ProcessingEnv donne l'accès à deux méthodes fondamentales du processor, à savoir getFiler et getMessager, la première permettant d'exploiter les ressources (lire, créer, supprimer des fichiers du contexte),la seconde permettant d'établir un log via des objets Diagnostic et est particulièrement précieuse pour debugger le processor au moment de la compilation dans le client :

```java

@Override
	public boolean process(Set<? extends TypeElement> annotations,
			RoundEnvironment roundEnv) {

```

Dans cette même méthode, on commence par définir toutes les variables qui vont être lues du context (fichier de paramétrage du processor dans le client, notamment le nom des packages),
et celles qui seront extraites par le processor des classes annotées (nom de la classe, données membres...) :
On initialise également une Map qui va nous permettre d'injecter ces variables dans les templates et une seconde map qui prendra en charge les données membres.

```java
// Initialization of the different variables
		String className = null;
		String completedName = null;
		String packageName = null;
		String packageToScan = null;
		String packageService = null;
		String packageDAO = null;
		String persistenceAPI = null;
		String packageController = null;
		Map<String, String> mappy = new HashMap<>();
		Map<String, String> fieldsMap = new HashMap<>();
```
Pour pouvoir fonctionner, le processor doit capter toutes les classes annotées par @Entity. Il faut, pour cela, utiliser une boucle for qui va prendre en charge tous les éléments du roundEnv
qui sont annotés, puis une simple condition pour spécifier que seules les classes annotées seront traitées :

```java
for (Element e : roundEnv.getElementsAnnotatedWith(Entity.class)) {
			if (e.getKind() == ElementKind.CLASS) {
```
On récupère ensuite toutes les propriétés de notre classe (nom, données membres...), grâce à des méthodes fournies par la classe TypeElement par qui on peut désormais caster l'élément pris en charge par le processor :

```java
// Environment loading
				fieldsMap = new HashMap<>();
				TypeElement classElement = (TypeElement) e;
				className = classElement.getSimpleName().toString();
				List<? extends Element> enclosedElements = classElement
						.getEnclosedElements();
				completedName = classElement.getQualifiedName().toString();
```

Il est ensuite nécessaire de récupérer les paramètres fournis dans un fichier de configuration (.properties) dans le projet client, à l'aide de la méthode getFiler(). L'objet Filer retourné, possède une méthode getResource() nous permettant d'aller rechercher une ressource à divers endroits du projet client ou du projet courant (le processor). Pour récupérer un fichier situé dans le client, il faut impérativement définir dans le plugin de lecture du processor la racine "SOURCE_OUTPUT" comme étant la racine du projet, et ensuite indiquer en paramètre de la méthode getResource(), la localisation du fichier (StandardLocation.SOURCE_OUTPUT), le package (absent ici) et le chemin du fichier à partir de la racine du projet. La démarche est la même pour la lecture ou la suppression de tous les autres fichiers du client. Pour la génération des fichiers, ce sont d'autres méthodes du Filer qui seront sollicitées :

```java

	// Properties loading
				Properties p = new Properties();
				FileObject source = null;
				try {
					source = processingEnv.getFiler().getResource(
							StandardLocation.SOURCE_OUTPUT, "",
							"src/main/resources/winterburnContext.properties");
					p.load(source.openInputStream());
					processingEnv.getMessager().printMessage(
							Diagnostic.Kind.NOTE, source.toUri().toString());
				} catch (IOException e1) {
				}
				packageName = p.getProperty("packageName");
				packageToScan = p.getProperty("packageToScan");
				packageService = p.getProperty("packageService");
				packageDAO = p.getProperty("packageInterfaceDAO");
				packageController = p.getProperty("packageController");
				persistenceAPI = p.getProperty("persistenceAPI");
				
```	
			
L'ensemble des propriétés chargées sont ensuite insérées dans la map qui sera passée en paramètre des méthodes de génération de fichiers.

```java
				mappy.put("packageName", packageName);
				mappy.put("className", className);
				mappy.put("packageToScan", packageToScan);
				mappy.put("packageService", packageService);
				mappy.put("packageController", packageController);
				mappy.put("packageDAO", packageDAO);
				mappy.put("persistenceAPI", persistenceAPI);
```
On appelle ensuite les méthodes de génération de fichiers et de pages : une méthode par fichier JAVA (DAO, implémentation du DAO, service, controller) et une méthode pour la page xHTML.

```java
// Classes generation from the entity element located in the package to scan
					generateTemplate(mappy, "daoTemplate.ftl", packageName
							+ "." + packageDAO, "DAO", fieldsMap);
					generateTemplate(mappy, "serviceTemplate.ftl", packageName
							+ "." + packageService, "Service", fieldsMap);
					generateTemplate(mappy, "daoImplTemplate.ftl", packageName
							+ "." + persistenceAPI + "." + packageDAO,
							persistenceAPI.toUpperCase() + "DAO", fieldsMap);
					generateTemplate(mappy, "controllerjsf.ftl", packageName
							+ "." + packageController, "Controller", fieldsMap);
					this.generatePages("jsf2.ftl", className, fieldsMap, e);				
```

Nous allons présenter une de ces méthodes de génération, celle d'un fichier JAVA. Elle s'appuie sur la méthode createSourceFile() de l'objet Filer que nous avons pu voir plus haut et l'API de génération FreeMarker (moteur de template) qui va injecter les données présentes dans la map renseignée avec toutes les propriétés de notre classe annotée, dans un template prédéfini.
Voici un exemple de template (DAO.ftl) utilisé par le processor : 

```freemarker
package ${packageName}.${packageDAO};
import ${packageToScan}.${className};
import java.util.List;
import fr.treeptik.exception.DAOException;
public interface ${className}DAO {
	${className} save (${className} ${classNameLowerCase}) throws DAOException;
	void delete (${className} ${classNameLowerCase}) throws DAOException;
	List<${className}> findAll() throws DAOException;
}
```
Les variables className, packageName... sont renseignées dans la map passée en paramètre de la méthode (mappy). Les keys doivent avoir impérativement le même nom que les variables du template pour que les valeurs soient correctement injectées.
Voyons d'un peu plus près la méthode generateTemplate(). Celle-ci prend en paramètres la map de variable à injecter, le fichier template .ftl, le nom du package où le fichier sera créé, le suffixe du fichier (ici DAO) et une map contenant les données membres (utile surtout pour la génération des pages d'exemple xHTML).
Dans un premier temps, il faut renseigner la configuration pour que Freemarker puisse aller récupérer le template et créer en mémoire le fichier qui devra être généré :

```java
private boolean generateTemplate(Map<String, String> mappy,
			String nameTemplate, String namePackage,
			String suffixeNameClassGenerated, Map<String, String> fields) {

		Configuration cfg = new Configuration();

		cfg.setClassForTemplateLoading(this.getClass(),
				"/fr/treeptik/winterburn/template/");

		Template template = null;
		try {
			template = cfg.getTemplate(nameTemplate);
		} catch (IOException e) {
			e.printStackTrace();
		}
```

Une étape très importante et sur laquelle le processor se doit d'être infaillible est la vérification de l'existence du fichier avant même qu'il ne soit généré. Cela évite ainsi la suppression des modifications ultérieures apportées par le développeur. Pour cela, on crée une URL avec l'objet Filer à l'endroit où est supposé être le fichier dans le projet client, puis on crée un fichier (on prendra soin d'échapper les espaces dans les noms de dossier pour s'assurer d'avoir un chemin correct) puis on vérifie l'existence du fichier. Si celui-ci est présent, on retourne false et on sort de la méthode sans avoir généré de nouveaux fichiers.

```java
			URL url = processingEnv
					.getFiler()
					.getResource(
							StandardLocation.SOURCE_OUTPUT,
							"",
							pathDirectory.replace(".", "/")
									+ namePackage.replace(".", "/") + ("/")
									+ className + suffixeNameClassGenerated
									+ ".java").toUri().toURL();
			File file = new File(url.getPath().replace("%20", " "));
			if (file.exists()) {
				return false;
			}
```

On crée ensuite un JavaFileObject avec la méthode createSourceFile() de l'objet Filer auquel on indique en paramètres le chemin à partir de la racine du projet et le nom du fichier sans l'extension.
De là, on peut définir un writer qui va être passé en paramètre de la méthode process() du template. Le second paramètre de cette méthode est la map (input) qui contient nos variables à injecter dans le template.
Ne pas oublier de fermer le writer avec la méthode close().

```java
jfo = processingEnv.getFiler().createSourceFile(
					pathDirectory + namePackage + (".") + className
							+ suffixeNameClassGenerated);
		} catch (IOException e) {
			e.printStackTrace();
		}
		Writer writer = null;
		try {
			writer = jfo.openWriter();
		} catch (IOException e) {
			e.printStackTrace();
		}
		try {
			template.process(input, writer);
		} catch (TemplateException | IOException e) {
			e.printStackTrace();
		}
		try {
			writer.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
```

Pour générer les pages xhtml ou tout autre fichier (non java), il faudra non plus la méthode createSourceFile() mais la méthode createResource() dont les paramètres sont un peu différents (extension à indiquer, récupération de l'objet Element de la méthode process() du processor...).

### Côté Client :

Une documentation expliquant la mise en place du processor côté client est fournie avec le projet client d'exemple. De plus, une vidéo de démonstration (ci-dessous) montre les substilités de la configuration des plugins dans le .pom du projet client.

[![IMAGE ALT TEXT HERE](http://img.youtube.com/vi/YOUTUBE_VIDEO_ID_HERE/0.jpg)](http://www.youtube.com/watch?v=3mMtUV_WIP8)