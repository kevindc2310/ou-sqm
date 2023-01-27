# OU Rascal Lab Assignment - Measuring source code maintainability
This is the lab assignment Rascal project made by Martin Vlaar and Kevin De Coster for the Software Quality Management course of Open Universiteit of the Netherlands.

## Getting started
### Calculating metrics
* Open the project in Eclipse IDE, along with a Java-project on which you want to perform the analysis
* Define the name and the location of the Java project in LabAssignment.rsc (line 29). An example is:
```
tuple[str name, loc location] Project = <"SmallSQL",|project://smallsql|>;
```
* Open a Rascal shell in the project and import the LabAssignment file 
```
import LabAssignment.rsc;
```
* Run the function runAnalysis() and wait for the output to appear in the shell
```
runAnalysis();
```

### Visualization
#### Unit size and unit complexity stacked bars
The visualizations of these metrics will automatically calculated when running the analysis. They should automatically display in Eclipse.
![image](https://user-images.githubusercontent.com/25271716/213926222-5cda0ac5-787a-48cf-a597-05f4e6dae1bd.png)

#### Unit size and complexity scatter chart
This chart displays the relations between unit sizes and their complexity. The data for this chart is generated while running the analysis. You can find it under src/output/complexitysizes.json. In order to display the graph, enter the following lines of code in the Rascal shell:
```
  import visual::UnitSizeComplexityRelation;
  import lang::json::IO;
  list[Point] complexityGraphData = readJSON(#list[Point], |project://MyRascal/src/output/complexitysizes.json|);
  makeVisualisation(complexityGraphData);
```
The graph is also interactive:
* It can toggle the threshold values of the unit size and complexity metrics as colored zones.
* It is zoomable through the use of a mousewheel
* Hovering over a dot will show the location and the name of the unit

![image](https://user-images.githubusercontent.com/25271716/213926379-6b1f7cd7-2193-4786-b55a-be9f452e3079.png)

#### Class dependency hierarchical edge bundles
A diagram that displays the dependencies of classes in both 'used' and 'used by' ways. To display, the data first needs to be calculated:
```
  import visual::ClassDependencies;
  import lang::json::IO;
  generateClassDependencies(|project://MyRascal/src/output/complexitysizes.json|);
```
Next, you can visualize it using the following code:
```
  list[Dependency] dependencyGraphData = readJSON(#list[Dependency], |project://MyRascal/src/output/dependencies.json|);
  makeDependencyVisualisation(dependencyGraphData);
```
![image](https://user-images.githubusercontent.com/25271716/213926322-3de033d3-fec5-4155-afa4-2bc37147ea26.png)
