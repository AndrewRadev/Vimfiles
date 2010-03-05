#!/usr/bin/env python
#  Author:  A. S. Budden
## Date::   2nd March 2010       ##
## RevTag:: r391                 ##

import os
import sys
import optparse
import re
import fnmatch
import glob
import subprocess

revision = "## RevTag:: r391 ##".strip('# ').replace('RevTag::', 'revision')

field_processor = re.compile(
r'''
	^                 # Start of the line
	(?P<keyword>.*?)  # Capture the first field: everything up to the first tab
	\t                # Field separator: a tab character
	.*?               # Second field (uncaptured): everything up to the next tab
	\t                # Field separator: a tab character
	(?P<search>.*?)   # Any character at all, but as few as necessary (i.e. catch everything up to the ;")
	;"                # The end of the search specifier (see http://ctags.sourceforge.net/FORMAT)
	(?=\t)            # There MUST be a tab character after the ;", but we want to match it with zero width
	.*\t              # There can be other fields before "kind", so catch them here.
	                  # Also catch the tab character from the previous line as there MUST be a tab before the field
	(kind:)?          # This is the "kind" field; "kind:" is optional
	(?P<kind>\w)      # The kind is a single character: catch it
	(\t|$)            # It must be followed either by a tab or by the end of the line
	.*                # If it is followed by a tab, soak up the rest of the line; replace with the syntax keyword line
''', re.VERBOSE)

field_trim = re.compile(r'ctags_[pF]')
field_keyword = re.compile(r'syntax keyword (?P<kind>ctags_\w) (?P<keyword>.*)')
field_const = re.compile(r'\bconst\b')

vim_synkeyword_arguments = [
		'contains',
		'oneline',
		'fold',
		'display',
		'extend',
		'contained',
		'containedin',
		'nextgroup',
		'transparent',
		'skipwhite',
		'skipnl',
		'skipempty'
		]

ctags_exe = 'ctags'
cscope_exe = 'cscope'

# Used for timing a function; from http://www.daniweb.com/code/snippet368.html
import time
def print_timing(func):
	def wrapper(*arg):
		t1 = time.time()
		res = func(*arg)
		t2 = time.time()
		print '%s took %0.3f ms' % (func.func_name, (t2-t1)*1000.0)
		return res
	return wrapper

def GetCommandArgs(options):
	Configuration = {}
	Configuration['CTAGS_OPTIONS'] = ''

	if options.recurse:
		Configuration['CTAGS_OPTIONS'] = '--recurse'
		if options.include_locals:
			Configuration['CTAGS_OPTIONS'] += ' --c-kinds=+l'
		Configuration['CTAGS_FILES'] = ['.']
	else:
		if options.include_locals:
			Configuration['CTAGS_OPTIONS'] = '--c-kinds=+l'
		Configuration['CTAGS_FILES'] = glob.glob('*')
	if not options.include_docs:
		Configuration['CTAGS_OPTIONS'] += r" --exclude=docs --exclude=Documentation"
	return Configuration

key_regexp = re.compile('^(?P<keyword>.*?)\t(?P<remainder>.*\t(?P<kind>[a-zA-Z])(?:\t|$).*)')

def ctags_key(ctags_line):
	match = key_regexp.match(ctags_line)
	if match is None:
		return ctags_line
	return match.group('keyword') + match.group('kind') + match.group('remainder')

def CreateCScopeFile(options):
	cscope_options = '-b'
	run_cscope = False

	if options.build_cscopedb:
		run_cscope = True
	
	if os.path.exists('cscope.files'):
		if options.build_cscopedb_if_file_exists:
			run_cscope = True
	else:
		cscope_options += 'R'

	if run_cscope:
		print "Spawning cscope"
		os.spawnl(os.P_NOWAIT, cscope_exe, 'cscope', cscope_options)

#@print_timing
def CreateTagsFile(config, languages, options):
	print "Generating Tags"
	
	ctags_languages = languages[:]
	if 'c' in ctags_languages:
		ctags_languages.append('c++')

	ctags_cmd = '%s %s %s %s' % (ctags_exe, config['CTAGS_OPTIONS'], "--languages=" + ",".join(ctags_languages), " ".join(config['CTAGS_FILES']))

#	fh = open('ctags_cmd.txt', 'w')
#	fh.write(ctags_cmd)
#	fh.write('\n')
#	fh.close()

	#os.system(ctags_cmd)
	subprocess.call(ctags_cmd, shell = (os.name != 'nt'))

	tagFile = open('tags', 'r')
	tagLines = [line.strip() for line in tagFile]
	tagFile.close()

	# Also sort the file a bit better (tag, then kind, then filename)
	tagLines.sort(key=ctags_key)

	tagFile = open('tags', 'w')
	for line in tagLines:
		tagFile.write(line + "\n")
	tagFile.close()

def GetLanguageParameters(lang):
	params = {}
	# Default value for iskeyword
	params['iskeyword'] = '@,48-57,_,192-255'
	if lang == 'c':
		params['suffix'] = 'c'
		params['extensions'] = r'[ch]\w*'
	elif lang == 'python':
		params['suffix'] = 'py'
		params['extensions'] = r'pyw?'
	elif lang == 'ruby':
		params['suffix'] = 'ruby'
		params['extensions'] = 'rb'
	elif lang == 'java':
		params['suffix'] = 'java'
		params['extensions'] = 'java'
	elif lang == 'perl':
		params['suffix'] = 'pl'
		params['extensions'] = r'p[lm]'
	elif lang == 'vhdl':
		params['suffix'] = 'vhdl'
		params['extensions'] = r'vhdl?'
	elif lang == 'php':
		params['suffix'] = 'php'
		params['extensions'] = r'php'
	elif lang == 'c#':
		params['suffix'] = 'cs'
		params['extensions'] = 'cs'
	else:
		raise AttributeError('Language not recognised %s' % lang)
	return params

def GenerateValidKeywordRange(iskeyword):
	ValidKeywordSets = iskeyword.split(',')
	rangeMatcher = re.compile('^(?P<from>(?:\d+|\S))-(?P<to>(?:\d+|\S))$')
	falseRangeMatcher = re.compile('^^(?P<from>(?:\d+|\S))-(?P<to>(?:\d+|\S))$')
	validList = []
	for valid in ValidKeywordSets:
		m = rangeMatcher.match(valid)
		fm = falseRangeMatcher.match(valid)
		if valid == '@':
			for ch in [chr(i) for i in range(0,256)]:
				if ch.isalpha():
					validList.append(ch)
		elif m is not None:
			# We have a range of ascii values
			if m.group('from').isdigit():
				rangeFrom = int(m.group('from'))
			else:
				rangeFrom = ord(m.group('from'))

			if m.group('to').isdigit():
				rangeTo = int(m.group('to'))
			else:
				rangeTo = ord(m.group('to'))

			validRange = range(rangeFrom, rangeTo+1)
			for ch in [chr(i) for i in validRange]:
				validList.append(ch)

		elif fm is not None:
			# We have a range of ascii values: remove them!
			if fm.group('from').isdigit():
				rangeFrom = int(fm.group('from'))
			else:
				rangeFrom = ord(fm.group('from'))

			if fm.group('to').isdigit():
				rangeTo = int(fm.group('to'))
			else:
				rangeTo = ord(fm.group('to'))

			validRange = range(rangeFrom, rangeTo+1)
			for ch in [chr(i) for i in validRange]:
				for i in range(validList.count(ch)):
					validList.remove(ch)

		elif len(valid) == 1:
			# Just a char
			validList.append(valid)

		else:
			raise ValueError('Unrecognised iskeyword part: ' + valid)

	return validList


def IsValidKeyword(keyword, iskeyword):
	for char in keyword:
		if not char in iskeyword:
			return False
	return True
	
#@print_timing
def CreateTypesFile(config, Parameters, options):
	outfile = 'types_%s.vim' % Parameters['suffix']
	print "Generating " + outfile
	lineMatcher = re.compile(r'^.*?\t[^\t]*\.(?P<extension>' + Parameters['extensions'] + ')\t')

	#p = os.popen(ctags_cmd, "r")
	p = open('tags', "r")

	if options.include_locals:
		LocalTagType = ',ctags_l'
	else:
		LocalTagType = ''

	ctags_entries = []
	while 1:
		line = p.readline()
		if not line:
			break

		if not lineMatcher.match(line):
			continue

		m = field_processor.match(line.strip())
		if m is not None:
			vimmed_line = 'syntax keyword ctags_' + m.group('kind') + ' ' + m.group('keyword')

			if options.parse_constants and (Parameters['suffix'] == 'c') and (m.group('kind') == 'v'):
				if field_const.search(m.group('search')) is not None:
					vimmed_line = vimmed_line.replace('ctags_v', 'ctags_k')

			if not field_trim.match(vimmed_line):
				ctags_entries.append(vimmed_line)
	
	p.close()
	
	# Essentially a uniq() function
	ctags_entries = dict.fromkeys(ctags_entries).keys()
	# Sort the list
	ctags_entries.sort()

	if len(ctags_entries) == 0:
		print "No tags found"
		return
	
	keywordDict = {}
	for line in ctags_entries:
		m = field_keyword.match(line)
		if m is not None:
			if not keywordDict.has_key(m.group('kind')):
				keywordDict[m.group('kind')] = []
			keywordDict[m.group('kind')].append(m.group('keyword'))

	if options.check_keywords:
		iskeyword = GenerateValidKeywordRange(Parameters['iskeyword'])
	
	matchEntries = []
	vimtypes_entries = []

	clear_string = 'silent! syn clear '

	patternCharacters = "/@#':"
	charactersToEscape = '\\' + '~[]*.$^'
	KindList = GetKindList()[Parameters['suffix']]

	if not options.include_locals:
		remove_list = []
		for key, value in KindList.iteritems():
			if value == 'CTagsLocalVariable':
				remove_list.append(key)
		for key in remove_list:
			try:
				del(KindList[key])
			except KeyError:
				pass

	UsedTypes = KindList.keys()

	clear_string += " ".join(UsedTypes)

	vimtypes_entries.append(clear_string)


	# Specified highest priority first
	Priority = [
			'ctags_c', 'ctags_d', 'ctags_t',
			'ctags_p', 'ctags_f', 'ctags_e',
			'ctags_g', 'ctags_k', 'ctags_v',
			'ctags_u', 'ctags_m', 'ctags_s',
			]

	# Reverse the list as highest priority should be last!
	Priority.reverse()

	typeList = sorted(keywordDict.keys())

	# Reorder type list according to sort order
	allTypes = []
	for thisType in Priority:
		if thisType in typeList:
			allTypes.append(thisType)
			typeList.remove(thisType)
	for thisType in typeList:
		allTypes.append(thisType)
#   print allTypes

	for thisType in allTypes:
		if thisType not in UsedTypes:
			continue

		keystarter = 'syntax keyword ' + thisType
		keycommand = keystarter
		for keyword in keywordDict[thisType]:
			if options.check_keywords:
				# In here we should check that the keyword only matches
				# vim's \k parameter (which will be different for different
				# languages).  This is quite slow so is turned off by
				# default; however, it is useful for some things where the
				# default generated file contains a lot of rubbish.  It may
				# be worth optimising IsValidKeyword at some point.
				if not IsValidKeyword(keyword, iskeyword):
					matchDone = False

					for patChar in patternCharacters:
						if keyword.find(patChar) == -1:
							escapedKeyword = keyword
							for ch in charactersToEscape:
								escapedKeyword = escapedKeyword.replace(ch, '\\' + ch)
							if not options.skip_matches:
								matchEntries.append('syntax match ' + thisType + ' ' + patChar + escapedKeyword + patChar)
							matchDone = True
							break

					if not matchDone:
						print "Skipping keyword '" + keyword + "'"

					continue


			if keyword.lower() in vim_synkeyword_arguments:
				matchEntries.append('syntax match ' + thisType + ' /' + keyword + '/')
				continue

			temp = keycommand + " " + keyword
			if len(temp) >= 512:
				vimtypes_entries.append(keycommand)
				keycommand = keystarter
			keycommand = keycommand + " " + keyword
		if keycommand != keystarter:
			vimtypes_entries.append(keycommand)
	
	# Essentially a uniq() function
	matchEntries = dict.fromkeys(matchEntries).keys()
	# Sort the list
	matchEntries.sort()

	vimtypes_entries.append('')
	for thisMatch in matchEntries:
		vimtypes_entries.append(thisMatch)

	LanguageKinds = GetKindList()
	AddList = 'add='

	for thisType in allTypes:
		if thisType in UsedTypes:
			vimtypes_entries.append('hi link ' + thisType + ' ' + LanguageKinds[Parameters['suffix']][thisType])
			if AddList != 'add=':
				AddList += ','
			AddList += thisType;
	AddList += ' '

	if Parameters['suffix'] in ['c',]:
		vimtypes_entries.append('')
		vimtypes_entries.append("if exists('b:hlrainbow') && !exists('g:nohlrainbow')")
		vimtypes_entries.append('\tsyn cluster cBracketGroup ' + AddList + LocalTagType)
		vimtypes_entries.append('\tsyn cluster cCppBracketGroup ' + AddList + LocalTagType)
		vimtypes_entries.append('\tsyn cluster cCurlyGroup ' + AddList + LocalTagType)
		vimtypes_entries.append('\tsyn cluster cParenGroup ' + AddList + LocalTagType)
		vimtypes_entries.append('\tsyn cluster cCppParenGroup ' + AddList + LocalTagType)
		vimtypes_entries.append('endif')

	try:
		fh = open(outfile, 'wb')
	except IOError:
		sys.stderr.write("ERROR: Couldn't create %s\n" % (outfile))
		sys.exit(1)
	
	try:
		for line in vimtypes_entries:
			fh.write(line)
			fh.write('\n')
	except IOError:
		sys.stderr.write("ERROR: Couldn't write %s contents\n" % (outfile))
		sys.exit(1)
	finally:
		fh.close()

def main():
	import optparse
	parser = optparse.OptionParser(version=("Types File Creator (%%prog) %s" % revision))
	parser.add_option('-r','-R','--recurse',
			action="store_true",
			default=False,
			dest="recurse",
			help="Recurse into subdirectories")
	parser.add_option('--ctags-dir',
			action='store',
			default=None,
			dest='ctags_dir',
			type='string',
			help='CTAGS Executable Directory')
	parser.add_option('--include-docs',
			action='store_true',
			default=False,
			dest='include_docs',
			help='Include docs or Documentation directory (stripped by default for speed)')
	parser.add_option('--do-not-check-keywords',
			action='store_false',
			default=True,
			dest='check_keywords',
			help="Do not check validity of keywords (for speed)")
	parser.add_option('--include-invalid-keywords-as-matches',
			action='store_false',
			default=True,
			dest='skip_matches',
			help='Include invalid keywords as regular expression matches (may slow it loading)')
	parser.add_option('--do-not-analyse-constants',
			action='store_false',
			default=True,
			dest='parse_constants',
			help="Do not treat constants as separate entries")
	parser.add_option('--include-language',
			action='append',
			dest='languages',
			type='string',
			default=[],
			help='Only include specified languages')
	parser.add_option('--build-cscopedb',
			action='store_true',
			default=False,
			dest='build_cscopedb',
			help="Also build a cscope database")
	parser.add_option('--build-cscopedb-if-cscope-file-exists',
			action='store_true',
			default=False,
			dest='build_cscopedb_if_file_exists',
			help="Also build a cscope database if cscope.files exists")
	parser.add_option('--cscope-dir',
			action='store',
			default=None,
			dest='cscope_dir',
			type='string',
			help='CSCOPE Executable Directory')
	parser.add_option('--include-locals',
			action='store_true',
			default=False,
			dest='include_locals',
			help='Include local variables in the database')
	parser.add_option('--use-existing-tagfile',
			action='store_true',
			default=False,
			dest='use_existing_tagfile',
			help="Do not generate tags if a tag file already exists")

	options, remainder = parser.parse_args()

	if options.ctags_dir is not None:
		global ctags_exe
		ctags_exe = os.path.join(options.ctags_dir, 'ctags')


	if options.cscope_dir is not None:
		global cscope_exe
		cscope_exe = options.cscope_dir + '/' + 'cscope'

	Configuration = GetCommandArgs(options)

	CreateCScopeFile(options)

	full_language_list = ['c', 'java', 'perl', 'python', 'ruby', 'vhdl', 'php', 'c#']
	if len(options.languages) == 0:
		# Include all languages
		language_list = full_language_list
	else:
		language_list = [i for i in full_language_list if i in options.languages]

	if options.use_existing_tagfile and not os.path.exists('tags'):
		options.use_existing_tagfile = False

	if not options.use_existing_tagfile:
		CreateTagsFile(Configuration, language_list, options)

	for language in language_list:
		Parameters = GetLanguageParameters(language)
		CreateTypesFile(Configuration, Parameters, options)

def GetKindList():
	LanguageKinds = {}
	LanguageKinds['asm'] = \
	{
		'ctags_d': 'CTagsDefinedName',
		'ctags_l': 'CTagsLabel',
		'ctags_m': 'CTagsMacro',
		'ctags_t': 'CTagsType',
	}
	LanguageKinds['asp'] = \
	{
		'ctags_c': 'CTagsConstant',
		'ctags_f': 'CTagsFunction',
		'ctags_s': 'CTagsSubroutine',
		'ctags_v': 'CTagsVariable',
	}
	LanguageKinds['awk'] = \
	{
		'ctags_f': 'CTagsFunction',
	}
	LanguageKinds['basic'] = \
	{
		'ctags_c': 'CTagsConstant',
		'ctags_f': 'CTagsFunction',
		'ctags_l': 'CTagsLabel',
		'ctags_t': 'CTagsType',
		'ctags_v': 'CTagsVariable',
		'ctags_g': 'CTagsEnumeration',
	}
	LanguageKinds['beta'] = \
	{
		'ctags_f': 'CTagsFragment',
		'ctags_p': 'CTagsPattern',
		'ctags_s': 'CTagsSlot',
		'ctags_v': 'CTagsVirtualPattern',
	}
	LanguageKinds['c'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_d': 'CTagsDefinedName',
		'ctags_e': 'CTagsEnumerationValue',
		'ctags_f': 'CTagsFunction',
		'ctags_g': 'CTagsEnumeratorName',
		'ctags_k': 'CTagsConstant',
		'ctags_l': 'CTagsLocalVariable',
		'ctags_m': 'CTagsMember',
		'ctags_n': 'CTagsNamespace',
		'ctags_p': 'CTagsFunction',
		'ctags_s': 'CTagsStructure',
		'ctags_t': 'CTagsType',
		'ctags_u': 'CTagsUnion',
		'ctags_v': 'CTagsGlobalVariable',
		'ctags_x': 'CTagsExtern',
	}
	LanguageKinds['c++'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_d': 'CTagsDefinedName',
		'ctags_e': 'CTagsEnumerationValue',
		'ctags_f': 'CTagsFunction',
		'ctags_g': 'CTagsEnumerationName',
		'ctags_k': 'CTagsConstant',
		'ctags_l': 'CTagsLocalVariable',
		'ctags_m': 'CTagsMember',
		'ctags_n': 'CTagsNamespace',
		'ctags_p': 'CTagsFunction',
		'ctags_s': 'CTagsStructure',
		'ctags_t': 'CTagsType',
		'ctags_u': 'CTagsUnion',
		'ctags_v': 'CTagsGlobalVariable',
		'ctags_x': 'CTagsExtern',
	}
	LanguageKinds['cs'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_d': 'CTagsDefinedName',
		'ctags_e': 'CTagsEnumerationValue',
		'ctags_E': 'CTagsEvent',
		'ctags_f': 'CTagsField',
		'ctags_g': 'CTagsEnumerationName',
		'ctags_i': 'CTagsInterface',
		'ctags_l': 'CTagsLocalVariable',
		'ctags_m': 'CTagsMethod',
		'ctags_n': 'CTagsNamespace',
		'ctags_p': 'CTagsProperty',
		'ctags_s': 'CTagsStructure',
		'ctags_t': 'CTagsType',
	}
	LanguageKinds['cobol'] = \
	{
		'ctags_d': 'CTagsData',
		'ctags_f': 'CTagsFileDescription',
		'ctags_g': 'CTagsGroupItem',
		'ctags_p': 'CTagsParagraph',
		'ctags_P': 'CTagsProgram',
		'ctags_s': 'CTagsSection',
	}
	LanguageKinds['eiffel'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_f': 'CTagsFeature',
		'ctags_l': 'CTagsEntity',
	}
	LanguageKinds['erlang'] = \
	{
		'ctags_d': 'CTagsDefinedName',
		'ctags_f': 'CTagsFunction',
		'ctags_m': 'CTagsModule',
		'ctags_r': 'CTagsRecord',
	}
	LanguageKinds['fortran'] = \
	{
		'ctags_b': 'CTagsBlockData',
		'ctags_c': 'CTagsCommonBlocks',
		'ctags_e': 'CTagsEntryPoint',
		'ctags_f': 'CTagsFunction',
		'ctags_i': 'CTagsInterfaceComponent',
		'ctags_k': 'CTagsTypeComponent',
		'ctags_l': 'CTagsLabel',
		'ctags_L': 'CTagsLocalVariable',
		'ctags_m': 'CTagsModule',
		'ctags_n': 'CTagsNamelist',
		'ctags_p': 'CTagsProgram',
		'ctags_s': 'CTagsSubroutine',
		'ctags_t': 'CTagsType',
		'ctags_v': 'CTagsGlobalVariable',
	}
	LanguageKinds['html'] = \
	{
		'ctags_a': 'CTagsAnchor',
		'ctags_f': 'CTagsFunction',
	}
	LanguageKinds['java'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_e': 'CTagsEnumerationValue',
		'ctags_f': 'CTagsField',
		'ctags_g': 'CTagsEnumeratorName',
		'ctags_i': 'CTagsInterface',
		'ctags_l': 'CTagsLocalVariable',
		'ctags_m': 'CTagsMethod',
		'ctags_p': 'CTagsPackage',
	}
	LanguageKinds['javascript'] = \
	{
		'ctags_f': 'CTagsFunction',
		'ctags_c': 'CTagsClass',
		'ctags_m': 'CTagsMethod',
		'ctags_p': 'CTagsProperty',
		'ctags_v': 'CTagsGlobalVariable',
	}
	LanguageKinds['lisp'] = \
	{
		'ctags_f': 'CTagsFunction',
	}
	LanguageKinds['lua'] = \
	{
		'ctags_f': 'CTagsFunction',
	}
	LanguageKinds['make'] = \
	{
		'ctags_m': 'CTagsFunction',
	}
	LanguageKinds['pascal'] = \
	{
		'ctags_f': 'CTagsFunction',
		'ctags_p': 'CTagsFunction',
	}
	LanguageKinds['perl'] = \
	{
		'ctags_c': 'CTagsGlobalConstant',
		'ctags_f': 'CTagsFormat',
		'ctags_l': 'CTagsLabel',
		'ctags_p': 'CTagsPackage',
		'ctags_s': 'CTagsFunction',
		'ctags_d': 'CTagsFunction',
	}
	LanguageKinds['php'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_i': 'CTagsInterface',
		'ctags_d': 'CTagsGlobalConstant',
		'ctags_f': 'CTagsFunction',
		'ctags_v': 'CTagsGlobalVariable',
		'ctags_j': 'CTagsFunction',
	}
	LanguageKinds['python'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_f': 'CTagsFunction',
		'ctags_m': 'CTagsMember',
		'ctags_v': 'CTagsGlobalVariable',
	}
	LanguageKinds['rexx'] = \
	{
		'ctags_s': 'CTagsFunction',
	}
	LanguageKinds['ruby'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_f': 'CTagsMethod',
		'ctags_m': 'CTagsModule',
		'ctags_F': 'CTagsSingleton',
	}
	LanguageKinds['scheme'] = \
	{
		'ctags_f': 'CTagsFunction',
		'ctags_s': 'CTagsSet',
	}
	LanguageKinds['sh'] = \
	{
		'ctags_f': 'CTagsFunction',
	}
	LanguageKinds['slang'] = \
	{
		'ctags_f': 'CTagsFunction',
		'ctags_n': 'CTagsNamespace',
	}
	LanguageKinds['sml'] = \
	{
		'ctags_e': 'CTagsException',
		'ctags_f': 'CTagsFunction',
		'ctags_c': 'CTagsFunctionObject',
		'ctags_s': 'CTagsSignature',
		'ctags_r': 'CTagsStructure',
		'ctags_t': 'CTagsType',
		'ctags_v': 'CTagsGlobalVariable',
	}
	LanguageKinds['sql'] = \
	{
		'ctags_c': 'CTagsCursor',
		'ctags_d': 'CTagsFunction',
		'ctags_f': 'CTagsFunction',
		'ctags_F': 'CTagsField',
		'ctags_l': 'CTagsLocalVariable',
		'ctags_L': 'CTagsLabel',
		'ctags_P': 'CTagsPackage',
		'ctags_p': 'CTagsFunction',
		'ctags_r': 'CTagsRecord',
		'ctags_s': 'CTagsType',
		'ctags_t': 'CTagsTable',
		'ctags_T': 'CTagsTrigger',
		'ctags_v': 'CTagsGlobalVariable',
		'ctags_i': 'CTagsIndex',
		'ctags_e': 'CTagsEvent',
		'ctags_U': 'CTagsPublication',
		'ctags_R': 'CTagsService',
		'ctags_D': 'CTagsDomain',
		'ctags_V': 'CTagsView',
		'ctags_n': 'CTagsSynonym',
	}
	LanguageKinds['tcl'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_m': 'CTagsMethod',
		'ctags_p': 'CTagsFunction',
	}
	LanguageKinds['vera'] = \
	{
		'ctags_c': 'CTagsClass',
		'ctags_d': 'CTagsDefinedName',
		'ctags_e': 'CTagsEnumerationValue',
		'ctags_f': 'CTagsFunction',
		'ctags_g': 'CTagsEnumeratorName',
		'ctags_l': 'CTagsLocalVariable',
		'ctags_m': 'CTagsMember',
		'ctags_p': 'CTagsProgram',
		'ctags_P': 'CTagsFunction',
		'ctags_t': 'CTagsTask',
		'ctags_T': 'CTagsType',
		'ctags_v': 'CTagsGlobalVariable',
		'ctags_x': 'CTagsExtern',
	}
	LanguageKinds['verilog'] = \
	{
		'ctags_c': 'CTagsGlobalConstant',
		'ctags_e': 'CTagsEvent',
		'ctags_f': 'CTagsFunction',
		'ctags_m': 'CTagsModule',
		'ctags_n': 'CTagsNetType',
		'ctags_p': 'CTagsPort',
		'ctags_r': 'CTagsRegisterType',
		'ctags_t': 'CTagsTask',
	}
	LanguageKinds['vhdl'] = \
	{
		'ctags_c': 'CTagsGlobalConstant',
		'ctags_t': 'CTagsType',
		'ctags_T': 'CTagsTypeComponent',
		'ctags_r': 'CTagsRecord',
		'ctags_e': 'CTagsEntity',
		'ctags_C': 'CTagsComponent',
		'ctags_d': 'CTagsPrototype',
		'ctags_f': 'CTagsFunction',
		'ctags_p': 'CTagsFunction',
		'ctags_P': 'CTagsPackage',
		'ctags_l': 'CTagsLocalVariable',
	}
	LanguageKinds['vim'] = \
	{
		'ctags_a': 'CTagsAutoCommand',
		'ctags_c': 'CTagsCommand',
		'ctags_f': 'CTagsFunction',
		'ctags_m': 'CTagsMap',
		'ctags_v': 'CTagsGlobalVariable',
	}
	LanguageKinds['yacc'] = \
	{
		'ctags_l': 'CTagsLabel',
	}
	return LanguageKinds

	
if __name__ == "__main__":
	main()
