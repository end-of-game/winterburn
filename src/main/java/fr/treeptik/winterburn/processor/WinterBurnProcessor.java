package fr.treeptik.winterburn.processor;

import java.io.File;
import java.io.IOException;
import java.io.Writer;
import java.net.URL;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import javax.annotation.processing.AbstractProcessor;
import javax.annotation.processing.RoundEnvironment;
import javax.annotation.processing.SupportedAnnotationTypes;
import javax.annotation.processing.SupportedSourceVersion;
import javax.lang.model.SourceVersion;
import javax.lang.model.element.Element;
import javax.lang.model.element.ElementKind;
import javax.lang.model.element.TypeElement;
import javax.persistence.Entity;
import javax.tools.Diagnostic;
import javax.tools.FileObject;
import javax.tools.JavaFileObject;
import javax.tools.StandardLocation;

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;

@SupportedAnnotationTypes("javax.persistence.Entity")
@SupportedSourceVersion(SourceVersion.RELEASE_7)
public class WinterBurnProcessor extends AbstractProcessor {

	@Override
	public boolean process(Set<? extends TypeElement> annotations,
			RoundEnvironment roundEnv) {

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

		for (Element e : roundEnv.getElementsAnnotatedWith(Entity.class)) {
			if (e.getKind() == ElementKind.CLASS) {

				// Environment loading
				fieldsMap = new HashMap<>();
				TypeElement classElement = (TypeElement) e;
				className = classElement.getSimpleName().toString();
				List<? extends Element> enclosedElements = classElement
						.getEnclosedElements();

				completedName = classElement.getQualifiedName().toString();

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

				// Putting properties in a map for the template generation

				mappy.put("packageName", packageName);
				mappy.put("className", className);
				mappy.put("packageToScan", packageToScan);
				mappy.put("packageService", packageService);
				mappy.put("packageController", packageController);
				mappy.put("packageDAO", packageDAO);
				mappy.put("persistenceAPI", persistenceAPI);

				if (enclosedElements.size() != 0) {
					for (Element field : enclosedElements) {
						if (field.getKind() == ElementKind.FIELD) {
							if (field.asType().toString()
									.equalsIgnoreCase("java.lang.String")) {
								fieldsMap.put(field.getSimpleName().toString(),
										field.getSimpleName().toString());
							}
						}
					}
				}
				processingEnv.getMessager().printMessage(Diagnostic.Kind.NOTE,
						fieldsMap.keySet().toString(), e);
				if (className != null
						&& completedName
								.substring(
										0,
										(completedName.length() - (className
												.length() + 1)))
								.equalsIgnoreCase(packageToScan)) {

					// Classes generation from the entity element located in the
					// package
					// to scan

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

				}

			}
		}

		return true;
	}

	//
	// Generation method for JAVA Templates
	//

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

		Map<String, Object> input = new HashMap<String, Object>();
		input.putAll(mappy);
		String className = mappy.get("className");
		input.put("classNameLowerCase", className.toLowerCase());

		//
		// TODO rendre parametrable ?
		//

		String pathDirectory = "src.main.java.";

		JavaFileObject jfo = null;

		try {

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

		return true;
	}

	//
	// Generation method for pages template
	//

	private boolean generatePages(String nameTemplate, String fileName,
			Map<String, String> fields, Element element) {

		Configuration cfg = new Configuration();

		cfg.setClassForTemplateLoading(this.getClass(),
				"/fr/treeptik/winterburn/template/");

		Template template = null;

		try {
			template = cfg.getTemplate(nameTemplate);

		} catch (IOException e) {

			e.printStackTrace();

		}

		Map<String, Object> input = new HashMap<String, Object>();

		input.put("className", fileName);
		input.put("classNameToLowerCase", fileName.toLowerCase());

		if (fields.containsKey("id")) {
			fields.remove("id");
		}
		if (fields.containsKey("serialVersionUID")) {
			fields.remove("serialVersionUID");
		}
		input.put("fields", fields);

		//
		// TODO rendre parametrable ?
		//

		String pathDirectory = "src.main.webapp.pages";

		FileObject jfo = null;

		try {

			URL url = processingEnv
					.getFiler()
					.getResource(
							StandardLocation.SOURCE_OUTPUT,
							"",
							pathDirectory.replace(".", "/") + "/"
									+ fileName.toLowerCase() + ".xhtml")
					.toUri().toURL();

			File file = new File(url.getPath().replace("%20", " "));

			if (file.exists()) {

				return false;

			}

			jfo = processingEnv.getFiler().createResource(
					StandardLocation.SOURCE_OUTPUT,
					"",
					pathDirectory.replace(".", "/") + "/"
							+ fileName.toLowerCase() + ".xhtml", element);

		} catch (Exception e) {

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
		generateMainPage("main.ftl", element);
		return true;
	}

	private boolean generateMainPage(String nameTemplate, Element element) {
		Configuration cfg = new Configuration();
		cfg.setClassForTemplateLoading(this.getClass(),
				"/fr/treeptik/winterburn/template/");
		Template template = null;
		try {
			template = cfg.getTemplate(nameTemplate);
			Map<String, Object> input = new HashMap<String, Object>();

			Map<String, String> mappy = new HashMap<String, String>();
			URL url = processingEnv
					.getFiler()
					.getResource(StandardLocation.SOURCE_OUTPUT, "",
							"src/main/webapp/template/main.xhtml").toUri()
					.toURL();
			processingEnv.getMessager().printMessage(
					Diagnostic.Kind.NOTE,
					url.getPath().substring(0, url.getPath().length() - 19)
							.replace("%20", " ")
							+ "pages", element);
			File file = new File(url.getPath()
					.substring(0, url.getPath().length() - 19)
					.replace("%20", " ")
					+ "pages");
			String[] tabs = file.list();
			for (String string : tabs) {
				mappy.put(string.substring(0, string.length() - 6),
						string.substring(0, string.length() - 6));
			}
			input.put("entities", mappy);
			FileObject jfo = null;
			Writer writer = null;
			jfo = processingEnv.getFiler().createResource(
					StandardLocation.SOURCE_OUTPUT, "",
					"src/main/webapp/template/main.xhtml", element);
			writer = jfo.openWriter();
			template.process(input, writer);
			writer.close();

		} catch (IOException | TemplateException e) {

			e.printStackTrace();
		}

		return true;
	}

}
