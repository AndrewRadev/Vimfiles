# -*- coding: utf-8 -*-
from __future__ import with_statement

"""
This module is part of vim PyInteractive plugin
"""

import sys
from code import InteractiveConsole
from StringIO import StringIO
import contextlib
import optparse
import tokenize, token

#import logging
#LOG_FILENAME = r'D:\usr\dev\python\src\projects\interactive-vim-python\pyinteractive.log'
#logging.basicConfig(filename=LOG_FILENAME, filemode='w',level=logging.DEBUG)


try:
    import vim
except ImportError:
    # ignore module (for doctests)
    pass


BANNER = "[python interpreter]"
PROMPT = (sys.ps1 if hasattr(sys, 'ps1') else '>>> ')
MORE   = (sys.ps2 if hasattr(sys, 'ps2') else '... ')

NAMESPACE_DELIMITER = '.'


HIST_IN_PATTERN  = " in[%i]: "
HIST_OUT_PATTERN = "out[%i]: "

# history flags
IN_FLAG  = 0
OUT_FLAG = 1

# indent 4 spaces
TABSTOP  = 4


def _debug_tokeninfo(token_):
    """ _debug_tokeninfo(token_: tuple) -> str
    """
    type_, tok, (srow, scol), (erow, ecol), line = token_
    return '''\
            type:       %s
            token:      [%s]
            srow-scol:  (%i,%i)
            erow-ecol:  (%i,%i)
            line:       [%s]
            ''' % (token.tok_name[type_], tok, srow, scol, erow, ecol, line)


@contextlib.contextmanager
def redirect_output(stream):
    """ Utility contextmanager for redirect stdout to stream
        stream - file-like object (e.g. StringIO)

        Usage:
            >>> stream = StringIO()
            >>> with redirect_output(stream):
            ...     print "Hello"
            ...
            >>> stream.getvalue()
            'Hello\\n'
    """
    old = sys.stdout
    sys.stdout = stream
    try:
        yield

    finally:
        sys.stdout = old


@contextlib.contextmanager
def vim_input_guard():
    """ Contextmanager for vim safe input
    """
    vim.command('call inputsave()')
    yield
    vim.command('call inputrestore()')


def _tokenize(codestr):
    """ _tokenize(codestr: str) -> list
        Tokenize python source code
    """
    tokenized = []
    try:
        token_info = tokenize.tokenize(StringIO(codestr).readline,
            (lambda type_, token, (srow, scol), (erow, ecol), line:
                tokenized.append((type_, token, (srow, scol), (erow, ecol), line))))

    except tokenize.TokenError:
        pass

    return tokenized


def _filter_candidates(begin, candidates):
    """ _filter_candidates(begin: str, candidates: iterable) -> iterable
        Utility function helps in autocomplete

        Usage:
            >>> _filter_candidates('abr', ['abbra_cadabra', 'abbreviations'])
            []
            >>> _filter_candidates('abbr', ['abbra_cadabra', 'abbreviations'])
            ['abbra_cadabra', 'abbreviations']
            >>> _filter_candidates('he', ['apply', 'help', 'bin'])
            ['help']
            >>> _filter_candidates('_', ['a_b', 'c_d', '_e'])
            ['_e']
            >>> _filter_candidates('_', ['a_', '_b', 'c_d', '_e'])
            ['_b', '_e']
    """
    result = []
    for candidate in candidates:
        if len(candidate) < len(begin):
            continue
        if candidate[0:len(begin)] == begin:
            result.append(candidate)
    #vim.command('call confirm("begin:\n%s\ncandidates:\n%s\nresult:%s\n", "Close")' % (begin, candidates, result))
    return result


def _get_inner_namespace(codestr):
    """ _get_inner_namespace(codestr: str) -> list
    For 'mod1.func("_", [mod2.class1.__' codestring return 'mod2.class1'

    Usage:
        >>> _get_inner_namespace('mod1.func("_",[mod2.class1.__')
        'mod2.class1'
        >>> _get_inner_namespace('mod1.func("_",[mod2.class1.')
        'mod2.class1'
        >>> _get_inner_namespace('mod1.func("_",(mod2.class1_')
        'mod2'
        >>> _get_inner_namespace('help(  vars.')
        'vars'
        >>> _get_inner_namespace('help(  vars._')
        'vars'
        >>> _get_inner_namespace('vars._')
        'vars'
        >>> _get_inner_namespace('vars.')
        'vars'
        >>> _get_inner_namespace('vars')
        ''
    """
    tokenized = _tokenize(codestr)
    for token_info in reversed(tokenized):
        if (token_info[0] == tokenize.OP and token_info[1] == NAMESPACE_DELIMITER
            or token_info[0] == tokenize.NAME):
            continue
        # sys.std|...
        # help(sys.std|...
        last = tokenized[-1]
        if (last[0] == tokenize.NAME or (last[0] == tokenize.ENDMARKER
            and len(tokenized) > 1)):

            lastop_info = _get_lastop_info(tokenized)
            if not lastop_info:
                return ''
            return codestr[token_info[3][1]:lastop_info[2][1]].lstrip()
        # sys.|...
        # help(sys.|...
        else:
            return codestr[token_info[3][1]:len(codestr)-1].lstrip()


def _get_lastop_info(tokenized):
    """  _get_lastop_info(tokenized: list) -> iterable or None
        Return token info for last OP or None if OP not exist
    """
    for token_info in reversed(tokenized):
        if token_info[0] == tokenize.OP:
            return token_info
    return None


def _get_last_meaning_token_info(tokenized):
    """ _get_last_name_token(tokenized: list) -> iterable or None
        Return last meaning token (NAME, OP...) in token list if exists or None
        Doctest:
            >>> tokens = [\
                    (5, ' ', (1,0),(1,1),'abbr'),\
                    (1, 'abbr', (1,1),(1,5),'abbr'),\
                    (6, '', (2,0),(2,0),'abbr'),\
                    (0, '', (2,0),(2,0),'abbr')]
            >>> tokens[-3] == _get_last_meaning_token_info(tokens)
            True
            >>> _get_last_meaning_token_info([(0, '', (1,0),(1,0),'')]) is None
            True
    """
    last = tokenized[-1]
    if last[0] == tokenize.ENDMARKER:
        if len(tokenized) > 1:
            # >>> boo
            #     NAME-ENDMARKER
            #       ^---<------<----
            last = tokenized[-2]
            if len(tokenized) > 2 and last[0] == tokenize.DEDENT:
                # >>>        boo
                #    INDENT-NAME-DEDENT-ENDMARKER
                #             ^---<------<----
                last = tokenized[-3]
        else: # |...
            return None

    return last


def _exclude_privates(candidates):
    """ _exclude_privates(candidates: iterable) -> iterable
    Skip items begins  with '_'
        Usage:
            >>> attribs = ['_a', 'b', '_c', 'd_', 'e_f']
            >>> _exclude_privates(attribs)
            ['b', 'd_', 'e_f']
    """
    return filter(lambda string: string[:1] != '_', candidates)

# hel| divmod?
def python_autocomplete(codestr, cmdline, cursorpos):
    """ python_autocomplete(codestr: str, cmdline: str, cursorpos: int) -> list
        Uses for vim command autocompletion
        Usage:
            # setup
            >>> sys_module = __import__('sys')
            >>> _interpreter.locals['sys'] = sys_module
            >>> sys_names = _exclude_privates(dir(_interpreter.locals['sys']))

            >>> _interpreter.locals['abbra_cadabra'] = None
            >>> python_autocomplete('abbr', 'abbr', 4)
            ['abbra_cadabra']
            >>> python_autocomplete('abbre', 'abbre', 5)
            []
            >>> _interpreter.locals['abbreviations'] = None
            >>> python_autocomplete('abbr', 'abbr', 4)
            ['abbreviations', 'abbra_cadabra']

            >>> python_autocomplete('abbre', 'abbre', 5)
            ['abbreviations']
            >>> ['sys.' + item for item in sys_names] == python_autocomplete('sys.', 'sys.', 4)
            True
            >>> (['help(sys.' + item for item in sys_names] \
                    == python_autocomplete('help(sys.', 'help(sys.', 9))
            True
            >>> python_autocomplete('help(sys.stdou', 'help(sys.stdou', 14)
            ['help(sys.stdout']

            >>> python_autocomplete('help(abbr', 'help(abbr', 9)
            ['help(abbreviations', 'help(abbra_cadabra']

            >>> python_autocomplete('help(abbra', 'help(abbra', 10)
            ['help(abbra_cadabra']

            >>> python_autocomplete('help(abbr.', 'help(abbr.', 10)
            []
            >>> python_autocomplete('help( abbra', 'help( abbra', 11)
            ['help( abbra_cadabra']
            >>> python_autocomplete(' abbr', ' abbr', 5)
            [' abbreviations', ' abbra_cadabra']
    """
    #vim.command('call confirm("<%s>\n<%s>\n<%i>", %i)' % (codestr,cmdline,cursorpos,cursorpos))

    candidates = []
    namespace = _interpreter.locals
    namespace.update(__builtins__ if isinstance(__builtins__, dict)
                     else __builtins__.__dict__)

    tokenized = _tokenize(codestr)
    lastop_info = _get_lastop_info(tokenized)
    last = _get_last_meaning_token_info(tokenized)

#    logging.debug('''
#codestr\t\t[%s]
#cmdline\t\t[%s]
#cursorpos\t%i
#tokenname\t%s
#tokenizedln\t%i\n
#tokenized->\n%s\n'''
#        % (codestr,
#            cmdline,
#            cursorpos,
#            token.tok_name[tokenized[-1][0]],
#            len(tokenized),
#            "\t\t\n".join([_debug_tokeninfo(t_) for t_ in tokenized])
#            ))
    # >>> |...
    # >>>   |...
    if last is None:
        return _exclude_privates(codestr + c for c in list(namespace.keys()))

    if last[0] == tokenize.NAME:
        # sys.std|...
        # help(sys.std|...
        if lastop_info and lastop_info[1] == NAMESPACE_DELIMITER:
            inner = _get_inner_namespace(codestr)
            try:
                candidates = eval('dir(%s)' % inner, namespace)
            except (NameError, SyntaxError):
                #vim.command('call confirm("debug: syntax or name error#1\n<%s>\n<%s>")' % (codestr, inner))
                return []

            candidates = _filter_candidates(last[1], candidates)
            return [codestr[:-len(last[1])] + item for item in candidates]
        # help(bu|...
        elif lastop_info:
            candidates = _filter_candidates(last[1], list(namespace.keys()))
            return [codestr[:-len(last[1])] + item for item in candidates]
        # __|...
        else:
            # >>> INDENT bo|...
            if tokenized[0][0] == token.INDENT:
                #vim.command('call confirm("!!")')
                return [tokenized[0][1] + c for c in _filter_candidates(last[1],
                    list(namespace.keys()))]
            # boo|...
            else:
                return _filter_candidates(last[1], list(namespace.keys()))

    elif last[0] == tokenize.OP:
        # sys.|...
        # help(sys.|...
        if last[1] == NAMESPACE_DELIMITER:
            try:
                candidates = eval('dir(%s)' % _get_inner_namespace(codestr), namespace)
                candidates = _exclude_privates(candidates)
            except (NameError, SyntaxError):
                #vim.command('call confirm("debug: syntax or name error#2\n%s")' % (codestr[:-1]))
                return []

        else: # help(|...
            candidates = _exclude_privates(list(namespace.keys()))

    return [codestr + item for item in candidates]


class dynamicmethod(object):
    """Class implements decorator for making instance methods

        Example:
            >>> class Dummy(object): pass
            >>> dum = Dummy()

            >>> @dynamicmethod(dum)
            ... def say_hello(self):
            ...    return 'hello'

            >>> dum.say_hello()
            'hello'
    """

    def __init__(self, instance):
        self.instance = instance


    def __call__(self, func):

        # get instancemethod descriptor
        im_descriptor = self.__init__.__class__

        method = im_descriptor(func, self.instance, self.instance.__class__)
        setattr(self.instance, func.__name__, method)

        return method


class VimInterpreter(InteractiveConsole):

    def __init__(self, locals=None, filename="<console>"):
        InteractiveConsole.__init__(self, locals, filename)

        # history consists of list of pairs [(FLAG, record), ...]
        # flag is IN_FLAG or OUT_FLAG
        # record a string containing history line
        self.history = []


    def push(self, line):
        stream = StringIO()
        stdout = sys.stdout
        interpriter = self

        # replace StringIO.write method in stream
        @dynamicmethod(stream)
        def write(self, data):
            interpriter.history.append((OUT_FLAG, data))
            stdout.write(data)

        self.history.append((IN_FLAG, line))
        with redirect_output(stream):
            return InteractiveConsole.push(self, line)


    def interact(self, banner=None):
        """ Run python read-eval-print loop
            press <esc> to exit
        """

        if banner:
            print(banner)

        while True:
            with vim_input_guard():
                codestr = vim.eval(u'input("%s","","customlist,'
                        'pyinteractive#PythonAutoComplete")' % PROMPT)

            vim.command('normal g1')
            if codestr is None:
                break

            # autoident
            indent = (' ' * TABSTOP)
            indent_level = 1
            autoindent = (lambda level: indent * level if level > 0 else "")

            while self.push(codestr):
                print(codestr)

                with vim_input_guard():
                    codestr = vim.eval(
                        u'input("%s","%s","customlist,'
                                'pyinteractive#PythonAutoComplete")'
                                % (MORE, autoindent(indent_level)) )

                vim.command('normal g1')
                if codestr is None:
                    return

                # TODO: hardcoded condition
                if codestr.rstrip().endswith(':'):
                    indent_level += 1

                elif codestr.isspace():
                    indent_level = (0 if indent_level==0 else indent_level-1)


    def evaluate(self, codestr):
        """ Evaluate python code in interpreter
            codestr - python code (str)
        """

        for line in codestr.splitlines():
            self.push(line)
        self.push('\n')


    def format_history(self, include_output=True, raw=False):
        """ Format and return input/output history in current
            session (list of strings)
            include_output (bool) if True (by default) output history added to result
            raw (bool) if True extra info not appended to result
        """
        result = []
        lineno_map = {IN_FLAG: 1, OUT_FLAG: 1}
        flags_case = {IN_FLAG: HIST_IN_PATTERN, OUT_FLAG: HIST_OUT_PATTERN}

        format_line = (lambda flag, line:
                (line if raw else (flags_case[flag] % lineno_map[flag] + line)))

        for flag, line in self.history:
            if line == '\n':
                continue

            if (include_output and flag == OUT_FLAG) or flag == IN_FLAG:
                result.append(format_line(flag, line))
                lineno_map[flag] += 1

        return result


_interpreter = VimInterpreter()


def run():
    """ Run python read-eval-print loop
        press <esc> to exit
    """
    _interpreter.interact()


def evaluate(codestr):
    """ Evaluate python code in interpreter
        codestr - python code (str)
    """
    _interpreter.evaluate(codestr)


def _restart():
    """ Restart interpreter """

    global _interpreter
    _interpreter = VimInterpreter()


def show_history(args=''):
    """ Display input/output history in current session
        args:
            -r          history in raw format
            -i          input only
            -f <FILE>   write history to file
    """
    def parse_cmdline(args):
        """ parse_cmdline(args: str) -> list
        """
        result = []
        delimiter = False
        last_index = 0
        for index, char in enumerate(args):
            if char == " " and not delimiter:
                arg = args[last_index:index].lstrip().rstrip()
                if arg:
                    result.append(arg)
                    last_index = index

            elif char == '"':
                delimiter = (False if delimiter else True)

            if index == len(args)-1:
                last_arg = args[last_index:len(args)].lstrip().rstrip()
                if last_arg:
                    result.append(last_arg)

        # if one arg
        if not result and args:
            result.append(args)

        return result

    parser = optparse.OptionParser()
    parser.add_option('-f', dest='log_filename', metavar='FILE')
    parser.add_option('-r', dest='raw_format', action='store_true', default=False)
    parser.add_option('-i', dest='input_only', action='store_true', default=False)

    options, _ = parser.parse_args(parse_cmdline(args))
    history_lines = _interpreter.format_history(not options.input_only, options.raw_format)

    if options.log_filename:
        with open(options.log_filename.strip('"'), 'w') as logfile:
            logfile.write('\n'.join(history_lines))
    else:
        print('\n'.join(history_lines))


def _test():
    import doctest
    doctest.testmod()


if(__name__ == '__main__'):
    _test()


