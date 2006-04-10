
import unittest
from MCWidgets import Escape

class EscapeTest(unittest.TestCase):

    def test_html(self):
        self.assertEqual('&amp; &gt; abc', Escape.html_escape('& > abc'))

    def test_custom(self):
        e = Escape.Escape([tuple(x) for x in '0a 1b 2c 3d 4e 5f'.split()])
        self.assertEqual('aabbccddeeff', e('001122334455'))

class EscapeChainTest(unittest.TestCase):

    def test_chain(self):
        randstr = '<test case &&&>'
        e = Escape.Escape([('as', 'case'), ('e', 'i')])
        h = Escape.html_escape
        self.assertEqual(e(h)(randstr), e(h(randstr)))
        self.assertEqual(e(e(h))(randstr), e(e(h(randstr))))

if __name__ == '__main__':
    unittest.main()
