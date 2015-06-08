'From Cuis 4.2 of 25 July 2013 [latest update: #2226] on 7 April 2015 at 8:31:23.669375 pm'!
'Description A program to draw names before Christmas. Names are listed in a text file:

name1				"Single"
name2 & name3	"Couples"

See class comment for rules.'!
!provides: 'SecretSanta' 1 2!
!classDefinition: #SecretSanta category: #'SecretSanta-Model'!
Object subclass: #SecretSanta
	instanceVariableNames: 'pastYears singles spouses names counts runTime'
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

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 16:27'!
getLines
	"Answer the lines obtained from a file"
	| fileName file lines str |
	lines _ OrderedCollection new.
	fileName _ FillInTheBlankMorph 
		request: 'File Containing Names?' 
		initialAnswer: 'c:\dir\file.ext' 
		centerAt: Display center
		onCancelReturn: ''
		acceptOnCR: true
		answerExtent: FillInTheBlankMorph defaultAnswerExtent.
	fileName notEmpty ifTrue: [
			file _ FileDirectory new readOnlyFileNamed: fileName.
			str _ file contents readStream.
			[str atEnd not] whileTrue: [
				lines add: (str upTo: Character cr) withoutTrailingBlanks. 
				str next]].
	file ifNotNil: [file close].
	^lines asArray! !

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 19:56'!
initialize
	| yr yrNow |
	super initialize.
	self parseNames: self getLines.
	names _ self namesList.
	counts _ {0. 0. 0. 0. 0. 0.}.
	yrNow _ self thisYear asNumber.
	names ifNotEmpty: [
		yr _ (FillInTheBlankMorph
					request: 'Last of what 3 years?'
					initialAnswer: (yrNow - 1) asString
					centerAt: Display center
					onCancelReturn: ''
					acceptOnCR: true
					answerExtent: FillInTheBlankMorph defaultAnswerExtent) asNumber.
		self yearsFrom: yr - 2 to: yr.
		self drawNames]
			ifEmpty: [PopUpMenu inform: 'There can be no drawing
without a list of names.'].
! !

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 16:08'!
namesList
	"Answer the names of participants, ensuring no duplication"
	^ (Set new
		addAll: singles ;
		addAll: spouses asSet;
		yourself) asOrderedCollection
! !

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 16:08'!
notPastYears: aCollection
	"Answer true if for each name, the corresponding name in aCollection is not the same as in as many as 3 prior years; otherwise, answer false"
	| dx |
	1 to: pastYears size do: [:iy | 
		dx _ pastYears at: iy.
		1 to: names size do: [:ix | 
			(dx at: (names at: ix ifAbsent: []) ifAbsent: []) = (aCollection at: ix)
				ifTrue: [self tally: 3 + iy.
					^ false]]].
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

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 18:42'!
parseNames: anArray
	"Answer the singles and spouses in anArray"
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

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 20:03'!
report: who drew: aList
	"Show the results of the name drawing as a dictionary"
	| str |
	str _ String new writeStream.
	str nextPutAll: 'drawn', self thisYear; newLine;
		nextPutAll: '	"Answer the Secret Santa drawing of ', self thisYear, '"'; newLine;
		nextPutAll: '	^ Dictionary new'; newLine.
	1 to: who size do: [:ix | 
		str nextPutAll: '		at: ', (who at: ix) printString, ' put: ', (aList at: ix) printString, ';'; newLine].
	str nextPutAll: '		yourself'; newLine.
	^ str contents
! !

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 16:10'!
saveResults: aString
	"Create a new class method from aString"
	self class class compile: aString! !

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 20:03'!
stats
	"Answer statistics"
	| str boilerPlate |
	str _ String new writeStream.
	boilerPlate _ ' times someone '.
	str newLine;
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

!SecretSanta methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 16:16'!
yearsFrom: begin to: end
	"Populate the pastYears collection with the results of class methods named drawnyyyy (yyyy = year)"
	| symb dx |
	pastYears _ OrderedCollection new.
	begin to: end do: [:a | 
		symb _ ('drawn', a asString) asSymbol.
		(self class class canUnderstand: symb) 
			ifTrue: [dx _ self class perform: symb.
				pastYears add: dx]]
! !

!SecretSanta class methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 16:16'!
drawn2011
	"Answer the Secret Santa drawing of 2011"
	^ Dictionary new
		at: 'Apu' put: 'Marge';
		at: 'Bart' put: 'Monty';
		at: 'Lisa' put: 'Apu';
		at: 'Maggie' put: 'Seymour';
		at: 'S.L.Helper' put: 'Lisa';
		at: 'Snowball' put: 'Agnes';
		at: 'Seymour' put: 'Ned';
		at: 'Agnes' put: 'Smithers';
		at: 'Homer' put: 'Maggie';
		at: 'Marge' put: 'Bart';
		at: 'Ned' put: 'Maude';
		at: 'Maude' put: 'S.L.Helper';
		at: 'Monty' put: 'Homer';
		at: 'Smithers' put: 'Snowball';
		yourself
! !

!SecretSanta class methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 16:17'!
drawn2012
	"Answer the Secret Santa drawing of 2012"
	^ Dictionary new
		at: 'Apu' put: 'Ned';
		at: 'Bart' put: 'Snowball';
		at: 'Lisa' put: 'Monty';
		at: 'Maggie' put: 'Lisa';
		at: 'S.L.Helper' put: 'Homer';
		at: 'Snowball' put: 'Marge';
		at: 'Seymour' put: 'S.L.Helper';
		at: 'Agnes' put: 'Apu';
		at: 'Homer' put: 'Agnes';
		at: 'Marge' put: 'Seymour';
		at: 'Ned' put: 'Smithers';
		at: 'Maude' put: 'Maggie';
		at: 'Monty' put: 'Bart';
		at: 'Smithers' put: 'Maude';
		yourself
! !

!SecretSanta class methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 16:17'!
drawn2013
	"Answer the Secret Santa drawing of 2013"
	^ Dictionary new
		at: 'Apu' put: 'Bart';
		at: 'Bart' put: 'S.L.Helper';
		at: 'Lisa' put: 'Agnes';
		at: 'Maggie' put: 'Homer';
		at: 'S.L.Helper' put: 'Maude';
		at: 'Snowball' put: 'Monty';
		at: 'Seymour' put: 'Apu';
		at: 'Agnes' put: 'Snowball';
		at: 'Homer' put: 'Ned';
		at: 'Marge' put: 'Smithers';
		at: 'Ned' put: 'Maggie';
		at: 'Maude' put: 'Marge';
		at: 'Monty' put: 'Seymour';
		at: 'Smithers' put: 'Lisa';
		yourself
! !

!SecretSanta class methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 16:17'!
drawn2014
	"Answer the Secret Santa drawing of 2014"
	^ Dictionary new
		at: 'Homer' put: 'Snowball';
		at: 'Bart' put: 'Ned';
		at: 'Maude' put: 'Monty';
		at: 'Ned' put: 'Marge';
		at: 'Apu' put: 'Agnes';
		at: 'Lisa' put: 'Seymour';
		at: 'Agnes' put: 'Homer';
		at: 'Marge' put: 'S.L.Helper';
		at: 'Smithers' put: 'Maggie';
		at: 'Maggie' put: 'Bart';
		at: 'Seymour' put: 'Smithers';
		at: 'Snowball' put: 'Maude';
		at: 'Monty' put: 'Lisa';
		at: 'S.L.Helper' put: 'Apu';
		yourself
! !

!SecretSanta class methodsFor: 'as yet unclassified' stamp: 'dhn 3/8/2015 16:17'!
howTo
	"Do:

	SecretSanta new

	the dictionary part of the output will be saved as a SecretSanta class method.
	This will be used next year."
! !
