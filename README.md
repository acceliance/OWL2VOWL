OWL2VOWL converter
==================

[![Docker CI](https://github.com/acceliance/OWL2VOWL/actions/workflows/docker-ci.yml/badge.svg)](https://github.com/acceliance/OWL2VOWL/actions/workflows/docker-ci.yml)
[![Docker Release](https://github.com/acceliance/OWL2VOWL/actions/workflows/docker-release.yml/badge.svg)](https://github.com/acceliance/OWL2VOWL/actions/workflows/docker-release.yml)
[![Version](https://img.shields.io/badge/version-0.3.7-blue)](pom.xml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE.txt)
[![Java](https://img.shields.io/badge/java-8%2B-orange)](https://adoptium.net/)
[![Maven Central](https://img.shields.io/maven-central/v/org.visualdataweb.vowl.owl2vowl/OWL2VOWL?label=maven%20central)](https://mvnrepository.com/artifact/org.visualdataweb.vowl.owl2vowl/OWL2VOWL)
[![JitPack](https://jitpack.io/v/VisualDataWeb/OWL2VOWL.svg)](https://jitpack.io/#VisualDataWeb/OWL2VOWL)
[![Fork of](https://img.shields.io/badge/fork%20of-VisualDataWeb%2FOWL2VOWL-lightgrey)](https://github.com/VisualDataWeb/OWL2VOWL)
[![Maintained by Acceliance](https://img.shields.io/badge/maintained%20by-Acceliance-0072C6)](https://github.com/acceliance)

This is the [Acceliance](https://www.acceliance.fr/) fork of OWL2VOWL, the converter behind
[WebVOWL](https://github.com/acceliance/WebVOWL). See [Acceliance contributions](#acceliance-contributions)
for what differs from upstream. The Maven Central and JitPack badges above refer to the **upstream** artifact —
this fork is not published to either.

Dev Dependency
--------------
We have a release repo in maven central but the version there is and will not be updated frequently.
Therefore i suggest to use [Jitpack OWL2VOWL](https://jitpack.io/#VisualDataWeb/OWL2VOWL) in order to pull the latest release version (in example master branch or the available tags).

For instructions how to include the dependency click the above link or as a example for maven projects:

```
	<repositories>
		<repository>
		    <id>jitpack.io</id>
		    <url>https://jitpack.io</url>
		</repository>
	</repositories>
       ....
       <dependency>
	    <groupId>com.github.VisualDataWeb</groupId>
	    <artifactId>OWL2VOWL</artifactId>
	    <version>master-SNAPSHOT</version>
	</dependency>
       
```


Requirements
------------
*   Java 8 (or higher)
*   Maven


Instructions for using OWL2VOWL JAR
------------

The converted ontology will be written in a .json file in the working directory by default.

### Convert an ontology by its IRI
Run owl2vowl.jar with the `-iri` parameter: `java -jar owl2vowl.jar -iri "[Ontology IRI]"`

**Example**: `java -jar owl2vowl.jar -iri "http://ontovibe.visualdataweb.org"`


### Convert an ontology from a local file
Run owl2vowl.jar with the `-file` parameter: `java -jar owl2vowl.jar -file path/to/local/ontology`

**Example**: `java -jar owl2vowl.jar -file ontologies/foaf.rdf`


### Convert an ontology with dependencies from a local file
Run owl2vowl with the additional `-dependencies` parameter: `java -jar owl2vowl.jar -file path/to/local/ontology -dependencies path/to/dependency1 path/to/dependency2 ...`

**Example**: `java -jar owl2vowl.jar -file ontovibe.ttl -dependencies ontovibe_imported.ttl`


### Echo the converted ontology on the console
Use any of the input parameters together with the `-echo` flag: `java -jar owl2vowl.jar -echo -iri "[Ontology IRI]"`

**Example**: `java -jar owl2vowl.jar -iri "http://ontovibe.visualdataweb.org" -echo`

Instructions for developing with OWL2VOWL
-----------

### First steps
`Maven` is required to develop with OWL2VOWL and compile the code. It will load all dependencies automatically. If there occur any problems, refreshing the dependencies might solve them.
OWL2VOWL has been developed to work with Java 8, so `JDK 8` has to be used for compiling.

### Build the jar
To build the jar file, simply execute `mvn package`. The built `jar` only contains the compiled source code. 
To build a jar file that can be executed standalone, you have to use the package option with parameter: `mvn package -Denv=standalone` or `mvn package -P standalone-release`. This will build the file `...-shaded.jar` containing all dependencies needed to be executable.

### Build the war
To build the war file, simply execute `mvn package -P war-release`. This will generate a war file.
This war can be execute like a jar file to start a local server.

### Running in IDE
It would be a pain always building the jar only to test some new implemented stuff. We included a possiblity to run the conversion directly with the IDE. For this you need to change the `ConverterImpl.java` class.

To run a Spring Server directly from the IDE you have to start the `ServerMain.java` class.

### Docker

- **With WebVOWL (recommended):** clone both repos as siblings; build and run from the WebVOWL directory — see `WebVOWL/docker/README.md`.
- **Standalone converter:** see [doc/docker/README.md](doc/docker/README.md) (`docker build -t owl2vowl:local .`).


Acceliance contributions
------------------------

[Acceliance](https://www.acceliance.fr/) maintains this fork and contributes the following changes on top of
upstream `VisualDataWeb/OWL2VOWL` (commit `e6cde17`, *ui improvements*). They are the converter-side counterpart
of the sidebar and annotation work in the [WebVOWL fork](https://github.com/acceliance/WebVOWL) — the frontend
reads the extra JSON fields produced here.

### Object property assertions are exported

`AbstractConverter` gains `processObjectPropertyAssertions()`, which walks every `OBJECT_PROPERTY_ASSERTION`
axiom of the ontology and its imports and attaches the subject/object pair to the corresponding property
(anonymous properties and individuals are skipped). Assertions are stored on `AbstractProperty` through
`addIndividualAssertion()` / `getIndividualAssertions()` and released in `releaseMemory()`.

The JSON export then emits two new per-property attributes in `JsonGeneratorVisitorImpl`:

*   `instances` — the number of asserted individual pairs for the property
*   `individuals` — the pairs themselves, as `{"subject": "<IRI>", "object": "<IRI>"}` entries

Both are emitted for plain and for referenced/merged properties. WebVOWL renders the count under the property
label in the graph and lists the assertions in the sidebar.

### Annotations are keyed by full IRI

`Annotation` now retains the full annotation-property IRI (`getFullIri()`, with surrounding angle brackets
stripped) alongside the short identifier, and `Annotations` maps by that full IRI instead of the short form.
Previously two annotation properties from different namespaces that shared a local name — for example
`dc:description` and `dcterms:description` — collapsed into a single bucket and lost values. Keying by IRI keeps
them distinct, which is what lets the WebVOWL sidebar list every annotation separately.


FAQ
==================

## I want to log information, errors, etc to files. Is there a default configuration?
If you want to use logging to files there is log4j2 configuration provided under ```src/main/resources/log4j2-spring-file.xml```.

- JAR/IDE: To load it you have to provide a JVM argument. For example if you have the JAR you have to exeecute:
       ```java -Dlog4j.configurationFile=path/to/log4j2-spring-file.xml -jar ...```
- WAR: Uncomment the line in ```src/main/resources/application.properties```        
  
