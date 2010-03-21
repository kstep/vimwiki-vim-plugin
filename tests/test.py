#!/usr/bin/python
# vim:shiftwidth=4:softtabstop=4:expandtab:foldmethod=marker

"""Test vimwiki's HTML generator.

This module contains doctests, you can run them using:
    python -m doctest test.py
"""

import sys
import os
import os.path
from optparse import OptionParser
from glob import glob

# Separator between wiki page and expected HTML output.
SEPARATOR = '@@@@\n'

def parse_test(content):
    """Parse test file.

    Returns source wiki page text and expected HTML output.
    """
    return content.split(SEPARATOR, 1)

def mkdir(path):
    """Make directory if it doesn't exist yet
    """
    if not os.path.isdir(path):
        os.mkdir(path)

def remove_suffix(str, suffix):
    """Remove suffix from string.

    If 'str' ends with given suffix, return 'str' with suffix removed,
    otherwise return 'str' unchanged.

    >>> remove_suffix('abcdef', 'ef')
    'abcd'
    >>> remove_suffix('abcdef', 'de')
    'abcdef'
    """
    if str.endswith(suffix):
        return str[0:-len(suffix)]
    else:
        return str

def side_by_side(left, right, column_width=None, gap=' '):
    r"""Format two strings in two columns side-by-side.

    >>> print side_by_side('some\ntext', 'another\nlong\ntext', 10)
    some      another
    text      long
              text
    """
    # Break strings into lines.
    left_lines, right_lines = left.splitlines(), right.splitlines()

    if column_width is None and len(left_lines) > 0:
        column_width = max(len(line) for line in left_lines) + 1

    # Extend shorter list with empty lines so that lists lengths are equal.
    if len(left_lines) < len(right_lines):
        shorter, longer = left_lines, right_lines
    else:
        shorter, longer = right_lines, left_lines
    shorter.extend([""] * (len(longer)-len(shorter)))

    # Format lines.
    lines = []
    for l, r in zip(left_lines, right_lines):
        full_gap = ' ' * (column_width - len(l)) + gap
        lines.append('%s%s%s' % (l, full_gap, r))

    return '\n'.join(lines)

def compose_wiki(name):
    # Read and parse test.
    content = open(os.path.join('tests', name+'.htmltest')).read()
    wiki, expected_html = parse_test(content)

    # Write wiki page and expected output.
    wiki_path = os.path.join('tests', 'wiki', name+'.wiki')
    open(wiki_path, 'w').write(wiki)

    expected_path = os.path.join('tests', 'expected', name+'.html')
    open(expected_path, 'w').write(expected_html)

def main(args):
    """Run tests from "args" list, or all tests if "args" is empty.

    Returns True if all tests pass, otherwise False.
    """
    # Parse command-line options.
    option_parser = OptionParser()
    option_parser.usage = 'test.py [options] [test..]'
    option_parser.add_option('-s', '--side-by-side',
        action='store_true', dest='side_by_side', default=False,
        help="Show expected and actual results side by side\
            in two columns instead of one after another"
    )
    options, tests = option_parser.parse_args(args)

    # Prepare directories.
    mkdir(os.path.join('tests', 'wiki'))
    mkdir(os.path.join('tests', 'expected'))
    mkdir(os.path.join('tests', 'actual'))

    # Collect all test names.
    mask = os.path.join('tests', '*.htmltest')
    all_tests = [remove_suffix(os.path.basename(path), '.htmltest') for path in glob(mask)]

    # If test names aren't given explicitly, run all tests.
    if not tests:
        tests = all_tests

    # Compose wiki pages. {{{
    for test in tests:
        if test in all_tests:
            compose_wiki(test)
    open(os.path.join('tests', 'wiki', 'index.wiki'), 'w')
    # }}}

    # Generate HTML using vimwiki. {{{
    vimrc_path = os.path.join('tests', 'vimrc')
    index_path = os.path.join('tests', 'wiki', 'index.wiki')
    vim_command = "execute 'VimwikiAll2HTML' | q"
    command = 'vim -n -u "%s" -c "%s" %s' % (vimrc_path, vim_command, index_path)

    status = os.system(command)
    if not os.WIFEXITED(status) or os.WIFSIGNALED(status) or os.WEXITSTATUS(status) != 0:
        raise Exception("vim failed with status %d" % status)
    # }}}

    failed_count = 0 # Number of failed tests.

    # Compare actual HTML with expected one. {{{
    for test in tests:
        if test in all_tests:
            expected = open(os.path.join('tests', 'expected', test+'.html')).read()
            actual   = open(os.path.join('tests', 'actual',   test+'.html')).read()
            if expected == actual:
                print("+ %s" % test)
            else:
                failed_count += 1
                if options.side_by_side:
                    diff = side_by_side("expected:\n"+expected, "actual:\n"+actual)
                else:
                    diff = "expected:\n%s\nactual:\n%s" % (expected, actual)
                print("! %s:\n%s" % (test, diff))
        else:
            # Test is unknown.
            print("? %s" % test)
    # }}}

    return failed_count == 0

if __name__ == '__main__':
    try:
        success = main(sys.argv[1:])
        sys.exit(0 if success else 1)
    except Exception as err:
        print("Error: %s" % err)
        sys.exit(2)

