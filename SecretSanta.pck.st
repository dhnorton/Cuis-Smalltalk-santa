'From Cuis 4.2 of 25 July 2013 [latest update: #2563] on 30 October 2015 at 6:42:50.934065 pm'!
'Description A program to draw names before Christmas. Names are listed in a text file:

name1				"Single"
name2 & name3	"Couples"

See class comment for rules.'!
!provides: 'SecretSanta' 1 3!
!classDefinition: #SecretSanta category: #'SecretSanta-Model'!
Object subclass: #SecretSanta
	instanceVariableNames: 'path pastYears singles spouses names counts runTime'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SecretSanta-Model'!
!classDefinition: 'SecretSanta class' category: #'SecretSanta-Model'!
SecretSanta class
	instanceVariableNames: ''!


!SecretSanta commentStamp: 'dhn 3/8/2015 16:17' prior: 0!
This class performs an annual drawing of names, ensuring that certain rules are followed.
A family may decide to draw names at Christmas so that each person can receive one especially nice gift instead of many lesser ones. The tedium of obtaining a good drawing by "pulling names from a hat" inspired this program.

Get started by making a file of names. The name of each single person appears on a separate line. Spouses are entered on a separate line as Spouse1 & Spouse2. You will be asked for the file name when the program runs.

Rules for the Secret Santa name drawing:

Can not draw yourself
Can not draw your spouse (you will give him or her a gift regardless)
Can not have reciprocals (A draws B and B draws A)
Can not be a repeat of the last 3 years

Names can be drawn even if there is no history for "the last 3 years".
History is built by using the output to create a class method for the current year.!

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 20:13'!
display: anObject
	"Show the results of the name drawing in a window"
	| window |
	window _ Workspace new 
		contents: anObject;
		openLabel: 'Santa Drawing'! !

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 20:31'!
drawNames
	"Match each name in a list with another while following rules"
	| currentDraw result iter out |
	result _ false.
	iter _ 0.
	runTime _ Time
				millisecondsToRun: [
					[result]	whileFalse: [
						1000000 < (iter _ iter + 1) ifTrue: [
							(PopUpMenu labelArray: #(
								'More names are needed in order to have a successful drawing.' 'OK')) 
								startUpWithCaption: iter printStringWithCommas, ' Attempts'.
								result _ true].
						currentDraw _ names shuffled.
							(self notYou: currentDraw)
								ifTrue: [(self notSpouse: currentDraw)
										ifTrue: [(self notReciprocal: currentDraw)
												ifTrue: [(self notPastYears: currentDraw)
														ifTrue: [result _ true]]
												ifFalse: [self tally: 3]]
										ifFalse: [self tally: 2]]
								ifFalse: [self tally: 1]]].
	self display: (out _ self report: names drew: currentDraw), self stats.
	self saveResults: out.
! !

!SecretSanta methodsFor: 'file I/O' stamp: 'dhn 10/28/2015 15:47'!
getLines
	"Answer the lines obtained from a file"
	| fileName wholeFile lines str |
	lines _ OrderedCollection new.
	fileName _ FillInTheBlankMorph 
		request: 'File Containing Names?' 
		initialAnswer: 'c:\dir\file.ext' 
		centerAt: Display center
		onCancelReturn: ''
		acceptOnCR: true
		answerExtent: FillInTheBlankMorph defaultAnswerExtent.
	fileName notEmpty ifTrue: [
			wholeFile _ ReadStream on: fileName asFileEntry fileContents.
			[(str _ wholeFile nextLine) notNil]
				whileTrue: [	str size > 0 
					ifTrue: [lines add: (str upTo: Character cr) withoutTrailingBlanks]]]. 
	^lines asArray! !

!SecretSanta methodsFor: 'file I/O' stamp: 'dhn 10/28/2015 22:11'!
getLinesFrom: fileName
	"Answer the lines obtained from a file named fileName"
	| wholeFile lines str |
	
	lines _ OrderedCollection new.
	wholeFile _ ReadStream on: fileName asFileEntry fileContents.
	[(str _ wholeFile nextLine) notNil]
		whileTrue: [
			str size > 0 
				ifTrue: [lines add: (str upTo: Character cr) withoutTrailingBlanks]]. 
	^ lines! !

!SecretSanta methodsFor: 'initialization' stamp: 'dhn 10/30/2015 14:58'!
initialize
	| yr |
	super initialize.
	
	path _ (FillInTheBlankMorph
		request: 'Directory?'
		initialAnswer: 'c:\dir\etc\'
		centerAt: Display center
		onCancelReturn: ''
		acceptOnCR: true
		answerExtent: FillInTheBlankMorph defaultAnswerExtent).

	self parseNames: (self getLinesFrom: path, self class in, '.txt').
	names _ self namesList.
	counts _ {0. 0. 0. 0. 0. 0.}.
	names ifNotEmpty: [
		yr _ (FillInTheBlankMorph
					request: 'Up to 3 years beginning with...'
					initialAnswer: 'yyyy'
					centerAt: Display center
					onCancelReturn: ''
					acceptOnCR: true
					answerExtent: FillInTheBlankMorph defaultAnswerExtent) asNumber.
		pastYears _ self yearsFrom: yr  to: yr +2.
		self drawNames]
			ifEmpty: [PopUpMenu inform: 'There can be no drawing
without a list of names.'].
! !

!SecretSanta methodsFor: 'initialization' stamp: 'dhn 3/8/2015 16:08'!
namesList
	"Answer the names of participants, ensuring no duplication"
	^ (Set new
		addAll: singles ;
		addAll: spouses asSet;
		yourself) asOrderedCollection
! !

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 10/29/2015 18:40'!
notPastYears: aCollection
	"Answer true if for each name, the corresponding name in aCollection is not the same as in as many as 3 prior years; otherwise, answer false"
	| dx |
	1 to: pastYears size do: [:iy | 
		(dx _ pastYears at: iy)
			ifNotNil: [
				1 to: names size do: [:ix | 
					(dx at: (names at: ix ifAbsent: []) ifAbsent: []) = (aCollection at: ix)
						ifTrue: [self tally: 3 + iy.
							^ false]]]].
	^ true! !

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 16:09'!
notReciprocal: aCollection
	"Answer true if none of aCollection result in reciprocal matches; otherwise,
	answer false"
	| drawn1 drawn2 iy |
	1 to: names size do: [:ix | 
		drawn1 _ aCollection at: ix.
		iy _ names indexOf: drawn1.
		drawn2 _ aCollection at: iy.
		(names at: ix) = drawn2
			ifTrue: [^ false]].
	^ true! !

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 16:09'!
notSpouse: aCollection 
	"Answer true if no names in aCollection match a spouse; otherwise,
	answer false"
	| drawn other |
	1 to: names size do: [:ix | 
		drawn _ aCollection at: ix.
		other _ spouses at: drawn ifAbsent: ['no one'].
		(names at: ix) = other ifTrue: [^ false]].
	^ true! !

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 16:09'!
notYou: aCollection 
	"Answer true if for each name, the corresponding name in aCollection is not the same; otherwise, answer false"
	1 to: names size do: [:ix | 
		(names at: ix) ~= (aCollection at: ix)
			ifFalse: [^ false]].
	^ true! !

!SecretSanta methodsFor: 'initialization' stamp: 'dhn 10/29/2015 12:56'!
parseLine: aString
	"Answer an association of Santa -> recipient parsed from aString"
	| ix santa kid |
	
	ix _ aString indexOf: $>.
	santa _ (aString copyFrom: 1 to: ix - 1) withBlanksTrimmed asLowercase capitalized.
	kid _ (aString copyFrom: ix + 6 to: aString size) withBlanksTrimmed asLowercase capitalized.
	^ (santa -> kid)
	! !

!SecretSanta methodsFor: 'initialization' stamp: 'dhn 10/28/2015 18:24'!
parseNames: anArray
	"Set the singles and spouses from names in anArray"
	| ones |
	ones _ OrderedCollection new.
	spouses _ Dictionary new.
	anArray do: [:ea | | ix single spouse1 spouse2 |
		ix _ ea indexOf: $& ifAbsent: [0].
		ix = 0 
			ifTrue: [
				single _ ea withBlanksCondensed.
				single notEmpty ifTrue: [ones add: single]]
			ifFalse: [
				spouse1 _ (ea copyFrom: 1 to: ix - 1) withBlanksCondensed.
				spouse2 _ (ea copyFrom: ix + 1 to: ea size) withBlanksCondensed.
				spouses at: spouse1 put: spouse2.
				spouses at: spouse2 put: spouse1]].
	singles _ ones asArray
! !

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 10/30/2015 17:49'!
report: who drew: aList
	"Answer the results of the name drawing"
	| str |
	str _ String new writeStream.
	str	
		newLine;
		nextPutAll: '==', self thisYear, '=='.
	1 to: who size do: [:ix | 
		str 
			newLine;
			nextPutAll: (who at: ix) printString, '  >drew>  ', (aList at: ix) printString].
	^ str contents
! !

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 10/30/2015 17:32'!
saveResults: aString
	"Optionally append the results to previous drawings"
	| b |
	b _ PopUpMenu 
		confirm: 'Save results?'
		trueChoice: 'Yes, append to file.'
		falseChoice: 'No, leave file unchanged.'.
	b ifTrue: [
		(path, self class out, '.txt') asFileEntry appendContents: aString]! !

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 10/30/2015 17:54'!
stats
	"Answer statistics"
	| str boilerPlate |
	str _ String new writeStream.
	boilerPlate _ ' times someone '.
	str newLine; newLine;
		nextPutAll: (counts at: 1) printString, boilerPlate, 'drew themselves.'; newLine;
		nextPutAll: (counts at: 2) printString, boilerPlate, 'drew their spouse.'; newLine;
		nextPutAll: (counts at: 3) printString, boilerPlate, 'had a reciprocal.'; newLine;
		nextPutAll: (counts at: 4) printString, boilerPlate, 'drew same as 3 years ago.'; newLine;
		nextPutAll: (counts at: 5) printString, boilerPlate, 'drew same as 2 years ago.'; newLine;
		nextPutAll: (counts at: 6) printString, boilerPlate, 'drew same as last year.'; newLine;
		nextPutAll: (counts inject: 0 into: [:a :c | a + c]) printString, ' total iterations.'; newLine;
		nextPutAll: (runTime) printString, ' milliseconds elapsed time.'.
	^ str contents
! !

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 16:16'!
tally: anIndex
	"Add 1 to the counts at anIndex"
	counts at: anIndex
		put: (1 + counts at: anIndex)! !

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 19:54'!
thisYear
	"Answer the current year as a string"
	^ (Date today printFormat: #( 3 2 1$/ 1 1)) copyFrom: 1 to: 4
! !

!SecretSanta methodsFor: 'initialization' stamp: 'dhn 10/30/2015 18:34'!
yearsFrom: begin to: end
	"Answer a collection of previous drawings"
	| old outFile ios line sstr dx yr widgits get |
	outFile _ (path, self class out, '.txt') asFileEntry assureExistence.
	old _ OrderedCollection new.
	ios _ ReadStream on: outFile fileContents.
	yr _ begin.
	get _ false.
	dx _ Dictionary new.
	
	[ios atEnd not]
		whileTrue: [
			line _ ios nextLine.
			sstr _ '==', yr asString.
			line size >= 6
				ifTrue: [
				(line copyFrom: 1 to: 6) = sstr
					ifTrue: [
						get _ true.
						yr _ yr + 1.
						dx ifNotEmpty: [old add: dx].
						dx _ Dictionary new]	"end if match for sstr"
					ifFalse: [
						(get and: yr <= (end + 1))
							ifTrue: [
								widgits _ self parseLine: line.
								dx at: widgits key put: widgits value].
						].	"end if no match for sstr"
					].	"end if line size >="
			].	"end while ios atEnd not"
		dx ifNotEmpty: [old add: dx].
	^ old
! !

!SecretSanta class methodsFor: 'documentation' stamp: 'dhn 10/28/2015 17:54'!
howTo
"
	SecretSanta new.
	
	First time: create an input file of participants, then cmd-d on the line above.
	Drawing results will be saved in an output file. This file and the input file will be used in subsequent drawings.
	
"! !

!SecretSanta class methodsFor: 'file names' stamp: 'dhn 10/28/2015 17:56'!
in
	"Answer the name portion (preceeding .txt) of the file of participants"
	
	^ 'SSANTAinput'! !

!SecretSanta class methodsFor: 'file names' stamp: 'dhn 10/28/2015 17:56'!
out
	"Answer the name portion (preceeding .txt) of the file containing prior results"
	
	^ 'SSANTAoutput'! !
