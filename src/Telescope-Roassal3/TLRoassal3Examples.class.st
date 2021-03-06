"
I have examples
"
Class {
	#name : #TLRoassal3Examples,
	#superclass : #Object,
	#instVars : [
		'greenExamples'
	],
	#category : #'Telescope-Roassal3-Examples'
}

{ #category : #private }
TLRoassal3Examples >> buildLegendOn: canvas [
	| lb theme |
	theme := Smalltalk ui theme.
	lb := RSLegend new.
	lb layout horizontal
		gapSize: 20.
	lb container: canvas.
	lb defaultLabel color: theme textColor.
	lb defaultBox withBorder.
	#(
	'Error running' red
	'Running' white
	'Similar to Telescope' green
	) pairsDo: [ :text :col | 
		lb text: text withBoxColor: (Color colorFrom: col) translucent ].
	lb location 
		offset: 0@20.
	lb build.
]

{ #category : #public }
TLRoassal3Examples >> createBoxFor: method [ 
	| com theme |
	com := RSComposite new.
	theme := Smalltalk ui theme.
	com add: (RSLabel new
		color: theme textColor;
		text: (method selector copyFrom: 'example' size+1 to: method selector size)).
	com 
		model: method;
		withBorder;
		adjustToChildren;
		popupText: 'click me!';
		padding: 10;
		when: RSMouseClick send: #openExample: to: self;
		when: RSMouseDoubleClick do: [:evt | evt shape model browse].
	
	^ com 
]

{ #category : #private }
TLRoassal3Examples >> createProgressShapeOn: canvas [
	| rect w red total b1 b2 percent |
	rect := canvas encompassingRectangle.
	w := rect width * 0.8.
	red := Color red translucent.
	total := canvas nodes 
		inject: 0 
		into: [ :s :n | s + (n color = red
			ifTrue: [ 0 ]
			ifFalse: [ 1 ]) ].
	percent := total / canvas nodes size.
	b1 := RSBox new
		height: 10;
		width: w;
		withBorder;
		popupText: (percent * 100) asInteger asString, 
			'% Telescope examples running without errors', String crlf,
			total asString,'/',canvas nodes size asString ,' examples', String crlf,
			greenExamples size asString ,'/', canvas nodes size asString, ' green examples';
		cornerRadius: 5;
		noPaint;
		yourself.
	
	b2 := RSBox new
		height: 10;
		cornerRadius: 5;
		width: percent * w;
		yourself.
	RSLocation new
		above;
		offset: 0@ -30;
		move: b1 on: rect;
		offset: 0@0;
		inner;
		left;
		move: b2 on: b1.
	canvas add: b2; add: b1.
	
]

{ #category : #public }
TLRoassal3Examples >> exampleAll [
	<script: 'self new exampleAll open setLabel: ''Telescope Examples''; extent: 800@500'>
	| canvas examples no theme |
	canvas := RSCanvas new.
	theme := Smalltalk ui theme.
	canvas color: theme backgroundColor.
	no := 
		{TLDemos class >> #exampleCompositeNodeWithLabelInsideInButterfly.
		TLDemos class >> #exampleTreeExplorerCollectionHierarchy.
		TLDemos class >> #exampleTwoConnectedVisualization}.
	examples := TLDemos class methods
		select: [ :met | met selector beginsWith: 'example' ].
	
	examples := examples reject: [ :met | no includes: met ].
	examples := examples sorted: CompiledMethod sortBlock.
	examples :=  examples collect: [:met | self createBoxFor: met].
	examples 
		do: [ :ex | self testExample: ex ]
		displayingProgress: [ :ex | 'Processing ', ex model selector ].
	canvas addAll: examples.
	RSCellLayout new
		lineItemsCount: 3;
		gapSize: 10;
		on: canvas nodes.
	self createProgressShapeOn: canvas.
	self buildLegendOn: canvas.
	^ canvas @ RSCanvasController
]

{ #category : #initialization }
TLRoassal3Examples >> initialize [
	super initialize.
	greenExamples := 
	#(exampleAdaptNodeWidthFromLabel
	exampleAllShapes
	exampleBackgroundImages
	exampleButterflyUsingStyleFunctionnality
	exampleChangingLayout
	exampleCompositeExploringHierarchy
	exampleConnectAction
	exampleConnectionStyle
	exampleConnectionsCustomization
	exampleCustomMultiChoiceAction
	exampleCycleDependencies
	exampleDistributionMap
	exampleDistributionMapAbstractMethodsCollection
	exampleExpandCollapseNodesAction
	exampleFLowControl
	exampleGradient
	exampleHideAndShowConnections
	exampleHideAndShowNode
	exampleHighlightElements
	exampleLabelWrap
	exampleLayoutsAngle
	exampleLegend
	exampleLineStyle
	exampleMovingNodeChangeEntity
	exampleMovingNodeToAnotherGroup
	exampleMovingNodeToFirstPosition
	exampleNameCloud
	exampleNodeLabelPosition
	examplePackageHierarchy
	examplePopUp
	exampleSortingChildren
	exampleSystemComplexityMultipleRoots
	examplePathBuilder
	exampleProjectMap
	exampleSystemComplexity
	exampleSystemComplexityInContainer
	exampleVisualizationWithCompositeChildrenConnectionsShowing
	"no"
	exampleRecursiveCompositeNode
	).
]

{ #category : #public }
TLRoassal3Examples >> openExample: evt [
	| shape vis met |
	shape := evt shape.
	met := shape model.
	[ vis := met selector value: TLDemos.
	vis open ]
	on: Error
	do: [ :ex | met browse ].
]

{ #category : #private }
TLRoassal3Examples >> testExample: evt [
	| shape res sel |
	shape := evt shape.
	res := nil.
	sel := shape model selector.
	[ res := sel value: TLDemos.
	res open.
	res generator close.
	shape color: ((greenExamples includes: sel)
		ifTrue: [Color green translucent]
		ifFalse: [Color white] )]
	on: Error
	do: [ :ex | shape color: Color red translucent ].
	^ res
]
