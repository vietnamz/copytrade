# -*- coding:utf-8 -*-

import datetime

from django import http
from django.db.models.query import QuerySet
from django_excel_base import BytesIO, StringIO, as_csv, as_row_merge_xls, as_xls, is_py2
from django_six import Support_ValuesQuerySet, ValuesQuerySet


# Min (Max. Rows) for Widely Used Excel
# http://superuser.com/questions/366468/what-is-the-maximum-allowed-rows-in-a-microsoft-excel-xls-or-xlsx
EXCEL_MAXIMUM_ALLOWED_ROWS = 65536
# Column Width Limit For ``xlwt``
# https://github.com/python-excel/xlwt/blob/master/xlwt/Column.py#L22
EXCEL_MAXIMUM_ALLOWED_COLUMN_WIDTH = 65535


def __init__(self, data, output_name='excel_data', format='%Y%m%d%H%M%S', headers=None, force_csv=False, encoding='utf-8-sig', font='', sheet_name='Sheet 1', blanks_for_none=True, auto_adjust_width=True, vert=0x01, horz=0x01, row_merge=False):
    self.data = data
    self.output_name = output_name
    self.format = format
    self.headers = headers
    self.force_csv = force_csv
    self.encoding = encoding
    self.font = font
    self.sheet_name = sheet_name
    self.blanks_for_none = blanks_for_none
    self.auto_adjust_width = auto_adjust_width
    # VERT_TOP     = 0x00    顶端对齐
    # VERT_CENTER  = 0x01    居中对齐（垂直方向上）
    # VERT_BOTTOM  = 0x02    底端对齐
    # HORZ_LEFT    = 0x01    左端对齐
    # HORZ_CENTER  = 0x02    居中对齐（水平方向上）
    # HORZ_RIGHT   = 0x03    右端对齐
    self.vert = vert
    self.horz = horz

    # Make sure we've got the right type of data to work with
    # ``list index out of range`` if data is ``[]``
    valid_data = False
    if Support_ValuesQuerySet and isinstance(self.data, ValuesQuerySet):
        self.data = list(self.data)
    elif isinstance(self.data, QuerySet):
        self.data = list(self.data.values())
    if hasattr(self.data, '__getitem__'):
        if isinstance(self.data[0], dict):
            if headers is None:
                headers = self.data[0].keys()
            self.data = [[row[col] for col in headers] for row in self.data]
            self.data.insert(0, headers)
        if hasattr(self.data[0], '__getitem__'):
            valid_data = True
    assert valid_data is True, 'ExcelResponse requires a sequence of sequences'

    self.output = StringIO() if is_py2 else BytesIO()
    if row_merge:
        _, content_type, file_ext = (self.as_row_merge_xls, 'application/vnd.ms-excel', 'xls')
    else:
        # Excel has a limit on number of rows; if we have more than that, make a csv
        use_xls = True if len(self.data) <= self.EXCEL_MAXIMUM_ALLOWED_ROWS and not self.force_csv else False
        _, content_type, file_ext = (self.as_xls, 'application/vnd.ms-excel', 'xls') if use_xls else (self.as_csv, 'text/csv', 'csv')
    self.output.seek(0)
    super(ExcelResponse, self).__init__(self.output, content_type=content_type)
    file_name_ext = '_{0}'.format(datetime.datetime.now().strftime(self.format)) if self.format else ''
    self['Content-Disposition'] = 'attachment;filename="%s.%s"' % ('{0}{1}'.format(self.output_name, file_name_ext).replace('"', '\"'), file_ext)


names = dir(http)


clsdict = {
    'EXCEL_MAXIMUM_ALLOWED_ROWS': EXCEL_MAXIMUM_ALLOWED_ROWS,
    'EXCEL_MAXIMUM_ALLOWED_COLUMN_WIDTH': EXCEL_MAXIMUM_ALLOWED_COLUMN_WIDTH,
    '__init__': __init__,
    'as_xls': as_xls,
    'as_row_merge_xls': as_row_merge_xls,
    'as_csv': as_csv,
}


if 'FileResponse' in names:
    ExcelResponse = type('ExcelResponse', (http.FileResponse, ), clsdict)
elif 'StreamingHttpResponse' in names:
    ExcelResponse = type('StreamingHttpResponse', (http.StreamingHttpResponse, ), clsdict)
else:
    ExcelResponse = type('HttpResponse', (http.HttpResponse, ), clsdict)
