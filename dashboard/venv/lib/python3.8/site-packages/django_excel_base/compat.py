# -*- coding: utf-8 -*-

"""
pythoncompat
"""

import sys


# -------
# Pythons
# -------

# Syntax sugar.
_ver = sys.version_info

#: Python 2.x?
is_py2 = (_ver[0] == 2)

#: Python 3.x?
is_py3 = (_ver[0] == 3)

# ---------
# Specifics
# ---------

if is_py2:
    builtin_str = str
    str = unicode
    bytes = str
    basestring = basestring
    numeric_types = (int, long, float)
    try:
        from cStringIO import StringIO as BytesIO, StringIO
    except ImportError:
        from StringIO import StringIO as BytesIO, StringIO

elif is_py3:
    builtin_str = str
    str = str
    bytes = bytes
    basestring = (str, bytes)
    numeric_types = (int, float)
    from io import BytesIO, StringIO
